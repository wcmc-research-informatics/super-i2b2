/* 
   Integrates the encounters from AllScripts with encounters stored in I2B2.
 
   Copyright (c) 2014-2017 Weill Cornell Medical College
 */

use <prefix>i2b2demodata;

-- Go against CompuRecord and associate new encounters with our patients in I2B2. acct_no from CompuRecord
-- is used as the encounter_ide. We first insert encounters for patients which only exist in CompuRecord
INSERT INTO visit_dimension
(
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
	  , enc_type_path)
SELECT encounter_num
	, patient_num
	, 'U*B' AS active_status_cd
	, admitdtm AS start_date
	, dischargedtm AS end_date
	, 'INPATIENT' -- all compurecord data is inpatient data
	, location_cd
	, COALESCE(C_FULLNAME, '@') as location_path
	, datediff(minute, admitdtm, dischargedtm) -- appointment length is calculated in minutes
	, getDate()
	, getDate()
	, getDate()
	, 'ECLIPSYS'
	, '@' as enc_type_path
FROM (
	SELECT DISTINCT ClientIDCode as [MRN]
		, replace(substring(VisitIDCode, patindex('%[^0]%',VisitIDCode),len(VisitIDCode)), ' ', '') as AccountNUM
		, cast([ADMITDTM] AS DATE) [admitdtm]
		, cast([DISCHARGEDTM] AS DATE) [dischargedtm]
		, cve.VisitStatus
	FROM Jupiter.JupiterSCM.CV3ClientVisit_East cve
	join Jupiter.JupiterSCM.CV3ClientID_East cie on cie.ClientGUID = cve.ClientGUID
	   and cie.TypeCode = 'Hospital MRN1' and IDStatus = 'ACT'
	   and visitidcode <> '000000000 000       ' and cve.TypeCode = 'Inpatient'
	   and visitstatus <> 'CAN' -- canceled?
	) v
INNER JOIN (
	SELECT DISTINCT encounter_ide
		, encounter_num
		, patient_num
		, LOCATION_CD
	FROM ENCOUNTER_MAPPING
	WHERE SOURCESYSTEM_CD = 'ECLIPSYS'
	) em
	ON encounter_ide = AccountNUM
LEFT JOIN heroni2b2metadata.dbo.i2b2 [i] on  location_cd = [i].c_basecode;