#!/usr/bin/python
'''
    To facilitate rapid deployment of i2b2 projects, Weill Cornell Medicine has
    adopted a view-based strategy in creating new projects which will allow one
    central OBSERVATION_FACT table to power many smaller views. Each project is
    responsible for creating its views and specifying the data sources of interest.
    The following tables have been converted to views when following this strategy.
    
    * CODE_LOOKUP
    * CONCEPT_DIMENSION
    * ENCOUNTER_MAPPING
    * MODIFIER_DIMENSION
    * OBSERVATION_FACT
    * PATIENT_DIMENSION
    * PATIENT_MAPPING
    * PROVIDER_DIMENSION
    * SOURCE_MASTER
    * TIME_DIMENSION
    * VISIT_DIMENSION
    
    No data needs to be processed for any of these views, provided views are created
    in these projects. Code to do so is located in preprocessing/create_project_views.
    The only data which needs to be populated would be the metadata tables for each
    project.

    @author: mzd2016
    @last_edited: 8/14/2017
'''

from db_utils import run_scripts, finalize
from paver.easy import task, needs, no_help

@task
@needs([  'mpn.metadata'
        , 'mpn.build_indexes_metadata'
        , 'mpn.dimension'
        , 'mpn.miscellaneous_entries'
        , 'mpn.create_datamart_report'])
def etl():
  ''' Rebuilds metadata, sourcesystem tables and creates a datamart report '''
  pass



'''Top level ETL functions'''
@task
@needs([  'mpn.metadata_truncate'
        , 'mpn.drop_indexes_metadata'
        , 'mpn.epic_metadata'
        , 'mpn.other_metadata'])
def metadata():
  ''' Encapsulates creation of metadata entries '''
  pass

@task
@needs([    'mpn.truncate_dimension'
          , 'mpn.drop_indexes_dimension'
          , 'mpn.other_dimension'
  ])
def dimension():
  '''encapulates creation of dimension entries'''
  pass


@task
@needs(['mpn.truncate_misc'])
@run_scripts('mpn'
               , 'metadata/build_schemes.sql'
               )
def miscellaneous_entries():
  pass

@task
@run_scripts('mpn', 'preprocessing/create_datamart_report.sql')
def create_datamart_report():
  ''' Creates a report on the RDR at the end of the ETL '''
  pass



'''Metadata and dimension ETL functions'''
@task
@run_scripts('mpn'
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
@needs([  'mpn.profiler_metadata'
          #,'mpn.redcap_metadata'
          ,'mpn.ormanager_metadata'
          ,'mpn.compurecord_metadata'
          ,'mpn.crest_metadata'
          ,'mpn.tumor_registry_metadata'
          ,'mpn.custom_metadata'])
def other_metadata():
  '''Builds metadata for Other data domains'''
  pass

@task
@needs([  
        'mpn.custom_dimension'
        ])
def other_dimension():
  ''' Builds dimension entries for Other data domains '''
  pass



'''
General Index management tasks
'''
@task
@run_scripts('mpn', 'index/drop_indexes_dimension_metadata.sql')
def drop_indexes_dimension():
  pass


@task
@run_scripts('mpn', 'index/drop_indexes_metadata.sql')
def drop_indexes_metadata():
  pass


@task
@run_scripts('mpn', 'index/build_indexes_metadata.sql')
def build_indexes_metadata():
  pass



'''
General truncation tasks
'''
@task
@run_scripts('mpn', 'etc/truncate_tables_dimension_metadata.sql')
def truncate_dimension():
  ''' Empties select I2B2 tables while leaving their structure intact. '''
  pass

@task
@run_scripts('mpn', 'etc/truncate_tables_metadata.sql')
def metadata_truncate():
  pass

@task
@run_scripts('mpn', 'etc/truncate_tables_misc.sql')
def truncate_misc():
  ''' Empties select I2B2 tables while leaving their structure intact. '''
  pass

'''CUSTOM'''
@task
@needs([  'mpn.custom_truncate'
          ,'mpn.custom_metadata'
          ,'mpn.custom_dimension'])
def refresh_custom():
  '''refreshes the custom metadata and dimension'''
  pass

@task
@run_scripts('mpn', 'etc/truncate_custom_metadata.sql')
def custom_truncate():
  ''' Truncates only CUSTOM metadata data from table'''
  pass

@task
@run_scripts('mpn'
              ,'metadata/build_table_access_custom.sql'
              ,'metadata/build_custom_ontology_mpn.sql')
def custom_metadata():
  '''builds custom metadata'''
  pass

@task
@run_scripts('mpn','demodata/build_concept_dimension_entries_custom.sql')
def custom_dimension():
  '''build custom dimension'''
  pass



'''TUMOR REGISTRY'''
@task
@needs([   'mpn.tumor_registry_truncate'
          ,'mpn.tumor_registry_metadata'])
def refresh_tumor_registry():
  '''refreshes tumor registry metadata and dimension'''
  pass

@task
@run_scripts('mpn', 'etc/truncate_mapping_tumor_registry_metadata.sql')
def tumor_registry_truncate():
  ''' Empties i2b2 tables of tumor registry data'''
  pass

@task
@run_scripts( 'mpn'
              ,'metadata/build_table_access_tumor_registry.sql'
              ,'metadata/build_tumor_registry_ontology.sql')
def tumor_registry_metadata():
  '''build tumor registry metadata'''
  pass


'''PROFILER'''
@task
@needs([  'mpn.profiler_truncate'
          ,'mpn.profiler_metadata'])
def refresh_profiler():
  '''refreshes profiler metadata and dimension'''
  pass

@task
@run_scripts('mpn', 'etc/truncate_profiler_metadata.sql')
def profiler_truncate():
  ''' Truncate only specimens data from table '''
  pass

@task
@run_scripts( 'mpn'
              ,'metadata/build_table_access_profiler.sql'
              ,'metadata/build_specimen_ontology.sql')
def profiler_metadata():
  '''build profiler metadata'''
  pass

'''REDCAP'''
@task
@needs([  'mpn.redcap_truncate'
          ,'mpn.redcap_preprocessing'
          ,'mpn.redcap_metadata'])
def refresh_redcap():
  '''refreshes redcap metadata and dimension'''
  pass

@task
@run_scripts('mpn', 'etc/truncate_redcap_metadata.sql')
def redcap_truncate():
  ''' Truncate only REDCap data from table '''
  pass

@run_scripts('mpn', 'preprocessing/pre-processing_redcap_tables.sql'
                    , 'preprocessing/populate_adjusted_redcap_tables.sql'
                    , 'index/create_staging_area_indexes_redcap.sql')
def redcap_preprocessing():
  ''' Refreshes the REDCap tables prior to ETL and cleans them up '''
  pass

@task
@run_scripts( 'mpn'
              ,'metadata/build_table_access_redcap.sql'
              ,'metadata/build_redcap_ontology.sql')
def redcap_metadata():
  '''build redcap metadata'''
  pass

'''COMPURECORD'''
@task
@needs([  'mpn.compurecord_truncate'
          ,'mpn.compurecord_metadata'])
def refresh_compurecord():
  '''Refresh compurecord metadata and dimension'''
  pass

@task
@run_scripts('mpn', 'etc/truncate_compurecord_metadata.sql')
def compurecord_truncate():
  ''' Truncate from table data imported from REDCap '''
  pass

@task
@run_scripts( 'mpn'
              ,'metadata/build_table_access_compurecord.sql'
              ,'metadata/build_compurecord_ontology.sql')
def compurecord_metadata():
  '''build compurecord metadata'''
  pass

'''CREST'''
@task
@needs([  'mpn.crest_truncate'
          ,'mpn.crest_metadata'])
def refresh_crest():
  '''Refreshes crest metadata and dimesnion'''
  pass

@task
@run_scripts('mpn', 'etc/truncate_crest_metadata.sql')
def crest_truncate():
  ''' Truncates only CREST data from table'''
  pass

@task
@run_scripts( 'mpn'
              ,'metadata/build_table_access_crest.sql'
              ,'metadata/build_crest_ontology.sql')
def crest_metadata():
  '''build crest metadata'''
  pass

'''ORMANAGER'''
@task
@needs([  'mpn.ormanager_truncate'
          ,'mpn.ormanager_metadata'])
def refresh_ormanager():
  '''Refreshes ormanager metadata and dimension'''
  pass

@task
@run_scripts('mpn', 'etc/truncate_ormanager_metadata.sql')
def ormanager_truncate():
  ''' Truncate from table data imported from ORManager '''
  pass

@task
@run_scripts( 'mpn'
              ,'metadata/build_table_access_ormanager.sql'
              , 'metadata/build_ormanager_ontology.sql')
def ormanager_metadata():
  '''build ormanager metadata'''
  pass

'''ECLIPSYS'''
@task
@needs([  'mpn.eclipsys_truncate'
          ,'mpn.eclipsys_metadata'])
def refresh_eclipsys():
  '''Refreshes eclipsys metadata and dimension'''
  pass

@task
@run_scripts('mpn', 'etc/truncate_eclipsys_metadata.sql')
def eclipsys_truncate():
  ''' Truncate from table data imported from CDW '''
  pass

@task
@run_scripts('mpn', 'metadata/build_encounters_ontology_eclipsys.sql')
def eclipsys_metadata():
  '''Build Eclipsys metadata'''
  pass

'''EAGLE'''
@task
@needs([  'mpn.eagle_truncate'
          ,'mpn.eagle_metadata'])
def refresh_eagle():
  '''Refreshes Eagle metadata and dimension'''
  pass

@task
@run_scripts('mpn', 'etc/truncate_eagle_metadata.sql')
def eagle_truncate():
  ''' Truncate from table data imported from CDW '''
  pass

@task
@run_scripts('mpn'
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
@run_scripts('mpn', 'counting/count_diagnoses.sql'
                              , 'counting/count_encounters.sql'
                              , 'counting/count_providers.sql')
def patient_counting():
  pass
