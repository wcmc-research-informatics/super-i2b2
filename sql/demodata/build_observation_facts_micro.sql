/**
 *
 * Creates the facts for Antibiotic Sensitivity. 
 * 
 */
USE <prefix>i2b2demodata;

-- Microbiology Observation Facts by CPT
--    For these sets of facts, the concept code is Micro followed by the CPT code, the modifier code is the organism id and the tvalchar is +/-.
INSERT INTO observation_fact (
	encounter_num
	,patient_num
	,concept_cd
	,provider_id
	,start_date
	,modifier_cd
	,instance_num
	,VALTYPE_CD
	,TVAL_CHAR
	,valueflag_cd
	,units_cd
	,location_cd
	, update_date
	, download_date
	, import_date
	, sourcesystem_cd
	)
SELECT ENCOUNTER_NUM
	,PATIENT_NUM
	,CONCEPT_CD
	,PROVIDER_ID
	,E.CONTACT_DATE
	,MOD_CD AS MODIFIER_CD
	,1 AS INSTANCE_NUM
	,'T' AS VALTYPE_CD
	,[STATUS] AS TVAL_CHAR
	,'@' AS VALUEFLAG_CD
	,'@' AS UNITS_CD
	,LOCATION_CD
	, update_date
	, download_date
	, import_date
	, sourcesystem_cd
FROM (SELECT PAT_ENC_CSN_ID, 'MICRO:' + CAST(PROC_CODE AS VARCHAR) as CONCEPT_CD, 'MOD:' + CAST(OVL AS VARCHAR) AS MOD_CD, STATUS
	 FROM SUPER_STAGING.DBO.MICROBIOLOGY M
	 WHERE PAT_ENC_CSN_ID IS NOT NULL AND OVL IS NOT NULL
	  UNION
	 SELECT PAT_ENC_CSN_ID, 'MICRO:' + cast(PROC_CODE as varchar) as CONCEPT_CD, 'MOD:' + CAST(CL AS VARCHAR) AS MOD_CD, STATUS
	 FROM SUPER_STAGING.DBO.MICROBIOLOGY M
	 WHERE PAT_ENC_CSN_ID IS NOT NULL AND CL IS NOT NULL
	  UNION
	 SELECT PAT_ENC_CSN_ID, 'MICRO:' + CAST(PROC_CODE AS VARCHAR) as CONCEPT_CD, '@' AS MOD_CD, STATUS
	 FROM SUPER_STAGING.DBO.MICROBIOLOGY M
	 WHERE PAT_ENC_CSN_ID IS NOT NULL
    ) T
INNER JOIN encounter_mapping e ON ENCOUNTER_IDE = T.PAT_ENC_CSN_ID and SOURCESYSTEM_CD = 'EPIC'

-- Microbiology Observation Facts by Organism
--    For these sets of facts, the concept code is 'Microbio' followed by the organism id, the modifier code is the CPT Code and the tvalchar is +/-.
INSERT INTO observation_fact (
	encounter_num
	,patient_num
	,concept_cd
	,provider_id
	,start_date
	,modifier_cd
	,instance_num
	,VALTYPE_CD
	,TVAL_CHAR
	,valueflag_cd
	,units_cd
	,location_cd
	, update_date
	, download_date
	, import_date
	, sourcesystem_cd
	)
SELECT ENCOUNTER_NUM
	,PATIENT_NUM
	,CONCEPT_CD
	,PROVIDER_ID
	,E.CONTACT_DATE
	,MOD_CD AS MODIFIER_CD
	,1 AS INSTANCE_NUM
	,'T' AS VALTYPE_CD
	,[STATUS] AS TVAL_CHAR
	,'@' AS VALUEFLAG_CD
	,'@' AS UNITS_CD
	,LOCATION_CD
	, update_date
	, download_date
	, import_date
	, sourcesystem_cd
FROM (SELECT PAT_ENC_CSN_ID, 'MOD:' + CAST(PROC_CODE AS VARCHAR) as MOD_CD, 'MICROBIO:' + CAST(OVL AS VARCHAR) AS CONCEPT_CD, STATUS
	 FROM SUPER_STAGING.DBO.MICROBIOLOGY M
	 WHERE PAT_ENC_CSN_ID IS NOT NULL AND OVL IS NOT NULL
	  UNION
	 SELECT PAT_ENC_CSN_ID, 'MOD:' + cast(PROC_CODE as varchar) as MOD_CD, 'MICROBIO:' + CAST(CL AS VARCHAR) AS CONCEPT_CD, STATUS
	 FROM SUPER_STAGING.DBO.MICROBIOLOGY M
	 WHERE PAT_ENC_CSN_ID IS NOT NULL AND CL IS NOT NULL
	  UNION
	 SELECT PAT_ENC_CSN_ID, '@' AS MOD_CD, 'MICROBIO:' + CAST(CL AS VARCHAR) as CONCEPT_CD, STATUS
	 FROM SUPER_STAGING.DBO.MICROBIOLOGY M
	 WHERE PAT_ENC_CSN_ID IS NOT NULL AND CL IS NOT NULL
	  UNION
	 SELECT PAT_ENC_CSN_ID, '@' AS MOD_CD, 'MICROBIO:' + CAST(OVL AS VARCHAR) as CONCEPT_CD, STATUS
	 FROM SUPER_STAGING.DBO.MICROBIOLOGY M
	 WHERE PAT_ENC_CSN_ID IS NOT NULL AND OVL IS NOT NULL
    ) T
INNER JOIN encounter_mapping e ON ENCOUNTER_IDE = T.PAT_ENC_CSN_ID and SOURCESYSTEM_CD = 'EPIC'
