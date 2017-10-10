/*
* This script is used to populate our custom RDRs with their patient cohorts. These
* patient cohorts are taken from the IM_MPI_MAPPING table.
* Copyright (c) 2014-2017 Weill Cornell Medical College
*/
USE <child>i2b2demodata;

/*
 * Projects share ENCOUNTER_MAPPING because they require encounters and patients in order
 * to drive cohort queries. It makes sense to process these encounter/patient pairs once
 * and reuse them for multiple projects.
 */
EXEC (
              '
  CREATE VIEW [dbo].ENCOUNTER_MAPPING (
  [ENCOUNTER_NUM]
      ,[ENCOUNTER_IDE]
      ,[ENCOUNTER_IDE_SOURCE]
      ,[CONTACT_DATE]
      ,[PROJECT_ID]
      ,[PATIENT_IDE]
      ,[PATIENT_NUM]
      ,[PATIENT_IDE_SOURCE]
      ,[ENCOUNTER_IDE_STATUS]
      ,[PROVIDER_ID]
      ,[LOCATION_CD]
      ,[UPLOAD_DATE]
      ,[UPDATE_DATE]
      ,[DOWNLOAD_DATE]
      ,[IMPORT_DATE]
      ,[SOURCESYSTEM_CD]
      ,[UPLOAD_ID]) AS (
         SELECT [ENCOUNTER_NUM]
      ,[ENCOUNTER_IDE]
      ,[ENCOUNTER_IDE_SOURCE]
      ,[CONTACT_DATE]
      ,O.[PROJECT_ID]
      ,[PATIENT_IDE]
      ,[PATIENT_NUM]
      ,[PATIENT_IDE_SOURCE]
      ,[ENCOUNTER_IDE_STATUS]
      ,[PROVIDER_ID]
      ,[LOCATION_CD]
      ,[UPLOAD_DATE]
      ,O.[UPDATE_DATE]
      ,O.[DOWNLOAD_DATE]
      ,O.[IMPORT_DATE]
      ,O.[SOURCESYSTEM_CD]
      ,O.[UPLOAD_ID] FROM <parent>i2b2demodata.DBO.ENCOUNTER_MAPPING O
			INNER JOIN (SELECT DISTINCT GLOBAL_ID FROM <parent>i2b2imdata.DBO.[IM_PROJECT_PATIENTS] im
						  INNER JOIN <parent>i2b2pm.DBO.PREFIX_MAPPINGS PM ON PM.PROJECT_ID = IM.PROJECT_ID
						  WHERE [PREFIX] = ''<child>'') 	
							 IM ON GLOBAL_ID = PATIENT_NUM
               )'
              )

/*
 * OBSERVATION_FACT is the most expensive table to process, so it makes sense that we would
 * do processing once and then take the relevant slices of encounters and patient facts from
 * the table for particular projects. This per-project filter is taken care of by joining to 
 * some IM tables and checking source systems against the ones assigned to projects in 
 * IM_PROJECT_PATIENTS and PREFIX_MAPPINGS.
 *
 * PREFIX_MAPPINGS is a WCM-helper table which maps <child> values to database prefixes for
 * projects.
 */
EXEC (
'create view [dbo].OBSERVATION_FACT (
          [ENCOUNTER_NUM]
      ,[PATIENT_NUM]
      ,[CONCEPT_CD]
      ,[PROVIDER_ID]
      ,[START_DATE]
      ,[MODIFIER_CD]
      ,[INSTANCE_NUM]
      ,[VALTYPE_CD]
      ,[TVAL_CHAR]
      ,[NVAL_NUM]
      ,[VALUEFLAG_CD]
      ,[QUANTITY_NUM]
      ,[UNITS_CD]
      ,[END_DATE]
      ,[LOCATION_CD]
      ,[OBSERVATION_BLOB]
      ,[CONFIDENCE_NUM]
      ,[UPDATE_DATE]
      ,[DOWNLOAD_DATE]
      ,[IMPORT_DATE]
      ,[SOURCESYSTEM_CD]
      ,[UPLOAD_ID]
      ,[TEXT_SEARCH_INDEX]) AS (
         SELECT [ENCOUNTER_NUM]
      ,[PATIENT_NUM]
      ,[CONCEPT_CD]
      ,[PROVIDER_ID]
      ,[START_DATE]
      ,[MODIFIER_CD]
      ,[INSTANCE_NUM]
      ,[VALTYPE_CD]
      ,[TVAL_CHAR]
      ,[NVAL_NUM]
      ,[VALUEFLAG_CD]
      ,[QUANTITY_NUM]
      ,[UNITS_CD]
      ,[END_DATE]
      ,[LOCATION_CD]
      ,NULL AS [OBSERVATION_BLOB]
      ,[CONFIDENCE_NUM]
      ,o.[UPDATE_DATE]
      ,o.[DOWNLOAD_DATE]
      ,o.[IMPORT_DATE]
      ,o.[SOURCESYSTEM_CD]
      ,NULL AS [UPLOAD_ID]
      ,[TEXT_SEARCH_INDEX] FROM <parent>i2b2demodata.DBO.observation_fact O
	  where patient_num in (select global_id from <parent>i2b2imdata.DBO.[IM_PROJECT_PATIENTS] 
					  where project_id in (select project_id from <parent>i2b2pm.DBO.PREFIX_MAPPINGS 
					   WHERE [PREFIX] = ''<child>'') )
               )'
              )

/*
 * Projects share PATIENT_DIMENSION because they require a patient cohort to do investigation.
 * We process this table once and share for all projects.
 */
EXEC (
              '
create view [dbo].PATIENT_DIMENSION (
       [PATIENT_NUM]
      ,[VITAL_STATUS_CD]
      ,[BIRTH_DATE]
      ,[DEATH_DATE]
      ,[SEX_CD]
      ,[AGE_IN_YEARS_NUM]
      ,[LANGUAGE_CD]
      ,[RACE_CD]
      ,[MARITAL_STATUS_CD]
      ,[RELIGION_CD]
      ,[STATECITYZIP_PATH]
      ,[INCOME_CD]
      ,[PATIENT_BLOB]
      ,[UPDATE_DATE]
      ,[DOWNLOAD_DATE]
      ,[IMPORT_DATE]
      ,[SOURCESYSTEM_CD]
      ,[UPLOAD_ID]
      ,[state_cd]
      ,[ethnicity_cd]) AS (
         SELECT [PATIENT_NUM]
      ,[VITAL_STATUS_CD]
      ,[BIRTH_DATE]
      ,[DEATH_DATE]
      ,[SEX_CD]
      ,[AGE_IN_YEARS_NUM]
      ,[LANGUAGE_CD]
      ,[RACE_CD]
      ,[MARITAL_STATUS_CD]
      ,[RELIGION_CD]
      ,[STATECITYZIP_PATH]
      ,[INCOME_CD]
      ,[PATIENT_BLOB]
      ,O.[UPDATE_DATE]
      ,O.[DOWNLOAD_DATE]
      ,O.[IMPORT_DATE]
      ,O.[SOURCESYSTEM_CD]
      ,O.[UPLOAD_ID]
      ,[state_cd]
      ,[ethnicity_cd] FROM <parent>i2b2demodata.DBO.PATIENT_DIMENSION O
		INNER JOIN (SELECT DISTINCT GLOBAL_ID FROM <parent>i2b2imdata.DBO.[IM_PROJECT_PATIENTS] im
						  INNER JOIN <parent>i2b2pm.DBO.PREFIX_MAPPINGS PM ON PM.PROJECT_ID = IM.PROJECT_ID
						  WHERE [PREFIX] = ''<child>'') 	
							 IM ON GLOBAL_ID = PATIENT_NUM
               )'
              )


/*
 * TIME_DIMENSION is a look up table for dates. There's no reason to copy into each project.
 */
EXEC('
	create view dbo.TIME_DIMENSION(
		[START_DATE]
      ,[DAY_OF_WEEK]
      ,[WEEK_NUMBER]
      ,[LAST_FRIDAY]
      ,[MONTH_END]
      ,[MONTH_NAME]
      ,[MONTH_NUMBER]
      ,[WEEKEND_YN]
      ,[QUARTER_BEGIN_DATE]
      ,[QUARTER_END_DATE]
      ,[LEAP_YEAR_YN]
      ,[HOLIDAY_YN]
      ,[DAY]
      ,[DAY_OF_THE_YEAR]
      ,[INSTANT_AT_MIDNIGHT]
      ,[YEAR]
      ,[OCCURRENCE_IN_MONTH]
      ,[UPDATE_DATE]
      ,[DOWNLOAD_DATE]
      ,[IMPORT_DATE]) AS
SELECT [START_DATE]
      ,[DAY_OF_WEEK]
      ,[WEEK_NUMBER]
      ,[LAST_FRIDAY]
      ,[MONTH_END]
      ,[MONTH_NAME]
      ,[MONTH_NUMBER]
      ,[WEEKEND_YN]
      ,[QUARTER_BEGIN_DATE]
      ,[QUARTER_END_DATE]
      ,[LEAP_YEAR_YN]
      ,[HOLIDAY_YN]
      ,[DAY]
      ,[DAY_OF_THE_YEAR]
      ,[INSTANT_AT_MIDNIGHT]
      ,[YEAR]
      ,[OCCURRENCE_IN_MONTH]
      ,[UPDATE_DATE]
      ,[DOWNLOAD_DATE]
      ,[IMPORT_DATE]
  FROM [<parent>i2b2demodata].[dbo].[TIME_DIMENSION];
		')

/*
 * Projects share PATIENT_MAPPING because they require a patient cohort to do investigation.
 * We process this table once and share for all projects.
 */
EXEC (
              'CREATE VIEW [dbo].PATIENT_MAPPING ([PATIENT_NUM]
      ,[PATIENT_IDE]
      ,[PATIENT_IDE_SOURCE]
      ,[PATIENT_IDE_STATUS]
      ,[PROJECT_ID]
      ,[UPLOAD_DATE]
      ,[UPDATE_DATE]
      ,[DOWNLOAD_DATE]
      ,[IMPORT_DATE]
      ,[SOURCESYSTEM_CD]
      ,[UPLOAD_ID]) AS ( SELECT [PATIENT_NUM]
      ,[PATIENT_IDE]
      ,[PATIENT_IDE_SOURCE]
      ,[PATIENT_IDE_STATUS]
      ,O.[PROJECT_ID]
      ,O.[UPLOAD_DATE]
      ,O.[UPDATE_DATE]
      ,O.[DOWNLOAD_DATE]
      ,O.[IMPORT_DATE]
      ,O.[SOURCESYSTEM_CD]
      ,O.[UPLOAD_ID] FROM <parent>i2b2demodata.DBO.PATIENT_MAPPING O
INNER JOIN (SELECT DISTINCT GLOBAL_ID FROM <parent>i2b2imdata.DBO.[IM_PROJECT_PATIENTS] im
						  INNER JOIN <parent>i2b2pm.DBO.PREFIX_MAPPINGS PM ON PM.PROJECT_ID = IM.PROJECT_ID
						  WHERE [PREFIX] = ''<child>'') 	
							 IM ON GLOBAL_ID = PATIENT_NUM
               )'
              )

/*
 * Projects take only the modifiers that they require as specified by the metadata.
 */
EXEC (
	'CREATE VIEW dbo.MODIFIER_DIMENSION AS
		SELECT M.* FROM <parent>i2b2demodata.dbo.MODIFIER_DIMENSION M
		where modifier_cd in (
			select C_BASECODE FROM <child>i2b2metadata.dbo.i2b2 where C_VISUALATTRIBUTES = ''RA''
			UNION
			select C_BASECODE FROM <child>i2b2metadata.dbo.ICD10_ICD9 where C_VISUALATTRIBUTES = ''RA''
			UNION
			select C_BASECODE FROM <child>i2b2metadata.dbo.CUSTOM_META where C_VISUALATTRIBUTES = ''RA''
			UNION
			select C_BASECODE FROM <child>i2b2metadata.dbo.BIRN where C_VISUALATTRIBUTES = ''RA''
			)'
              )

/*
 * Projects share VISIT_DIMENSION because they require encounters to do investigation.
 * We process this table once and share for all projects.
 */
EXEC (
'CREATE VIEW [dbo].VISIT_DIMENSION (
       [ENCOUNTER_NUM]
      ,[PATIENT_NUM]
      ,[ACTIVE_STATUS_CD]
      ,[START_DATE]
      ,[END_DATE]
      ,[INOUT_CD]
      ,[LOCATION_CD]
      ,[LOCATION_PATH]
      ,[LENGTH_OF_STAY]
      ,[VISIT_BLOB]
      ,[UPDATE_DATE]
      ,[DOWNLOAD_DATE]
      ,[IMPORT_DATE]
      ,[SOURCESYSTEM_CD]
      ,[UPLOAD_ID]
      ,[enc_type_path]) AS (SELECT [ENCOUNTER_NUM]
      ,[PATIENT_NUM]
      ,[ACTIVE_STATUS_CD]
      ,[START_DATE]
      ,[END_DATE]
      ,[INOUT_CD]
      ,[LOCATION_CD]
      ,[LOCATION_PATH]
      ,[LENGTH_OF_STAY]
      ,[VISIT_BLOB]
      ,O.[UPDATE_DATE]
      ,O.[DOWNLOAD_DATE]
      ,O.[IMPORT_DATE]
      ,O.[SOURCESYSTEM_CD]
      ,O.[UPLOAD_ID]
      ,[enc_type_path] FROM <parent>i2b2demodata.DBO.VISIT_DIMENSION O
INNER JOIN (SELECT DISTINCT GLOBAL_ID FROM <parent>i2b2imdata.DBO.[IM_PROJECT_PATIENTS] im
						  INNER JOIN <parent>i2b2pm.DBO.PREFIX_MAPPINGS PM ON PM.PROJECT_ID = IM.PROJECT_ID
						  WHERE [PREFIX] = ''<child>'') 	
							 IM ON GLOBAL_ID = PATIENT_NUM
               )'
              )

/*
 * Project sources are determined from IM_PROJECT_SITES
 */

EXEC('
CREATE VIEW DBO.[SOURCE_MASTER] (
	[SOURCESYSTEM_CD], [DESCRIPTION], [CREATE_DATE]
) AS (
	SELECT [SOURCESYSTEM_CD], [DESCRIPTION], [CREATE_DATE]
	FROM <parent>i2b2demodata.DBO.SOURCE_MASTER [SM]
	WHERE [SM].[SOURCESYSTEM_CD] IN (
		SELECT LCL_SITE
		FROM [<parent>I2B2IMDATA].[DBO].[IM_PROJECT_SITES] [IM]
		INNER JOIN <parent>I2B2PM.DBO.PREFIX_MAPPINGS PM ON PM.PROJECT_ID = IM.PROJECT_ID
		WHERE [PREFIX] = ''<child>''
		)
)')

/*
 * CODES included in CODE_LOOKUP stem from all sources a project
 * is allowed to use.
 */
EXEC('
CREATE VIEW [DBO].[CODE_LOOKUP] (
       [TABLE_CD]
      ,[COLUMN_CD]
      ,[CODE_CD]
      ,[NAME_CHAR]
      ,[LOOKUP_BLOB]
      ,[UPLOAD_DATE]
      ,[UPDATE_DATE]
      ,[DOWNLOAD_DATE]
      ,[IMPORT_DATE]
      ,[SOURCESYSTEM_CD]
      ,[UPLOAD_ID]
) AS (
	SELECT [TABLE_CD]
      ,[COLUMN_CD]
      ,[CODE_CD]
      ,[NAME_CHAR]
      ,[LOOKUP_BLOB]
      ,[UPLOAD_DATE]
      ,[UPDATE_DATE]
      ,[DOWNLOAD_DATE]
      ,[IMPORT_DATE]
      ,[SOURCESYSTEM_CD]
      ,[UPLOAD_ID]
  FROM [<parent>i2b2demodata].[dbo].[CODE_LOOKUP] cl
  WHERE [cl].[SOURCESYSTEM_CD] IN (
		SELECT LCL_SITE
		FROM [<parent>I2B2IMDATA].[DBO].[IM_PROJECT_SITES] [IM]
		INNER JOIN <parent>I2B2PM.DBO.PREFIX_MAPPINGS PM ON PM.PROJECT_ID = IM.PROJECT_ID
		WHERE [PREFIX] = ''<child>''
		)
  )')

/*
 * Use the metadata to find the concepts to populate concept_dimension with
 */
EXEC('
 CREATE VIEW DBO.[CONCEPT_DIMENSION] (
	[CONCEPT_PATH]
      ,[CONCEPT_CD]
      ,[NAME_CHAR]
      ,[UPDATE_DATE]
      ,[DOWNLOAD_DATE]
      ,[IMPORT_DATE]
      ,[SOURCESYSTEM_CD]
      ,[UPLOAD_ID]) AS (
	  SELECT [CONCEPT_PATH]
      ,[CONCEPT_CD]
      ,[NAME_CHAR]
      ,[UPDATE_DATE]
      ,[DOWNLOAD_DATE]
      ,[IMPORT_DATE]
      ,[SOURCESYSTEM_CD]
      ,[UPLOAD_ID] FROM <parent>i2b2demodata.DBO.CONCEPT_DIMENSION CD
	  WHERE [cd].[SOURCESYSTEM_CD] IN (
		SELECT LCL_SITE
		FROM [I2B2IMDATA].[DBO].[IM_PROJECT_SITES] [IM]
		INNER JOIN I2B2PM.DBO.PREFIX_MAPPINGS PM ON PM.PROJECT_ID = IM.PROJECT_ID
		WHERE [PREFIX] = ''<child>''
		)

		union

	  SELECT [CONCEPT_PATH]
      ,[CONCEPT_CD]
      ,[NAME_CHAR]
      ,[UPDATE_DATE]
      ,[DOWNLOAD_DATE]
      ,[IMPORT_DATE]
      ,[SOURCESYSTEM_CD]
      ,[UPLOAD_ID] FROM <child>I2B2demodata.DBO.CONCEPT_DIMENSION_LOCAL
  )')

/*
 * The metadata has only the providers in their instance, so it is good enough
 * to base PROVIDER_DIMENSION off of
 */
 exec('
 create view [dbo].[provider_dimension] (
	[PROVIDER_ID]
      ,[PROVIDER_PATH]
      ,[NAME_CHAR]
      ,[PROVIDER_BLOB]
      ,[UPDATE_DATE]
      ,[DOWNLOAD_DATE]
      ,[IMPORT_DATE]
      ,[SOURCESYSTEM_CD]
      ,[UPLOAD_ID]) as (
	select C_BASECODE
      ,C_FULLNAME
      ,C_NAME
	  ,'''' as [PROVIDER_BLOB]
      ,[UPDATE_DATE]
      ,[DOWNLOAD_DATE]
      ,[IMPORT_DATE]
      ,[SOURCESYSTEM_CD]
      ,null as [UPLOAD_ID] from <child>i2b2metadata.dbo.i2b2 pd
	where c_fullname like ''\i2b2\Provider%''
	)')