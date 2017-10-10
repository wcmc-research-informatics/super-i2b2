/*
	Create mapping tables based on CREST_SUBJECTS table
	Copyright (c) 2014-2017 Weill Cornell Medical College
*/

USE <prefix>i2b2demodata;

BEGIN TRANSACTION;

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

-- Can populate MAPPING tables with CREST data for any RDR.
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
	, provider_id
	, location_cd
	, upload_date
	, import_date
	, sourcesystem_cd
	)
SELECT (
		NEXT VALUE FOR item_seq
		) AS ENCOUNTER_NUM
	, CONVERT(VARCHAR(1000), CONVERT(VARBINARY(8), (SYSPATIENTSTUDYID)), 1) AS ENCOUNTER_IDE
	, 'CREST' AS ENCOUNTER_IDE_SOURCE
	, isnull([START_DATE], '1776-07-04') AS CONTACT_DATE
	, [IM].[PROJECT_ID] AS PROJECT_ID
	, lcl_id AS PATIENT_IDE
	, PATIENT_NUM
	, 'CREST' AS PATIENT_IDE_SOURCE
	, 'A' AS ENCOUNTER_IDE_STATUS
	, UPPER(PI_CWID) AS PROVIDER_ID
	, '@' AS LOCATION_CD
	, GETDATE() AS UPLOAD_DATE
	, GETDATE() AS IMPORT_DATE
	, 'CREST' AS SOURCESYSTEM_CD
FROM SUPER_DAILY.DBO.CREST_SUBJECTS CS
INNER JOIN SUPER_DAILY.DBO.CREST_STUDIES CST
	ON CST.PROTOCOL_NUMBER = CS.PROTOCOL_NUMBER
LEFT JOIN SUPER_MONTHLY.DBO.CLARITY_SER SER
	ON [USER_ID] = PI_CWID
INNER JOIN (
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
		AND lcl_site = 'CREST'
	) im
	ON im.LCL_ID = NYPH_MRN
INNER JOIN (
	SELECT DISTINCT pat_id
		, min(identity_id) AS nyph_mrn
	FROM SUPER_MONTHLY.DBO.IDENTITY_ID
	WHERE IDENTITY_TYPE_ID = 3
	GROUP BY PAT_ID
	) II
	ON II.NYPH_MRN = CS.NYPH_MRN
INNER JOIN (
	SELECT DISTINCT patient_ide
		, patient_num
	FROM PATIENT_MAPPING
	WHERE PATIENT_IDE_SOURCE = 'WCM'
	) WPM
	ON GLOBAL_ID = PATIENT_NUM;

DROP sequence item_Seq;

COMMIT TRANSACTION;
