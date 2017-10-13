#!/usr/bin/python
'''
    This python file demonstrates the dependencies that must be met to
	populate a child i2b2 project with data from its parent project.
	Makes extensive use of the paver package within Python to specify
	SQL file dependencies and their order
'''

from db_utils import run_scripts, finalize
from paver.easy import task, needs, no_help

@task
@needs([  'child.metadata'
        , 'child.build_indexes_metadata'
        , 'child.dimension'
        , 'child.miscellaneous_entries'
        , 'child.create_datamart_report'])
def etl():
  ''' Rebuilds metadata, sourcesystem tables and creates a datamart report '''
  pass



'''Top level ETL functions'''
@task
@needs([  'child.metadata_truncate'
        , 'child.drop_indexes_metadata'
        , 'child.epic_metadata'
        , 'child.other_metadata'])
def metadata():
  ''' Encapsulates creation of metadata entries '''
  pass

@task
@needs([    'child.truncate_dimension'
          , 'child.drop_indexes_dimension'
          , 'child.other_dimension'
  ])
def dimension():
  '''encapulates creation of dimension entries'''
  pass


@task
@needs(['child.truncate_misc'])
@run_scripts('child'
               , 'metadata/build_schemes.sql'
               )
def miscellaneous_entries():
  pass

@task
@run_scripts('child', 'preprocessing/create_datamart_report.sql')
def create_datamart_report():
  ''' Creates a report on the RDR at the end of the ETL '''
  pass



'''Metadata and dimension ETL functions'''
@task
@run_scripts('child'
               , 'metadata/build_table_access.sql'
               , 'metadata/build_table_access_nlp.sql'
               , 'metadata/build_demographics_ontology.sql'
               , 'metadata/build_mrn_entry.sql'
               , 'metadata/build_icd9_diagnoses_ontology.sql'
               , 'metadata/build_icd10_diagnoses_ontology.sql'
               , 'metadata/build_encounters_ontology.sql'
               , 'metadata/build_procedures_ontology.sql' 
               , 'metadata/build_medications_ontology.sql'
               , 'metadata/build_social_history_ontology.sql'
               , 'metadata/build_family_history_ontology.sql'
               , 'metadata/build_insurance_ontology.sql'
               , 'metadata/build_results_ontology.sql'
               , 'metadata/build_nlp_ontology.sql'
               , 'metadata/build_provider_ontology.sql'
               , 'metadata/build_allergy_ontology.sql'
               , 'metadata/build_micro_ontology.sql'
               , 'metadata/build_modifier_ontology.sql'
               , 'metadata/rectify_ontological_disparities.sql')
def epic_metadata():
  ''' Refreshes the EPIC metadata '''
  pass

@task
@needs([  'child.profiler_metadata'
          #,'child.redcap_metadata'
          ,'child.ormanager_metadata'
          ,'child.compurecord_metadata'
          ,'child.crest_metadata'
          ,'child.tumor_registry_metadata'
          ,'child.custom_metadata'])
def other_metadata():
  '''Builds metadata for Other data domains'''
  pass

@task
@needs([  
        'child.custom_dimension'
        ])
def other_dimension():
  ''' Builds dimension entries for Other data domains '''
  pass



'''
General Index management tasks
'''
@task
@run_scripts('child', 'index/drop_indexes_dimension_metadata.sql')
def drop_indexes_dimension():
  pass


@task
@run_scripts('child', 'index/drop_indexes_metadata.sql')
def drop_indexes_metadata():
  pass


@task
@run_scripts('child', 'index/build_indexes_metadata.sql')
def build_indexes_metadata():
  pass



'''
General truncation tasks
'''
@task
@run_scripts('child', 'etc/truncate_tables_dimension_metadata.sql')
def truncate_dimension():
  ''' Empties select I2B2 tables while leaving their structure intact. '''
  pass

@task
@run_scripts('child', 'etc/truncate_tables_metadata.sql')
def metadata_truncate():
  pass

@task
@run_scripts('child', 'etc/truncate_tables_misc.sql')
def truncate_misc():
  ''' Empties select I2B2 tables while leaving their structure intact. '''
  pass

'''CUSTOM'''
@task
@needs([  'child.custom_truncate'
          ,'child.custom_metadata'
          ,'child.custom_dimension'])
def refresh_custom():
  '''refreshes the custom metadata and dimension'''
  pass

@task
@run_scripts('child', 'etc/truncate_custom_metadata.sql')
def custom_truncate():
  ''' Truncates only CUSTOM metadata data from table'''
  pass

@task
@run_scripts('child'
              ,'metadata/build_table_access_custom.sql'
              ,'metadata/build_custom_ontology_child.sql')
def custom_metadata():
  '''builds custom metadata'''
  pass

@task
@run_scripts('child','demodata/build_concept_dimension_entries_custom.sql')
def custom_dimension():
  '''build custom dimension'''
  pass



'''TUMOR REGISTRY'''
@task
@needs([   'child.tumor_registry_truncate'
          ,'child.tumor_registry_metadata'])
def refresh_tumor_registry():
  '''refreshes tumor registry metadata and dimension'''
  pass

@task
@run_scripts('child', 'etc/truncate_mapping_tumor_registry_metadata.sql')
def tumor_registry_truncate():
  ''' Empties i2b2 tables of tumor registry data'''
  pass

@task
@run_scripts( 'child'
              ,'metadata/build_table_access_tumor_registry.sql'
              ,'metadata/build_tumor_registry_ontology.sql')
def tumor_registry_metadata():
  '''build tumor registry metadata'''
  pass


'''PROFILER'''
@task
@needs([  'child.profiler_truncate'
          ,'child.profiler_metadata'])
def refresh_profiler():
  '''refreshes profiler metadata and dimension'''
  pass

@task
@run_scripts('child', 'etc/truncate_profiler_metadata.sql')
def profiler_truncate():
  ''' Truncate only specimens data from table '''
  pass

@task
@run_scripts( 'child'
              ,'metadata/build_table_access_profiler.sql'
              ,'metadata/build_specimen_ontology.sql')
def profiler_metadata():
  '''build profiler metadata'''
  pass

'''REDCAP'''
@task
@needs([  'child.redcap_truncate'
          ,'child.redcap_preprocessing'
          ,'child.redcap_metadata'])
def refresh_redcap():
  '''refreshes redcap metadata and dimension'''
  pass

@task
@run_scripts('child', 'etc/truncate_redcap_metadata.sql')
def redcap_truncate():
  ''' Truncate only REDCap data from table '''
  pass

@run_scripts('child', 'preprocessing/pre-processing_redcap_tables.sql'
                    , 'preprocessing/populate_adjusted_redcap_tables.sql'
                    , 'index/create_staging_area_indexes_redcap.sql')
def redcap_preprocessing():
  ''' Refreshes the REDCap tables prior to ETL and cleans them up '''
  pass

@task
@run_scripts( 'child'
              ,'metadata/build_table_access_redcap.sql'
              ,'metadata/build_redcap_ontology.sql')
def redcap_metadata():
  '''build redcap metadata'''
  pass

'''COMPURECORD'''
@task
@needs([  'child.compurecord_truncate'
          ,'child.compurecord_metadata'])
def refresh_compurecord():
  '''Refresh compurecord metadata and dimension'''
  pass

@task
@run_scripts('child', 'etc/truncate_compurecord_metadata.sql')
def compurecord_truncate():
  ''' Truncate from table data imported from REDCap '''
  pass

@task
@run_scripts( 'child'
              ,'metadata/build_table_access_compurecord.sql'
              ,'metadata/build_compurecord_ontology.sql')
def compurecord_metadata():
  '''build compurecord metadata'''
  pass

'''CREST'''
@task
@needs([  'child.crest_truncate'
          ,'child.crest_metadata'])
def refresh_crest():
  '''Refreshes crest metadata and dimesnion'''
  pass

@task
@run_scripts('child', 'etc/truncate_crest_metadata.sql')
def crest_truncate():
  ''' Truncates only CREST data from table'''
  pass

@task
@run_scripts( 'child'
              ,'metadata/build_table_access_crest.sql'
              ,'metadata/build_crest_ontology.sql')
def crest_metadata():
  '''build crest metadata'''
  pass

'''ORMANAGER'''
@task
@needs([  'child.ormanager_truncate'
          ,'child.ormanager_metadata'])
def refresh_ormanager():
  '''Refreshes ormanager metadata and dimension'''
  pass

@task
@run_scripts('child', 'etc/truncate_ormanager_metadata.sql')
def ormanager_truncate():
  ''' Truncate from table data imported from ORManager '''
  pass

@task
@run_scripts( 'child'
              ,'metadata/build_table_access_ormanager.sql'
              , 'metadata/build_ormanager_ontology.sql')
def ormanager_metadata():
  '''build ormanager metadata'''
  pass

'''ECLIPSYS'''
@task
@needs([  'child.eclipsys_truncate'
          ,'child.eclipsys_metadata'])
def refresh_eclipsys():
  '''Refreshes eclipsys metadata and dimension'''
  pass

@task
@run_scripts('child', 'etc/truncate_eclipsys_metadata.sql')
def eclipsys_truncate():
  ''' Truncate from table data imported from CDW '''
  pass

@task
@run_scripts('child', 'metadata/build_encounters_ontology_eclipsys.sql')
def eclipsys_metadata():
  '''Build Eclipsys metadata'''
  pass

'''EAGLE'''
@task
@needs([  'child.eagle_truncate'
          ,'child.eagle_metadata'])
def refresh_eagle():
  '''Refreshes Eagle metadata and dimension'''
  pass

@task
@run_scripts('child', 'etc/truncate_eagle_metadata.sql')
def eagle_truncate():
  ''' Truncate from table data imported from CDW '''
  pass

@task
@run_scripts('child'
              ,'metadata/build_table_access_eagle.sql'
              ,'metadata/build_icd9cm_ontology.sql'
              , 'metadata/build_icd10cm_ontology.sql'
              , 'metadata/build_encounters_ontology_eagle.sql'
              , 'metadata/build_eagle_admission_status_ontology.sql')
def eagle_metadata():
  '''Build Eagle metadata'''
  pass

'''
Building miscellaneous I2B2 tables and related i2b2 tables.
'''
@task
@run_scripts('child', 'counting/count_diagnoses.sql'
                              , 'counting/count_encounters.sql'
                              , 'counting/count_providers.sql')
def patient_counting():
  pass
