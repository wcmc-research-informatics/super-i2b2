/*
 * Inserts tumor registry metadata information from CUSTOM_META into
 * CONCEPT_DIMENSION
 */
use <prefix>i2b2demodata;

INSERT INTO [CONCEPT_DIMENSION]
	(concept_path, concept_cd, name_char, update_date, import_date, sourcesystem_Cd)
SELECT [cm].[C_FULLNAME] AS [CONCEPT_PATH]
      ,[cm].[C_BASECODE] AS [CONCEPT_CD]
      ,[cm].[C_NAME] AS [NAME_CHAR]
      ,GETDATE() AS [UPDATE_DATE]
      ,GETDATE() AS [IMPORT_DATE]
      ,'TUMORREGISTRY' AS [SOURCESYSTEM_CD]
FROM [<prefix>i2b2metadata].[dbo].[custom_meta] [cm]
WHERE [cm].[C_FULLNAME] LIKE '\i2b2\TumorRegistry%'
and nullif(c_basecode, '') is not null;