/* 
   Integrates the encounters from CompuRecord with encounters stored in I2B2.
 
   Copyright (c) 2014-2017 Weill Cornell Medical College
 */
use <prefix>i2b2demodata;

/*
 * Insert all CompuRecord visits into VISIT_DIMENSION
 */
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
	   , isnull(crdem.PROCEDURESTART, crdem.PROCEDURESTART) as start_date
	   , ISNULL(crdem.PROCEDUREEND, crdem.PROCEDUREEND) as end_date
	   , CASE WHEN NUMVALUE IN ('5031', '10048') then 'INPATIENT'
			  when numvalue in ('10235') then 'OUTPATIENT' END
	   , location_cd
	   , '@' as location_path
		  -- appointment length is calculated in minutes
	   , datediff( minute, isnull(crdem.PROCEDURESTART, crdem.PROCEDURESTART), ISNULL(crdem.PROCEDUREEND, crdem.PROCEDUREEND) )
	   , getDate()
	   , getDate()
	   , getDate()
	   , 'COMPURECORD'
	   , '@' as enc_type_path
from [Jupiter].[Compurecord].[Demographics] crdem
inner join ( select encounter_num, patient_num, encounter_ide, contact_Date, provider_id, location_cd, sourcesystem_Cd from encounter_mapping where SOURCESYSTEM_CD = 'COMPURECORD' )  e on e.encounter_ide = ACCOUNTNUMBER
inner join SUPER_ADHOC.dbo.cr_details crdet on crdem.internalcaseid = crdet.internalcaseid
WHERE crdem.PROCEDURESTART is not null and crdet.category = 'ADMISSION';