/* 
   Populates the visit dimension table with all encounters from EPIC.
   PAT_ENC is used as the soruce table.

   Copyright (c) 2014-2017 Weill Cornell Medical College
 */

use <prefix>i2b2demodata;


-- Add all encounters from EPIC
INSERT INTO visit_dimension (
	encounter_num
	, patient_num
	, active_status_cd
	, start_date
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
SELECT e.encounter_num
	, patient_num
	, 'U*B' AS active_status_cd
	, isnull(e.contact_date, calendar_dt) as [start_date]
	, inout_cd
	, location_cd
	, isnull(c_fullname, '@') AS location_path
	, appt_length as [length_of_stay]
	, [update_date]
	, [download_date]
	, [import_date]
	, [sourcesystem_cd]
	, enc_type_path
FROM (
	-- hosp_admsn_status_c = 5 indicates an inpatient encounter
	-- which is more reliable than using ZC_DISP_ENC_TYPE
	SELECT pat.pat_enc_csn_id
		, case when HOSP_ADMSN_STATUS_C = 5 then 'INPATIENT' else 'OUTPATIENT' END AS inout_cd
		, appt_length
		, '\i2b2\Encounters\Type\' + abbr + '\' AS enc_type_path
		, [ENTRY_TIME]
		, left(pat_enc_date_real, 5) [pat_enc_date_real]
		, calendar_dt
	FROM super_monthly.dbo.pat_enc pat
	LEFT JOIN (
		SELECT pat_enc_csn_id
			, hosp_admsn_status_c
		FROM SUPER_MONTHLY.DBO.PAT_ENC_HSP_2
		) peh2
		ON pat.pat_enc_csn_id = peh2.pat_enc_csn_id
	INNER JOIN super_monthly.dbo.zc_disp_enc_type det
		ON det.disp_enc_type_c = pat.enc_type_c	
    LEFT JOIN SUPER_MONTHLY.DBO.DATE_DIMENSION D ON CAST(PAT_ENC_DATE_REAL as varchar) = cast(EPIC_DTE as varchar)
	UNION
	SELECT pat.pat_enc_csn_id
		, case when HOSP_ADMSN_STATUS_C = 5 then 'INPATIENT' else 'OUTPATIENT' END AS inout_cd
		, appt_length
		, '@' AS enc_type_path
		, [ENTRY_TIME]
		, left(pat_enc_date_real, 5) [pat_enc_date_real]
		, calendar_dt
	FROM super_monthly.dbo.pat_enc pat
	LEFT JOIN (
		SELECT pat_enc_csn_id
			, hosp_admsn_status_c
		FROM SUPER_MONTHLY.DBO.PAT_ENC_HSP_2
		) peh2
		ON pat.pat_enc_csn_id = peh2.pat_enc_csn_id
    LEFT JOIN SUPER_MONTHLY.DBO.DATE_DIMENSION D ON CAST(PAT_ENC_DATE_REAL as varchar) = cast(EPIC_DTE as varchar)
	WHERE ENC_TYPE_C IS NULL
	) pat
INNER JOIN encounter_mapping e
	ON encounter_ide = cast(pat_enc_csn_id as varchar) and SOURCESYSTEM_CD = 'EPIC'
LEFT JOIN (
	SELECT c_fullname
		, c_basecode
	FROM heroni2b2metadata.dbo.i2b2
	WHERE c_fullname LIKE '\i2b2\Encounters\Location%'
	) i2b2
	ON c_basecode = location_cd;
