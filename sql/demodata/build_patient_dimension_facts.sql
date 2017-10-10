/**
 
  Entries about patients and associated identifiable information.

  Copyright (c) 2014-2017 Weill Cornell Medical College
 */

use <prefix>i2b2demodata;


-- Create the schema for the table. ##data_bog holds the raw information
-- from each source system as if that was the only source system to insert rows
-- into patient_dimension.
select top 0 * into ##data_bog from patient_dimension;

/*
 * All EPIC patients (2493073)
 */
INSERT INTO ##data_bog (
	patient_num
	, vital_status_cd
	, birth_date
	, death_date
	, sex_cd
	, age_in_years_num
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
SELECT DISTINCT p.patient_num AS patient_num
	, case when zcp.name = 'Alive' then 'ND'
		   when zcp.name = 'Deceased' then 'YD'
		   else 'U*D' end	
			 AS vital_status_cd
	, pat.birth_date AS birth_date
	, pat.death_date AS death_date
	, isnull(nullif(zcs.NAME, 'Unknown'), '@') AS sex_cd
	, datediff(year, pat.birth_date, isnull(pat.death_date, getDate())) AS age_in_years_num
	, isnull(nullif(zcl.NAME, 'Unknown'), '@') AS language_cd
	, isnull(nullif(nullif(zcrace.NAME, 'Unknown'),'Declined'), '@') AS race_cd
	, isnull(nullif(zcms.NAME, 'Unknown'), '@') AS marital_status_cd
	, isnull(nullif(zcr.NAME, 'Unknown'), '@') AS religion_cd
	, pat.city + '\' + pat.zip AS statecityzip_path
	, '@' AS income_cd
	, p.update_date
	, download_date
	, import_date
	, sourcesystem_cd
	, isnull(nullif(pat.city, 'Unknown'), '@') AS state_cd -- state_cd is a custom field 
	, isnull(nullif(zceg.NAME, 'Unknown'), '@') AS ethnicity_cd
FROM super_daily.dbo.patient AS pat
OUTER APPLY (
	SELECT TOP 1 patient_race_c
	FROM super_monthly.dbo.patient_race patr
	WHERE patr.pat_id = pat.pat_id
	) patr -- selects only one record from patient_race to avoid 
	-- importing duplicate records 
INNER JOIN patient_mapping p
	ON p.patient_ide = pat.pat_id and SOURCESYSTEM_CD = 'EPIC'
LEFT JOIN super_monthly.dbo.zc_sex zcs
	ON pat.sex_c = zcs.RCPT_MEM_SEX_C
LEFT JOIN super_monthly.dbo.zc_language zcl
	ON pat.LANGUAGE_C = zcl.LANGUAGE_C
LEFT JOIN super_monthly.dbo.zc_religion zcr
	ON pat.RELIGION_C = zcr.religion_c
LEFT JOIN super_monthly.dbo.zc_ethnic_group zceg
	ON pat.ETHNIC_GROUP_C = zceg.ethnic_group_c
LEFT JOIN super_monthly.dbo.zc_marital_status zcms
	ON pat.MARITAL_STATUS_C = zcms.marital_status_c
LEFT JOIN super_monthly.dbo.zc_state zcst
	ON pat.state_c = zcst.state_c
LEFT JOIN super_monthly.dbo.zc_patient_race zcrace
	ON patr.patient_race_c = zcrace.patient_race_c
LEFT JOIN super_monthly.dbo.zc_patient_status zcp
	ON zcp.patient_status_c = pat.pat_status_c
WHERE datediff(year, pat.birth_date, isnull(pat.death_date, getDate())) >= 0;

/*
 * All ECLIPSYS/JUPITER patients (1091930)
 */
INSERT INTO ##data_bog (
	patient_num
	, vital_status_cd
	, birth_date
	, death_date
	, sex_cd
	, age_in_years_num
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
SELECT DISTINCT p.patient_num AS patient_num
	, CASE WHEN DECEASEDDTM IS NOT NULL THEN 'YD' ELSE 'N*D' END AS vital_status_cd
	, [BIRTHDAY] AS birth_date
	, deceaseddtm AS death_date
	, GENDERCODE AS sex_cd
	, datediff(year, birthday, isnull([deceaseddtm], getDate())) AS age_in_years_num
	, languagecode AS language_cd
	, racecode AS race_cd
	, maritalstatuscode AS marital_status_cd
	, religioncode AS religion_cd
	, '@' AS statecityzip_path
	, '@' AS income_cd
	, getDate() AS update_date
	, getDate() AS download_date
	, getDate() AS import_date
	, 'ECLIPSYS' sourcesystem_cd
	-- CUSTOM FIELDS
	, '@' AS state_cd -- state_cd is a custom field 
	, ETHCODE AS ethnicity_cd
FROM (
	SELECT DISTINCT [CLIENTIDCODE] AS [MRN]
		, TRY_CONVERT(DATE,CAST([BIRTHYEARNUM] AS VARCHAR(4))+'-'+
                    CAST([BIRTHMONTHNUM] AS VARCHAR(2))+'-'+
                    CAST([BIRTHDAYNUM] AS VARCHAR(2))) [BIRTHDAY]
		, DECEASEDDTM 
		, CASE WHEN RELIGIONCODE IN ('000000000000', '000000000001', '000417150935', 'DO NOT USE', 'None', 'PREFER NOT TO STATE', 'UK', 'UNKNOWN') THEN '@'
					 WHEN RELIGIONCODE IN ('ADV') THEN 'SEVENTH DAY ADVENTIST'
					 WHEN RELIGIONCODE LIKE 'CAT%' THEN 'CATHOLIC'
					 WHEN RELIGIONCODE LIKE 'HEB%' THEN 'HEBREW'
					 WHEN RELIGIONCODE LIKE 'OTH%' THEN 'OTHER'
					 WHEN RELIGIONCODE LIKE 'PEN%' THEN 'PENTECOSTAL'
					 WHEN RELIGIONCODE LIKE 'SIK%' THEN 'SIKHISM'
					 WHEN RELIGIONCODE LIKE 'SEV%' THEN 'SEVENTH DAY ADVENTIST'
					 ELSE isnull(UPPER(RELIGIONCODE), '@') END ReligionCode
		, CASE WHEN LANGUAGECODE LIKE 'AL%' THEN 'ALBANIAN'
					  WHEN LANGUAGECODE LIKE 'ARA%' THEN 'ARABIC'
					  WHEN LANGUAGECODE LIKE 'CAN%' THEN 'CANTONESE'
					  WHEN LANGUAGECODE LIKE 'CRO%' THEN 'CROATIAN'
					  WHEN LANGUAGECODE LIKE 'DEC%' THEN 'DECLINED'
					  WHEN LANGUAGECODE LIKE 'EN%' THEN 'ENGLISH'
					  WHEN LANGUAGECODE LIKE 'FRE%' THEN 'FRENCH'
					  WHEN LANGUAGECODE LIKE 'GR%' THEN 'GREEK'
					  WHEN LANGUAGECODE LIKE 'HIN%' OR LANGUAGECODE LIKE 'IND%' THEN 'HINDI'
					  WHEN LANGUAGECODE LIKE 'ITA%' THEN 'ITALIAN'
					  WHEN LANGUAGECODE LIKE 'JPN%' THEN 'JAPANESE'
					  WHEN LANGUAGECODE LIKE 'KOR%' THEN 'KOREAN'
					  WHEN LANGUAGECODE LIKE 'MAL%' THEN 'MALAYALAM'
					  WHEN LANGUAGECODE LIKE 'MAN%' THEN 'MANDARIN'
					  WHEN LANGUAGECODE LIKE 'OT%' THEN 'OTHER'
					  WHEN LANGUAGECODE LIKE 'PER%' THEN 'PERSIAN'
					  WHEN LANGUAGECODE LIKE 'POR%' THEN 'PORTUGESE'
					  WHEN LANGUAGECODE LIKE 'RUM%' then 'RUMANIAN'
					  WHEN LANGUAGECODE LIKE 'RUS%' THEN 'RUSSIAN'
					  WHEN LANGUAGECODE LIKE 'SER%' OR LANGUAGECODE LIKE 'SRP%' THEN 'SERBIAN'
					  WHEN LANGUAGECODE LIKE 'SIGN%' THEN 'AMERICAN SIGN LANGUAGE'
					  WHEN LANGUAGECODE LIKE 'SPA%' THEN 'SPANISH'
					  WHEN LANGUAGECODE LIKE 'SW%' THEN 'SWAHILI'
					  WHEN LANGUAGECODE = 'TGL' THEN 'TAGALOG'
					  WHEN LANGUAGECODE LIKE 'UN%' OR LANGUAGECODE IS NULL THEN '@'
					  WHEN LANGUAGECODE LIKE 'URD%' THEN 'URDU'
					  WHEN LANGUAGECODE LIKE 'YID%' THEN 'YIDDISH'
					  ELSE UPPER(LANGUAGECODE) END Languagecode
		, case when gendercode like 'M%' then 'Male'
			   when gendercode like 'F%' then 'Female'
			   else	COALESCE(GENDERCODE		, '@') end GENDERCODE
		,case when racecode like 'Unk%' or racecode like 'Dec%' or racecode in ('D', 'O', 'Other') then '@'
			   when racecode in ( 'A', 'Asian', 'Burmese', 'Cambodian', 'Filipino', 'Hmong', 'Indonesian'
								, 'Japanese', 'Korean', 'Malaysian', 'Maldivian', 'Okinawan', 'Singaporean', 'Sri Lankan', 'Taiwanese', 'Thai', 'Vietnamese') then 'ASIAN'
			   when racecode in ('Asian Indian', 'Chinese', 'Bangladeshi', 'Bhutanese', 'I', 'Indian', 'Nepalese') then 'ASIAN INDIAN'
			   when racecode = 'Other Not Described' then 'OTHER COMBINATIONS NOT DESCRIBED'
			   when racecode in ('Black/African Am.', 'Black', 'B', 'Hispanic', 'H', 'Madagascar', 'M') then 'BLACK OR AFRICAN AMERICAN'
			   when racecode in ('Middle Eastern', 'Pakistani') then 'MIDDLE EASTERN OR NORTH AFRICAN'
			   WHEN RACECODE in ('Other Pacif Islander', 'Carolinian', 'Na Hawaii/Pac Island', 'Chamorro', 'Chuukese', 'Fijian'
								, 'Guamanian', 'Guamanian/Chamorro', 'Kiribati', 'Kosraean', 'Laotian', 'Marshallese', 'Melanesian'
								, 'Micronesian', 'Native Hawaiian', 'New Hebrides', 'P', 'Palauan', 'Papua New Guinean', 'Pohnpeian'
								, 'Polynesian', 'Saipanese', 'Samoan', 'Solomon Islander', 'Tahitian', 'Tongan', 'Yapese') THEN 'NAT.HAWAIIAN/OTH.PACIFIC ISLAND'
			   WHEN RACECODE = 'Am Indian/Alaska Nat' THEN 'AMERICAN INDIAN OR ALASKA NATION'
			   when racecode in ('Spanish', 'White', 'W') then 'WHITE'
			   else COALESCE(RACECODE, '@') end RACECODE
        ,case when racecode like 'Unk%' or racecode like 'Dec%' or racecode in ('D', 'O', 'Other') then '@'
			   when racecode in ( 'A', 'Asian', 'Burmese', 'Cambodian', 'Filipino', 'Hmong', 'Indonesian'
								, 'Japanese', 'Korean', 'Malaysian', 'Maldivian', 'Okinawan', 'Singaporean', 'Sri Lankan', 'Taiwanese', 'Thai', 'Vietnamese'
								, 'Asian Indian', 'Chinese', 'Bangladeshi', 'Bhutanese', 'I', 'Indian', 'Nepalese','Other Pacif Islander', 'Carolinian'
								, 'Na Hawaii/Pac Island', 'Chamorro', 'Chuukese', 'Fijian'
								, 'Guamanian', 'Guamanian/Chamorro', 'Kiribati', 'Kosraean', 'Laotian', 'Marshallese', 'Melanesian'
								, 'Micronesian', 'Native Hawaiian', 'New Hebrides', 'P', 'Palauan', 'Papua New Guinean', 'Pohnpeian'
								, 'Polynesian', 'Saipanese', 'Samoan', 'Solomon Islander', 'Tahitian', 'Tongan', 'Yapese') then 'ASIAN / PACIFIC ISLANDER'
			   when racecode = 'Other Not Described' then 'MULTI-RACIAL'
			   when racecode in ('Black/African Am.', 'Black', 'B', 'Madagascar', 'M') then 'AFRICAN AMERICAN'
			   WHEN RACECODE IN ('HISPANIC', 'H', 'Spanish') THEN 'HISPANIC OR LATINO OR SPANISH ORIGIN'
			   when racecode in ('Middle Eastern', 'Pakistani') then 'MIDDLE EASTERN OR NORTH AFRICAN'
			   WHEN RACECODE = 'Am Indian/Alaska Nat' THEN 'AMERICAN INDIAN / ESKIMO'
			   when racecode in ('White', 'W') then 'CAUCASIAN'
			   else COALESCE(RACECODE, '@') end ETHCODE
		,  CASE WHEN MARITALSTATUSCODE IN ('D', 'DIVORCED') THEN 'DIVORCED'
					  WHEN MARITALSTATUSCODE IN ('M', 'MARRIED') THEN 'MARRIED'
					  WHEN MARITALSTATUSCODE IN ('LIFE PARTNER') THEN 'DOMESTIC PARTNER'
					  WHEN MARITALSTATUSCODE IN ('O') THEN 'OTHER'
					  WHEN MARITALSTATUSCODE IN ('SEPARATED') THEN 'LEGALLY SEPARATED'
					  WHEN MARITALSTATUSCODE IN ('S', 'SINGLE') THEN 'SINGLE'
					  WHEN MARITALSTATUSCODE IN ('W', 'WIDOWER') THEN 'WIDOWED'
					  WHEN MARITALSTATUSCODE IN ('UNKNOWN') THEN '@'
					  ELSE ISNULL(MARITALSTATUSCODE, '@')  END MARITALSTATUSCODE
	FROM JUPITER.JUPITERSCM.CV3CLIENT_EAST [CLIENTEAST]
	JOIN JUPITER.JUPITERSCM.CV3CLIENTID_EAST [IDEAST] ON [IDEAST].[ClientGUID] = [CLIENTEAST].[GUID]
	   AND [IDEAST].TYPECODE = 'HOSPITAL MRN1' AND IDSTATUS = 'ACT'
	WHERE TRY_CONVERT(DATE,CAST([BIRTHYEARNUM] AS VARCHAR(4))+'-'+
                    CAST([BIRTHMONTHNUM] AS VARCHAR(2))+'-'+
                    CAST([BIRTHDAYNUM] AS VARCHAR(2))) IS NOT NULL
	) [dem]
INNER JOIN (
	SELECT patient_num
		, patient_ide
		, sourcesystem_cd
	FROM patient_mapping
	WHERE SOURCESYSTEM_CD = 'ECLIPSYS'
	) p
	ON p.patient_ide = [dem].[MRN]

/*
 * All EAGLE patients (2591159)
 */
INSERT INTO ##data_bog (
	patient_num
	, vital_status_cd
	, birth_date
	, sex_cd
	, age_in_years_num
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
SELECT DISTINCT p.patient_num AS patient_num
	, 'UD' AS vital_status_cd
	, birth_date AS birth_date
	, isnull([sex].[description], '@') AS sex_cd
	, datediff(year, birth_date, getDate()) AS age_in_years_num
	, '@' AS language_cd
	, [race].[description] AS race_cd
	, [mar].[description] AS marital_status_cd
	, [REL].[description] AS religion_cd
	, zip AS statecityzip_path
	, '@' AS income_cd
	, [patient].update_time AS update_date
	, getDate() AS download_date
	, getDate() AS import_date
	, sourcesystem_cd
	-- CUSTOM FIELDS
	, [state].[description] AS state_cd -- state_cd is a custom field 
	, '@' AS ethnicity_cd
FROM cdw.nickeast.patient [patient]
inner join (select distinct patient_id from cdw.nickeast.visit) [vis] on try_cast([patient].patient_id as numeric) = vis.patient_id
LEFT JOIN cdw.nickeast.code_sex [sex]
	ON [patient].[sex_code] = [sex].[sex_code]
LEFT JOIN cdw.nickeast.code_race [race]
	ON [patient].[race_code] = [race].[race_code]
LEFT JOIN cdw.nickeast.code_marital_Status [mar]
	ON [patient].[marital_status_code] = [mar].[marital_status_code]
LEFT JOIN cdw.nickeast.code_religion [rel]
	ON [patient].[religion_code] = [rel].[religion_code]
LEFT JOIN cdw.nickeast.code_state [state]
	ON [patient].[state_code] = [state].[state_code]
		AND [state].[description] <> ''
INNER JOIN (
	SELECT patient_num
		, patient_ide
		, sourcesystem_cd
	FROM patient_mapping
	WHERE SOURCESYSTEM_CD = 'EAGLE'
	) p
	ON try_cast(p.patient_ide as numeric) = try_cast([vis].PATIENT_ID as numeric);


/* Copy from temporary table into dimension table
 * first checking against eclipsys demographics
 * for information not present within EPIC (~2 MIL)
 */
INSERT INTO patient_dimension (
	patient_num
	, vital_status_cd
	, birth_date
	, death_date
	, sex_cd
	, age_in_years_num
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
SELECT patient_num
	, max(vital_status_cd)
	, max(birth_date) as [birth_date]
	-- Record the death date from whichever system it is in but do not adjust age_in_years_num
	-- until the next step
	, max(death_date) [death_date]
	, max(sex_cd) 
	, min(age_in_years_num)
	, max(language_cd)
	, max(race_cd)
	, max(marital_status_cd)
	, max(RELIGION_CD)
	, max(STATECITYZIP_PATH)
	, max(INCOME_CD)
	, max(UPDATE_DATE)
	, max(DOWNLOAD_DATE)
	, max(IMPORT_DATE)
	-- These data points come from EPIC but they contain information from other sources. It is impossible
	-- to tell where the original source is from so flag these data points as i2b2 generated
	, 'I2B2' as [sourcesystem_cd]
	, max(state_cd)
	, max(ethnicity_cd)
from ##data_bog
group by patient_num
order by patient_num;	 


-- Updates death date with the death date from Allscripts SCM
-- where the death date is not before the birth date
update patient_dimension
set   death_date = cast(e.death_date as datetime)
	, AGE_IN_YEARS_NUM = datediff(year, p.birth_date, cast(e.death_date as datetime))
	, VITAL_STATUS_CD = 'Y*D' 
from patient_dimension as p
inner join heroni2b2imdata.dbo.im_mpi_mapping i on patient_num = global_id
inner join cdw.nickr.epatient_death e on '0'+lcl_id = mrn and mrn like '0[1-9]%'
	where facility_code = 'A'
	and e.death_date > p.BIRTH_DATE;

update patient_dimension
set death_date = cast(e.death_date as datetime)
  , AGE_IN_YEARS_NUM = datediff(year, p.birth_date, cast(e.death_date as datetime))
  , VITAL_STATUS_CD = 'Y*D'  
from patient_dimension as p
inner join heroni2b2imdata.dbo.im_mpi_mapping i on patient_num = global_id
inner join cdw.nickr.epatient_death e on '00'+lcl_id = mrn and mrn like '00[1-9]%'
	where facility_code = 'A'
	and e.death_date > p.BIRTH_DATE;

-- A clever trick we learned from some clinical investigators involves looking for
-- discharge dates attached with a status code of EXP or Expired. This uncovers some
-- patients that have passed that have no other indications of such in the EHR.
update patient_dimension
set death_date = cast(vis.discharge_date as datetime)
   ,age_in_years_num = datediff(year, p.birth_date, cast(vis.discharge_date as datetime))
   ,vital_status_cd='Y*D'
from patient_dimension as p
inner join heroni2b2imdata.dbo.im_mpi_mapping i on p.patient_num = global_id
inner join cdw.nickeast.visit vis on cast(patient_id as varchar) = lcl_id
where vis.DISCHARGE_STATUS_CODE='EXP' and discharge_date is not null;

-- The ICD-9 code of 798 and ICD-10 code of R99 covers unknown/unspecified causes of mortality.
-- A few patients will be tagged with this code but not reported with a death date. Use the
-- time of encounter as the date of death for now, but ensure a patient has not had any
-- encounters after this one.
update patient_dimension
	set  death_date = [contact_date]
		,age_in_years_num =  datediff(year, p.birth_date, cast([t].contact_date as datetime))
		,vital_status_cd = 'Y*D'
from patient_dimension as p
inner join heroni2b2demodata.dbo.patient_mapping i on p.patient_num = i.patient_num and i.sourcesystem_cd = 'EPIC'
inner join (

select distinct pat_id, contact_date from super_monthly.dbo.pat_enc_dx [iu] where dx_id in 
	(select dx_id from super_monthly.dbo.EDG_CURRENT_ICD9 where CODE like '798%'
	 union
	 select dx_id from super_monthly.dbo.EDG_CURRENT_ICD10 where CODE like 'R99%')
	 and pat_id not in (select pat_id from super_monthly.dbo.pat_enc_dx [dx] where [dx].[CONTACT_DATE] > [iu].[CONTACT_DATE])

union all

select distinct pat_id, contact_date from super_monthly.dbo.medical_hx [iu] where dx_id in 
	(select dx_id from super_monthly.dbo.EDG_CURRENT_ICD9 where CODE like '798%'
	 union
	 select dx_id from super_monthly.dbo.EDG_CURRENT_ICD10 where CODE like 'R99%')
	 and pat_id not in (select pat_id from super_monthly.dbo.medical_hx [dx] where [dx].[CONTACT_DATE] > [iu].[CONTACT_DATE])

union all

select distinct pat_id, date_of_entry from super_monthly.dbo.problem_list [iu] where dx_id in 
	(select dx_id from super_monthly.dbo.EDG_CURRENT_ICD9 where CODE like '798%'
	 union
	 select dx_id from super_monthly.dbo.EDG_CURRENT_ICD10 where CODE like 'R99%')
	 and pat_id not in (select pat_id from super_monthly.dbo.problem_list [dx] where [dx].[DATE_OF_ENTRY] > [iu].[DATE_OF_ENTRY])
) [t] on [t].pat_id = patient_ide;

DROP TABLE ##data_bog;