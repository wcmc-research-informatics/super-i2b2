/*
 * Adds indexes to the patient and encounter lookup tables
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
SELECT (
			NEXT VALUE FOR item_seq
			) AS ENCOUNTER_NUM
	, [true_mrn].acctnbr AS ENCOUNTER_IDE
	, 'ORMANAGER' AS [ENCOUNTER_IDE_SOURCE]
	, ADMDATE AS [CONTACT_DATE]
	, [true_mrn].[PROJECT_ID] AS [PROJECT_ID]
	, [true_mrn].mrn AS PATIENT_IDE
	, W.PATIENT_NUM AS PATIENT_NUM
	, 'ORMANAGER' AS [PATIENT_IDE_SOURCE]
	, 'A' AS [ENCOUNTER_IDE_STATUS]
	, PROVIDER_ID
	, LOCATION_CD
	, GETDATE() AS UPLOAD_DATE
	, GETDATE() AS IMPORT_DATE
	, 'ORMANAGER' AS SOURCESYSTEM_CD
FROM (
	SELECT DISTINCT acctnbr
		, procdate AS AdmDate
		, procdate AS DischDate
		, lcl_id AS mrn
		, im.global_id AS patient_ide
		, pref.PROJECT_ID
	FROM arch.dbo.ORCases orc
	INNER JOIN heroni2b2imdata.dbo.IM_MPI_MAPPING im
		ON try_convert(VARCHAR, orc.mrn) = im.lcl_id
	INNER JOIN HERONI2B2IMDATA.DBO.IM_PROJECT_PATIENTS IMPP
		ON IM.GLOBAL_ID = IMPP.GLOBAL_ID
	INNER JOIN heroni2b2pm.dbo.PREFIX_MAPPINGS pref
		ON pref.project_id = impp.project_id
	WHERE acctnbr IS NOT NULL
		AND try_convert(VARCHAR, orc.mrn) IS NOT NULL
		AND prefix = '<prefix>'
		AND im.lcl_site = 'ORMANAGER'
	) [true_mrn]
LEFT JOIN (
	SELECT pe2.pat_id
		, pe2.pat_enc_csn_id
		, pe2.contact_date
		, bill_num
		, department_id
		, visit_prov_id
	FROM super_monthly.dbo.pat_enc_2 pe2
	INNER JOIN super_monthly.dbo.pat_enc pe1
		ON pe1.pat_enc_csn_id = pe2.pat_enc_csn_id
	WHERE bill_num IS NOT NULL
		AND bill_num NOT LIKE 'R%'
	) [pat_enc]
	ON [true_mrn].acctnbr = bill_num
LEFT JOIN (
	SELECT *
	FROM encounter_mapping
	WHERE SOURCESYSTEM_CD = 'EPIC'
	) w
	ON encounter_ide = cast([pat_enc].pat_enc_csn_id AS VARCHAR)
WHERE [true_mrn].PATIENT_IDE IS NOT NULL
	AND w.patient_num IS NOT NULL;

drop sequence item_seq;