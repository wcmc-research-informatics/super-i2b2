/* 
 *
 *  Creates a table in the staging database that holds age at time of encounter information that will be
 *  inserted into OBSERVATION_FACT.
 *
 *  Copyright (c) 2014-2017 Weill Cornell Medical College
 */
 
use <prefix>i2b2demodata;

insert into observation_fact(
	encounter_num
	, patient_num
	, concept_cd
	, provider_id
	, start_date
	, modifier_cd
	, instance_num
	, VALTYPE_CD
	, TVAL_CHAR
	, NVAL_NUM
	, valueflag_cd
	, units_cd
	, location_cd
	, update_date
	, download_date
	, import_date
	, sourcesystem_cd
	)
-- We don't need age at encounter for erroneous conversions or cancelled orders
select   e.encounter_num
       , e.patient_num
	   , 'AGEENC:' + cast(datediff(year, birth_date, p.contact_date ) as varchar) as concept_cd 
	   , provider_id
	   , p.contact_date
	   , '@' as modifier_cd
	   , 1 as instance_num
	   , 'N' as valtype_cd
	   , '=' as tval_char
	   , [age] as nval_num
	   , '@' as valueflag_cd
	   , '@' as units_cd
	   , location_cd
	   , e.update_date
	   , e.download_date
	   , e.import_date
	   , 'EPIC' as sourcesystem_cd
from super_monthly.dbo.pat_enc p
inner join ENCOUNTER_MAPPING e on e.encounter_ide = cast(p.pat_enc_csn_id as varchar(20)) AND SOURCESYSTEM_CD = 'EPIC'
inner join patient_dimension pat on e.patient_num = pat.patient_num
and birth_date is not null and p.contact_date is not null and p.pat_id is not null;

