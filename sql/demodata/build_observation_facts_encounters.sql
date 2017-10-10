/*
  Builds observation facts for encounter vital signs and locations from EPIC Clarity schema. 

    Copyright (c) 2014-2017 Weill Cornell Medical College
 */

use <prefix>i2b2demodata;

select top 0 ENCOUNTER_NUM
			,CONCEPT_CD
			,[START_DATE]
			,NVAL_NUM
INTO #OBS_FACT FROM DBO.OBSERVATION_FACT;

ALTER TABLE #OBS_FACT ALTER COLUMN ENCOUNTER_NUM VARCHAR(30);

INSERT INTO #OBS_FACT
SELECT    PAT_ENC_CSN_ID
		, 'BMI' CONCEPT_CD
        , CONTACT_DATE
		, CAST(BMI AS DECIMAL(18,5)) AS NVAL_NUM
from super_monthly.dbo.pat_enc pe
INNER JOIN PATIENT_MAPPING ON PAT_ID = PATIENT_IDE AND SOURCESYSTEM_CD = 'EPIC'
where bmi is not null;

INSERT INTO #OBS_FACT
SELECT    PAT_ENC_CSN_ID
		, 'BSA' CONCEPT_CD
        , CONTACT_DATE
		, CAST(BSA AS DECIMAL(18,5)) AS NVAL_NUM
from super_monthly.dbo.pat_enc pe
INNER JOIN PATIENT_MAPPING ON PAT_ID = PATIENT_IDE AND SOURCESYSTEM_CD = 'EPIC'
where pe.BSA > 0;

INSERT INTO #OBS_FACT
SELECT DISTINCT
          PAT_ENC_CSN_ID
		, 'HEAD_CIRCUMFERENCE' CONCEPT_CD
        , CONTACT_DATE
		, CAST(HEAD_CIRCUMFERENCE AS DECIMAL(18,5)) AS NVAL_NUM
from super_monthly.dbo.pat_enc pe
INNER JOIN PATIENT_MAPPING ON PAT_ID = PATIENT_IDE AND SOURCESYSTEM_CD = 'EPIC'
where pe.HEAD_CIRCUMFERENCE > 0;

INSERT INTO #OBS_FACT
SELECT DISTINCT
          PAT_ENC_CSN_ID
		, 'RESPIRATIONS' CONCEPT_CD
        , CONTACT_DATE
		, CAST(RESPIRATIONS AS DECIMAL(18,5)) AS NVAL_NUM
from super_monthly.dbo.pat_enc pe
INNER JOIN PATIENT_MAPPING ON PAT_ID = PATIENT_IDE AND SOURCESYSTEM_CD = 'EPIC'
where pe.RESPIRATIONS > 0;

INSERT INTO #OBS_FACT
SELECT    PAT_ENC_CSN_ID
		, 'HEIGHT' CONCEPT_CD
        , CONTACT_DATE
		, case when pe.height like '%'+char(39)+' cm"%' then replace(pe.height, char(39)+' cm"', '')
		       when pe.height like '%cm+char(39)+ "%' then replace(pe.height, 'cm+char(39)+"', '')
		       when pe.height like '%cm%[0-9]%' then left(pe.height, 3)
			   when pe.height like '[0-9][0-9][0-9]cm'+char(39)+' "' or pe.height like '[0-9][0-9]%.%cm'+char(39)+' "' then replace(pe.height, 'cm'+char(39)+' "', '') 
			   when pe.height like '%cm%"' then replace(replace(pe.height, char(39)+'cm'+char(39)+' "', ''), char(39)+'cm'+char(39)+' "', '')
			   when pe.height like '%inches%' then replace(pe.height, char(39)+' inches"', '') * cast(2.54 as decimal(38,10))
			   when pe.height like '%inch%' then replace(pe.height, char(39)+' inch"', '') * cast(2.54 as decimal(38,10))
			   when pe.height like '%in"' and pe.height not like '%ft%' then replace(pe.height, char(39)+' in"', '') * cast(2.54 as decimal(38,10))
			   when pe.height like '[0-9]ft'+char(39)+' [0-9]in"' then (try_cast(replace(substring(pe.height, 1, charindex(char(39), pe.height) - 1), 'ft', '') as int) * cast(30.48 as decimal(38,10))) + (substring(height, charindex(char(39), height)+2, 1)* cast(2.54 as decimal(38,10)))
			   when pe.height like '%in'+char(39)+' "' then replace(pe.height, 'in'+char(39)+' "', '') * cast(2.54 as decimal(38,10))
			   when pe.height like '%in%' then replace(replace(replace(replace(pe.height, 'inches', ''), 'inch', ''), 'in', ''), char(39)+' "', '')  * cast(2.54 as decimal(38,10)) -- strip out words and quotations and convert to centimeters
		  else 
		  (try_cast(substring(pe.height, 1, charindex(char(39), pe.height) - 1) as decimal(38,10)) * 12) + try_cast(rtrim(ltrim(replace(ltrim(substring(replace(pe.height, char(39)+' "', char(39)+' 0"'), charindex(char(39), replace(pe.height, char(39)+' "', char(39)+' 0"'))+1, len(replace(pe.height, char(39)+' "', char(39)+' 0"')))), '"', ''))) as decimal(38,10)) * cast(2.54 as decimal(38,10)) end as nval_num
from super_monthly.dbo.pat_enc pe
INNER JOIN PATIENT_MAPPING ON PAT_ID = PATIENT_IDE AND SOURCESYSTEM_CD = 'EPIC'
where PE.HEIGHT IS NOT NULL
	and case when pe.height like '%'+char(39)+' cm"%' then replace(pe.height, char(39)+' cm"', '')
		       when pe.height like '%cm+char(39)+ "%' then replace(pe.height, 'cm+char(39)+"', '')
		       when pe.height like '%cm%[0-9]%' then left(pe.height, 3)
			   when pe.height like '[0-9][0-9][0-9]cm'+char(39)+' "' or pe.height like '[0-9][0-9]%.%cm'+char(39)+' "' then replace(pe.height, 'cm'+char(39)+' "', '') 
			   when pe.height like '%cm%"' then replace(replace(pe.height, char(39)+'cm'+char(39)+' "', ''), char(39)+'cm'+char(39)+' "', '')
			   when pe.height like '%inches%' then replace(pe.height, char(39)+' inches"', '') * cast(2.54 as decimal(38,10))
			   when pe.height like '%inch%' then replace(pe.height, char(39)+' inch"', '') * cast(2.54 as decimal(38,10))
			   when pe.height like '%in"' and pe.height not like '%ft%' then replace(pe.height, char(39)+' in"', '') * cast(2.54 as decimal(38,10))
			   when pe.height like '[0-9]ft'+char(39)+' [0-9]in"' then (try_cast(replace(substring(pe.height, 1, charindex(char(39), pe.height) - 1), 'ft', '') as int) * cast(30.48 as decimal(38,10))) + (substring(height, charindex(char(39), height)+2, 1)* cast(2.54 as decimal(38,10)))
			   when pe.height like '%in'+char(39)+' "' then replace(pe.height, 'in'+char(39)+' "', '') * cast(2.54 as decimal(38,10))
			   when pe.height like '%in%' then replace(replace(replace(replace(pe.height, 'inches', ''), 'inch', ''), 'in', ''), char(39)+' "', '')  * cast(2.54 as decimal(38,10)) -- strip out words and quotations and convert to centimeters
		  else (try_cast(substring(pe.height, 1, charindex(char(39), pe.height) - 1) as decimal(38,10)) * 12) + try_cast(rtrim(ltrim(replace(ltrim(substring(replace(pe.height, char(39)+' "', char(39)+' 0"'), charindex(char(39), replace(pe.height, char(39)+' "', char(39)+' 0"'))+1, len(replace(pe.height, char(39)+' "', char(39)+' 0"')))), '"', ''))) as decimal(38,10)) * cast(2.54 as decimal(38,10)) end is not null

INSERT INTO #OBS_FACT
SELECT    PAT_ENC_CSN_ID
		, 'WEIGHT' CONCEPT_CD
        , CONTACT_DATE
		, [WEIGHT] AS NVAL_NUM
from super_monthly.dbo.pat_enc pe
INNER JOIN PATIENT_MAPPING ON PAT_ID = PATIENT_IDE AND SOURCESYSTEM_CD = 'EPIC'
where pe.[weight] is not null;

INSERT INTO #OBS_FACT
SELECT    PAT_ENC_CSN_ID
		, 'PULSE' CONCEPT_CD
        , CONTACT_DATE
		, PULSE AS NVAL_NUM
from super_monthly.dbo.pat_enc pe
INNER JOIN PATIENT_MAPPING ON PAT_ID = PATIENT_IDE AND SOURCESYSTEM_CD = 'EPIC'
where PULSE IS NOT NULL;

INSERT INTO #OBS_FACT
SELECT    PAT_ENC_CSN_ID
		, 'TEMPERATURE' CONCEPT_CD
        , CONTACT_DATE
		, [TEMPERATURE] AS NVAL_NUM
from super_monthly.dbo.pat_enc pe
INNER JOIN PATIENT_MAPPING ON PAT_ID = PATIENT_IDE AND SOURCESYSTEM_CD = 'EPIC'
where PE.TEMPERATURE is not null;


INSERT INTO #OBS_FACT
SELECT    PAT_ENC_CSN_ID
		, 'BP_SYSTOLIC' CONCEPT_CD
        , CONTACT_DATE
		, [BP_SYSTOLIC] AS NVAL_NUM
from super_monthly.dbo.pat_enc pe
INNER JOIN PATIENT_MAPPING ON PAT_ID = PATIENT_IDE AND SOURCESYSTEM_CD = 'EPIC'
where PE.BP_SYSTOLIC IS NOT NULL;


INSERT INTO #OBS_FACT
SELECT    PAT_ENC_CSN_ID
		, 'BP_DIASTOLIC' CONCEPT_CD
        , CONTACT_DATE
		, [BP_DIASTOLIC] AS NVAL_NUM
from super_monthly.dbo.pat_enc pe
INNER JOIN PATIENT_MAPPING ON PAT_ID = PATIENT_IDE AND SOURCESYSTEM_CD = 'EPIC'
where PE.BP_DIASTOLIC IS NOT NULL;

INSERT INTO #OBS_FACT
SELECT    PAT_ENC_CSN_ID
		, 'ENCTYPE:' + cast([enc_type_c] as varchar) CONCEPT_CD
        , CONTACT_DATE
		, NULL AS NVAL_NUM
from super_monthly.dbo.pat_enc pe
INNER JOIN PATIENT_MAPPING ON PAT_ID = PATIENT_IDE AND SOURCESYSTEM_CD = 'EPIC'
where enc_type_c is not null;

create nonclustered index [COVER] on #OBS_FACT
	([encounter_num],[concept_cd],[start_date],[nval_num]);


-- Insert all facts at once
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
select    rv.encounter_num
		, rv.patient_num
		, concept_cd
		, provider_id
	    , [start_date]
	    , '@' as modifier_cd
	    , 1 as instance_num
	    , 'N' as valtype_cd
	    , 'E' as tval_char
	    , nval_num
	    , '@' as valueflag_cd
	    , '@' as units_cd
	    , [start_date]
	    , location_cd
	    , rv.update_date
		, DOWNLOAD_DATE
	    , import_date
	    , sourcesystem_cd
from #OBS_FACT pe
inner join encounter_mapping rv 
	on rv.encounter_ide = pe.ENCOUNTER_NUM AND SOURCESYSTEM_CD = 'EPIC';

drop table #OBS_FACT;