/*
   Builds observation facts for height and weight from CompuRecord

   Copyright (c) 2014-2017 Weill Cornell Medical College
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
	, tval_char
	, nval_num
	, valueflag_cd
	, units_cd
	, location_cd
	, update_date
	, import_date
	, sourcesystem_cd
	)
select      	  encounter_num
			    , patient_num
				, 'HEIGHT' as concept_cd
				, provider_id
				, COALESCE(SERVICEDATE, CONTACT_DATE) as start_date
			    , '@' as modifier_cd
			    , 1 as instance_num
				, 'N' as valtype_cd
				, 'E' as tval_char
				, CASE WHEN HUNITS = '103' THEN [HEIGHT] * (2.54)
					   WHEN HUNITS = '61' THEN [HEIGHT] END as nval_num
			    , '@' as valueflag_cd
			    , 'cm' as units_cd
			    , location_cd
			    , getDate() as update_date
			    , getDate() as import_date
			    , 'COMPURECORD'  as sourcesystem_cd
from [Jupiter].[Compurecord].[Demographics] crdem
INNER JOIN (
	SELECT encounter_num
		, patient_num
		, encounter_ide
		, contact_Date
		, provider_id
		, location_cd
		, sourcesystem_Cd
	FROM encounter_mapping
	WHERE SOURCESYSTEM_CD = 'COMPURECORD'
	) wem
	ON cast(encounter_ide AS VARCHAR) = crdem.ACCOUNTNUMBER
where LEN(HEIGHT) > 0 AND LEN(HUNITS) > 0;



insert into observation_fact(
	encounter_num
	, patient_num
	, concept_cd
	, provider_id
	, start_date
	, modifier_cd
	, instance_num
	, VALTYPE_CD
	, tval_char
	, nval_num
	, valueflag_cd
	, units_cd
	, location_cd
	, update_date
	, import_date
	, sourcesystem_cd
	)
select      	  encounter_num
			    , patient_num
				, 'WEIGHT' as concept_cd
				, provider_id
				, COALESCE(SERVICEDATE, CONTACT_DATE) as start_date
			    , '@' as modifier_cd
			    , 1 as instance_num
				, 'N' as valtype_cd
				, 'E' as tval_char
				, CASE WHEN WUNITS = '103' THEN [WEIGHT] * (0.45359237)
					   WHEN WUNITS = '61' THEN [WEIGHT] END as nval_num
			    , '@' as valueflag_cd
			    , 'kg' as units_cd
			    , location_cd
			    , getDate() as update_date
			    , getDate() as import_date
			    , 'COMPURECORD'  as sourcesystem_cd
from [Jupiter].[Compurecord].[Demographics] crdem
INNER JOIN (
	SELECT encounter_num
		, patient_num
		, encounter_ide
		, contact_Date
		, provider_id
		, location_cd
		, sourcesystem_Cd
	FROM encounter_mapping
	WHERE SOURCESYSTEM_CD = 'COMPURECORD'
	) wem
	ON cast(encounter_ide AS VARCHAR) = crdem.ACCOUNTNUMBER
where LEN(WEIGHT) > 0 AND LEN(WUNITS) > 0;
