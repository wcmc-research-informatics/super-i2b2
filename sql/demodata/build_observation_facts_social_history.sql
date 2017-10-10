/* 
 *
 *  Creates a table in the staging database that holds demographics information that will be
 *  inserted into OBSERVATION_FACT.
 *
 *  Copyright (c) 2014-2017 Weill Cornell Medical College
 */
 
use <prefix>i2b2demodata;


----------------------------------------- Social History ---------------------------------------------------                      
                      
insert into observation_fact
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
	, end_date
	, location_cd
	, update_date
	, download_date
	, import_date
	, sourcesystem_cd
	)
SELECT em.encounter_num AS encounter
	, em.patient_num
	, 'HIST:' + soc.field AS concept_cd
	, provider_id
	, soc.contact_date AS start_date
	, '@' AS modifier_cd
	, 1 AS instance_num
	, CASE WHEN TRY_CONVERT(FLOAT, SOC.VALUE) IS NOT NULL THEN 'N' ELSE 'T' END as valtype_cd
	, CASE WHEN TRY_CONVERT(FLOAT, SOC.VALUE) IS NOT NULL THEN 'E' ELSE SOC.VALUE END as tval_char
	, CASE WHEN TRY_CONVERT(FLOAT, SOC.VALUE) IS NOT NULL THEN try_convert(FLOAT, soc.value) ELSE NULL END as nval_num
	, '@' AS valueflag_cd
	, '@' AS units_cd
	, soc.CONTACT_DATE AS end_date
	, location_cd
	, update_date
	, download_date
	, import_date
	, sourcesystem_cd
FROM social_data soc
inner join encounter_mapping em
	ON em.encounter_ide = pat_enc_csn_id and sourcesystem_cd = 'EPIC'
	where soc.field IN (
				  'SMOKING_QUIT_DATE'
				, 'SMOKELESS_QUIT_DATE'
				, 'CONDOM_YN'
				, 'PILL_YN'
				, 'DIAPHRAGM_YN'
				, 'IUD_YN'
				, 'SURGICAL_YN'
				, 'SPERMICIDE_YN'
				, 'IMPLANT_YN'
				, 'RHYTHM_YN'
				, 'INJECTION_YN'
				, 'FEMALE_PARTNER_YN'
				, 'MALE_PARTNER_YN'
				, 'SPONGE_YN'
				, 'INSERTS_YN'
				, 'ABSTINENCE_YN'
				, 'CIGARETTES_YN'
				, 'CHEW_YN'
				, 'CIGARS_YN'
				, 'PIPES_YN'
				, 'SNUFF_YN'
				, 'TOBACCO_USED_YEARS'
				, 'TOBACCO_PAK_PER_DY'
				, 'ILL_DRUG_USER_C'
				, 'ALCOHOL_USE_C'
				, 'SEXUALLY_ACTIVE_C'
				, 'ALCOHOL_OZ_PER_WK'
				, 'ILLICIT_DRUG_FREQ'
				, 'IV_DRUG_USER_YN'
				);

insert into observation_fact
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
	, end_date
	, location_cd
	, update_date
	, download_date
	, import_date
	, sourcesystem_cd
	)
SELECT em.encounter_num AS encounter
	, em.patient_num
	, 'HIST:' + soc.field AS concept_cd
	, provider_id
	, soc.contact_date AS start_date
	, '@' AS modifier_cd
	, 1 AS instance_num
	, 'T' as valtype_cd
	, soc.value as tval_char
	, null as nval_num
	, '@' AS valueflag_cd
	, '@' AS units_cd
	, soc.CONTACT_DATE AS end_date
	, location_cd
	, update_date
	, download_date
	, import_date
	, sourcesystem_cd
FROM social_data soc
inner join encounter_mapping em
	ON em.encounter_ide = pat_enc_csn_id and sourcesystem_cd = 'EPIC'
	where soc.field IN (
				  'TOBACCO_USER_C'
				, 'SMOKING_TOB_USE_C'
				, 'SMOKELESS_TOB_USE_C'
				);


				
				  