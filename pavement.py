#!/usr/bin/python
 
'''
Python does not add the current working directory to sys.path. This function
adds all packages to the path variable so imports can be resolved.
'''
def _paver_import_workaround():
    import os, sys
    sys.path.append(os.path.dirname(__file__))
_paver_import_workaround()


from db_utils import finalize, run_scripts
from paver.easy import task, needs, no_help
from paver.svn import update as paversvnupdate
from paver.tasks import Task
import os, getpass, subprocess, string  # for formatting output




'''
The brains of SUPER.

Each method in this script is listed as a paver task. Tasks are special methods that 
can be invoked from the command prompt by issuing 'paver method_name'. The available
methods can be viewed from the prompt by issuing 'paver help'. The names of the methods
reflects what project it runs on and what it does.

Every project will thus have many pavement tasks devoted to different functions within
the project. The core function which runs the ETL is suffixed with _etl.

There are also hidden methods annotated with @no_help that do not appear when issuing
help but will work. Do not run these unless you know what you are doing with them.
'''


''' 
   anes RDR TASKS 
'''

@task
@needs(['anes.etl'])
def anes_refresh():
    ''' Runs a quick metadata-only refresh with data from all sources. '''
    finalize()

@task
@no_help
@needs(['anes.patient_counting'])
def anes_count_patients():
    '''Computes patient counts for all concepts for the anes RDR'''
    finalize()

@task
@no_help
@needs(['anes.fix_qt_tables'])
def anes_fix_qt():
    ''' Repairs the QT tables, seeds with initial data.'''
    finalize()

''' 
   BIG RED COMMANDS 
'''

@task
@needs([#'general.imdata',
         'bigred.etl'])
def bigred_full(): 
    ''' Runs a full ETL that regenerates both metadata and demodata tables with data from all sources.'''
    finalize()  

@task
@needs(['bigred.etl_refresh'])
def bigred_refresh():
    ''' Runs a quick metadata-only refresh with data from all sources. '''
    finalize()

@task
@no_help
@needs(['bigred.demodata'])
def bigred_observation_fact():
    ''' Refreshes observation fact table only with data from all source systems '''
    finalize()
    
@task
@no_help
@needs(['bigred.counting'])
def bigred_count_patients():
    '''Computes patient counts for all facts '''
    finalize()    
   
@task
@needs(['bigred.metadata', 'bigred.refresh_concept_modifier_dimensions'])
def bigred_metadata():
    ''' Refreshes all metadata for Big Red project '''
    finalize()   
    
@task
@no_help
@needs(['bigred.fix_qt_tables'])
def bigred_fix_qt():
    ''' Recreates the QT lookup tables, seeds with initial data. '''
    finalize()

@task
@needs(['bigred.refresh_indexes'])
def bigred_rebuild_indexes():
    ''' Drops and rebuilds indexes for metadata and demodata tables '''
    finalize()   
    
@task
@needs(['bigred.build_indexes_fact'])
def bigred_check_and_build_indexes():
    ''' Checks for existence of indexes and builds them for a project
        without dropping all of them first '''
    finalize()
    
@task
@no_help
@needs(['bigred.mapping_tables'])
def bigred_epic_mapping():
    ''' Drops and rebuilds mapping tables '''
    finalize()        
    
@task
@run_scripts('',    'deidentification/drop_views.sql'
                  , 'deidentification/create_deidentification_tables.sql'
                  , 'deidentification/deid_concept_dimension.sql'
                  , 'deidentification/deid_schemes.sql'
                  , 'deidentification/deid_table_access.sql'
                  , 'deidentification/deid_i2b2_metadata.sql'
                  , 'deidentification/deid_icd10icd9_metadata.sql'
                  , 'deidentification/deid_observation_fact.sql'
                  , 'deidentification/deid_visit_dimension.sql'
                  , 'deidentification/deid_patient_dimension.sql'
                  , 'deidentification/deid_time_dimension.sql'
                  , 'deidentification/cleanup_deidentification.sql')
def bigred_deid():
    '''Creates views and tables to transfer to i2b2-GREEN (deidentified public facing instance)'''
    finalize()

''' 
   
   CADC Commands 
   
'''
     
@task
@needs(['cadc.etl'])
def cadc_refresh(): 
    ''' Runs a quick metadata-only refresh with data from all sources. '''
    finalize()  
    
@task
@no_help
@needs(['cadc.patient_counting'])
def cadc_count_patients():
    '''Computes patient counts for all facts'''
    finalize()    
    
@task
@no_help
@needs(['cadc.fix_qt_tables'])
def cadc_fix_qt():
    ''' Repairs the QT tables, seeds with initial data. Clears out the tables too!'''
    finalize()   


''' 
    LITTLE RED TASKS 
'''
@task
@needs(['littlered.etl'])
def littlered_full():
    ''' Runs a full ETL that regenerates both metadata and demodata tables with data from all sources.'''
    finalize()  
    
@task
@needs(['littlered.etl_refresh'])
def littlered_refresh():
    ''' Runs a quick metadata-only refresh with data from all sources. '''
    finalize()  

@task
@needs(['littlered.custom'])
def littlered_custom():
    ''' Runs a quick ETL for all non-EPIC data sources. '''
    finalize()  


@task
@needs(['littlered.create_datamart_report', 'littlered.counting'])
def littlered_count_patients():
    '''Computes patient counts for all facts'''
    finalize()
    
@task
@no_help
@needs(['littlered.fix_qt_tables'])
def littlered_fix_qt():
    ''' Repairs the QT tables, seeds with initial data. Clears out the tables too!'''
    finalize()
    
@task
@needs(['littlered.refresh_indexes'])
def littlered_indexes():
    ''' Rebuilds indexes on all i2b2 tables. '''
    finalize()
    
@task
@needs(['littlered.metadata', 'littlered.refresh_concept_modifier_dimensions'])
def littlered_metadata():
    ''' Rebuilds metadata on all i2b2 tables. '''
    finalize()


@task
@needs(['littlered.mapping_tables'])
def littlered_epic_mapping():
    ''' Rebuilds patient and encounter mapping tables. Only brings in patients and encounters from EPIC. '''
    finalize()    
    
@task
@needs(['littlered.unit_test'])
def littlered_unit_test():
    ''' Runs through all SQL without populating patient or encounter mapping to test correctness of ssSQL syntax  '''
    finalize()
    

''' leukemia TASKS '''
@task
@needs(['leu.etl'])
def leu_refresh():
    ''' Runs a quick metadata-only refresh with data from all sources. '''
    finalize()  

@task
@needs(['leu.patient_counting'])
def leu_count_patients():
    '''Computes patient counts for all facts'''
    finalize()
    
@task
@no_help
@needs(['leu.fix_qt_tables'])
def leu_fix_qt():
    ''' Repairs the QT tables, seeds with initial data. Clears out the tables too!'''
    finalize()

''' MPN '''
  
@task
@needs(['mpn.etl'])
def mpn_refresh(): 
    ''' Runs a quick metadata-only refresh with data from all sources. '''
    finalize()  
    
@task
@no_help
@needs(['mpn.patient_counting'])
def mpn_count_patients():
    '''Computes patient counts for all facts'''
    finalize()    
    
@task
@no_help
@needs(['mpn.fix_qt_tables'])
def mpn_fix_qt():
    ''' Repairs the QT tables, seeds with initial data. Clears out the tables too!'''
    finalize()     
    
    
''' OPH '''
  
@task
@needs(['oph.etl'])
def oph_refresh(): 
    ''' Runs a quick metadata-only refresh with data from all sources. '''
    finalize()  
    
@task
@no_help
@needs(['oph.patient_counting'])
def oph_count_patients():
    '''Computes patient counts for all facts'''
    finalize()    
    
@task
@no_help
@needs(['oph.fix_qt_tables'])
def oph_fix_qt():
    ''' Repairs the QT tables, seeds with initial data. Clears out the tables too!'''
    finalize()

''' MISCELLANEOUS '''
@task
@needs(['anes.etl', 'cadc.etl', 'leu.etl', 'mpn.etl', 'oph.etl', 'pul.etl'])
def refresh_project_metadata():
    finalize()

@task
@needs(['general.imdata'])
def imdata():
    ''' Refreshes IM data '''
    pass    
    
@task
@no_help
@needs(['general.test_error_handling'])
def fail():
    ''' Throws an error to test how Python handles and reports it '''
    pass
    
@task
@no_help
def update():
    paversvnupdate(os.getcwd())
    ''' Updates all code in the project implicitly before running ETL '''
    
    ''' Change the permissions of all files in this directory to the group 'supehr'
        so any team member can use the tool without having to invoke sudo '''
    process = subprocess.Popen("chown -R "+ getpass.getuser() +":supehr " + os.getcwd(), shell=True, stdout=subprocess.PIPE)
    pass  # We do not want to close database connections or stop writing to log file

@task
def status():
    ''' Prints the status of any running paver jobs '''
    process = subprocess.Popen("ps -ef | grep paver", shell=True, stdout=subprocess.PIPE)
    stdout_list = process.communicate()[0].split('\n')
    print('USER\tPID\tPPID\tCPU\tP\tTTY\tCPUT\tTASK')
    
    for x in range(0, len(stdout_list)):
        
        '''Format the last element and then insert a new line'''
        if (x % 8 == 0 and x != 0):
            if stdout_list[x].find("'/usr/bin/python /usr/bin/paver'") == -1:
                print stdout_list[x] + '\n'
        else:
            if stdout_list[x].find("'/usr/bin/python /usr/bin/paver'") == -1:    
                print stdout_list[x] + '\t'
        
        
@task
@needs(['general.build_clarity_indexes'])
def build_clarity_indexes():
    ''' Builds indexes on Clarity tables in super_monthly'''
    finalize()
    
@task
@needs(['general.build_jupiter_indexes'])
def build_jupiter_indexes():
    ''' Builds indexes on Jupiter tables in Jupiter'''
    finalize()
    
@task
@needs(['general.build_cdw_indexes'])
def build_cdw_indexes():
    ''' Builds indexes on CDW tables in CDW'''
    finalize()
    
@task
@needs(['general.build_clarity_indexes','general.build_jupiter_indexes','general.build_cdw_indexes'])
def build_source_indexes():
    ''' Builds indexes on all source tables'''
    finalize()


@task
@needs(['general.build_arch_indexes'])
def build_arch_indexes():
    ''' Builds indexes on arch tables in super_monthly'''
    finalize()

@task
@needs(['general.build_cdrn_indexes'])
def build_cdrn_indexes():
    ''' Builds indexes on NYC-CDRN genome tables '''
    finalize()
    
@task
@needs(['general.drop_staging_indexes'])
def drop_staging_indexes():
    ''' Drop ALL staging indexes '''
    finalize()

@task
@needs(['general.create_healthix_mapping_files'])
def create_healthix_mapping_files():
    ''' Creates a set of mapping tables to export to Healthix. '''
    finalize()