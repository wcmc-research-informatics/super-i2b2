#!/usr/bin/python
'''
Created on Jun 29, 2015

@author: mzd2016

Connects to the database and runs SQL against it. Also provides logging mechanisms to monitor
execution of ETL scripts.

DDL for logging tables

  create table SUPER_STAGING.dbo.SUPER_LOG
  (    [project] varchar(25)
  , [msg] varchar(5000)
  , [success] varchar(1)
  , [date] datetime2
  )

    create table SUPER_STAGING.dbo.SUPER_ETLSTARTSTOP_LOG
  (    
   [msg] varchar(5000)
  , [date] datetime2
  )
  
  
'''


import pymssql, os, errno, time, constants, logging.handlers
from pymssql import Error, DatabaseError, OperationalError, IntegrityError, DataError, ProgrammingError, NotSupportedError
from time import strftime
from os import sys
from paver.easy import no_help
from datetime import datetime
from traceback import format_exc
    
def run_scripts(prefix=None, *args):
    ''' Takes a variable number of arguments that represent paths to SQL scripts
        and executes them. Also keeps a log of all actions done with scripts.'''
   
    # First check to make sure that prefix was defined. If prefix was not defined this indicates a 
    # configuration error in a Python file.
    try:
        if prefix is None:
            raise ValueError('A prefix was not specified for one or more scripts.')
         
    except ValueError as ve:
        supehr_logger.error('An issue was encountered validating one or more SQL scripts.', exc_info=True)
        arch_cnxn.rollback()
        cursor.close()
        arch_cnxn.close()
        raise
        sys.exit()
    
    sql_query_array = [""] * len(args)
    i = 0
   
    for entry in args:
        sql_query_array[i] = constants.sql_file_directory + entry
        
        i += 1
        
    def run_scripts_outer_decorator(function):
        @no_help # Suppress this method in paver help menu
        def run_scripts_inner_decorator(*args, **kwargs):
             
            for query in sql_query_array:
                
                t_begin = datetime.utcnow()
                print(strftime("%Y-%m-%d %H:%M:%S") + ": started " + query )
                supehr_logger.info(query + " called from " + function.__name__ + " at " + strftime("%Y-%m-%d %H:%M:%S") + '\n')  
                
                # Print the start time that this query was run into a database log file
                cursor.execute("INSERT INTO SUPER_STAGING.dbo.SUPER_LOG VALUES (%s,%s,%s,%d);", (prefix, 'Started ' + query + ' on ' + prefix, 'Y', strftime("%Y-%m-%d %H:%M:%S")))
                arch_cnxn.commit()
                        
                sqlcmd = ""
                # The script must be read into memory before it can be sent to the server
                for line in open(query,'r'):             
                    sqlcmd += line + " "
                
                # String replacement of <prefix> in file with prefix parameter.
                # Allows for generalization of SQL scripts
                sqlcmd = sqlcmd.replace('<prefix>', prefix)
                
                try:
                    cursor.execute(sqlcmd)
                    arch_cnxn.commit()
                    t_end = datetime.utcnow()
                    print(strftime("%Y-%m-%d %H:%M:%S") + ": finished " + query )
                    print("Time taken: " + str(t_end - t_begin))
                    supehr_logger.info(query + " finished at " + strftime("%Y-%m-%d %H:%M:%S") + '\n')
                    supehr_logger.info("Time taken: " + str(t_end - t_begin))
                    supehr_logger.info(str(cursor.rowcount) + " rows affected.")
                    
                    # Print completion of script to log file
                    cursor.execute("INSERT INTO SUPER_STAGING.dbo.SUPER_LOG VALUES(%s,%s,%s,%d);", (prefix, 'Finished ' + query + ' on ' + prefix, 'Y', strftime("%Y-%m-%d %H:%M:%S")))
                    arch_cnxn.commit()
                    
                    # Convert days to minutes
                    timeDiff = (t_end - t_begin).seconds
                    
                    if timeDiff >= 300:
                        time.sleep(10)  # Pause for ten seconds to give server time to breathe   
                                     
                except (OperationalError, DataError, IntegrityError, ProgrammingError, NotSupportedError, DatabaseError, IndexError, Error) as e:
                    ''' Roll back the database connection, then fail properly '''
                    supehr_logger.error("Initiating rollback...")
                    arch_cnxn.rollback()
                    supehr_logger.error("An error occurred during the ETL.", exc_info=True)
                    print("Time of error occurrence: " + strftime("%Y-%m-%d %H:%M:%S") + "\n" )
                    supehr_logger.error(format_exc())
                    supehr_logger.error("Time of error occurrence: " + strftime("%Y-%m-%d %H:%M:%S") + "\n" )
                    cursor.execute("INSERT INTO SUPER_STAGING.dbo.SUPER_LOG VALUES (%s,%s,%s,%d);", (prefix, format_exc(), 'N', strftime("%Y-%m-%d %H:%M:%S")))
                    arch_cnxn.commit()
                    
                    cursor.close()
                    arch_cnxn.close()
                    # Print error to log file
                     # cursor.execute("INSERT INTO SUPER_STAGING.dbo.SUPER_LOG VALUES ( %s, %d );", ('An error occurred when finalizing the ETL run ' + query + ' on ' + prefix + '. Error msg: ' + e, strftime("%Y-%m-%d %H:%M:%S")))
                    
                    print(format_exc())
                    raise
                    sys.exit()
                           
                                          
        return run_scripts_inner_decorator
    
    return run_scripts_outer_decorator

# Make sure a directory exists for storing logs before creating it. Ignore it if it already exists
def make_sure_log_directory_exists():    
    '''Check if log directory exists and create it if it doesn't'''
    try:
        os.makedirs('log/')
    except OSError as exception:
        if exception.errno != errno.EEXIST:
            raise

def init_logging():
    LOG_FILENAME = './log/super_etl_log_' + strftime("%Y-%m-%d %H:%M:%S") + '.log'    
            
    ''' 
    
    Set up a specific logger with our desired output level 

    '''
    supehr_logger = logging.getLogger(__name__)
    supehr_logger.setLevel(logging.INFO)

    # Add the log message handler to the logger
    supehr_handler = logging.handlers.RotatingFileHandler(LOG_FILENAME, maxBytes=100000000, backupCount=5)
    supehr_logger.addHandler(supehr_handler)
    
    supehr_logger.info("\n" + constants.program_name + " Log Output\n---------------------\n")
    
    return supehr_logger

def finalize( ):
    ''' Closes database connection and prints finish to log '''
    
    arch_cnxn.commit()
    cursor.close()
    arch_cnxn.close()
    
    t_end_exe = datetime.utcnow()
    print("Total ETL execution time: " + str(t_end_exe - t_begin_exe))
    
    print("\nETL completed at " + strftime("%Y-%m-%d %H:%M:%S"))    
    supehr_logger.info("\nETL completed at " + strftime("%Y-%m-%d %H:%M:%S"))
    supehr_logger.info("\nTotal ETL execution time: " + str(t_end_exe - t_begin_exe))

# Track the total time of ETL. This will be useful to print out
# at the end 
t_begin_exe = datetime.utcnow()

# Database connection parameters    
username = constants.db_username
pw = constants.db_password
db = constants.db_name

# Make sure the logging directory exists
make_sure_log_directory_exists()

# Start a logger
supehr_logger = init_logging()

## this is to connect to databases. Only activate one at a time!
## If developing from a new machine you may have to install FreeTDS/UnixODBC and adjust parameters in the connect string appropriately.
# To connect from SUPER-ETL
arch_cnxn = pymssql.connect(server=constants.server_addr, database=db, user=username, password=pw)
cursor = arch_cnxn.cursor()

arch_cnxn.commit()     