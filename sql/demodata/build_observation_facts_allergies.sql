/*
   Inserts observation fact records for allergies from an EPIC data schema

     Copyright (c) 2014-2017 Weill Cornell Medical College
 */

use <prefix>i2b2demodata;

-- ALLERGY functions as the latest slice of ALLERGY_HX. Since historical allergies are of as much importance
-- to us as current allergies, we bring them all in with the allergen_id that was in use at the time of
-- diagnosis. We use ALRGY_HX_ENTRY_DTTM as the date time value for allergy facts since this field tracks
-- when the allergy was last updated. For one recording, it has the date time to a more specific value than 
-- DATE_NOTED. For multiple recordings, denoted by an increasing line value, the date in ALRGY_HX_ENTRY_DTTM
-- is a more recent date as opposed to DATE_NOTED which only uses the original date. There are no encounter
-- numbers associated with allergies and they do not work in "Same Financial Encounter" queries as expected.
INSERT INTO observation_fact(
	encounter_num
	, patient_num
	, concept_cd
	, provider_id
	, start_date
	, modifier_cd
	, instance_num
	, location_cd
	,update_date
	,download_date
	,import_date
	, sourcesystem_cd
	)
SELECT -1 AS encounter_num
	, PM.patient_num
	, 'ALLERGY:' + cast(coalesce(hx_allergen_id, allergen_id) AS VARCHAR(12))
	, coalesce(hx_entry_user_id, ALR.entry_user_id, '@') as provider_id
	, ALRGY_HX_ENTRY_DTTM as [START_DATE]
	, '@' AS modifier_cd
	, alrhx.line AS instance_num
	, '@' as location_cd
	, pm.update_date
	, download_date
	, import_date
	, sourcesystem_cd
FROM super_monthly.dbo.allergy alr
	-- ALLERGY_DX.PROBLEM_LIST_ID links to ALLERGY.ALLERGY_ID
	-- Not to PROBLEM_LIST.PROBLEM_LIST_ID
INNER JOIN SUPER_MONTHLY.DBO.ALLERGY_HX ALRHX ON ALR.ALLERGY_ID = ALRHX.PROBLEM_LIST_ID
inner JOIN PATIENT_MAPPING pm 
	on pm.patient_ide = alr.pat_id 
	and SOURCESYSTEM_CD = 'EPIC'
where allergen_id is not null;

-- Records exist in ALLERGY and ALLERGY_HX with no ALLERGEN_ID which is necessary for CONCEPT_CD
-- creation and to join between these tables and the lookup table CL_ELG. Many of these records
-- have misspelled allergies so we do fuzzy matching via the Jaro-Winkler algorithm. Take only 
-- records with a 90% match.
INSERT INTO observation_fact(
	encounter_num
	, patient_num
	, concept_cd
	, provider_id
	, start_date
	, modifier_cd
	, instance_num
	, location_cd
	, CONFIDENCE_NUM
	, update_date
	, download_date
	, import_date
	, sourcesystem_cd
	)
SELECT -1 AS encounter_num
	, PM.patient_num
	, 'ALLERGY:' + cast(JWA.allergen_id AS VARCHAR(12))
	, coalesce(hx_entry_user_id, '@') as provider_id
	, ALRGY_HX_ENTRY_DTTM as [START_DATE]
	, '@' AS modifier_cd
	, line AS instance_num
	, '@' as location_cd
	, best_match as confidence_num
	, pm.update_date
	, download_date
	, import_date
	, sourcesystem_cd
FROM (SELECT PAT_ID, HX_DESC, ALRGY_HX_ENTRY_DTTM, HX_ENTRY_USER_ID, LINE, hx_allergen_id FROM SUPER_MONTHLY.DBO.ALLERGY_HX WHERE HX_ALLERGEN_ID IS NULL) ALRGY
INNER JOIN SUPER_STAGING.DBO.JAROWINKLERALLERGY JWA ON ALRGY.HX_DESC = JWA.HX_DESC
INNER JOIN SUPER_MONTHLY.DBO.CL_ELG CL ON CL.ALLERGEN_ID = JWA.ALLERGEN_ID
inner JOIN PATIENT_MAPPING pm 
	on pm.patient_ide = alrgy.pat_id 
	and SOURCESYSTEM_CD = 'EPIC';