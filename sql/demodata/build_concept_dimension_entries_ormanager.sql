/*
 * Adds metadata entries about or manager observations to the concept_dimension
 * master list, to enable queries.
 *  Copyright (c) 2014-2017 Weill Cornell Medical College
 */

use <prefix>i2b2demodata;

insert into concept_dimension
	(concept_path, concept_cd, name_char, update_date, import_date, sourcesystem_Cd)
select c_fullname, c_basecode, c_name, getDate(), getDate(), 'ORMANAGER' from <prefix>i2b2metadata.dbo.custom_meta where sourcesystem_cd = 'ORMANAGER' 
and c_facttablecolumn = 'concept_cd' and c_basecode is not null
and c_synonym_cd = 'N'; -- restrict to only the 2 leaf nodes