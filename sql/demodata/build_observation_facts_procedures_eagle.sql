/*
 The inpatient billing system EAGLE records procedures using both ICD-9-CM
 and ICD-10-PCS.
 
 Copyright (c) 2014-2017 Weill Cornell Medical College
 */

use <prefix>i2b2demodata;


--insert into observation_Fact
--(
--	  encounter_num
--	, patient_num
--	, concept_cd
--	, provider_id
--	, start_date
--	, modifier_cd
--	, instance_num
--	, valueflag_cd
--	, units_cd
--	, location_cd
--	, import_date
--	, sourcesystem_cd
--	)
-- SELECT ENCOUNTER_NUM
--	, PATIENT_NUM
--	, 'ICD9CM:' + cast([PROCEDURE_CODE] as varchar) AS CONCEPT_CD
--	, '@' AS PROVIDER_ID
--	, ISNULL(cast([EAGLE_PROC_DATE] as datetime2), '1776-07-04') AS [START_DATE]
--	, '@' AS MODIFIER_CD
--	, 1 AS INSTANCE_NUM
--	, '@' AS VALUEFLAG_CD
--	, '@' AS UNITS_CD
--	, '@' AS LOCATION_CD
--	, GETDATE() AS IMPORT_DATE
--	, 'EAGLE' AS SOURCESYSTEM_CD
--  FROM [CDW].[NICKEAST].[VISIT_PROCEDURE] vp
--  INNER JOIN (select encounter_num, patient_num, cast(encounter_ide as varchar(16)) [encounter_ide], cast(contact_date as datetime2) [contact_date] from ENCOUNTER_MAPPING
--			WHERE [ENCOUNTER_IDE_SOURCE] = 'EAGLE') EM
--	ON ENCOUNTER_IDE = VP.ACCOUNT
--	where vp.code_type = 'I9'
--		and PROCEDURE_CODE is not null;

--insert into observation_Fact
--(
--	  encounter_num
--	, patient_num
--	, concept_cd
--	, provider_id
--	, start_date
--	, modifier_cd
--	, instance_num
--	, valueflag_cd
--	, units_cd
--	, location_cd
--	, import_date
--	, sourcesystem_cd
--	)
-- SELECT ENCOUNTER_NUM
--	, PATIENT_NUM
--	, 'ICD10PCS:' + cast([PROCEDURE_CODE] as varchar) AS CONCEPT_CD
--	, '@' AS PROVIDER_ID
--	, ISNULL(cast([EAGLE_PROC_DATE] as datetime2), '1776-07-04') AS [START_DATE]
--	, '@' AS MODIFIER_CD
--	, 1 AS INSTANCE_NUM
--	, '@' AS VALUEFLAG_CD
--	, '@' AS UNITS_CD
--	, '@' AS LOCATION_CD
--	, GETDATE() AS IMPORT_DATE
--	, 'EAGLE' AS SOURCESYSTEM_CD
--  FROM [CDW].[NICKEAST].[VISIT_PROCEDURE] vp
--  INNER JOIN (select encounter_num, patient_num, cast(encounter_ide as varchar(16)) [encounter_ide], cast(contact_date as datetime2) [contact_date] from ENCOUNTER_MAPPING
--			WHERE [ENCOUNTER_IDE_SOURCE] = 'EAGLE') EM
--	ON ENCOUNTER_IDE = VP.ACCOUNT
--	where vp.code_type = 'I0'
--		and PROCEDURE_CODE is not null;


/*
 * Modifier for all inpatient procedures to distinguish them from outpatient procedures
 */

 insert into observation_Fact
 (
	  encounter_num
	, patient_num
	, concept_cd
	, provider_id
	, start_date
	, modifier_cd
	, instance_num
	, valueflag_cd
	, units_cd
	, location_cd
	, import_date
	, sourcesystem_cd
	)
SELECT ENCOUNTER_NUM
	, PATIENT_NUM
	, 'ICD9CM:' + cast([PROCEDURE_CODE] as varchar) AS CONCEPT_CD
	, '@' AS PROVIDER_ID
	, cast([EAGLE_PROC_DATE] as datetime2) AS [START_DATE]
	, 'CPT:INPATPROC' AS MODIFIER_CD
	, 1 AS INSTANCE_NUM
	, '@' AS VALUEFLAG_CD
	, '@' AS UNITS_CD
	, '@' AS LOCATION_CD
	, GETDATE() AS IMPORT_DATE
	, 'EAGLE' AS SOURCESYSTEM_CD
  FROM [CDW].[NICKEAST].[VISIT_PROCEDURE] vp
  INNER JOIN (select encounter_num, patient_num, cast(encounter_ide as varchar(16)) [encounter_ide], cast(contact_date as datetime2) [contact_date] from ENCOUNTER_MAPPING
			WHERE [ENCOUNTER_IDE_SOURCE] = 'EAGLE') EM
	ON ENCOUNTER_IDE = VP.ACCOUNT and vp.EAGLE_PROC_DATE = [contact_date]
	where vp.code_type = 'I9'
		and PROCEDURE_CODE is not null;

 insert into observation_Fact
 (
	  encounter_num
	, patient_num
	, concept_cd
	, provider_id
	, start_date
	, modifier_cd
	, instance_num
	, valueflag_cd
	, units_cd
	, location_cd
	, import_date
	, sourcesystem_cd
	)
 SELECT ENCOUNTER_NUM
	, PATIENT_NUM
	, 'ICD10PCS:' + cast([PROCEDURE_CODE] as varchar) AS CONCEPT_CD
	, '@' AS PROVIDER_ID
	, ISNULL(cast([EAGLE_PROC_DATE] as datetime2), '1776-07-04') AS [START_DATE]
	, 'CPT:INPATPROC' AS MODIFIER_CD
	, 1 AS INSTANCE_NUM
	, '@' AS VALUEFLAG_CD
	, '@' AS UNITS_CD
	, '@' AS LOCATION_CD
	, GETDATE() AS IMPORT_DATE
	, 'EAGLE' AS SOURCESYSTEM_CD
  FROM [CDW].[NICKEAST].[VISIT_PROCEDURE] vp
  INNER JOIN (select encounter_num, patient_num, cast(encounter_ide as varchar(16)) [encounter_ide], cast(contact_date as datetime2) [contact_date] from ENCOUNTER_MAPPING
			WHERE [ENCOUNTER_IDE_SOURCE] = 'EAGLE') EM
	ON ENCOUNTER_IDE = VP.ACCOUNT and vp.EAGLE_PROC_DATE = [contact_date]
	where vp.code_type = 'I0'
		and PROCEDURE_CODE is not null;
