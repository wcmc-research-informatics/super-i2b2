/*
  Creates facts that represent a patient's age at a particular encounter
  for all encounters from Eclipsys (Allscripts scm)

  Copyright (c) 2014-2017 Weill Cornell Medical College
 */

use <prefix>i2b2demodata;

/* Age at Encounter Eclipsys */
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
	, CONTACT_DATE
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
	, e.sourcesystem_cd
from patient_dimension pd
INNER JOIN (
	SELECT encounter_ide
		, patient_num
		, encounter_num
		, CONTACT_DATE
		, provider_id
		, location_cd
		, SOURCESYSTEM_cd
	FROM encounter_mapping
	WHERE sourcesystem_cd = 'ECLIPSYS'
	) e
	ON [pd].patient_num = e.patient_num
	where birth_date is not null and contact_date is not null and datediff(year, birth_date, CONTACT_DATE) >= 0;
