/*
  Entries about patients and associated identifiable information for CREST subjects.
 */

use <prefix>i2b2demodata;

-- Patients as recorded from CREST
-- Entries in this table have a concept code to enable searches via metadata
insert into patient_dimension
(patient_num, vital_status_cd, birth_date, death_date, sex_cd,
 age_in_years_num, language_cd, race_cd, MARITAL_STATUS_CD, RELIGION_CD,
 STATECITYZIP_PATH, INCOME_CD, PATIENT_BLOB, UPDATE_DATE, DOWNLOAD_DATE,
 IMPORT_DATE, SOURCESYSTEM_CD, UPLOAD_ID, state_cd, ethnicity_cd)
select distinct GLOBAL_ID as patient_num
       , isnull( (select case when zcp.name = 'Alive' then 'ND' when zcp.name = 'Deceased' then 'YD' end) , 'UD' ) as vital_status_cd
       , pat.birth_date as birth_date
	   , pat.death_date as death_date
	   , isnull(zcs.name, '@') as sex_cd
	   , datediff( year, pat.birth_date, isnull(pat.death_date, getDate()) ) as age_in_years_num
	   , isnull(zcl.name, '@') as language_cd
	   , isnull(zcrace.name, '@') as race_cd
	   , isnull(zcms.name, '@') as marital_status_cd
	   , isnull(zcr.name, '@') as religion_cd
	   , left(pat.zip, 5) as statecityzip_path
	   , null as income_cd
	   , '' as patient_blob
	   , pat.update_date
	   , getDate() as download_date
	   , getDate() as import_date
	   , 'CREST'  as sourcesystem_cd
	   , null as upload_id
	   , isnull(pat.city, '@') as state_cd -- state_cd is a custom field 
	   , isnull(zceg.name, '@') as ethnicity_cd
from  heroni2b2imdata.dbo.im_mpi_mapping imm
inner join ( select patient_num,  patient_ide from patient_mapping where SOURCESYSTEM_CD = 'CREST' )  wpm on imm.global_id = patient_num
inner join ( select pat_id, identity_id from super_monthly.dbo.identity_id where identity_type_id = 3 ) [id] on [id].IDENTITY_ID = wpm.patient_ide
inner join super_monthly.dbo.patient pat on id.pat_id = pat.pat_id
OUTER APPLY
    (
        SELECT TOP 1 patient_race_c
        FROM super_monthly.dbo.patient_race patr
        WHERE patr.pat_id = pat.pat_id
    ) patr -- selects only one record from patient_race to avoid 
	       -- importing duplicate records 
left join super_monthly.dbo.zc_sex zcs on pat.sex_c = zcs.RCPT_MEM_SEX_C
left join super_monthly.dbo.zc_language zcl on pat.LANGUAGE_C = zcl.LANGUAGE_C
left join super_monthly.dbo.zc_religion zcr on pat.RELIGION_C = zcr.religion_c
left join super_monthly.dbo.zc_ethnic_group zceg on pat.ETHNIC_GROUP_C = zceg.ethnic_group_c
left join super_monthly.dbo.zc_marital_status zcms on pat.MARITAL_STATUS_C = zcms.marital_status_c
left join super_monthly.dbo.zc_state zcst on pat.state_c = zcst.state_c
left join super_monthly.dbo.zc_patient_race zcrace on patr.patient_race_c = zcrace.patient_race_c
left join super_monthly.dbo.zc_patient_status zcp on zcp.patient_status_c = pat.pat_status_c
where datediff( year, pat.birth_date, isnull(pat.death_date, getDate()) ) >= 0;