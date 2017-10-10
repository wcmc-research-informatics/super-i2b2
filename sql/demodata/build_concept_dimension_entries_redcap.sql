/* 
  Copies concepts from REDCap metadata into the dimension tables
  to enable queries from the web client
  
  Copyright (c) 2014-2017 Weill Cornell Medical College
 */

use <prefix>i2b2demodata;

INSERT INTO [CONCEPT_DIMENSION]
	(concept_path, concept_cd, name_char, update_date, import_date, sourcesystem_Cd)
select c_fullname
	  , c_basecode
	  , c_name
      ,GETDATE() AS [UPDATE_DATE]
      ,GETDATE() AS [IMPORT_DATE]
      ,'REDCAP' AS [SOURCESYSTEM_CD]
FROM [<prefix>i2b2metadata].[dbo].[custom_meta] [cm]
WHERE [cm].[C_FULLNAME] LIKE '\i2b2\REDCap%'
and nullif(c_basecode, '') is not null
and c_synonym_cd = 'N';

