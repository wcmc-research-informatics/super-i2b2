/*
  
  The patient_mapping table maps the i2b2 patient_num to an encrypted number from
  the source_system,patient_ide (the e in ide is for encrypted.) Patient_ide_source
  contains the name of the source system. Patient_ide_status gives the status of the
  patient number in the source system, for example, if it is Active or Inactive or Deleted
  or Merged. 
  Copyright (c) 2014-2017 Weill Cornell Medical College
 */


USE [<prefix>I2B2demodata]

/*
* Create patient IDs for missing patient nums
* In total, this provides us with 34,694 patient numbers in patient_mapping,
* which corresponds to the number of unique MRNs found in the TumorRegistryData.
*/
--INSERT INTO [patient_mapping]
--SELECT [tstats].*
--FROM (
--	SELECT COALESCE([id].[PAT_ID], [trd].[Medical Record Number]) AS [PATIENT_IDE]
--		, 'TUMORREG' AS [patient_ide_source]
--		, [trd].[Medical Record Number] AS [nyp_mrn]
--		, 'A' as PATIENT_IDE_STATUS
--		, @pid AS [project_id]
--		, GETDATE() AS UPLOAD_DATE
--		, NULL AS UPDATE_DATE
--		, NULL AS DOWNLOAD_DATE
--		, GETDATE() AS IMPORT_DATE
--		, 'TUMORREGISTRY' AS SOURCESYSTEM_CD
--		, NULL AS upload_id
--	FROM (
--		SELECT DISTINCT [itrd].[Medical Record Number]
--		FROM [SUPER_ADHOC].[dbo].[TumorRegistryData_Testing] [itrd]
--		) [trd]
--	INNER JOIN (
--		SELECT DISTINCT [iid].[PAT_ID]
--			, [iid].[IDENTITY_ID]
--		FROM [SUPER_MONTHLY].[dbo].[IDENTITY_ID] [iid]
--		WHERE [iid].[IDENTITY_TYPE_ID] = 3
--		) [id]
--		ON [trd].[Medical Record Number] = [id].[IDENTITY_ID]
	
--	UNION
	
--	SELECT [trd].[Medical Record Number] AS [patient_ide]
--	    , 'TUMORREG' AS [patient_ide_source]
--		, [trd].[Medical Record Number] AS [nyp_mrn]
--		, 'Active' AS patient_ide_status
--		, @pid AS [project_id]
--		, GETDATE() AS UPLOAD_DATE
--		, NULL AS UPDATE_DATE
--		, NULL AS DOWNLOAD_DATE
--		, GETDATE() AS IMPORT_DATE
--		, 'TUMORREGISTRY' AS SOURCESYSTEM_CD
--		, NULL AS upload_id
--	FROM (
--		SELECT DISTINCT [itrd].[Medical Record Number]
--		FROM [SUPER_ADHOC].[dbo].[TumorRegistryData_Testing] [itrd]
--		) [trd]
--	WHERE NOT EXISTS (
--			SELECT DISTINCT [iii].[IDENTITY_ID]
--			FROM [SUPER_MONTHLY].[dbo].[IDENTITY_ID] [iii]
--			WHERE [iii].[IDENTITY_TYPE_ID] = 3
--				AND [iii].[IDENTITY_ID] = [trd].[Medical Record Number]
--			)
--	) [tstats]
--WHERE [tstats].[nyp_mrn] NOT IN (
--		SELECT DISTINCT [wpm].[nyp_mrn]
--		FROM [patient_mapping] [wpm]
--		WHERE sourcesystem_cd LIKE '%tumor%'
--		)
 

CREATE TABLE [#ec] (
	[MRN] VARCHAR(20)
	, [DATE] VARCHAR(20)
	, [ENCOUNTER_IDE] VARCHAR(20)
	, [PATIENT_IDE] VARCHAR(20)
	, [PATIENT_NUM] VARCHAR(20)
	)

INSERT INTO [#ec]
SELECT [estats].* FROM
(
--22439
SELECT distinct [trd].[Medical Record Number]
		,CAST([trd_date].[date] AS DATE) AS [formated_date]
		,ISNULL([pe].[pat_enc_csn_id],
					CASE
						WHEN CONVERT(BIGINT, CONVERT(VARBINARY(4), HASHBYTES('MD5', CAST([trd].[Medical Record Number] AS VARCHAR(20)) + CAST([trd].[Date Case Initiated] AS VARCHAR) + CAST([trd].[Medical Record Number] AS VARCHAR)) % 2000000)) < 0
						THEN CONVERT(BIGINT, CONVERT(VARBINARY(4), HASHBYTES('MD5', CAST([trd].[Medical Record Number] AS VARCHAR(20)) + CAST([trd].[Date Case Initiated] AS VARCHAR) + CAST([trd].[Medical Record Number] AS VARCHAR)) % 2000000))
						ELSE -1* CONVERT(BIGINT, CONVERT(VARBINARY(4), HASHBYTES('MD5', CAST([trd].[Medical Record Number] AS VARCHAR(20)) + CAST([trd].[Date Case Initiated] AS VARCHAR) + CAST([trd].[Medical Record Number] AS VARCHAR)) % 2000000))
				END) [encounter_ide]
		, [wpm].[patient_ide]
		, [wpm].[patient_num]
	FROM [SUPER_ADHOC].[dbo].[TumorRegistryData] [trd]
	INNER JOIN (
		SELECT DISTINCT [itrd].[Date Case Initiated] AS [org_date]
			, CASE 
				WHEN LEN([itrd].[Date Case Initiated]) = 4
					THEN CONCAT (
							[itrd].[Date Case Initiated]
							, '0101'
							)
				WHEN LEN([itrd].[Date Case Initiated]) = 6
					THEN CONCAT (
							[itrd].[Date Case Initiated]
							, '01'
							)
				WHEN LEN([itrd].[Date Case Initiated]) = 8
					THEN [itrd].[Date Case Initiated]
				END [date]
		FROM [SUPER_ADHOC].[dbo].[TumorRegistryData] [itrd]
		) [trd_date]
		ON [trd].[Date Case Initiated] = [trd_date].[org_date]
	INNER JOIN (
		SELECT global_id
			, lcl_id
			, lcl_site
		FROM [heroni2b2imdata].[dbo].[IM_MPI_MAPPING]
		WHERE LCL_SITE = 'TUMORREGISTRY'
		) imm
		ON [Medical Record Number] = lcl_id
	INNER JOIN [patient_mapping] [wpm]
		ON wpm.patient_num = imm.global_id
	LEFT JOIN (
		SELECT [ipe].[PAT_ID]
			, MIN([ipe].[PAT_ENC_CSN_ID]) AS [PAT_ENC_CSN_ID]
			, [ipe].[CONTACT_DATE]
		FROM [SUPER_MONTHLY].[dbo].[PAT_ENC] [ipe]
		GROUP BY [ipe].[PAT_ID]
			, [ipe].[CONTACT_DATE]
		) [pe]
		ON [wpm].[patient_ide] = [pe].[PAT_ID]
			AND TRY_CAST([trd_date].[date] AS DATE) = [pe].[CONTACT_DATE]
	) [estats]
WHERE CAST([estats].[encounter_ide] AS VARCHAR) NOT IN (
		SELECT DISTINCT [encounter_ide]
		FROM [encounter_mapping]
		WHERE [sourcesystem_cd] LIKE '%tumor%'
		);

/*
* Grab encounter IDs
* This is dates that match up with encounters in PAT_ENC.
*/
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

INSERT INTO [encounter_mapping] (
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
	, upload_date
	, import_date
	, sourcesystem_cd
	)
SELECT (
		NEXT VALUE FOR item_seq
		) AS ENCOUNTER_NUM
	, [#ec].[encounter_ide] AS [encounter_ide]
	, 'TUMORREG' AS [encounter_ide_source]
	, [#ec].[DATE] AS [contact_date]
	, pref.[PROJECT_ID] AS project_id
	, [#ec].[patient_ide] AS patient_ide
	, [#ec].[patient_num] AS patient_num
	, 'TUMORREG' AS patient_ide_source
	, 'A' AS encounter_ide_status
	, '@' AS [location_cd]
	, '@' AS [provider_id]
	, GETDATE() AS UPLOAD_DATE
	, GETDATE() AS IMPORT_DATE
	, 'TUMORREGISTRY' AS SOURCESYSTEM_CD
FROM [#ec]
INNER JOIN HERONI2B2IMDATA.DBO.IM_MPI_MAPPING IM
	ON mrn = lcl_id
INNER JOIN HERONI2B2IMDATA.DBO.IM_PROJECT_PATIENTS IMPP
	ON IM.GLOBAL_ID = IMPP.GLOBAL_ID
INNER JOIN heroni2b2pm.dbo.PREFIX_MAPPINGS pref
	ON pref.project_id = impp.project_id
WHERE prefix = '<prefix>'
	AND im.lcl_site = 'TUMORREGISTRY';



DROP TABLE [#ec];
DROP SEQUENCE ITEM_SEQ;