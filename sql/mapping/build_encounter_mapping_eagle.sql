/*
 * Integrates encounters from the CDW into i2b2
 * Copyright (c) 2014-2017 Weill Cornell Medical College
 */


use <prefix>i2b2demodata;

DECLARE @max INT;
DECLARE @sql varchar(100);

SELECT @max = (
		SELECT MAX(encounter_num) + 1
		FROM encounter_mapping
		);

SELECT @sql = 'ALTER SEQUENCE item_seq RESTART WITH ' + cast(@max as varchar) + ' INCREMENT BY 1;'

-- Create a sequence up front, then alter it with ALTER SEQUENCE
-- Need to do this because T-SQL does not "see" item_seq within
-- an exec but @max variable does not work within SEQUENCE
-- definition. Need to mix the two approaches to work.
IF EXISTS (
		SELECT *
		FROM sys.sequences
		WHERE object_id = object_id('dbo.item_seq')
		)
BEGIN
	DROP sequence item_seq;
END

CREATE SEQUENCE item_seq START WITH 1 INCREMENT BY 1;

EXEC ( @sql	)


-- Eagle encounters that begin with G or R are sent to Eagle from
-- Epic. G is general, R is lab results. These already have encounter
-- numbers in i2b2 for these EPIC encounters so reuse them for 
-- EPIC, flag ENCOUNTER_IDE with the G variant, and sourcesystem_cd
-- as EAGLE
insert into ENCOUNTER_MAPPING(
	encounter_num
	, encounter_ide
	, encounter_ide_source
	, contact_date
	, project_id
	, patient_ide
	, patient_num
	, patient_ide_source
	, encounter_ide_status
	, provider_id
	, location_cd
	, upload_date
	, download_date
	, import_date
	, sourcesystem_cd
	)
SELECT   [EPIC].ENCOUNTER_NUM AS ENCOUNTER_NUM
	   , [CDW].[account] AS ENCOUNTER_IDE		-- KEEP THE G/R
	   , 'EPIC' AS [ENCOUNTER_IDE_SOURCE]  -- THESE WERE SENT FROM EPIC TO EAGLE
	   , ISNULL(cast(cast([ADMIT_DATE] as datetime2) as datetime), [PRIMARY_TIME]) [CONTACT_DATE]
	   , PROJECT_ID as [PROJECT_ID]
       , [CDW].PATIENT_ID AS PATIENT_IDE
	   , PM.PATIENT_NUM AS PATIENT_NUM
	   , 'EPIC' AS [PATIENT_IDE_SOURCE]
	   , [CASE_STATUS_CODE] AS [ENCOUNTER_IDE_STATUS]
       , RTRIM([PROVIDER_ID]) AS PROVIDER_ID
	   , [LOCATION_CODE] AS LOCATION_CD
	   , CAST(UPDATEDDTM_CDW AS DATETIME) AS UPLOAD_DATE
	   , (SELECT [create_date] FROM cdw.sys.tables where name='VISIT') [download_date]
	   , GETDATE() AS IMPORT_DATE  
	   , 'EAGLE' AS SOURCESYSTEM_CD
FROM (SELECT DISTINCT [PAT_ENC_CSN_ID]
					, v.PATIENT_ID
					, coalesce(PROVIDER_ID, '@') [PROVIDER_ID]
					, [ADMIT_DATE]
					, [location_code]
					, [PRIMARY_TIME]
					, [v].[UPDATEDDTM_CDW]
					, [case_status_code] 
					, v.[ACCOUNT]
	   FROM [CDW].[NICKEAST].[VISIT] [v]
	  inner join cdw.nickeast.visit_location vi 
		ON vi.account = v.ACCOUNT
	  inner join super_monthly.dbo.pat_enc pe on replace(replace(v.account, 'G', ''), 'R', '') = cast(pat_enc_csn_id as varchar)
	  WHERE left(v.account, 1) in ('G', 'R') and PATIENT_CLASS_CODE = 'I'
		and v.FACILITY_CODE = 'A'
	  ) [CDW]
INNER JOIN (
	   SELECT DISTINCT ENCOUNTER_NUM
					,  ENCOUNTER_IDE
					,  PATIENT_IDE
					,  PATIENT_NUM
	   FROM ENCOUNTER_MAPPING 
	   WHERE SOURCESYSTEM_CD = 'EPIC'
	  ) [EPIC] ON [CDW].[PAT_ENC_CSN_ID] = [EPIC].[ENCOUNTER_IDE]
INNER JOIN (select distinct patient_ide
						  , patient_num
						  , lcl_id
						  , lcl_site
						  , pref.project_id 
			from PATIENT_MAPPING 
			INNER JOIN heroni2b2imdata.dbo.IM_MPI_MAPPING im 
				ON patient_num = im.global_id
			INNER JOIN HERONI2B2IMDATA.DBO.IM_PROJECT_PATIENTS IMPP
				ON IM.GLOBAL_ID = IMPP.GLOBAL_ID
			INNER JOIN heroni2b2pm.dbo.PREFIX_MAPPINGS pref
				ON pref.project_id = impp.project_id
			where LCL_SITE = 'EAGLE' 
				and patient_ide_source = 'HIVE'
				and prefix = '<prefix>') pm 
	ON cdw.patient_id = pm.LCL_ID;



-- For all non G/R ACCOUNT numbers in EAGLE, match
-- where possible to EPIC and reuse an already existing
-- i2b2 ENCOUNTER_NUM
insert into ENCOUNTER_MAPPING (
	encounter_num
	, encounter_ide
	, encounter_ide_source
	, contact_date
	, project_id
	, patient_ide
	, patient_num
	, patient_ide_source
	, encounter_ide_status
	, provider_id
	, location_cd
	, upload_date
	, import_date
	, sourcesystem_cd
	)
SELECT   [cdw].ENCOUNTER_NUM
	   , [cdw].ENCOUNTER_IDE
	   , 'EAGLE' AS [ENCOUNTER_IDE_SOURCE]
	   , [PRIMARY_TIME] as [CONTACT_DATE]
	   , pm.PROJECT_ID as [PROJECT_ID]
       , PATIENT_ID AS PATIENT_IDE
	   , PM.PATIENT_NUM AS PATIENT_NUM
	   , 'EAGLE' AS [PATIENT_IDE_SOURCE]
	   , [CASE_STATUS_CODE] AS [ENCOUNTER_IDE_STATUS]
       , RTRIM(cdw.[PROVIDER_ID]) AS PROVIDER_ID
	   , [LOCATION_CODE] AS LOCATION_CD
	   , CAST(UPDATEDDTM_CDW AS DATETIME) AS UPLOAD_DATE
	   , GETDATE() AS IMPORT_DATE  
	   , 'EAGLE' AS SOURCESYSTEM_CD
FROM (
	  -- These EAGLE Encounters link to actual EPIC encounters
	  -- Before May 1, 2017 join ACCOUNT to BILL_NUM
	  -- After May 1, 2017 join ACCOUNT to PAT_ENC_CSN_ID
	  SELECT		  [em].[encounter_num] as [encounter_num]
					, v.ACCOUNT as [encounter_ide]
					, v.PATIENT_ID
					, COALESCE(vi.PROVIDER_ID, '@') [provider_id]
					, [location_code]
					, [PRIMARY_TIME]
					, [v].[UPDATEDDTM_CDW]
					, [case_status_code] 
	  FROM [CDW].[NICKEAST].[VISIT] [v]
	  inner join cdw.nickeast.visit_location vi 
		ON vi.account = v.ACCOUNT
	  inner join super_monthly.dbo.PAT_ENC_2 PE2
		on v.ACCOUNT=BILL_NUM
	  inner join <prefix>i2b2demodata.dbo.ENCOUNTER_MAPPING em on cast(em.encounter_ide as varchar) = cast(pe2.pat_enc_csn_id as varchar)  and SOURCESYSTEM_CD = 'EPIC'
	  where left(v.account, 1) not in ('G', 'R') and v.FACILITY_CODE = 'A' AND v.PATIENT_CLASS_CODE = 'I' AND bill_num <> '0' and BILL_NUM is not null
		
) [cdw]
INNER JOIN (select distinct patient_ide
						  , patient_num
						  , lcl_id
						  , lcl_site
						  , pref.project_id 
			from PATIENT_MAPPING 
			INNER JOIN heroni2b2imdata.dbo.IM_MPI_MAPPING im 
				ON patient_num = im.global_id
			INNER JOIN HERONI2B2IMDATA.DBO.IM_PROJECT_PATIENTS IMPP
				ON IM.GLOBAL_ID = IMPP.GLOBAL_ID
			INNER JOIN heroni2b2pm.dbo.PREFIX_MAPPINGS pref
				ON pref.project_id = impp.project_id
			where LCL_SITE = 'EAGLE' 
				and patient_ide_source = 'HIVE'
				and prefix = '<prefix>') pm 
	ON [CDW].patient_id = pm.LCL_ID;

-- Eagle Encounters not found within EPIC are assigned new encounter numbers
insert into ENCOUNTER_MAPPING (
	encounter_num
	, encounter_ide
	, encounter_ide_source
	, contact_date
	, project_id
	, patient_ide
	, patient_num
	, patient_ide_source
	, encounter_ide_status
	, provider_id
	, location_cd
	, upload_date
	, import_date
	, sourcesystem_cd
	)
SELECT   (NEXT VALUE FOR item_seq) as [encounter_num]
	   , [cdw].ENCOUNTER_IDE
	   , 'EAGLE' AS [ENCOUNTER_IDE_SOURCE]
	   , ISNULL(cast(cast([ADMIT_DATE] as datetime2) as datetime), [PRIMARY_TIME]) [CONTACT_DATE]
	   , pm.PROJECT_ID as [PROJECT_ID]
       , PATIENT_ID AS PATIENT_IDE
	   , PM.PATIENT_NUM AS PATIENT_NUM
	   , 'EAGLE' AS [PATIENT_IDE_SOURCE]
	   , [CASE_STATUS_CODE] AS [ENCOUNTER_IDE_STATUS]
       , RTRIM(cdw.[PROVIDER_ID]) AS PROVIDER_ID
	   , [LOCATION_CODE] AS LOCATION_CD
	   , CAST(UPDATEDDTM_CDW AS DATETIME) AS UPLOAD_DATE
	   , GETDATE() AS IMPORT_DATE  
	   , 'EAGLE' AS SOURCESYSTEM_CD
FROM (
	  -- These EAGLE Encounters link to actual EPIC encounters
	  -- No need to restrict for dates here since these are strictly
	  -- before 2017-05-01 and just need to not exist in the target
	  -- table, PAT_ENC_2
	  SELECT		  v.account as [encounter_ide]
					, v.PATIENT_ID
					, COALESCE(PROVIDER_ID, '@') [provider_id]
					, [ADMIT_DATE]
					, [location_code]
					, [PRIMARY_TIME]
					, [v].[UPDATEDDTM_CDW]
					, [case_status_code] 
	  from [CDW].[NICKEAST].[VISIT] [v]
	  inner join cdw.nickeast.visit_location vi 
		ON vi.account = v.ACCOUNT
	  inner join super_monthly.dbo.PAT_ENC_2 pe2
	    on v.ACCOUNT=BILL_NUM
	  where left(v.account, 1) not in ('G', 'R')
		AND BILL_NUM is null 
		AND V.FACILITY_CODE = 'A'
		AND v.PATIENT_CLASS_CODE = 'I'
		
) [cdw]
INNER JOIN (select distinct patient_ide
						  , patient_num
						  , lcl_id
						  , lcl_site
						  , pref.project_id 
			from PATIENT_MAPPING 
			INNER JOIN heroni2b2imdata.dbo.IM_MPI_MAPPING im 
				ON patient_num = im.global_id
			INNER JOIN HERONI2B2IMDATA.DBO.IM_PROJECT_PATIENTS IMPP
				ON IM.GLOBAL_ID = IMPP.GLOBAL_ID
			INNER JOIN heroni2b2pm.dbo.PREFIX_MAPPINGS pref
				ON pref.project_id = impp.project_id
			where LCL_SITE = 'EAGLE' 
				and patient_ide_source = 'HIVE'
				and prefix = '<prefix>') pm 
	ON [CDW].patient_id = pm.LCL_ID;

DROP sequence item_seq;