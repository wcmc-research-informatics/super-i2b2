/**
 *
 * Creates modifiers about inpatient diagnosis encounters held at NYP
 *  Copyright (c) 2014-2017 Weill Cornell Medical College
 */

use <prefix>i2b2demodata;

insert into MODIFIER_DIMENSION
	(modifier_path, modifier_cd, name_char, update_date, download_date, import_date, sourcesystem_cd)
select distinct C_FULLNAME
		, c_basecode
		, c_name
		, update_date
		, download_date
		, import_date
		, sourcesystem_cd
from <prefix>i2b2metadata.dbo.custom_meta
WHERE sourcesystem_cd = 'COMPURECORD'
AND C_BASECODE IS NOT NULL
AND C_VISUALATTRIBUTES IN ('RA','DA')
UNION
select distinct C_FULLNAME
		, c_basecode
		, c_name
		, update_date
		, download_date
		, import_date
		, sourcesystem_cd
from <prefix>i2b2metadata.dbo.i2b2
WHERE C_BASECODE like 'CPT:COMPU%'
AND C_VISUALATTRIBUTES IN ('RA','DA')
UNION
select distinct C_FULLNAME
		, c_basecode
		, c_name
		, update_date
		, download_date
		, import_date
		, sourcesystem_cd
from <prefix>i2b2metadata.dbo.icd10_icd9
WHERE C_BASECODE like 'ICD9:COMPU%'
AND C_VISUALATTRIBUTES IN ('RA','DA');