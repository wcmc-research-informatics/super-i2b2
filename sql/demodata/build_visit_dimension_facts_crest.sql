/* 
   Populates the visit dimension table with all encounters from CREST.
   Copyright (c) 2014-2017 Weill Cornell Medical College
 */

use <prefix>i2b2demodata;

BEGIN TRANSACTION;

-- Add all encounters from EPIC
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
select   e.encounter_num
       , patient_num
	   , 'U*B' as active_status_cd
	   , [start_date]
	   , end_date
	   , 'OUTPATIENT'	-- all epic data is outpatient data
	   , location_cd
	   , '@' as location_path
	   , datediff(dd,[start_date],end_date)
	   , getDate()
	   , getDate()
	   , getDate()
	   , 'CREST'
	   , '@' as enc_type_path
from SUPER_DAILY.DBO.CREST_SUBJECTS CS
inner join ( select encounter_num, patient_num, encounter_ide, contact_Date, provider_id, location_cd, sourcesystem_Cd from encounter_mapping where SOURCESYSTEM_CD = 'CREST' )  e on e.encounter_ide = CONVERT(VARCHAR(1000),CONVERT(VARBINARY(8),SYSPATIENTSTUDYID),1)
;

COMMIT TRANSACTION;


