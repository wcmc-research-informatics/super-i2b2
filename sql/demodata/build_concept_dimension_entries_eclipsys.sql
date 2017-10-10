/*
  Copies concepts from the metadata into concept dimension for Eclipsys metadata elements
    Copyright (c) 2014-2017 Weill Cornell Medical College
 */

use <prefix>i2b2demodata;

insert into concept_dimension
	(concept_path, concept_cd, name_char, update_date, import_date, sourcesystem_Cd)
select c_fullname, c_basecode, c_name, getDate(), getDate(), 'ECLIPSYS'
from <prefix>i2b2metadata.dbo.i2b2 where sourcesystem_cd = 'ECLIPSYS'
and nullif(c_basecode, '') is not null
and c_synonym_cd = 'N';

