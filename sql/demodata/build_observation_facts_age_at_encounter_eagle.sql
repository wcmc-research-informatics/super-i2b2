
/*
 * Calculates the patient's age at the time of the encounter
 * for all data from Eagle and Eclipsys
 *  Copyright (c) 2014-2017 Weill Cornell Medical College
 */

use <prefix>i2b2demodata;

/* Age at Encounter Eagle */
INSERT INTO OBSERVATION_FACT(
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
	, import_date
	, sourcesystem_cd
	)
SELECT e.encounter_num
	, e.patient_num
	, 'AGEENC:' + cast(datediff(year, birth_date, CONTACT_DATE) AS VARCHAR) AS concept_cd
	, provider_id
	, CONTACT_DATE as [start_Date]
	, '@' AS modifier_cd
	, 1 AS instance_num
	, 'N' AS valtype_cd
	, 'E' AS tval_char
	, cast(datediff(year, birth_date, CONTACT_DATE) AS VARCHAR) AS nval_num
	, '@' AS valueflag_cd
	, '@' AS units_cd
	, location_cd
	, getDate() AS update_date
	, getDate() AS import_date
	, E.sourcesystem_cd
FROM PATIENT_DIMENSION PD
INNER JOIN (
	SELECT encounter_ide
		, patient_num
		, encounter_num
		, CONTACT_DATE
		, provider_id
		, location_cd
		, SOURCESYSTEM_CD
	FROM encounter_mapping
	WHERE sourcesystem_cd = 'EAGLE'
	) e
	ON [PD].[PATIENT_NUM] = [e].[PATIENT_NUM]
	where birth_date is not null and contact_date is not null;