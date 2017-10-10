/*
* Create Tumor Registry Observation facts.
* Copyright (c) 2014-2017 Weill Cornell Medical College
 */

USE [<prefix>I2B2demodata];

CREATE TABLE  [#icdodata]
(
    [mrn] VARCHAR(20)
   ,[patient_num] VARCHAR(20)
   ,[date] VARCHAR(20)
   ,[encounter_num] VARCHAR(20)
   ,[data] VARCHAR(20)
   ,[column_name] VARCHAR(50)
   ,[C_BASECODE] VARCHAR(100)
)
INSERT INTO [#icdodata]

SELECT [unpvt_data].[mrn]
      ,[wpm].[patient_num]
      ,[unpvt_data].[date]
      ,[wem].[encounter_num]
      ,[data]
      ,[column_name]
      ,CASE
            WHEN [column_name] = 'Morph--Type&Behav ICD-O-3' THEN 'ICD-O-3:Morph|Hist|' + LEFT([data],4) + '/' + RIGHT([data],1)
            WHEN [column_name] = 'Behavior Code ICD-O-3' THEN 'ICD-O-3:Morph|Behav|' + [data]
            WHEN [column_name] = 'Grade' THEN 'ICD-O-3:Morph|Grade|' + [data]
            WHEN [column_name] = 'Primary Site' THEN 'ICD-O-3:Topo|' + [data]
       END [C_BASECODE]
FROM
(
    SELECT CAST([Medical Record Number] AS VARCHAR) AS [mrn]
          ,CASE 
                WHEN LEN([Date Case Initiated]) = 4 THEN CAST(CONCAT([Date Case Initiated],'0101') AS VARCHAR)
                WHEN LEN([Date Case Initiated]) = 6 THEN CAST(CONCAT([Date Case Initiated],'01') AS VARCHAR)
                WHEN LEN([Date Case Initiated]) = 8 THEN CAST([Date Case Initiated] AS VARCHAR)
           END [date]
          ,CAST([Morph--Type&Behav ICD-O-3] AS VARCHAR) AS [Morph--Type&Behav ICD-O-3]
          ,CAST([Behavior Code ICD-O-3] AS VARCHAR) AS [Behavior Code ICD-O-3]
          ,CAST([Histologic Type ICD-O-3] AS VARCHAR) AS [Histology]
          ,CAST([Grade] AS VARCHAR) AS [Grade]
          ,CAST([Primary Site] AS VARCHAR) AS [Primary Site]
          ,[trd].[Date Case Initiated] AS [enc_date]
    FROM [super_adhoc].[dbo].[tumorregistrydata] [trd]
) [data_table]
UNPIVOT
(
    [data] FOR [column_name] IN
        (
            [Morph--Type&Behav ICD-O-3]
           ,[Behavior Code ICD-O-3]
           ,[Grade]
           ,[Primary Site]
        )
) AS [unpvt_data]
INNER JOIN (SELECT DISTINCT PATIENT_NUM, PATIENT_IDE, LCL_ID  AS NYP_MRN FROM heroni2b2imdata.DBO.IM_MPI_MAPPING 
			INNER JOIN PATIENT_MAPPING PM ON PATIENT_NUM = GLOBAL_ID 
			WHERE LCL_SITE = 'TUMORREGISTRY' and PM.SOURCESYSTEM_CD = 'EPIC' ) WPM
	  ON [unpvt_data].[MRN] = WPM.NYP_MRN 
--INNER JOIN [patient_mapping] [wpm]
--    ON [unpvt_data].[mrn] = [wpm].[nyp_mrn]
--		AND [wpm].[sourcesystem_cd] like '%tumor%'
LEFT JOIN
(
    SELECT [PAT_ID]
          ,MIN([PAT_ENC_CSN_ID]) AS [PAT_ENC_CSN_ID]
          ,[CONTACT_DATE]
    FROM [SUPER_MONTHLY].[dbo].[PAT_ENC]
    GROUP BY [PAT_ID],[CONTACT_DATE]
) [pe]
    ON [wpm].[patient_ide] = [pe].[PAT_ID]
        AND TRY_CAST([unpvt_data].[date] AS DATE) = [pe].[CONTACT_DATE]
INNER JOIN [encounter_mapping] [wem]
    ON ISNULL(cast([pe].[PAT_ENC_CSN_ID] as varchar),
        CASE
            WHEN CONVERT(BIGINT, CONVERT(VARBINARY(4), HASHBYTES('MD5', CAST([unpvt_data].[mrn] AS VARCHAR(20)) + CAST([unpvt_data].[enc_date] AS VARCHAR) + CAST([unpvt_data].[mrn] AS VARCHAR)) % 2000000)) < 0
            THEN CONVERT(BIGINT, CONVERT(VARBINARY(4), HASHBYTES('MD5', CAST([unpvt_data].[mrn] AS VARCHAR(20)) + CAST([unpvt_data].[enc_date] AS VARCHAR) + CAST([unpvt_data].[mrn] AS VARCHAR)) % 2000000))
            ELSE -1* CONVERT(BIGINT, CONVERT(VARBINARY(4), HASHBYTES('MD5', CAST([unpvt_data].[mrn] AS VARCHAR(20)) + CAST([unpvt_data].[enc_date] AS VARCHAR) + CAST([unpvt_data].[mrn] AS VARCHAR)) % 2000000))
       END
       ) = [wem].[encounter_ide]
		AND [wem].[sourcesystem_cd] like '%tumor%'
		and [wpm].[patient_num] = [wem].[patient_num]

INSERT INTO [observation_fact]
(
	  encounter_num
	, patient_num
	, concept_cd
	, provider_id
	, start_date
	, modifier_cd
	, instance_num
	, valtype_cd
	, tval_char
	, nval_num
	, valueflag_cd
	, units_cd
	, location_cd
	, update_date
	, download_date
	, import_date
	, sourcesystem_cd
	)
SELECT
    [#icdodata].[encounter_num] AS [ENCOUNTER_NUM]
   ,[#icdodata].[patient_num] AS [PATIENT_NUM]
   ,[#icdodata].[C_BASECODE] AS [CONCEPT_CD]
   ,'@' AS [PROVIDER_ID]
   ,[#icdodata].[date] AS [START_DATE]
   ,'@' AS [MODIFIER_CD]
   ,'1' AS [INSTANCE_NUM]
   ,CASE
        WHEN TRY_CONVERT(FLOAT,[#icdodata].[data]) IS NOT NULL THEN 'N'
        ELSE 'T'
    END [VALTYPE_CD]
   ,CASE
        WHEN TRY_CONVERT(FLOAT,[#icdodata].[data]) IS NOT NULL THEN 'E'
        ELSE LEFT([#icdodata].[data],255)
    END [TVAL_CHAR]
   ,TRY_CONVERT(FLOAT,[#icdodata].[data]) AS [NVAL_NUM]
   ,'@' AS [VALUEFLAG_CD]
   ,'' AS [UNITS_CD]
   ,'@' AS [LOCATION_CD]
   ,GETDATE() AS [UPDATE_DATE]
   ,GETDATE() AS [DOWNLOAD_DATE]
   ,GETDATE() AS [IMPORT_DATE]
   ,'TUMORREGISTRY' AS [SOURCESYSTEM_CD]
FROM [#icdodata]


DROP TABLE [#icdodata]