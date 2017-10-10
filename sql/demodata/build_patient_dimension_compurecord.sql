/*
  Entries about patients and associated identifiable information for CREST subjects.
 */

use <prefix>i2b2demodata;

-- Patients as recorded from Compurecord
-- Entries in this table have a concept code to enable searches via metadata
insert into patient_dimension
	(patient_num, vital_status_cd, birth_date, sex_cd,
	age_in_years_num, language_cd, race_cd, MARITAL_STATUS_CD, RELIGION_CD,
	STATECITYZIP_PATH, INCOME_CD, PATIENT_BLOB, UPDATE_DATE, DOWNLOAD_DATE,
	IMPORT_DATE, SOURCESYSTEM_CD, state_cd, ethnicity_cd)
select distinct patient_num
       , 'UD' as vital_status_cd
       , birthdate as birth_date
	   , CASE WHEN GENDER = '10012' THEN 'Female' 
			  WHEN GENDER = '10011' THEN 'Male'
			  ELSE '@' END as sex_cd
	   , DATEDIFF( YEAR, BIRTHDATE, GETDATE() ) as age_in_years_num
	   , '@' as language_cd
	   , '@' as race_cd
	   , '@' as marital_status_cd
	   , '@' as religion_cd
	   , '@' as statecityzip_path
	   , null as income_cd
	   , '' as patient_blob
	   , (SELECT [create_date] FROM jupiter.sys.tables where name='Demographics') UPDATE_DATE
	   , (SELECT [create_date] FROM jupiter.sys.tables where name='Demographics') AS DOWNLOAD_DATE
	   , GETDATE() AS IMPORT_DATE
	   , 'COMPURECORD' as sourcesystem_cd
	   , '@' as state_cd -- state_cd is a custom field 
	   , '@' as ethnicity_cd
FROM ( select distinct GENDER, MIN(BIRTHDATE) BIRTHDATE, MEDICALRECORDNUMBER FROM [Jupiter].[Compurecord].[Demographics] GROUP BY GENDER, MEDICALRECORDNUMBER) cr
INNER JOIN HERONI2B2demodata.dbo.encounter_mapping 
	on cr.MEDICALRECORDNUMBER = patient_ide
WHERE sourcesystem_cd = 'COMPURECORD'
and patient_num not in (select patient_num from patient_dimension)