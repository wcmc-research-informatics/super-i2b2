/**
 *
 * Creates the facts for Active ACO patients. 
 *   Copyright (c) 2014-2017 Weill Cornell Medical College
 */

use <prefix>i2b2demodata;

BEGIN TRANSACTION;

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
SELECT -1
	, PM.PATIENT_NUM
	, 'ACO'
	, '@'
	, '07-04-1776'
	, '@' AS MODIFIER_CD
	, 1 AS INSTANCE_NUM
	, '@' AS VALUEFLAG_CD
	, '@' AS UNITS_CD
	, '@' as LOCATION_CD
	, GETDATE() AS UPDATE_DATE
	, GETDATE() AS IMPORT_DATE
	, 'EPIC' AS SOURCESYSTEM_CD
FROM SUPER_MONTHLY.DBO.ACO_PATIENT P
INNER JOIN ( select patient_num,  patient_ide from patient_mapping where SOURCESYSTEM_CD = 'EPIC' )  PM ON PM.PATIENT_IDE = P.PAT_ID

COMMIT TRANSACTION;