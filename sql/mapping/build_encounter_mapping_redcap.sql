/* 
 * Finds all MRNs in REDCAP_DATA that are not found in patient_mapping,
 * and inserts them based on PAT_ID and minimum MRN found in CLARITY.
 * Copyright (c) 2014-2017 Weill Cornell Medical College
 */

use [SUPER_STAGING];

/*
 * Get the smallest MRN for each REDCap patient.
 */

IF EXISTS (
		SELECT *
		FROM sys.tables
		WHERE NAME = 'min_mrn'
		)
	DROP TABLE super_staging.dbo.min_mrn;

SELECT DISTINCT [redcapdates].encounter_num AS [redcapencounter]
	, i.pat_id
	, min(identity_id) AS mrn
	, [date]
INTO super_staging.dbo.min_mrn
FROM super_monthly.dbo.identity_id i
INNER JOIN (
	SELECT DISTINCT r2.mrn
	    , (SELECT [create_date] FROM super_staging.sys.tables where name='REDCAP_DATA')  as [date]
		, nullif(r1.[value], '') AS [data]
		, r2.encounter_num
		, r1.field_name
	FROM super_staging.dbo.redcap_data_adj r1
	INNER JOIN (
		SELECT [mrn_getter].*
			, r.event_id
			, r.value
			, r.field_name
			, r.encounter_num
		FROM super_staging.dbo.redcap_data_adj r
		INNER JOIN (
			SELECT [value] AS mrn
				, project_id
				, record
			FROM super_staging.dbo.redcap_data_adj r1
			WHERE field_name LIKE '%mrn%'
				and isnumeric([value]) = 1
			) [mrn_getter]
			ON [mrn_getter].project_id = r.project_id
				AND [mrn_getter].record = r.record
		) r2
		ON CONCAT (
				r1.project_id
				, r1.event_id
				, r1.record
				) = cast(r2.encounter_num as varchar)
	) [redcapdates]
	ON identity_id = mrn
INNER JOIN super_daily.dbo.patient p
	ON p.pat_id = i.pat_id
WHERE identity_type_id = 3
GROUP BY [redcapdates].encounter_num
	, i.pat_id
	, i.identity_id
	, [date]
ORDER BY pat_id ASC
	, mrn ASC;

CREATE NONCLUSTERED INDEX idx_min_mrn ON super_staging.dbo.min_mrn (
	pat_id ASC
	, mrn ASC
	);


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

/*
  The encounter_mapping table maps the i2b2 encounter_number to an encrypted
  number from the source system,encounter_ide_source (the e in ide is for
  encrypted.) Encounter_ide_source contains the name of the source system.
  Encounter_ide_status gives the status of the encounter in the source system, for
  example, if it is Active, Inactive, Deleted or Merged. 
*/

INSERT INTO ENCOUNTER_MAPPING(
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
SELECT  (
		NEXT VALUE FOR item_seq
		) AS ENCOUNTER_NUM
       , [redcapencounter] AS ENCOUNTER_IDE
	   , 'REDCAP' AS [ENCOUNTER_IDE_SOURCE]
	   , [date] AS [CONTACT_DATE]
	   , wpm.[PROJECT_ID] as [PROJECT_ID]
       , PATIENT_IDE AS PATIENT_IDE
	   , WPM.PATIENT_NUM AS PATIENT_NUM
	   , 'REDCAP' AS [PATIENT_IDE_SOURCE]
	   , 'A' AS [ENCOUNTER_IDE_STATUS]
       , '@' AS PROVIDER_ID
	   , '@' AS LOCATION_CD
	   , GETDATE() AS UPLOAD_DATE
	   , GETDATE() AS IMPORT_DATE  
	   , 'REDCAP' AS SOURCESYSTEM_CD
FROM super_staging.dbo.min_mrn
INNER JOIN (
	SELECT DISTINCT im.global_id as patient_num
		, lcl_id
		, lcl_site
		, p.patient_ide
		, pref.PROJECT_ID
	FROM patient_mapping p 
	inner join ( select pat_id, pat_enc_csn_id, department_id, visit_prov_id from super_monthly.dbo.pat_enc ) pe on pat_id = patient_ide
	inner join heroni2b2imdata.dbo.IM_MPI_MAPPING im on im.GLOBAL_ID = p.patient_num
	INNER JOIN HERONI2B2IMDATA.DBO.IM_PROJECT_PATIENTS IMPP
		ON IM.GLOBAL_ID = IMPP.GLOBAL_ID
	INNER JOIN heroni2b2pm.dbo.PREFIX_MAPPINGS pref
		ON pref.project_id = impp.project_id
	WHERE prefix = '<prefix>'
		AND lcl_site = 'WCM'
		and p.sourcesystem_cd = 'EPIC'
	) wpm
	ON mrn = lcl_id;

drop sequence item_seq;