/**
 * 
 * Creates a mapping of hierarchical paths to concept codes for Demographics.
 * 
 * Copyright (c) 2014-2017 Weill Cornell Medical College
 */

use <prefix>i2b2demodata;

insert into concept_dimension
	(concept_path, concept_cd, name_char, update_date, import_date, sourcesystem_Cd)
select distinct c_fullname
	,  c_basecode
	,  c_name
	,  getDate()
	,  getDate()
	,  sourcesystem_cd
from <prefix>i2b2metadata.dbo.i2b2
WHERE (C_FULLNAME NOT LIKE '\i2b2\Medications%'
	and c_fullname not like '\i2b2\Providers%'
	and c_fullname not like '\i2b2\Encounters\Location%')
and nullif(c_basecode, '') is not null
and c_synonym_cd = 'N' and c_visualattributes in ('LA', 'FA', 'CA');

----------------------------------- Diagnoses --------------------------------------------

INSERT INTO concept_dimension
	(concept_path, concept_cd, name_char, update_date, import_date, sourcesystem_Cd)
SELECT c_fullname
	, 'ICD9:' + PLAIN_CODE AS concept_cd
	, c_name
	, getdate()
	, getdate()
	, sourcesystem_cd
FROM <prefix>i2b2metadata.dbo.icd10_icd9
WHERE c_fullname LIKE '\i2b2\Diagnoses\%'
and c_synonym_cd = 'N' and PLAIN_CODE is not null;

INSERT INTO concept_dimension
	(concept_path, concept_cd, name_char, update_date, import_date, sourcesystem_Cd)
SELECT c_Fullname
	, c_basecode
	, c_name
	, getDate()
	, getDate()
	, 'EPIC' as sourcesystem_cd
FROM <prefix>i2b2metadata.dbo.icd10_icd9
WHERE c_fullname LIKE '\i2b2\ICD10CM_2015AA\%'
and nullif(c_basecode, '') is not null
and c_synonym_cd = 'N';


----------------------------------- Medications --------------------------------------------

insert into concept_dimension
	(concept_path, concept_cd, name_char, update_date, import_date, sourcesystem_Cd)
select c_fullname
	,  c_basecode
	,  c_name
	,  getDate()
	,  getDate()
	,  sourcesystem_cd
from <prefix>i2b2metadata.dbo.i2b2
WHERE C_FULLNAME LIKE '\i2b2\Medications%'
and nullif(c_basecode, '') is not null
and c_synonym_cd = 'N';


----------------------------------- NLP --------------------------------------------

insert into concept_dimension
	(concept_path, concept_cd, name_char, update_date, import_date, sourcesystem_Cd)
select c_fullname
	,  c_basecode
	,  c_name
	,  getDate()
	,  getDate()
	,  'EPIC' as sourcesystem_cd
from <prefix>i2b2metadata.dbo.custom_meta
WHERE C_FULLNAME LIKE '\i2b2\NLP%'
and nullif(c_basecode, '') is not null
and c_synonym_cd = 'N';


