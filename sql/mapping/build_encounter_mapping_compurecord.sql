/*
 * Populates encounter mapping for compurecord
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

/*
 * Map BILL_NUM to ACCOUNT values via PAT_ENC_2
 */
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
	, update_date
	, download_date
	, import_date
	, sourcesystem_cd
	)
SELECT DISTINCT
		  ENCOUNTER_NUM
		, ACCOUNTNUMBER AS [ENCOUNTER_IDE]
		, 'COMPURECORD' AS [ENCOUNTER_IDE_SOURCE]
		, CR.[CONTACT_DATE]
		, PREF.PROJECT_ID
		, MEDICALRECORDNUMBER AS PATIENT_IDE
		, PATIENT_NUM
		, 'COMPURECORD' AS [PATIENT_IDE_SOURCE]
		, 'A' as ENCOUNTER_IDE_STATUS
		, PROVIDER_ID
		, LOCATION_CD
		, (SELECT [create_date] FROM jupiter.sys.tables where name='Demographics') UPDATE_DATE
		, (SELECT [create_date] FROM jupiter.sys.tables where name='Demographics') AS DOWNLOAD_DATE
		, GETDATE() AS IMPORT_DATE
		, 'COMPURECORD' AS SOURCESYSTEM_CD
FROM (select distinct accountnumber
			, SERVICEDATE AS [CONTACT_DATE]
			, MEDICALRECORDNUMBER 
	  FROM [Jupiter].[Compurecord].[Demographics]
	  WHERE ACCOUNTNUMBER IS NOT NULL) cr
INNER JOIN (SELECT PAT_ENC_CSN_ID, CONTACT_DATE, BILL_NUM FROM SUPER_MONTHLY.DBO.PAT_ENC_2 WHERE BILL_NUM IS NOT NULL) [PE2] 
	ON CR.ACCOUNTNUMBER = PE2.BILL_NUM
	and cr.CONTACT_DATE = pe2.contact_Date
INNER JOIN ENCOUNTER_MAPPING [EM] 
	ON [EM].[ENCOUNTER_IDE] = [PE2].[PAT_ENC_CSN_ID]
	AND SOURCESYSTEM_CD = 'EPIC'
INNER JOIN HERONI2B2IMDATA.DBO.IM_PROJECT_PATIENTS IMPP
	ON [EM].[PATIENT_NUM] = IMPP.GLOBAL_ID
INNER JOIN heroni2b2pm.dbo.PREFIX_MAPPINGS pref
	ON pref.project_id = impp.project_id
WHERE   prefix = '<prefix>';

/* CompuRecord encounters not in EPIC */
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
	, update_date
	, download_date
	, import_date
	, sourcesystem_cd
	)
SELECT ( next value FOR item_seq )     AS ENCOUNTER_NUM 
       ,accountnumber                  AS [ENCOUNTER_IDE] 
       ,'COMPURECORD'                  AS [ENCOUNTER_IDE_SOURCE] 
       ,servicedate 
       ,PREF.project_id 
       ,medicalrecordnumber            AS PATIENT_IDE 
       ,IM3.global_id                  AS PATIENT_NUM 
       ,'COMPURECORD'                  AS [PATIENT_IDE_SOURCE] 
       ,'A'                            AS ENCOUNTER_IDE_STATUS 
       ,'@'                            PROVIDER_ID 
       ,'@'                            LOCATION_CD 
       ,(SELECT [create_date] 
         FROM   jupiter.sys.tables 
         WHERE  NAME = 'Demographics') UPDATE_DATE 
       ,(SELECT [create_date] 
         FROM   jupiter.sys.tables 
         WHERE  NAME = 'Demographics') AS DOWNLOAD_DATE 
       ,Getdate()                      AS IMPORT_DATE 
       ,'COMPURECORD'                  AS SOURCESYSTEM_CD 
FROM   (SELECT distinct accountnumber
			, SERVICEDATE 
			, MEDICALRECORDNUMBER  
        FROM   jupiter.compurecord.demographics 
        WHERE  medicalrecordnumber NOT IN (SELECT DISTINCT medicalrecordnumber 
                                           FROM 
               [Jupiter].[Compurecord].[demographics] cr 
               INNER JOIN (SELECT pat_enc_csn_id 
                                  ,contact_date 
                                  ,bill_num 
                           FROM 
               super_monthly.dbo.pat_enc_2 
                           WHERE  bill_num IS NOT NULL) 
                          [PE2] 
                       ON CR.accountnumber = PE2.bill_num 
                          AND servicedate = pe2.contact_date 
                                           WHERE  accountnumber IS NOT NULL) 
               AND accountnumber IS NOT NULL) [cr] 
       INNER JOIN heroni2b2imdata.dbo.im_mpi_mapping [IM3] 
               ON substring(cr.MEDICALRECORDNUMBER,patindex('%[^0]%',cr.MEDICALRECORDNUMBER),15) = IM3.lcl_id 
			   AND SOURCESYSTEM_CD = 'COMPURECORD'
       INNER JOIN heroni2b2imdata.dbo.im_project_patients IMPP 
               ON IM3.global_id = IMPP.global_id 
       INNER JOIN heroni2b2pm.dbo.prefix_mappings pref 
               ON pref.project_id = impp.project_id 
WHERE  prefix = '<prefix>'; 

drop sequence item_seq;