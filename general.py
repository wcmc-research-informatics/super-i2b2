#!/usr/bin/python

from paver.easy import task, needs
from db_utils import run_scripts

@task
@needs('general.build_cohorts')
@run_scripts('general', 'etc/truncate_im_tables.sql'
                      , 'imdata/update_im_mpi_mapping.sql'
                      , 'imdata/update_im_project_patients.sql'
                      , 'imdata/update_im_mpi_demographics.sql'
                      , 'imdata/update_im_project_sites.sql'
                      , 'index/build_indexes_im.sql')
def imdata():
    ''' Populates im_tables in i2b2 '''
    pass

@task
@needs('general.build_cohorts')
@run_scripts('general', 'etc/truncate_im_project_patients.sql'
                      , 'imdata/update_im_project_patients.sql'
                      , 'index/build_indexes_im.sql')
def cohort_im_refresh():
  '''rebuilds cohort and truncates/rebuilds im_project_patients without total rerun of imdata'''
  pass

@task
@run_scripts('general', 'cohort/build_cadc_cohort.sql'
                      , 'cohort/build_leukemia_cohort.sql'
                      , 'cohort/build_mpn_cohort.sql'
                      , 'cohort/build_oph_cohort.sql'
                      , 'cohort/build_pul_cohort.sql'
                      , 'cohort/build_nrsg_cohort.sql'
                      )
def build_cohorts():
    pass

@task
@run_scripts('general', 'etc/error_test.sql')
def test_error_handling():
    ''' Throws an error to test how Python handles and reports it '''
    pass

@task
@needs(['general.drop_indexes'])
@run_scripts('heron', 'etc/create_staging_area_tables.sql', 'etc/insert_misc_metadata_entries.sql')
def run():
    ''' Fill in information for I2B2 cell-independent metadata tables with one script. '''
    pass

@task
@run_scripts('general', 'etc/create_healthix_mapping_files.sql')
def create_healthix_mapping_files():
    ''' Creates a set of mapping tables to export to Healthix. '''
    pass

@task
@run_scripts('indexes', 'index/drop_clarity_index_procedures.sql', 'index/create_staging_area_indexes_clarity.sql', 'index/execute_clarity_clustered_index_procedures.sql', 'index/execute_clarity_index_procedures.sql')
def build_clarity_indexes():
    ''' Apply indexes on tables in staging area to speed up ETL. '''
    pass

@task
@run_scripts('indexes', 'index/drop_jupiter_index_procedures.sql', 'index/create_staging_area_indexes_jupiter.sql', 'index/execute_jupiter_clustered_index_procedures.sql', 'index/execute_jupiter_index_procedures.sql')
def build_jupiter_indexes():
    ''' Apply indexes on tables in staging area to speed up ETL. '''
    pass

@task
@run_scripts('indexes', 'index/drop_cdw_index_procedures.sql', 'index/create_staging_area_indexes_cdw.sql', 'index/execute_cdw_clustered_index_procedures.sql', 'index/execute_cdw_index_procedures.sql')
def build_cdw_indexes():
    ''' Apply indexes on tables in staging area to speed up ETL. '''
    pass

@task
@run_scripts('general', 'index/create_staging_area_indexes_arch.sql')
def build_arch_indexes():
    ''' Apply indexes on tables in arch staging area to speed up ETL. '''
    pass

@task
@run_scripts('general', 'index/create_staging_area_indexes_cdrn.sql')
def build_cdrn_indexes():
    ''' Apply indexes on tables in arch staging area to speed up ETL. '''
    pass

@task
@run_scripts('general', 'index/drop_staging_area_indexes.sql')
def drop_staging_indexes():
    ''' Drop ALL staging indexes '''
    pass

@task
@run_scripts('[SUPER_MONTHLY]','etl/preprocessing_dev_server.sql', 'etl/populating_dev_server.sql')
def populate_monthly_dev():
    ''' Transfer data from P02 to P03'''

@task
@run_scripts('general','etl/preprocessing_dev_server.sql', 'etl/populating_dev_server.sql')
def populate_dev_server():
    ''' Transfer data from P02 to P03'''
    pass

@task
@run_scripts( 'general'
              ,'repair/setup_new_i2b2_project_demodata.sql'
              ,'repair/setup_new_i2b2_project_metadata.sql'
              ,'repair/setup_new_i2b2_project_workdata.sql'
              ,'repair/setup_new_i2b2_project_qt_tables.sql'
              ,'repair/setup_new_i2b2_project_stored_procedures.sql'
              ,'repair/setup_new_i2b2_project_hive.sql'
              ,'repair/setup_new_i2b2_project_user_roles.sql'
              ,'repair/setup_new_i2b2_project_views.sql'
              ,'repair/truncate_new_i2b2_project_tables.sql' 
            )
def setup_new_i2b2_project():
  ''' Runs sequence of scripts to automate portion of new i2b2 project setup. Add proper arguments to super_adhoc.dbo.newi2b2project '''
  pass