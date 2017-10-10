/*
 * Adds indexes to the encounter lookup table.
 * When joining to PATIENT_MAPPING, we restrict to only the rows
 * from EPIC to remove duplicates.
 * Copyright (c) 2014-2017 Weill Cornell Medical College
 */
USE <prefix>i2b2demodata;

/**

drop table encounter_mapping;

CREATE TABLE [dbo].[ENCOUNTER_MAPPING](
	[ENCOUNTER_NUM] [int] NOT NULL,
	[ENCOUNTER_IDE] [varchar](30) NOT NULL,
	[ENCOUNTER_IDE_SOURCE] [varchar](50) NOT NULL,
	[CONTACT_DATE] [datetime] NOT NULL,
	[PROJECT_ID] [varchar](50) NOT NULL,
	[PATIENT_IDE] [varchar](200) NOT NULL,
	[PATIENT_NUM] [int] NOT NULL,
	[PATIENT_IDE_SOURCE] [varchar](50) NOT NULL,
	[ENCOUNTER_IDE_STATUS] [varchar](50) NULL,
	[PROVIDER_ID] [varchar](200) NULL,
	[LOCATION_CD] [varchar](200) NULL,
	[UPLOAD_DATE] [datetime] NULL,
	[UPDATE_DATE] [datetime] NULL,
	[DOWNLOAD_DATE] [datetime] NULL,
	[IMPORT_DATE] [datetime] NULL,
	[SOURCESYSTEM_CD] [varchar](50) NULL,
	[UPLOAD_ID] [int] NULL
) 

**/
-- Map all patients and MRNs from EPIC. 
-- Create a Sequence to construct the i2b2 patient_num
IF EXISTS (
		SELECT *
		FROM sys.sequences
		WHERE object_id = object_id('dbo.ENCNUM')
		)
BEGIN
	DROP sequence ENCNUM;
END


CREATE SEQUENCE [DBO].[ENCNUM] AS INT START
	WITH 1000000 INCREMENT BY 1;

-- Populates encounter mapping for all projects
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
	, update_date
	, download_date
	, import_date
	, sourcesystem_cd
	)
SELECT (
		NEXT VALUE FOR DBO.ENCNUM
		) AS ENCOUNTER_NUM
	, PE.PAT_ENC_CSN_ID AS ENCOUNTER_IDE
	, 'PAT_ENC' AS [ENCOUNTER_IDE_SOURCE]
	, COALESCE(TRY_CONVERT(DATE, CONTACT_DATE, 120), CALENDAR_DT) [CONTACT_DATE]
	, wpm.PROJECT_ID AS [PROJECT_ID]
	, PATIENT_IDE AS PATIENT_IDE
	, WPM.PATIENT_NUM AS PATIENT_NUM
	, 'WCM' AS [PATIENT_IDE_SOURCE]
	, 'A' AS [ENCOUNTER_IDE_STATUS]
	, ISNULL([USER_ID], '@') AS PROVIDER_ID
	, ISNULL(cast(cd.DEPARTMENT_ID AS VARCHAR), '@') AS LOCATION_CD
	, null AS UPLOAD_DATE
	, pe.UPDATE_DATE AS UPDATE_DATE
	, (SELECT [create_date] FROM super_monthly.sys.tables where name='PAT_ENC') as download_date
	, GETDATE() AS IMPORT_DATE
	, 'EPIC' AS SOURCESYSTEM_CD
FROM SUPER_MONTHLY.DBO.PAT_ENC PE
INNER JOIN (
	SELECT DISTINCT pm.patient_ide
		, pm.patient_num
		, im.global_id
		, lcl_id
		, lcl_site
		, pref.PROJECT_ID
	FROM PATIENT_MAPPING pm
	inner join heroni2b2imdata.dbo.IM_MPI_MAPPING im 
		on im.global_id = patient_num AND LCL_SITE = PATIENT_IDE_SOURCE
	INNER JOIN HERONI2B2IMDATA.DBO.IM_PROJECT_PATIENTS IMPP
		ON IM.GLOBAL_ID = IMPP.GLOBAL_ID
	INNER JOIN heroni2b2pm.dbo.PREFIX_MAPPINGS pref
		ON pref.project_id = impp.project_id
	WHERE prefix = '<prefix>'
		AND PATIENT_IDE_SOURCE = 'WCM'
		AND pm.SOURCESYSTEM_CD = 'EPIC'
	) WPM
	ON PATIENT_IDE = PAT_ID
LEFT JOIN SUPER_MONTHLY.DBO.CLARITY_DEP CD
	ON PE.DEPARTMENT_ID = CD.DEPARTMENT_ID
LEFT JOIN SUPER_MONTHLY.DBO.CLARITY_LOC CL
	ON CD.REV_LOC_ID = CL.LOC_ID
LEFT JOIN SUPER_MONTHLY.DBO.CLARITY_SER S
	ON VISIT_PROV_ID = PROV_ID
LEFT JOIN SUPER_MONTHLY.DBO.DATE_DIMENSION D 
	ON CAST(EPIC_DTE as varchar) = cast(PAT_ENC_DATE_REAL as varchar)
inner join super_monthly.dbo.zc_disp_enc_type zc on pe.enc_type_c = zc.disp_enc_type_c
where zc.[NAME] not in ('ERRONEOUS CONVERSION', 'Canceled')
	and COALESCE(TRY_CONVERT(DATE, CONTACT_DATE, 120), CALENDAR_DT) is not null 
	and NOT EXISTS (
		SELECT BAD_VAL
		FROM SUPER_STAGING.DBO.SUPER_PROVIDER_BLACKLIST
		WHERE BAD_VAL = PROV_ID
		)
	AND NOT EXISTS (
		SELECT BAD_VAL
		FROM SUPER_STAGING.DBO.SUPER_ENCOUNTER_LOCATION_BLACKLIST
		WHERE BAD_VAL = CL.LOC_ID);

DROP sequence encnum;
