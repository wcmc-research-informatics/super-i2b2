/*
  Builds observation facts for diagnoses from clinical notes. These can be considered 
  NLP facts.

  Copyright (c) 2014-2017 Weill Cornell Medical College
 */
use <prefix>i2b2demodata;

-- icd-9
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
SELECT ENCOUNTER_NUM
    , PATIENT_NUM
    , 'NLPICD9:'+ [icd9] as CONCEPT_CD
    , PROVIDER_ID
    , [start_date] as CONTACT_DATE
    , '@' AS MODIFIER_CD
    , INSTANCE_NUM
    , '@' AS VALUEFLAG_CD
    , '@' AS UNITS_CD
	, NULL as end_date
    , LOCATION_CD
	, update_date
	, download_date
	, import_date
	, sourcesystem_cd
FROM (SELECT  OP.PAT_ENC_CSN_ID as PAT_ENC_CSN_ID
      , ptlo.pat_id
	  , [icd9]
	  , 1 as instance_num
	  , contact_date as [start_date]
	  FROM [SUPER_NLP].[dbo].[PATHOLOGY_RDR] [ptlo]
	  JOIN SUPER_MONTHLY.DBO.ORDER_PROC [OP] ON ptlo.ORDER_PROC_ID = op.ORDER_PROC_ID
	  where len(ICD9)>0 and icd9 not like '%|%') [t]
inner join encounter_mapping e
	ON e.encounter_ide = pat_enc_csn_id and sourcesystem_cd = 'EPIC';


--ICD-10 scores
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
SELECT ENCOUNTER_NUM
    , PATIENT_NUM
    , 'NLPICD10:'+ [icd10] as CONCEPT_CD
    , PROVIDER_ID
    , [start_date] as CONTACT_DATE
    , '@' AS MODIFIER_CD
    , INSTANCE_NUM
    , '@' AS VALUEFLAG_CD
    , '@' AS UNITS_CD
	, NULL as end_date
    , LOCATION_CD
	, update_date
	, download_date
	, import_date
	, sourcesystem_cd
FROM (SELECT  OP.PAT_ENC_CSN_ID as PAT_ENC_CSN_ID
      , ptlo.pat_id
	  , [ICD10]
	  , 1 as instance_num
	  , contact_date as [start_date]
	  FROM [SUPER_NLP].[dbo].[PATHOLOGY_RDR] [ptlo]
	  JOIN SUPER_MONTHLY.DBO.ORDER_PROC [OP] ON ptlo.ORDER_PROC_ID = op.ORDER_PROC_ID
	  where len(ICD10)>0 and icd10 not like '%|%') [t]
inner join encounter_mapping e
	ON e.encounter_ide = pat_enc_csn_id and sourcesystem_cd = 'EPIC';

-- tnm scores
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
SELECT ENCOUNTER_NUM
    , PATIENT_NUM
    , 'TNM:'+ [stage] as CONCEPT_CD
    , PROVIDER_ID
    , [start_date] as CONTACT_DATE
    , '@' AS MODIFIER_CD
    , INSTANCE_NUM
    , '@' AS VALUEFLAG_CD
    , '@' AS UNITS_CD
	, NULL as end_date
    , LOCATION_CD
	, update_date
	, download_date
	, import_date
	, sourcesystem_cd
FROM (
		SELECT  OP.PAT_ENC_CSN_ID as PAT_ENC_CSN_ID
      , ptlo.pat_id
	  , tstage as [stage]
	  , 1 as instance_num
	  , contact_date as [start_date]
	  , '@' modifier_cd
	  FROM [SUPER_NLP].[dbo].[PATHOLOGY_RDR] [ptlo]
	  JOIN SUPER_MONTHLY.DBO.ORDER_PROC [OP] ON ptlo.ORDER_PROC_ID = op.ORDER_PROC_ID
	  where len(tstage) > 1	 

	  union

	  SELECT  OP.PAT_ENC_CSN_ID as PAT_ENC_CSN_ID
      , ptlo.pat_id
	  , nstage as [stage]
	  , 1 as instance_num
	  , contact_date as [start_date]
	  , '@' modifier_cd
	  FROM [SUPER_NLP].[dbo].[PATHOLOGY_RDR] [ptlo]
	  JOIN SUPER_MONTHLY.DBO.ORDER_PROC [OP] ON ptlo.ORDER_PROC_ID = op.ORDER_PROC_ID
	  where len(nstage) > 1	 

	  union

	  SELECT  OP.PAT_ENC_CSN_ID as PAT_ENC_CSN_ID
      , ptlo.pat_id
	  , mstage as [stage]
	  , 1 as instance_num
	  , contact_date as [start_date]
	  , '@' modifier_cd
	  FROM [SUPER_NLP].[dbo].[PATHOLOGY_RDR] [ptlo]
	  JOIN SUPER_MONTHLY.DBO.ORDER_PROC [OP] ON ptlo.ORDER_PROC_ID = op.ORDER_PROC_ID
	  where len(mstage) > 1	 
	  ) [t]
inner join encounter_mapping e
	ON e.encounter_ide = pat_enc_csn_id and sourcesystem_cd = 'EPIC'

-- Gleason scores
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
	, location_cd
	, update_date
	, download_date
	, import_date
	, sourcesystem_cd
	)
SELECT ENCOUNTER_NUM
    , PATIENT_NUM
    , 'GLEASONSCORE:'+GLEASONSCORE as CONCEPT_CD
    , PROVIDER_ID
    , [start_date] as CONTACT_DATE
    , '@' AS MODIFIER_CD
    , 1 as INSTANCE_NUM
    , '@' AS VALUEFLAG_CD
    , '@' AS UNITS_CD
    , LOCATION_CD
	, update_date
	, download_date
	, import_date
	, sourcesystem_cd
FROM (
		SELECT DISTINCT OP.PAT_ENC_CSN_ID as PAT_ENC_CSN_ID
      , ptlo.pat_id
	  , gleasonscore
	  , contact_date as [start_date]
	  , '@' modifier_cd
	  FROM [SUPER_NLP].[dbo].[PATHOLOGY_RDR] [ptlo]
	  JOIN SUPER_MONTHLY.DBO.ORDER_PROC [OP] ON ptlo.order_proc_id = op.ORDER_PROC_ID
	  where len(gleasonscore) > 1	 ) [t]
inner join encounter_mapping e
	ON e.encounter_ide = pat_enc_csn_id and sourcesystem_cd = 'EPIC'
where len(gleasonscore) > 0;