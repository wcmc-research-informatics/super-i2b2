/*
  Builds observation facts for diagnoses from EPIC Clarity schema. The diagnoses
  are coded using ICD9 system. Four modifiers are included for observation 
  facts, which indicate how the diagnosis information was collected and ultimately
  where it comes from within clarity.

  ENC_DX        - Encounter Diagnosis
  MEDICAL_HX    - Medical History
  PROBLEM_LIST  - Problem List
  TDL_TRAN		- Billing Diagnosis

    Copyright (c) 2014-2017 Weill Cornell Medical College
 */
 
use <prefix>i2b2demodata;


select top 0 ENCOUNTER_NUM
			,PATIENT_NUM
			,CONCEPT_CD
			,INSTANCE_NUM
			,[START_DATE]
			,MODIFIER_CD
INTO #OBS_FACT FROM OBSERVATION_FACT;

ALTER TABLE #OBS_FACT ALTER COLUMN PATIENT_NUM VARCHAR(30);
ALTER TABLE #OBS_FACT ALTER COLUMN ENCOUNTER_NUM varchar(30);

INSERT INTO #OBS_FACT
SELECT   PAT_ENC_CSN_ID
		, PAT_ID
		, DX_ID
        , LINE
        , CONTACT_DATE
		, 'MEDICAL_HX'
FROM SUPER_MONTHLY.DBO.MEDICAL_HX
INNER JOIN PATIENT_MAPPING ON PAT_ID = PATIENT_IDE AND SOURCESYSTEM_CD = 'EPIC'
WHERE DX_ID IS NOT NULL;

INSERT INTO #OBS_FACT
SELECT    PAT_ENC_CSN_ID
		, PAT_ID
		, DX_ID
        , LINE 
        , CONTACT_DATE
		, 'ENC_DX'
FROM SUPER_MONTHLY.DBO.PAT_ENC_DX
INNER JOIN PATIENT_MAPPING ON PAT_ID = PATIENT_IDE AND SOURCESYSTEM_CD = 'EPIC'
WHERE DX_ID IS NOT NULL;

INSERT INTO #OBS_FACT
select    problem_ept_csn
		, PAT_ID
		, DX_ID
		, 1 as instance_num
		, coalesce(noted_date, date_of_entry)
		, 'PROBLEM_LIST'
from super_monthly.dbo.problem_list
INNER JOIN PATIENT_MAPPING ON PAT_ID = PATIENT_IDE AND SOURCESYSTEM_CD = 'EPIC'
WHERE DX_ID IS NOT NULL AND PROBLEM_EPT_CSN IS NOT NULL;


insert into #OBS_FACT
select     pat_enc_csn_id
		,  INT_PAT_ID
		,  DX_ID
		,  instance_num
		,  ORIG_SERVICE_DATE
		,  'TDL_TRAN'
from SUPER_STAGING.DBO.TDL_TRAN_SLIM
INNER JOIN PATIENT_MAPPING ON INT_PAT_ID = PATIENT_IDE AND SOURCESYSTEM_CD = 'EPIC'
WHERE DX_ID IS NOT NULL AND INT_PAT_ID IS NOT NULL AND PAT_ENC_CSN_ID IS NOT NULL;

insert into #OBS_FACT
SELECT PAT_ENC_CSN_ID
	, PAT_ID
	, ECI.DX_ID
	, INSTANCE_NUM
	, CAST(SERVICE_DATE AS DATETIME)
	, 'IDX'
FROM SUPER_STAGING.DBO.IDX_DATA_SLIM IDX
INNER JOIN (SELECT MIN(DX_ID) DX_ID, CODE FROM SUPER_MONTHLY.DBO.EDG_CURRENT_ICD9 GROUP BY CODE) ECI ON IDX.DX = ECI.CODE
inner join (  select encounter_num, encounter_ide, ENCOUNTER_IDE_SOURCE from encounter_mapping where ENCOUNTER_IDE_SOURCE = 'IDX' ) E 
	ON encounter_ide = PAT_ENC_CSN_ID;

-- Index the table
create nonclustered index [COVER] on #OBS_FACT
	([encounter_num]) include ([concept_cd],[instance_num],[start_date],[modifier_cd]);

-- Insert modifiers
INSERT INTO OBSERVATION_FACT
(
	  encounter_num
	, patient_num
	, concept_cd
	, provider_id
	, start_date
	, modifier_cd
	, instance_num
	, valueflag_cd
	, units_cd
	, end_date
	, location_cd
	, update_date
	, download_date
	, import_date
	, sourcesystem_cd
	)
SELECT e.ENCOUNTER_NUM
    , e.PATIENT_NUM
    , dxm.CONCEPT_CD
    , PROVIDER_ID
    , [START_DATE]
    , 'ICD9:'+ MODIFIER_CD
    , INSTANCE_NUM
    , '@' AS VALUEFLAG_CD
    , '@' AS UNITS_CD
	, NULL as end_date
    , LOCATION_CD
    , UPDATE_DATE
    , DOWNLOAD_DATE
    , IMPORT_DATE
    , SOURCESYSTEM_CD
FROM #obs_fact PE
INNER JOIN ENCOUNTER_MAPPING e
    ON ENCOUNTER_IDE = pe.ENCOUNTER_NUM AND SOURCESYSTEM_CD = 'EPIC'	-- ENCOUNTER_NUM from temporary table is PAT_ENC_CSN_ID
INNER JOIN SUPER_STAGING.DBO.I2B2_DXID_MAPPING DXM ON PE.CONCEPT_CD = DXM.DX_ID	-- CONCEPT_CD is DX_ID

INSERT INTO OBSERVATION_FACT
(
	  encounter_num
	, patient_num
	, concept_cd
	, provider_id
	, start_date
	, modifier_cd
	, instance_num
	, valueflag_cd
	, units_cd
	, end_date
	, location_cd
	, update_date
	, download_date
	, import_date
	, sourcesystem_cd
	)
SELECT e.ENCOUNTER_NUM
    , e.PATIENT_NUM
    , C_BASECODE
    , PROVIDER_ID
    , e.CONTACT_DATE
    , 'ICD10:'+MODIFIER_CD
    , INSTANCE_NUM
    , '@' AS VALUEFLAG_CD
    , '@' AS UNITS_CD
	, NULL as end_date
    , LOCATION_CD
    , UPDATE_DATE
    , DOWNLOAD_DATE
    , IMPORT_DATE
    , SOURCESYSTEM_CD
FROM #obs_fact PE
INNER JOIN ENCOUNTER_MAPPING e
    ON ENCOUNTER_IDE = pe.ENCOUNTER_NUM	AND SOURCESYSTEM_CD = 'EPIC'
INNER JOIN super_staging.dbo.i2b2_icd10_mapping i10m on pe.concept_cd = i10m.dx_id
	WHERE NOT EXISTS (
			SELECT BAD_VAL
			FROM SUPER_STAGING.DBO.SUPER_DIAGNOSES_DXID_BLACKLIST
			WHERE BAD_VAL = pe.concept_cd
			);

DROP TABLE #OBS_FACT;