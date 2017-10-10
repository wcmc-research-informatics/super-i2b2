
 /*

  Builds observation facts for procedures from EPIC Clarity schema. The diagnoses
  are coded using HCPCS system. Three modifiers are included for observation 
  facts, which indicate how the information was collected and ultimately
  where it comes from within clarity. Records with missing encounters are substituted with
  the closest possible encounter for the patient with a similar PAT_ENC_DATE_REAL value.

  IDX_DATA - Legacy Billed Procedures
  ORDER_PROC - Ordered Procedures
  TDL_TRAN - Billed Procedures
  SURGICAL_HX - Surgical History

  Copyright (c) 2014-2017 Weill Cornell Medical College
  */
 
use <prefix>i2b2demodata;

select top 0 ENCOUNTER_NUM
			,CONCEPT_CD
			,INSTANCE_NUM
			,[START_DATE]
			,MODIFIER_CD
			,VALTYPE_CD
			,TVAL_CHAR
			,SOURCESYSTEM_CD
INTO #OBS_FACT FROM DBO.OBSERVATION_FACT;

ALTER TABLE #OBS_FACT ALTER COLUMN ENCOUNTER_NUM VARCHAR(30);

-- ORDER_PROC and its modifiers
INSERT INTO #OBS_FACT
SELECT   ops.encounter_ide
	   , CONCEPT_CD
	   , 1 AS INSTANCE_NUM
	   , ORDERING_DATE
	   , 'CPT:ORDER_PROC'
	   , 'T' AS VALTYPE_CD
	   , coalesce([modifier],'Unknown') AS TVAL_CHAR
	   , 'EPIC' AS SOURCESYSTEM_CD
FROM SUPER_STAGING.dbo.ORDER_PROC_SLIM ops
INNER JOIN (
	SELECT encounter_num
		, CAST(ENCOUNTER_IDE AS VARCHAR(20)) encounter_ide
	FROM encounter_mapping
	WHERE SOURCESYSTEM_CD = 'EPIC'
	) E
	ON E.ENCOUNTER_IDE = ops.encounter_ide
where ops.encounter_ide is not null;

INSERT INTO #OBS_FACT
SELECT   OPS.encounter_ide
	   , CONCEPT_CD
	   , 1 AS INSTANCE_NUM
	   , ORDERING_DATE
	   , case when INOUT_CD = 'INPATIENT' THEN 'CPT:INPATPROC'
			  WHEN INOUT_CD = 'OUTPATIENT' THEN 'CPT:OUTPATPROC' END AS MODIFIER_CD
	   , '@' AS VALTYPE_CD
	   , null AS TVAL_CHAR
	   , 'EPIC' AS SOURCESYSTEM_CD
FROM SUPER_STAGING.dbo.ORDER_PROC_SLIM ops
inner JOIN (SELECT ENCOUNTER_NUM, ENCOUNTER_IDE FROM ENCOUNTER_MAPPING WHERE SOURCESYSTEM_CD = 'EPIC') WEM
	ON wem.ENCOUNTER_IDE = ops.encounter_ide
INNER JOIN (select ENCOUNTER_NUM, INOUT_CD FROM VISIT_DIMENSION) VD ON WEM.ENCOUNTER_NUM = VD.ENCOUNTER_NUM;

-- TDL_TRAN and its modifiers
INSERT INTO #OBS_FACT
SELECT   PAT_ENC_CSN_ID
	   , CPT_CODE
	   , 1 AS INSTANCE_NUM
	   , ORIG_SERVICE_DATE
	   , 'CPT:TDL_TRAN'
	   , '@' AS VALTYPE_CD
	   , null AS TVAL_CHAR
	   , 'EPIC' AS SOURCESYSTEM_CD
FROM SUPER_STAGING.DBO.TDL_TRAN_SLIM [TDL]
INNER JOIN (
	SELECT cast(encounter_num as varchar(30)) encounter_num
		 , cast(encounter_ide as varchar(30)) encounter_ide
	FROM encounter_mapping
	WHERE SOURCESYSTEM_CD = 'EPIC'
	) E
	ON ENCOUNTER_IDE = PAT_ENC_CSN_ID;

INSERT INTO #OBS_FACT
SELECT   PAT_ENC_CSN_ID
	   , CPT_CODE
	   , 1 AS INSTANCE_NUM
	   , ORIG_SERVICE_DATE
	   , case when INOUT_CD = 'INPATIENT' THEN 'CPT:INPATPROC'
			  WHEN INOUT_CD = 'OUTPATIENT' THEN 'CPT:OUTPATPROC' END AS MODIFIER_CD
	   , '@' AS VALTYPE_CD
	   , null AS TVAL_CHAR
	   , 'EPIC' AS SOURCESYSTEM_CD
FROM SUPER_STAGING.DBO.TDL_TRAN_SLIM [TDL]
INNER JOIN (
	SELECT encounter_num
		, CAST(ENCOUNTER_IDE AS VARCHAR(20)) encounter_ide
	FROM encounter_mapping
	WHERE SOURCESYSTEM_CD = 'EPIC'
	) E
	ON ENCOUNTER_IDE = CAST(PAT_ENC_CSN_ID AS VARCHAR(20))
INNER JOIN VISIT_DIMENSION VD ON e.ENCOUNTER_NUM = VD.ENCOUNTER_NUM;

-- IDX and its modifiers
INSERT INTO #OBS_FACT
SELECT DISTINCT PAT_ENC_CSN_ID
	, 'CPT:' + CPT_CODE
	, 1 AS INSTANCE_NUM
	, SERVICE_DATE
	, CASE WHEN ENCOUNTER_IDE_SOURCE = 'PAT_ENC' THEN 'CPT:TDL_TRAN' ELSE 'CPT:IDX' END AS MODIFIER_CD	   
	, '@' AS VALTYPE_CD
	, null AS TVAL_CHAR
	, 'IDX' AS SOURCESYSTEM_CD
FROM SUPER_STAGING.DBO.IDX_DATA_SLIM IDX
inner join (  select encounter_num,  CAST(ENCOUNTER_IDE AS VARCHAR(20)) encounter_ide, ENCOUNTER_IDE_SOURCE from encounter_mapping where ENCOUNTER_IDE_SOURCE in ( 'PAT_ENC', 'IDX' )  ) E 
	ON encounter_ide = CAST(PAT_ENC_CSN_ID AS VARCHAR(20))
WHERE INSTANCE_NUM = 1 AND CPT_CODE <> '';

create index [cover] on #obs_fact (sourcesystem_cd)
	include (encounter_num, concept_cd, instance_num, start_date, modifier_cd)

-- Modifiers
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
	, UPDATE_DATE
    , download_date
    , IMPORT_DATE
    , sourcesystem_cd
	)
SELECT [e].[ENCOUNTER_NUM]
 , PATIENT_NUM
 , CONCEPT_CD
 , PROVIDER_ID
 , [OF].[START_DATE]
 , MODIFIER_CD
 , INSTANCE_NUM
 , '@' AS VALUEFLAG_CD
 , '@' AS UNITS_CD
 , LOCATION_CD
 , UPDATE_DATE
 , download_date
 , IMPORT_DATE
 , [of].sourcesystem_cd
FROM #OBS_FACT [OF]
INNER JOIN encounter_mapping e
	ON CAST(try_cast(ENCOUNTER_IDE as bigint) AS VARCHAR(20)) = try_cast([OF].ENCOUNTER_NUM as bigint)
	and [of].sourcesystem_cd = e.SOURCESYSTEM_CD and e.SOURCESYSTEM_CD IN ('EPIC','IDX');

/*
 * There are many procedures in EPIC that are referrals and have no associated
 * encounter number. Represent these as facts with -1 for the encounter number
 */
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
	, UPDATE_DATE
    , download_date
    , IMPORT_DATE
    , sourcesystem_cd
	)
SELECT -1 ENCOUNTER_NUM
 , PATIENT_NUM
 , 'CPT:' + CAST(eap.proc_code AS VARCHAR) as CONCEPT_CD
 , '@' as PROVIDER_ID
 , ORDERING_DATE
 , '@' AS MODIFIER_CD
 , 1 AS INSTANCE_NUM
 , '@' AS VALUEFLAG_CD
 , '@' AS UNITS_CD
 , '@' as LOCATION_CD
 , pm.UPDATE_DATE
 , download_date
 , IMPORT_DATE
 , sourcesystem_cd
FROM SUPER_MONTHLY.dbo.ORDER_PROC ops
inner join PATIENT_MAPPING pm on PAT_ID = PATIENT_IDE and sourcesystem_cd = 'EPIC'
INNER JOIN SUPER_MONTHLY.DBO.CLARITY_EAP EAP ON OPs.PROC_ID = EAP.PROC_ID
where ops.pat_enc_csn_id is null and ops.ORDER_PROC_ID not in (
	 SELECT distinct ORDER_PROC_ID FROM [SUPER_MONTHLY].[dbo].[ORDER_PROC] op
  inner join super_monthly.dbo.PAT_ENC pe on [op].[pat_id] = [pe].[pat_id] and LEFT(OP.PAT_ENC_DATE_REAL, 5) = LEFT(PE.PAT_ENC_DATE_REAL, 5)
  INNER JOIN SUPER_MONTHLY.DBO.CLARITY_EAP EAP ON OP.PROC_ID = EAP.PROC_ID
  LEFT JOIN [SUPER_MONTHLY].[dbo].ZC_ORDER_STATUS [os] on [os].order_status_c = [op].order_status_c
  where op.pat_enc_csn_id is null and op.pat_id is not null	and pe.PAT_ENC_DATE_REAL is null);

drop table #OBS_FACT;