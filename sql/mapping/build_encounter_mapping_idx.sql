/*
	Create mapping tables based on CREST_SUBJECTS table
	Copyright (c) 2014-2017 Weill Cornell Medical College
*/

USE <prefix>i2b2demodata;

-- Can populate MAPPING tables with IDX data for any RDR.
INSERT INTO ENCOUNTER_MAPPING (
	encounter_num
	, encounter_ide
	, encounter_ide_source
	, contact_date
	, project_id
	, patient_ide
	, patient_num
	, patient_ide_source
	, encounter_ide_status
	, location_cd
	, provider_id
	, update_date
	, download_date
	, import_date
	, sourcesystem_cd
	)
SELECT ENCOUNTER_NUM
	, EM.ENCOUNTER_IDE AS ENCOUNTER_IDE
	, 'IDX' AS ENCOUNTER_IDE_SOURCE
	, ISNULL(TRY_CONVERT(DATE, CONTACT_DATE, 120), '1776-07-04') [CONTACT_DATE]
	, [IM].[PROJECT_ID] AS PROJECT_ID
	, lcl_id AS PATIENT_IDE
	, EM.PATIENT_NUM
	, 'IDX' AS PATIENT_IDE_SOURCE
	, 'A' AS ENCOUNTER_IDE_STATUS
	, '@' AS LOCATION_CD
	, PROVIDER_ID
	, (SELECT [create_date] FROM super_staging.sys.tables where name='IDX_DATA') [update_date]
	, (SELECT [create_date] FROM super_staging.sys.tables where name='IDX_DATA') as download_date
	, GETDATE() AS IMPORT_DATE
	, 'IDX' AS SOURCESYSTEM_CD
FROM (SELECT DISTINCT PAT_ID, PAT_ENC_CSN_ID, NYP_MRN FROM SUPER_STAGING.DBO.IDX_DATA_SLIM) CS
JOIN (SELECT ENCOUNTER_IDE, ENCOUNTER_NUM, PATIENT_IDE, PATIENT_NUM, CONTACT_DATE, PROVIDER_ID FROM ENCOUNTER_MAPPING WHERE ENCOUNTER_IDE_SOURCE = 'PAT_ENC') EM ON CS.PAT_ENC_CSN_ID = ENCOUNTER_IDE
JOIN (
	SELECT DISTINCT im.global_id
		, lcl_id
		, lcl_site
		, pref.PROJECT_ID
	FROM heroni2b2imdata.dbo.IM_MPI_MAPPING im
	INNER JOIN HERONI2B2IMDATA.DBO.IM_PROJECT_PATIENTS IMPP
		ON IM.GLOBAL_ID = IMPP.GLOBAL_ID
	INNER JOIN heroni2b2pm.dbo.PREFIX_MAPPINGS pref
		ON pref.project_id = impp.project_id
	WHERE prefix = '<prefix>'
		AND lcl_site = 'IDX'
	) im
	ON im.GLOBAL_ID = PATIENT_NUM;
