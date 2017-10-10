/**
 * Create facts and modifiers for procedures collected from SURGICAL_HX.
 * There are no null encounters in SURGICAL_HX.
 
  Copyright (c) 2014-2017 Weill Cornell Medical College
 */

use <prefix>i2b2demodata;

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
	, download_date
	, import_date
	, sourcesystem_cd
	)
SELECT wem.encounter_num
	, wem.patient_num
	, concept_cd
	, provider_id
	, shx.[contact_date]
	, '@' AS modifier_cd
	, line AS instance_num
	, '@' AS valueflag_cd
	, '@' AS units_cd
	, location_cd
	, update_date
	, download_date
	, import_date
	, sourcesystem_cd
FROM (
	SELECT pat_id
		, cast(s.pat_enc_csn_id AS VARCHAR(20)) pat_enc_csn_id
		, line
		, concept_cd
			-- Take date reported surgical encounter occurred if available, otherwise use the contact_date
			-- when this information was recorded
		, coalesce(try_cast([SURGICAL_HX_DATE] AS DATETIME), CONTACT_DATE) AS [contact_date]
	FROM [SUPER_MONTHLY].[dbo].[SURGICAL_HX] s
	INNER JOIN [SUPER_STAGING].[dbo].I2B2_PROC_MAPPING IPM ON IPM.PROC_CODE = S.PROC_CODE
	) shx
inner join encounter_mapping wem
	ON wem.encounter_ide = pat_enc_csn_id and sourcesystem_cd = 'EPIC';


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
	, download_date
	, import_date
	, sourcesystem_cd
	)
select wem.encounter_num
	,  wem.patient_num
	,  concept_cd
	,  provider_id
	,  shx.[contact_date]
	,  'CPT:SURGICAL_HX' as modifier_cd
	,  line as instance_num
	,  '@' as valueflag_cd
	,  '@' as units_cd
	,  location_cd
	, update_date
	, download_date
	, import_date
	, sourcesystem_cd
FROM (
	SELECT pat_id
		, cast(s.pat_enc_csn_id AS VARCHAR(20)) pat_enc_csn_id
		, line
		, concept_cd
			-- Take date reported surgical encounter occurred if available, otherwise use the contact_date
			-- when this information was recorded
		, coalesce(try_cast([SURGICAL_HX_DATE] AS DATETIME), CONTACT_DATE) AS [contact_date]
	FROM [SUPER_MONTHLY].[dbo].[SURGICAL_HX] s
	INNER JOIN [SUPER_STAGING].[dbo].I2B2_PROC_MAPPING IPM ON IPM.PROC_CODE = S.PROC_CODE
	) shx
inner join encounter_mapping wem
	ON wem.encounter_ide = pat_enc_csn_id and sourcesystem_cd = 'EPIC';
