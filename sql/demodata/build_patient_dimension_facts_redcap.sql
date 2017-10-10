/*
 * Builds entries in patient dimension for patient information taken from REDCap.
 * For patients with overlap copy already existing information and change 
 * sourcesystem. For patients with no overlap try to get information but
 * substitute with UNKNOWN when not found
 * Copyright (c) 2014-2017 Weill Cornell Medical College
 */

use heroni2b2demodata;

-- Patients with overlap
--insert into patient_dimension(
--	patient_num
--	, vital_status_cd
--	, birth_date
--	, death_date
--	, sex_cd
--	, age_in_years_num
--	, language_cd
--	, race_cd
--	, MARITAL_STATUS_CD
--	, RELIGION_CD
--	, STATECITYZIP_PATH
--	, INCOME_CD
--	, UPDATE_DATE
--	, DOWNLOAD_DATE
--	, IMPORT_DATE
--	, SOURCESYSTEM_CD
--	, state_cd
--	, ethnicity_cd
--	)
--select patient_num
--	,  vital_status_cd
--	,  birth_date
--	,  death_date
--	,  sex_cd
--	,  age_in_years_num
--	,  language_cd
--	,  race_cd
--	,  marital_status_cd
--	,  religion_cd
--	,  statecityzip_path
--	,  income_cd
--	,  getDate() as update_date
--	,  download_date
--	,  import_date
--	,  'REDCAP' AS SOURCESYSTEM_CD
--	,  state_cd
--	,  ethnicity_cd
--from patient_dimension where patient_num in (
--	select distinct patient_num from encounter_mapping w
--	where SOURCESYSTEM_CD = 'REDCAP'
--)


-- Patients without overlap
INSERT INTO patient_dimension (
	patient_num
	, vital_status_cd
	, birth_date
	, sex_cd
	, language_cd
	, race_cd
	, MARITAL_STATUS_CD
	, RELIGION_CD
	, STATECITYZIP_PATH
	, INCOME_CD
	, UPDATE_DATE
	, DOWNLOAD_DATE
	, IMPORT_DATE
	, SOURCESYSTEM_CD
	, state_cd
	, ethnicity_cd
	)
SELECT DISTINCT patient_num
	, 'UD' AS vital_status_cd
	, coalesce([birth_date], '1776-07-04') birth_date
	, coalesce([sex], '@') AS sex_cd -- use epic code for now
	, '@' AS language_cd
	, coalesce([race], '@') AS race_cd
	, '@' AS marital_status_cd
	, '@' AS religion_cd
	, '@' AS statecityzip_path
	, '@' AS income_cd
	, getDate() AS update_date
	, getDate() AS download_date
	, getDate() AS import_date
	, 'REDCAP' AS SOURCESYSTEM_CD
	, '@' AS state_cd
	, coalesce([eth], '@') AS ethnicity_cd
FROM (
	SELECT DISTINCT im.global_id AS patient_num
		, lcl_id AS nyp_mrn
		, lcl_site
		, p.patient_ide
		, pref.PROJECT_ID
	FROM patient_mapping p
	INNER JOIN heroni2b2imdata.dbo.IM_MPI_MAPPING im
		ON im.GLOBAL_ID = p.patient_num
	INNER JOIN heronI2B2IMDATA.DBO.IM_PROJECT_PATIENTS IMPP
		ON IM.GLOBAL_ID = IMPP.GLOBAL_ID
	INNER JOIN heroni2b2pm.dbo.PREFIX_MAPPINGS pref
		ON pref.project_id = impp.project_id
	WHERE prefix = 'heron'
		AND lcl_site = 'WCM'
		AND p.sourcesystem_cd = 'REDCAP'
	) w
LEFT JOIN (
	SELECT DISTINCT patient_num AS patnum
		, value AS [birth_date]
	FROM super_Staging.dbo.min_mrn mm
	LEFT JOIN patient_mapping w
		ON mm.pat_id = w.patient_ide
	INNER JOIN super_staging.dbo.redcap_data_adj r1
		ON cast(concat(r1.project_id,r1.event_id,r1.record) as varchar) = cast(mm.redcapencounter as varchar)
	WHERE field_name LIKE '%birth%date'
		-- captures 'birthdate' and variations like 'birth date' and 'birth_date'
		-- but not variations such as 'birth_date_e'
	) [rcbdate]
	ON patient_num = [rcbdate].patnum
-- Need to restrict to universe of redcap patients. Without this join we are comparing
-- all patients in heron project and these patients can come from many different EMRs
-- However if the same patient is recorded once across multiple projects this patient
-- will have multiple entries in this table as each REDCap form can store different
-- information about this patient
inner join super_staging.dbo.min_mrn mm on mm.any_mrn = w.nyp_mrn
inner join super_staging.dbo.redcap_data_adj r1 on cast(concat(r1.project_id,r1.event_id,r1.record) as varchar) = cast(mm.redcapencounter as varchar)
left join (
					select distinct patient_num as patnum, r1.project_id, case
							-- Must go against metadata to define what source values for Male and Female
							-- are per project. Easiest to extract this info from c_symbol
							-- Predicate with c_basecode implicitly filters out NULL
							-- Project ID enables us to uniquely identify this field even when multiple
							-- projects use the same field_name
							when value = (select left(c_symbol, len(c_symbol) - 1) 
							              from heroni2b2metadata.dbo.custom_meta
							              where C_FULLNAME like '\i2b2\REDCap\' + cast(r1.project_id as varchar(5)) 
																			  + '%race\' + value + '\')							  
								 then (select c_basecode
							              from heroni2b2metadata.dbo.custom_meta
							              where C_FULLNAME like '\i2b2\REDCap\' + cast(r1.project_id as varchar(5)) 
																			  + '%race\' + value + '\')	
							else '@' end as [race] 
					from super_Staging.dbo.min_mrn mm
					inner join patient_mapping w on mm.pat_id = w.patient_ide
					inner join super_staging.dbo.redcap_data_adj r1 on cast(concat(r1.project_id,r1.event_id,r1.record) as varchar) = cast(mm.redcapencounter as varchar)
					where field_name = 'race'
					-- it is tempting to use gender_e but not all projects have this available
					-- gender and sex will both try to map either gender or sex exactly but will not catch
					-- variations
			) [rcrace] on patient_num = [rcrace].patnum and [rcrace].project_id = r1.project_id
left join (
					select distinct patient_num as patnum, r1.project_id, case
							-- Must go against metadata to define what source values for Male and Female
							-- are per project. Easiest to extract this info from c_symbol
							-- Predicate with c_basecode implicitly filters out NULL
							-- Project ID enables us to uniquely identify this field even when multiple
							-- projects use the same field_name
							when value = (select left(c_symbol, len(c_symbol) - 1) 
							              from heroni2b2metadata.dbo.custom_meta
							              where C_FULLNAME like '\i2b2\REDCap\' + cast(r1.project_id as varchar(5)) 
																			  + '%ethnicity\' + value + '\')							  
								 then (select c_basecode
							              from heroni2b2metadata.dbo.custom_meta
							              where C_FULLNAME like '\i2b2\REDCap\' + cast(r1.project_id as varchar(5)) 
																			  + '%ethnicity\' + value + '\')	
							else '@' end as [eth] 
					from super_Staging.dbo.min_mrn mm
					inner join patient_mapping w on mm.pat_id = w.patient_ide
					inner join super_staging.dbo.redcap_data_adj r1 on cast(concat(r1.project_id,r1.event_id,r1.record) as varchar) = cast(mm.redcapencounter as varchar)
					where field_name like '%ethnicity'
			) [rceth] on patient_num = [rceth].patnum and [rceth].project_id = r1.project_id
left join (
					select distinct patient_num as patnum, r1.project_id, case 
							-- Must go against metadata to define what source values for Male and Female
							-- are per project. Easiest to extract this info from c_symbol
							-- Predicate with c_basecode implicitly filters out NULL
							-- Project ID enables us to uniquely identify this field even when multiple
							-- projects use the same field_name
							when value = (select left(c_symbol, len(c_symbol) - 1) 
										  from heroni2b2metadata.dbo.custom_meta where c_name = 'Male'
										  and c_basecode like 'REDCAP:' + cast(r1.project_id as varchar(5)) + '%') then (select c_basecode
																														 from heroni2b2metadata.dbo.custom_meta where c_name = 'Male'
																														 and c_basecode like 'REDCAP:' + cast(r1.project_id as varchar(5)) + '%')
							when value = (select left(c_symbol, len(c_symbol) - 1) 
										  from heroni2b2metadata.dbo.custom_meta where c_name = 'Female'
										  and c_basecode like 'REDCAP:' + cast(r1.project_id as varchar(5)) + '%') then (select c_basecode
																														 from heroni2b2metadata.dbo.custom_meta where c_name = 'Female'
																														 and c_basecode like 'REDCAP:' + cast(r1.project_id as varchar(5)) + '%')
							else '@' end as [sex] 
					from super_Staging.dbo.min_mrn mm
					inner join patient_mapping w on mm.pat_id = w.patient_ide
					inner join super_staging.dbo.redcap_data_adj r1 on cast(concat(r1.project_id,r1.event_id,r1.record) as varchar) = cast(mm.redcapencounter as varchar)
					where field_name in ('gender', 'sex')
					-- it is tempting to use gender_e but not all projects have this available
					-- gender and sex will both try to map either gender or sex exactly but will not catch
					-- variations
			) [rcsex] on patient_num = [rcsex].patnum and [rcsex].project_id = r1.project_id
where patient_num not in (select patient_num from patient_dimension);	