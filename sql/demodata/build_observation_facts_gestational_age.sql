/* 
 *
 *  Creates a table in the staging database that holds gestational age at time of encounter.
 *
 *  Copyright (c) 2014-2017 Weill Cornell Medical College
 */
 
use <prefix>i2b2demodata;


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
select   e.encounter_num
       , e.patient_num
	   , 'GESTATIONAL_AGE' as concept_cd 
	   , provider_id
	   , [start_date]
	   , '@' as modifier_cd
	   , 1 as instance_num
	   , 'N' as valtype_cd
	   , 'E' as tval_char
	   , DATEDIFF(WEEK, DATEADD(DAY, -280, [OB_WRK_EDD_DT]), pe.[CONTACT_DATE]) as nval_num
	   , '@' as valueflag_cd
	   , '@' as units_cd
	   , END_DATE as end_date
	   , location_cd
	   , e.update_date
	   , e.download_date
	   , e.import_date
	   , sourcesystem_cd
  FROM [SUPER_MONTHLY].[dbo].[EPISODE] [EPI]
  INNER JOIN [SUPER_MONTHLY].[DBO].[EPISODE_LINK] [EL] ON [EPI].[EPISODE_ID] = [EL].[EPISODE_ID]
  INNER JOIN [SUPER_MONTHLY].[DBO].[PAT_ENC] [PE] ON [EL].[PAT_ENC_CSN_ID] = [PE].[PAT_ENC_CSN_ID]
  inner join ENCOUNTER_MAPPING e on e.encounter_ide = cast(pe.pat_enc_csn_id as varchar(20)) AND SOURCESYSTEM_CD = 'EPIC'
  WHERE [OB_WRK_EDD_DT] IS NOT NULL AND [start_date] IS NOT NULL
  -- Because gestational age is only pertinent over the duration of a pregnancy we should exclude
  -- any encounters with dates that fall outside of this range (9mo before estimated date of conception)
  and DATEDIFF(WEEK, DATEADD(DAY, -280, [OB_WRK_EDD_DT]), pe.[CONTACT_DATE]) > 0

