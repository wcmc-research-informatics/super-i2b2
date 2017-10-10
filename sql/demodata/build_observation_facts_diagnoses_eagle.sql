/*

Builds facts about diagnoses from the CDW. Data from the CDW comes
from both ECLIPSYS [ECL] and EAGLE [NCK]. One is for inpatient billing, the
other for outpatient clinical purposes. Both contain ICD9 and ICD10 codes so
two passes need to be taken, once for each code. For ICD9, we map
to the minimum DX_ID from EPIC to maintain consistent representation 
in i2b2 without duplication of facts.

  Copyright (c) 2014-2017 Weill Cornell Medical College
 */

use <prefix>i2b2demodata;

/*
 * Model Eagle ICD9 Diagnosis. While modeling this data we ran into issues processing
 * the field PRIMARY_TIME since it is stored as a varchar(255). We got around this by
 * assuming all values in that column have the same number of characters and then do
 * clever substitution to replace certain values in the string. The goal is to
 * transform the string into datetime format and then cast it properly. This only removes
 * the three least significant digits from the seconds since datetime cannot handle
 * nanoseconds to six digits.
 */

SELECT TOP 0 ENCOUNTER_NUM
	, PATIENT_NUM
	, CONCEPT_CD
	, MODIFIER_CD
	, [START_DATE]
INTO #obs_fact FROM DBO.OBSERVATION_FACT;

INSERT INTO #obs_fact
SELECT ENCOUNTER_NUM
	 , PATIENT_NUM
	 , 'ICD9:' + cast(DX_ID AS VARCHAR) AS CONCEPT_CD
	 , 'ICD9:DXCODES' AS MODIFIER_CD
	 , cast([PRIMARY_TIME] as datetime) AS [START_DATE]  
FROM [CDW].[NICKEAST].[VISIT_DIAGNOSIS] vd
INNER JOIN (
	SELECT distinct encounter_num
		, patient_num
		, cast(encounter_ide AS VARCHAR(16)) [encounter_ide]
		, [CONTACT_DATE]
	FROM ENCOUNTER_MAPPING
	WHERE [ENCOUNTER_IDE_SOURCE] = 'EAGLE'
	) EM
	ON ENCOUNTER_IDE = VD.ACCOUNT
		and [PRIMARY_TIME] = CONTACT_DATE
INNER JOIN (
	SELECT DISTINCT [ICD9_DIAGNOSIS_CODE]
		, min([dx_id]) AS dx_id
	FROM [CDW].[NICKEAST].[CODE_ICD9_DIAGNOSIS] [CID]
	INNER JOIN SUPER_MONTHLY.dbo.EDG_CURRENT_ICD9 edg
		ON [icd9_diagnosis_code] = [edg].[CODE] and line=1
	GROUP BY ICD9_DIAGNOSIS_CODE
	) [MAP]
	ON [MAP].ICD9_DIAGNOSIS_CODE = VD.DIAGNOSIS_CODE
WHERE code_type = 'I9'
	AND VD.DIAGNOSIS_CODE IS NOT NULL
	AND vd.DIAGNOSIS_CODE <> 'NOCODE';

INSERT INTO #OBS_FACT
SELECT ENCOUNTER_NUM
	 , PATIENT_NUM
	 , 'ICD10:' + cast(VD.DIAGNOSIS_CODE AS VARCHAR) AS CONCEPT_CD
	 , 'ICD10:DXCODES' AS modifier_cd
	 , [PRIMARY_TIME] AS [START_DATE]
FROM [CDW].[NICKEAST].[VISIT_DIAGNOSIS] VD
INNER JOIN (
	SELECT distinct encounter_num
		, patient_num
		, cast(encounter_ide AS VARCHAR(16)) [encounter_ide]
		, [contact_date]
	FROM ENCOUNTER_MAPPING
	WHERE [ENCOUNTER_IDE_SOURCE] = 'EAGLE'
	) EM
	ON ENCOUNTER_IDE = VD.ACCOUNT
		and [PRIMARY_TIME] = CONTACT_DATE
WHERE code_type = 'I10'
	AND VD.DIAGNOSIS_CODE IS NOT NULL
	AND vd.DIAGNOSIS_CODE <> 'NOCODE';

/*
 * Modifier for Diagnosis Codes to represent icd-9 Diagnoses from Eagle 
 */
INSERT INTO OBSERVATION_FACT (
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
SELECT ENCOUNTER_NUM
	, PATIENT_NUM
	, CONCEPT_CD
	, '@' AS PROVIDER_ID
	, [START_DATE]
	, MODIFIER_CD
	, 1 AS INSTANCE_NUM
	, '@' AS VALUEFLAG_CD
	, '@' AS UNITS_CD
	, '@' AS LOCATION_CD
	, GETDATE() AS UPDATE_DATE
	, GETDATE() AS IMPORT_DATE
	, 'EAGLE' AS SOURCESYSTEM_CD
FROM #obs_fact;

drop table #OBS_FACT;