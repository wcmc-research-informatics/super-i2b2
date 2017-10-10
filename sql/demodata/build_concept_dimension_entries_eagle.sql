/*
  Inserts ICD9CM and ICD10PCS concepts from the metadata into concept_dimension
  This also grabs any leftover EAGLE specific ontologies.

  Copyright (c) 2014-2017 Weill Cornell Medical College
 */

use <prefix>i2b2demodata;

insert into concept_dimension
	(concept_path, concept_cd, name_char, update_date, import_date, sourcesystem_Cd)
select c_fullname, c_basecode, c_name, getDate(), getDate(), 'EAGLE'
from <prefix>i2b2metadata.dbo.icd10_icd9 where c_fullname like '\i2b2\(00-99.99) Pro~c9a4%'
and c_basecode <> '(null)'
and c_synonym_cd = 'N';

insert into concept_dimension
	(concept_path, concept_cd, name_char, update_date, import_date, sourcesystem_Cd)
select c_fullname, c_basecode, c_name, getDate(), getDate(), 'EAGLE'
from <prefix>i2b2metadata.dbo.icd10_icd9 where c_fullname like '\i2b2\ICD10PCS_2015AA%'
and c_basecode <> '(null)'
and c_synonym_cd = 'N'; 

-- Mostly demographics and encounters ontologies
insert into concept_dimension
	(concept_path, concept_cd, name_char, update_date, import_date, sourcesystem_Cd)
select c_fullname, c_basecode, c_name, getDate(), getDate(), sourcesystem_cd
from <prefix>i2b2metadata.dbo.i2b2 where sourcesystem_cd = 'EAGLE'
and nullif(c_basecode, '') is not null
and c_synonym_cd = 'N'; 
