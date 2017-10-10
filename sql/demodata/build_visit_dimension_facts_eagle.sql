/* 
   Integrates the encounters from AllScripts with encounters stored in I2B2.
 
   Copyright (c) 2014-2017 Weill Cornell Medical College
 */

use <prefix>i2b2demodata;

INSERT INTO visit_dimension (
	  encounter_num
	, patient_num
	, active_status_cd
	, start_date
	, end_date
	, inout_cd
	, location_cd
	, location_path
	, length_of_stay
	, update_date
	, download_date
	, import_date
	, sourcesystem_cd
	, enc_type_path
	)
SELECT encounter_num
	, patient_num
	, 'U*B' AS active_status_cd
	, [admit_date] AS start_date
	, [DISCHARGE_DATE] AS end_date
	, [patient_class_code] as inout_cd
	, location_cd
	, COALESCE(C_FULLNAME, '@') LOCATION_PATH
	, datediff(minute, [ADMIT_DATE], [DISCHARGE_DATE]) -- appointment length is calculated in minutes
	, getDate()
	, getDate()
	, getDate()
	, 'EAGLE'
	, '@'
FROM (
	SELECT DISTINCT ACCOUNT
		, PATIENT_ID
		, try_cast([ADMIT_DATE] AS DATE) admit_date
		, try_cast([DISCHARGE_DATE] AS DATE) discharge_date
		, [case_status_code]
		, 'OUTPATIENT' as [patient_class_code]
	FROM [CDW].[NICKEAST].[VISIT] Vi
	inner join cdw.nickeast.CODE_PATIENT_CLASS c on vi.PATIENT_CLASS_CODE = c.PATIENT_CLASS_CODE
	WHERE C.PATIENT_CLASS_CODE IN ('A', 'O', 'S')

	UNION

	SELECT DISTINCT ACCOUNT
		, PATIENT_ID
		, try_cast([ADMIT_DATE] AS DATE) admit_date
		, try_cast([DISCHARGE_DATE] AS DATE) discharge_date
		, [case_status_code]
		, 'INPATIENT' as [patient_class_code]
	FROM [CDW].[NICKEAST].[VISIT] Vi
	inner join cdw.nickeast.CODE_PATIENT_CLASS c on vi.PATIENT_CLASS_CODE = c.PATIENT_CLASS_CODE
	WHERE C.PATIENT_CLASS_CODE IN ('E', 'I')

	) V
INNER JOIN (
	SELECT DISTINCT encounter_ide
		, encounter_num
		, patient_num
		, LOCATION_CD
	FROM ENCOUNTER_MAPPING
	WHERE SOURCESYSTEM_CD = 'EAGLE'
	) em
	ON encounter_ide = account
LEFT JOIN <prefix>i2b2metadata.dbo.i2b2 [i] on  location_cd = [i].c_basecode;