/*
 * A set of facts, 1 per patient, which details their vital status in observation fact.
 * Added so the breakdown option in the web client works.
 * -1 is chosen as a dummy encounter number because these facts are not linked to any one
 * encounter in particular
 * Copyright (c) 2014-2017 Weill Cornell Medical College
 */

use <prefix>i2b2demodata;

INSERT INTO observation_fact (
	  encounter_num
	, patient_num
	, concept_cd
	, provider_id
	, start_date
	, modifier_cd
	, instance_num
	, valtype_cd
	, tval_char
	, valueflag_cd
	, units_cd
	, location_cd
	, update_date
	, download_date
	, import_date
	, sourcesystem_cd
	)
SELECT - 1 AS encounter_num
	, patient_num
	, CASE WHEN VITAL_STATUS_CD like 'N%D' THEN 'DEM|VITALS:N*D'
		   WHEN VITAL_STATUS_CD like 'Y%D' THEN 'DEM|VITALS:Y*D'
		   WHEN VITAL_STATUS_CD like 'U%D' THEN 'DEM|VITALS:UNKNOWN' END as concept_cd
	, '@' AS provider_id
	, coalesce(death_date, birth_date)
	, '@' AS modifier_cd
	, 1 AS instance_num
	, 'T' AS valtype_cd
	, 'Alive' AS tval_char
	, '@' AS valueflag_cd
	, '@' AS units_cd
	, '@' AS location_cd
	, update_date
	, download_date
	, import_date
	, sourcesystem_cd
FROM patient_dimension p
WHERE SOURCESYSTEM_CD = 'EPIC';

