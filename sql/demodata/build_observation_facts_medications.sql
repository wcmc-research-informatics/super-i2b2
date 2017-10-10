/*
  Builds observation facts for medications from EPIC Clarity schema. 
  Copyright (c) 2014-2017 Weill Cornell Medical College
 */
 
use <prefix>i2b2demodata;

/*
 * ORDERED MEDICATIONS
 */

SELECT TOP 0 
	 ENCOUNTER_NUM
	,CONCEPT_CD
	,INSTANCE_NUM
	,[START_DATE]
	,END_DATE
	,MODIFIER_CD
	,VALTYPE_CD
	,TVAL_CHAR
INTO #OBS_FACT FROM OBSERVATION_FACT;

ALTER TABLE #OBS_FACT ALTER COLUMN ENCOUNTER_NUM VARCHAR(30);

INSERT INTO #OBS_FACT
SELECT PAT_ENC_CSN_ID
	,  'RXNORM:' + cast(rxnorm_code as varchar) [concept_cd]
	,  1 AS INSTANCE_NUM
	,  coalesce(ordering_date, start_date, calendar_dt)  AS [start_date]
	,  coalesce(end_date, calendar_dt) as [end_date]
	,  CASE WHEN OM.RSN_FOR_DISCON_C IS NOT NULL THEN 'MEDS:RSNFORDISCON' ELSE '@' END AS MODIFIER_CD
	,  'T' AS VALTYPE_CD
	,  ISNULL(NAME, 'Unknown') [TVAL_CHAR]
FROM [SUPER_MONTHLY].[dbo].[order_med] om
INNER JOIN PATIENT_MAPPING ON PAT_ID = PATIENT_IDE AND SOURCESYSTEM_CD = 'EPIC'
left join super_monthly.dbo.date_dimension dd on pat_enc_date_real = epic_dte
inner JOIN (	select min(medication_id) medication_id, rxnorm_code, rxnorm_historic_yn,rxnorm_term_type_c  from super_monthly.dbo.RXNORM_CODES
													 where rxnorm_historic_yn is null and rxnorm_term_type_c in (9, 18) and line = 1
													 group by rxnorm_code, rxnorm_historic_yn, rxnorm_term_type_c) rm on om.medication_id = rm.medication_id
LEFT JOIN super_monthly.dbo.ZC_RSN_FOR_DISCON zcr
	ON om.RSN_FOR_DISCON_C = zcr.RSN_FOR_DISCON_C
WHERE ORDERING_DATE IS NOT NULL AND PAT_ENC_CSN_ID IS NOT NULL;

-- Current medications modifiers
INSERT INTO #OBS_FACT
select pat_enc_csn_id
	,  'RXNORM:' + cast(rxnorm_code as varchar)  [concept_cd]
	,  [LINE] AS INSTANCE_NUM
	,  COALESCE(CONTACT_DATE, calendar_dt) AS [START_DATE] 
	,  NULL AS END_DATE
	,  'MEDS:ACTIVE:' + [IS_ACTIVE_YN] AS MODIFIER_CD
	,  '@' AS VALTYPE_CD
	,  '@' AS TVAL_CHAR 
FROM [SUPER_MONTHLY].[DBO].[PAT_ENC_CURR_MEDS] PM
inner JOIN (	select min(medication_id) medication_id, rxnorm_code, rxnorm_historic_yn,rxnorm_term_type_c  from super_monthly.dbo.RXNORM_CODES
													 where rxnorm_historic_yn is null and rxnorm_term_type_c in (9, 18) and line = 1
													 group by rxnorm_code, rxnorm_historic_yn, rxnorm_term_type_c) rm on pm.medication_id = rm.medication_id
left join super_monthly.dbo.date_dimension dd on pat_enc_date_real = epic_dte
INNER JOIN PATIENT_MAPPING ON PAT_ID = PATIENT_IDE AND SOURCESYSTEM_CD = 'EPIC'
WHERE [IS_ACTIVE_YN] IN ('Y','N') and pm.MEDICATION_ID is not null;


-- Copy over all rows
INSERT INTO observation_fact(
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
	, end_date
	, location_cd
	, update_date
	, download_date
	, import_date
	, sourcesystem_cd
	)
SELECT wem.encounter_num
	, wem.patient_num
	, concept_cd
	, provider_id
	, [start_date]
	, modifier_cd
	, instance_num
	, valtype_cd
	, tval_char
	, '@' AS VALUEFLAG_CD
	, '@' AS UNITS_CD
	, END_DATE
	, location_cd
	, UPDATE_DATE
	, download_date
	, IMPORT_DATE
	, sourcesystem_cd
FROM #OBS_FACT E
INNER JOIN (select encounter_ide, encounter_num, patient_num, provider_id, location_cd, update_date, download_date, import_date, sourcesystem_cd from encounter_mapping where sourcesystem_cd = 'EPIC') wem
	ON wem.ENCOUNTER_IDE = e.ENCOUNTER_NUM;

DROP TABLE #OBS_FACT;