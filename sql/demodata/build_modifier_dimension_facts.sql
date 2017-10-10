/* 
 *  Populates the MODIFIER_DIMENSION table with all modifiers currently
 *  in use in the ontology.
 *
 *  Copyright (c) 2014-2017 Weill Cornell Medical College
 */

use <prefix>i2b2demodata;

INSERT INTO modifier_dimension
	(modifier_path, modifier_cd, name_char, update_date, download_date, import_date, sourcesystem_cd)
SELECT DISTINCT c_fullname
	, c_basecode
	, c_name
	, update_date
	, download_date
	, import_date
	, sourcesystem_cd
FROM <prefix>i2b2metadata.dbo.icd10_icd9
WHERE c_visualattributes = 'RA'
union
SELECT DISTINCT c_fullname
	, c_basecode
	, c_name
	, update_date
	, download_date
	, import_date
	, sourcesystem_cd
FROM <prefix>i2b2metadata.dbo.i2b2
WHERE c_visualattributes = 'RA'
ORDER BY C_FULLNAME;

-- One more row to represent rows with modifier_cd values of '@'
INSERT INTO modifier_dimension
	(modifier_path, modifier_cd, name_char, update_date, download_date, import_date, sourcesystem_cd)
values ('', '@', 'No modifier', getDate(), getDate(), getDate(), '')