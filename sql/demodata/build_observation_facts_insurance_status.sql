/**
 *
 * Creates the facts for Insurance Status. 
 *   Copyright (c) 2014-2017 Weill Cornell Medical College
 */
USE <prefix>i2b2demodata;

-- Building the lookup table for the different insurance plans
BEGIN
	SELECT cast(benefit_plan_id as numeric(18,0)) as BENEFIT_PLAN_ID
		,'DEM|MC_MCR_MCD' AS CONCEPT_CD
		,'Managed Care (Medicare or Medicaid)' AS PROD_TYPE
	INTO #PLANS
	FROM SUPER_MONTHLY.DBO.CLARITY_EPP_2 EPP
	INNER JOIN SUPER_MONTHLY.DBO.ZC_PROD_TYPE ZC ON ZC.PROD_TYPE_C = EPP.PROD_TYPE_C
	where NAME = 'chp'
	union
		SELECT cast(benefit_plan_id as numeric(18,0)) as BENEFIT_PLAN_ID
		,'DEM|MC_MCD' AS CONCEPT_CD
		, 'Managed Care (Medicaid)' AS PROD_TYPE
	FROM SUPER_MONTHLY.DBO.CLARITY_EPP_2 EPP
	INNER JOIN SUPER_MONTHLY.DBO.ZC_PROD_TYPE ZC ON ZC.PROD_TYPE_C = EPP.PROD_TYPE_C
	WHERE NAME = 'fhp'
	union
		SELECT cast(benefit_plan_id as numeric(18,0)) as BENEFIT_PLAN_ID
		,'DEM|CMRCL' AS CONCEPT_CD
		,'Commercial' AS PROD_TYPE
	FROM SUPER_MONTHLY.DBO.CLARITY_EPP_2 EPP
	INNER JOIN SUPER_MONTHLY.DBO.ZC_PROD_TYPE ZC ON ZC.PROD_TYPE_C = EPP.PROD_TYPE_C
	where name = 'cmo' or name = 'commercial' OR NAME = 'Long Term Healthcare' or name = 'Union'
	union
		SELECT cast(benefit_plan_id as numeric(18,0)) as BENEFIT_PLAN_ID
		,'DEM|MC' AS CONCEPT_CD
		,'Managed Care' AS PROD_TYPE
	FROM SUPER_MONTHLY.DBO.CLARITY_EPP_2 EPP
	INNER JOIN SUPER_MONTHLY.DBO.ZC_PROD_TYPE ZC ON ZC.PROD_TYPE_C = EPP.PROD_TYPE_C
	where name = 'epo' or name = 'HMO'
	union
		SELECT cast(benefit_plan_id as numeric(18,0)) as BENEFIT_PLAN_ID
		,'DEM|MC' AS CONCEPT_CD
		,'Managed Care' AS PROD_TYPE
	FROM SUPER_MONTHLY.DBO.CLARITY_EPP_2 EPP
	INNER JOIN SUPER_MONTHLY.DBO.ZC_PROD_TYPE ZC ON ZC.PROD_TYPE_C = EPP.PROD_TYPE_C
	where name = 'MCO' or name = 'pos' or name = 'PPO' or name = 'Vision Plan'
	union
		SELECT cast(benefit_plan_id as numeric(18,0)) as BENEFIT_PLAN_ID
		,'DEM|MCD' AS CONCEPT_CD
		,'Medicaid' AS PROD_TYPE
	FROM SUPER_MONTHLY.DBO.CLARITY_EPP_2 EPP
	INNER JOIN SUPER_MONTHLY.DBO.ZC_PROD_TYPE ZC ON ZC.PROD_TYPE_C = EPP.PROD_TYPE_C
	where name = 'Medicaid'
	union
		SELECT cast(benefit_plan_id as numeric(18,0)) as BENEFIT_PLAN_ID
		,'DEM|MCR' AS CONCEPT_CD
		,'Medicare' AS PROD_TYPE
	FROM SUPER_MONTHLY.DBO.CLARITY_EPP_2 EPP
	INNER JOIN SUPER_MONTHLY.DBO.ZC_PROD_TYPE ZC ON ZC.PROD_TYPE_C = EPP.PROD_TYPE_C
	where name = 'Medicare'
	union
		SELECT cast(benefit_plan_id as numeric(18,0)) as BENEFIT_PLAN_ID
		,'DEM|WRKR_CMP' AS CONCEPT_CD
		,'Worker''s Comp/No fault' AS PROD_TYPE
	FROM SUPER_MONTHLY.DBO.CLARITY_EPP_2 EPP
	INNER JOIN SUPER_MONTHLY.DBO.ZC_PROD_TYPE ZC ON ZC.PROD_TYPE_C = EPP.PROD_TYPE_C
	where name = 'No Fault' or name = 'Worker''s Compensation';
END

-- Inserting facts first at the patient level from PAT_ACCT_CVG
INSERT INTO observation_fact (
	encounter_num
	,patient_num
	,concept_cd
	,provider_id
	,[START_DATE]
	,end_date
	,modifier_cd
	,instance_num
	,valueflag_cd
	,units_cd
	,location_cd
	,update_date
	,download_date
	,import_date
	,sourcesystem_cd
	)
SELECT DISTINCT - 1
	,PM.PATIENT_NUM
	,CONCEPT_CD
	,'@'
	,CVG_EFF_DT AS [START_DATE]
	,CVG_TERM_DT AS END_DATE
	,'@' AS MODIFIER_CD
	,1 AS INSTANCE_NUM
	,'@' AS VALUEFLAG_CD
	,'@' AS UNITS_CD
	,'@' AS location_cd
	,PM.Update_DATE
	,download_date
	,IMPORT_DATE
	,SOURCESYSTEM_CD
FROM SUPER_MONTHLY.DBO.PAT_ACCT_CVG PAC
JOIN SUPER_MONTHLY.DBO.COVERAGE CVG ON CVG.COVERAGE_ID = PAC.COVERAGE_ID
INNER JOIN patient_mapping pm on pm.patient_ide = pac.pat_id and SOURCESYSTEM_CD = 'EPIC'
INNER JOIN #PLANS P ON P.BENEFIT_PLAN_ID = PAC.PLAN_ID
WHERE CONCEPT_CD IS NOT NULL AND CVG_EFF_DT IS NOT NULL AND CVG_TERM_DT IS NOT NULL

INSERT INTO observation_fact (
	encounter_num
	,patient_num
	,concept_cd
	,provider_id
	,[START_DATE]
	,end_date
	,modifier_cd
	,instance_num
	,valueflag_cd
	,units_cd
	,location_cd
	,update_date
	,download_date
	,import_date
	,sourcesystem_cd
	)
SELECT DISTINCT - 1
	,PM.PATIENT_NUM
	,CONCEPT_CD
	,'@'
	,CVG_EFF_DT AS [START_DATE]
	,CVG_EFF_DT AS END_DATE
	,'@' AS MODIFIER_CD
	,1 AS INSTANCE_NUM
	,'@' AS VALUEFLAG_CD
	,'@' AS UNITS_CD
	,'@' AS location_cd
	,PM.Update_DATE
	,download_date
	,IMPORT_DATE
	,SOURCESYSTEM_CD
FROM SUPER_MONTHLY.DBO.PAT_ACCT_CVG PAC
JOIN SUPER_MONTHLY.DBO.COVERAGE CVG ON CVG.COVERAGE_ID = PAC.COVERAGE_ID
INNER JOIN patient_mapping pm on pm.patient_ide = pac.pat_id and SOURCESYSTEM_CD = 'EPIC'
INNER JOIN #PLANS P ON P.BENEFIT_PLAN_ID = PAC.PLAN_ID
WHERE CONCEPT_CD IS NOT NULL AND CVG_TERM_DT IS NULL AND CVG_EFF_DT IS NOT NULL

INSERT INTO observation_fact (
	encounter_num
	,patient_num
	,concept_cd
	,provider_id
	,[START_DATE]
	,end_date
	,modifier_cd
	,instance_num
	,valueflag_cd
	,units_cd
	,location_cd
	,update_date
	,download_date
	,import_date
	,sourcesystem_cd
	)
-- Inserting facts at the encounter level from PAT_ENC
SELECT DISTINCT encounter_num
	,e.PATIENT_NUM
	,CONCEPT_CD
	,'@'
	,CVG_EFF_DT AS [START_DATE]
	,CVG_TERM_DT AS END_DATE
	,'@' AS MODIFIER_CD
	,1 AS INSTANCE_NUM
	,'@' AS VALUEFLAG_CD
	,'@' AS UNITS_CD
	,'@' AS location_cd
	,e.Update_DATE
	,download_date
	,IMPORT_DATE
	,SOURCESYSTEM_CD
FROM SUPER_MONTHLY.DBO.PAT_ENC PE
JOIN super_monthly.dbo.coverage cvg ON cvg.coverage_id = pe.coverage_id
inner join ENCOUNTER_MAPPING e on e.encounter_ide = cast(pe.pat_enc_csn_id as varchar(20)) AND SOURCESYSTEM_CD = 'EPIC'
INNER JOIN #PLANS P ON P.BENEFIT_PLAN_ID = cvg.PLAN_ID
WHERE CONCEPT_CD IS NOT NULL AND CVG_TERM_DT IS NOT NULL AND CVG_EFF_DT IS NOT NULL

INSERT INTO observation_fact (
	encounter_num
	,patient_num
	,concept_cd
	,provider_id
	,[START_DATE]
	,end_date
	,modifier_cd
	,instance_num
	,valueflag_cd
	,units_cd
	,location_cd
	,update_date
	,download_date
	,import_date
	,sourcesystem_cd
	)
SELECT DISTINCT encounter_num
	,e.PATIENT_NUM
	,CONCEPT_CD
	,'@'
	,CVG_EFF_DT AS [START_DATE]
	,CVG_EFF_DT AS END_DATE
	,'@' AS MODIFIER_CD
	,1 AS INSTANCE_NUM
	,'@' AS VALUEFLAG_CD
	,'@' AS UNITS_CD
	,'@' AS location_cd
	,e.Update_DATE
	,download_date
	,IMPORT_DATE
	,SOURCESYSTEM_CD
FROM SUPER_MONTHLY.DBO.PAT_ENC PE
JOIN super_monthly.dbo.coverage cvg ON cvg.coverage_id = pe.coverage_id
inner join ENCOUNTER_MAPPING e on e.encounter_ide = cast(pe.pat_enc_csn_id as varchar(20)) AND SOURCESYSTEM_CD = 'EPIC'
INNER JOIN #PLANS P ON P.BENEFIT_PLAN_ID = cvg.PLAN_ID
WHERE CONCEPT_CD IS NOT NULL AND CVG_EFF_DT IS NOT NULL AND CVG_TERM_DT IS NULL


BEGIN
	DROP TABLE #PLANS
END
