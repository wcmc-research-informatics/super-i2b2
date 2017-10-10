/* 
 *
 *  Creates a table in the staging database that holds age at time of encounter information that will be
 *  inserted into OBSERVATION_FACT.
 *
 *  Copyright (c) 2014-2017 Weill Cornell Medical College
 */
 
use <prefix>i2b2demodata;

/*
 * Aggregate these concepts before insertion into observation fact
 */

INSERT INTO observation_fact(
	encounter_num
	, patient_num
	, concept_cd
	, provider_id
	, start_date
	, modifier_cd
	, instance_num
	, valueflag_cd
	, units_cd
	, location_cd
	, update_date
	, import_date
	, sourcesystem_cd
	)
SELECT e.encounter_num
	, patient_num
	, 'AGEENC:' + cast(datediff(year, birthdate, procdate) AS VARCHAR) AS concept_cd
	, provider_id
	, procdate
	, '@' AS modifier_cd
	, 1 AS instance_num
	, '@' AS valueflag_cd
	, '@' AS units_cd
	, '@' AS location_cd
	, getDate() AS update_date
	, getDate() AS import_date
	, 'ORMANAGER' AS sourcesystem_cd
FROM arch.dbo.ORCases
INNER JOIN arch.dbo.nyp_anes_demographics
	ON AcctNo = AcctNbr
INNER JOIN (
	SELECT encounter_num
		, patient_num
		, encounter_ide
		, provider_id
		, location_cd
		, contact_date
		, sourcesystem_Cd
	FROM encounter_mapping
	WHERE SOURCESYSTEM_CD = 'ORMANAGER'
	) e
	ON e.encounter_ide = cast(acctnbr AS VARCHAR(20))
WHERE procdate IS NOT NULL;