/*
 * Adds metadata entries about Profiler specimens to the concept_dimension
 * master list, to enable queries.
 *   Copyright (c) 2014-2017 Weill Cornell Medical College
 */

use <prefix>i2b2demodata;

-------------------------------- Profiler Specimen ------------------------------------

insert into concept_dimension
	(concept_path, concept_cd, name_char, update_date, import_date, sourcesystem_Cd)
select c_fullname,c_basecode,c_name,getdate(),getdate(),'EPIC' 
  from <prefix>i2b2metadata.dbo.custom_meta where c_basecode like '%SPEC:%' 
  and c_synonym_cd = 'N';