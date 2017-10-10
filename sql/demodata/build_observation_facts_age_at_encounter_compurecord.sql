/* 
 *
 *  Creates a table in the staging database that holds age at time of encounter information that will be
 *  inserted into OBSERVATION_FACT.
 *
 *  Copyright (c) 2014-2017 Weill Cornell Medical College
 */
 
use <prefix>i2b2demodata;

BEGIN TRANSACTION;

insert into observation_fact(
	encounter_num
	, patient_num
	, concept_cd
	, provider_id
	, start_date
	, modifier_cd
	, instance_num
	, VALTYPE_CD
	, NVAL_NUM
	, valueflag_cd
	, units_cd
	, location_cd
	, update_date
	, import_date
	, sourcesystem_cd
	)
select distinct	  e.encounter_num
			    , patient_num
				, 'AGEENC:' + cast(age AS VARCHAR) as concept_cd
				, provider_id
				, servicedate as start_date
			    , '@' as modifier_cd
			    , 1 as instance_num
				, 'N' as valtype_cd
				, cast(datediff(year, birthdate, servicedate ) as varchar) as nval_num
			    , '@' as valueflag_cd
			    , '@' as units_cd
			    , location_cd
			    , getDate() as update_date
			    , getDate() as import_date
			    , 'COMPURECORD'  as sourcesystem_cd
from [Jupiter].[Compurecord].[Demographics] crdem
inner join ( select encounter_num, patient_num, encounter_ide, provider_id, location_cd, contact_date, sourcesystem_Cd from encounter_mapping where SOURCESYSTEM_CD = 'COMPURECORD' )  e on e.encounter_ide = ACCOUNTNUMBER
where servicedate is not null and birthdate is not null;

COMMIT TRANSACTION;