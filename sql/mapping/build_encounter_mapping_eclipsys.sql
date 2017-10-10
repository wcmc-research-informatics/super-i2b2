/*
 * Populates encounter mapping table, generating the i2b2 patient number with a sequence.
 * Only inserts Eclipsys data.
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
	, update_date
	, download_date
	, import_date
	, sourcesystem_cd
	)
SELECT (
		NEXT VALUE FOR item_seq
		) AS ENCOUNTER_NUM
	, [AccountNUM] AS ENCOUNTER_IDE
	, 'ECLIPSYS' AS [ENCOUNTER_IDE_SOURCE]
	, ISNULL([ADMITDTM], '1776-07-04') [CONTACT_DATE]
	, [PROJECT_ID]
	, [mrn] AS PATIENT_IDE
	, PM.PATIENT_NUM AS PATIENT_NUM
	, 'ECLIPSYS' AS [PATIENT_IDE_SOURCE]
	, [VISITSTATUS] AS [ENCOUNTER_IDE_STATUS]
	, '@' AS PROVIDER_ID
	, CurrentLocationGUID AS LOCATION_CD
	, createdwhen AS UPDATE_DATE
	, (SELECT [create_date] FROM Jupiter.sys.tables where name='CV3ClientVisit_East') [download_date]
	, GETDATE() AS IMPORT_DATE
	, 'ECLIPSYS' AS SOURCESYSTEM_CD
FROM (
	SELECT DISTINCT ClientIDCode as [MRN]
		, replace(substring(VisitIDCode, patindex('%[^0]%',VisitIDCode),len(VisitIDCode)), ' ', '') as AccountNUM
		, cast([ADMITDTM] AS DATE) [admitdtm]
		, cve.VisitStatus
		, cve.CurrentLocationGUID
		, cve.CreatedWhen
	FROM Jupiter.JupiterSCM.CV3ClientVisit_East cve
	join Jupiter.JupiterSCM.CV3ClientID_East cie on cie.ClientGUID = cve.ClientGUID
	   and cie.TypeCode = 'Hospital MRN1' and IDStatus = 'ACT'
	) v
INNER JOIN (
	SELECT DISTINCT patient_ide
		, patient_num
		, lcl_id
		, lcl_site
		, pref.project_id
	FROM PATIENT_MAPPING
	INNER JOIN heroni2b2imdata.dbo.IM_MPI_MAPPING im
		ON patient_num = im.global_id
	INNER JOIN HERONI2B2IMDATA.DBO.IM_PROJECT_PATIENTS IMPP
		ON IM.GLOBAL_ID = IMPP.GLOBAL_ID
	INNER JOIN heroni2b2pm.dbo.PREFIX_MAPPINGS pref
		ON pref.project_id = impp.project_id
	WHERE LCL_SITE = 'ECLIPSYS'
		AND patient_ide_source = 'HIVE'
		AND prefix = '<prefix>'
	) pm
	ON v.[mrn] = pm.LCL_ID;



DROP sequence item_seq;