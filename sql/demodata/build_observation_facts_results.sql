/* 
 *  Processes lab results from ORDER_RESULTS and turns them into facts for i2b2.
 *  When the PAT_ENC_CSN_ID value is missing, use ORDER_PROC_ID as a substitute
 *  and repurpose the ENCOUNTER_IDE_SOURCE value in ENCOUNTER_MAPPING to distinguish
 *  between the two. When the date is missing, join between ORD_DATE_REAL and
 *  EPIC_DTE in DATE_DIMENSION to find an approximate date to use as a substitute.
 * 
 *  Copyright (c) 2014-2017 Weill Cornell Medical College
 */

use <prefix>i2b2demodata;

INSERT INTO OBSERVATION_FACT
(
	  encounter_num
	, patient_num
	, concept_cd
	, provider_id
	, start_date
	, modifier_cd
	, instance_num
	, valtype_cd
	, tval_char
	, nval_num
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
	, case when ORD_NUM_VALUE <> '9999999' then 'LOINC:' +cast(loinc_code as varchar) 
	     when ORD_VALUE like 'NEG%' or ord_value like '%NONE%' or ord_value like 'NOS%' or ord_value like 'NO %'
               or ord_value like '%NOT %' or ord_value like 'NEGATIVE%'  
               or ord_value like 'NORMAL%'
               then 'LOINC:' +cast(loinc_code as varchar) + 'RES:Negative' 
         when ord_value like '%POSITIVE%' or ord_value like '%POS%' or ord_value like 'DETECTED%' or ord_value like '%Abnormal%'
               then 'LOINC:' +cast(loinc_code as varchar) + 'RES:Positive'
         else  'LOINC:' +cast(loinc_code as varchar) + 'RES:Other' end as concept_cd
	, PROVIDER_ID
	, RESULT_DATE AS [START_DATE]
	, '@' AS MODIFIER_CD
	, [LINE] AS INSTANCE_NUM
	, 'N' AS VALTYPE_CD
	, 'E' AS TVAL_CHAR
	, NULLIF(CAST(ORD_NUM_VALUE AS DECIMAL(18,5)), '9999999') NVAL_NUM
	, '@' AS VALUEFLAG_CD
	, '@' AS UNITS_CD
	, LOCATION_CD
	, EM.update_date
	, download_date
	, import_date
	, sourcesystem_cd
FROM SUPER_MONTHLY.DBO.ORDER_RESULTS RES
INNER JOIN SUPER_MONTHLY.DBO.ORDER_PROC ORP ON RES.ORDER_PROC_ID = ORP.ORDER_PROC_ID
LEFT JOIN SUPER_STAGING.DBO.SUPER_PATIENT_BLACKLIST SPB ON ORP.PAT_ID = SPB.BAD_VAL 
INNER JOIN SUPER_MONTHLY.DBO.CLARITY_COMPONENT CC ON RES.COMPONENT_ID = CC.COMPONENT_ID
INNER JOIN ENCOUNTER_MAPPING EM ON ENCOUNTER_IDE = ORP.PAT_ENC_CSN_ID 
WHERE LOINC_CODE IS NOT NULL AND RESULT_DATE IS NOT NULL 
	AND SOURCESYSTEM_CD = 'EPIC' AND BAD_VAL IS NULL AND ORP.PAT_ENC_CSN_ID IS NOT NULL

  
