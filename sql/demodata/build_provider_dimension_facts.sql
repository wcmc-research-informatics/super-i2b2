
/*
 * Populates the provider dimension table with WCM providers from Clarity.
 * Copyright (c) 2014-2017 Weill Cornell Medical College
 */

use <prefix>i2b2demodata;

insert into PROVIDER_DIMENSION
	(provider_id, provider_path, name_char, update_date, download_date, import_date, sourcesystem_cd)
select distinct c_basecode
     , c_fullname as provider_path
	 , c_name
	 , UPDATE_DATE
	 , DOWNLOAD_DATE
	 , getDate()
	 , sourcesystem_cd
from <prefix>i2b2metadata.dbo.i2b2
where c_fullname like '\i2b2\Provi%' and 
      c_basecode is not null;