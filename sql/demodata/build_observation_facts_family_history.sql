/*
  Builds observation facts for family history information from EPIC Clarity schema. 
 */
 
use <prefix>i2b2demodata;

/*
 * We want to compare against the link id before falling back to the
 * encounter id for family history. Putting the ISNULL() into the predicate
 * makes the query non-SARGable and kills performance. We fix this 
 * by preparing a new temporary table and indexing this first
 */
SELECT cast(coalesce(hx_lnk_enc_csn, pat_enc_csn_id) AS VARCHAR(20)) AS enc_id
	, isnull(contact_date, CALENDAR_DT) AS contact_date
	, 'HIST:FAM:' + cast(MEDICAL_HX_C AS VARCHAR) AS concept_cd
	, 'MOD:FAM:' + relation_c AS modifier_cd
INTO #familyhx
FROM super_monthly.dbo.family_hx
INNER JOIN SUPER_MONTHLY.DBO.DATE_DIMENSION 
		ON PAT_ENC_DATE_REAL = EPIC_DTE
WHERE MEDICAL_HX_C > 0 	AND RELATION_C > 0;


create nonclustered index pk_familyhx on #familyhx ([enc_id]) include ([contact_date], [concept_cd], [modifier_cd]);

INSERT INTO observation_fact
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
SELECT em.encounter_num
	, em.patient_num
	, concept_cd
	, provider_id
	, HX.contact_date AS start_date
	, '@' AS modifier_cd
	, 1 AS instance_num
	, '@' AS valueflag_cd
	, '@' AS units_cd
	, location_cd
	, update_date
	, download_date
	, import_date
	, sourcesystem_cd
FROM #familyhx hx
inner join encounter_mapping em
	ON em.encounter_ide = enc_id and sourcesystem_cd = 'EPIC'


INSERT INTO observation_fact
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
SELECT em.encounter_num
	, em.patient_num
	, concept_cd
	, provider_id
	, HX.contact_date
	, modifier_cd
	, 1 AS instance_num
	, '@' AS valueflag_cd
	, '@' AS units_cd
	, location_cd
	, update_date
	, download_date
	, import_date
	, sourcesystem_cd
FROM #familyhx hx
inner join encounter_mapping em
	ON em.encounter_ide = enc_id and sourcesystem_cd = 'EPIC'

DROP TABLE #familyhx;
