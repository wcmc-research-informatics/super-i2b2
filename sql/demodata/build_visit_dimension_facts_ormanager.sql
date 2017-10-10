/* 
   Integrates the encounters from OR Manager with encounters stored in I2B2.
 
   Copyright (c) 2014-2017 Weill Cornell Medical College
 */

use <prefix>i2b2demodata;

-- Go against ORManager and associate new encounters with our patients in I2B2. acct_no from ORManager
-- is used as the encounter_ide. We first insert encounters for patients which only exist in ORManager
insert into visit_dimension(
        encounter_num
	  , patient_num 
	  , active_status_cd
	  , start_date
	  , end_date
	  , inout_cd
	  , location_cd 
	  , location_path
	  , length_of_stay 
	  , update_date
	  , download_date 
	  , import_date 
	  , sourcesystem_cd
	  , enc_type_path)
select   encounter_num
       , patient_num
	   , 'U*B' as active_status_cd
	   , procdate as start_date
	   , null as end_date
	   , 'INPATIENT'	-- all ORManager data is inpatient data
	   , location_cd
	   , '@' as location_path
	   , null -- appointment length is calculated in minutes
	   , getDate()
	   , getDate()
	   , getDate()
	   , 'ORMANAGER'
	   , '@' as enc_type_path
from arch.dbo.orcases o
left outer join jupiter.compurecord.demographics crd on o.acctnbr = crd.ACCOUNTNUMBER
inner join encounter_mapping e on e.encounter_ide = crd.accountnumber
where procdate is not null and SOURCESYSTEM_CD = 'ORMANAGER';
