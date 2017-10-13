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
   PARENT PROJECT COMMANDS 
'''

@task
@needs([#'general.imdata',
         'parent.etl'])
def parent_full(): 
    ''' Runs a full ETL that regenerates both metadata and demodata tables with data from all sources.'''
    finalize()  

@task
@needs(['parent.etl_refresh'])
def parent_refresh():
    ''' Runs a quick metadata-only refresh with data from all sources. '''
    finalize()

   
@task
@needs(['parent.metadata', 'parent.refresh_concept_modifier_dimensions'])
def parent_metadata():
    ''' Refreshes all metadata for Big Red project '''
    finalize()   

@task
@needs(['parent.refresh_indexes'])
def parent_rebuild_indexes():
    ''' Drops and rebuilds indexes for metadata and demodata tables '''
    finalize()   
    
@task
@no_help
@needs(['parent.mapping_tables'])
def parent_epic_mapping():
    ''' Drops and rebuilds mapping tables '''
    finalize()        
    

''' child commands '''
  
@task
@needs(['child.etl'])
def child_refresh(): 
    ''' Runs a quick metadata-only refresh with data from all sources. '''
    finalize()  

  
    