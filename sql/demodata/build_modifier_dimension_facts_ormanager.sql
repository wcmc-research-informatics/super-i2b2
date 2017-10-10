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
where c_visualattributes = 'RA' and sourcesystem_cd = 'ORMANAGER'
and c_SYNONYM_CD = 'N';


