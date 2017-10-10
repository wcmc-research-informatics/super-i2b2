/* 
 *
 *  Creates a table in the staging database that holds specimens information from profiler that will be
 *  inserted into OBSERVATION_FACT.
 *
 *  Copyright (c) 2014-2017 Weill Cornell Medical College
 */

BEGIN TRANSACTION;

use <prefix>i2b2demodata;

insert into observation_fact (
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
	, download_date
	, import_date
	, sourcesystem_cd
	)
select    encounter_num
       ,  patient_num
	   ,  concept_cd
	   , provider_id
	   , contact_date
	   , '@' as modifier_cd
	   , 1 as instance_num
	   , '@' as valueflag_cd
	   , '@' as units_cd
	   , location_cd
	   , getDate() AS download_date
	   , getDate() AS import_date
	   , 'PROFILER'  as sourcesystem_cd
from (select  999999999 as encounter_num
			, pm.patient_num
			, 'SPEC:TISS:HIST_TYPE:'+cast(col.HISTOLOGIC_TYPE as varchar) as concept_cd
			, substring(col.date_of_surgery,1,10) as contact_date
			, substring(col.date_of_surgery,1,10) as end_date
			, isnull(provider_id, '@') as provider_id
			, 'ENC|LOC:UNKNOWN' as location_cd
	  from arch.dbo.GIC_COLORECTAL_INFO col
	  inner join arch.dbo.GIC_HISTOLOGIC_TYPE_SEL gic on gic.HIST_TYPE_ID = col.HISTOLOGIC_TYPE
	  inner join arch.dbo.GIC_PATIENT_DEM_INFO dem on dem.DEM_ID = col.dem_id
      INNER JOIN (select PATIENT_NUM, PATIENT_IDE, LCL_ID AS NYP_MRN FROM PATIENT_MAPPING PM
				  INNER JOIN heroni2b2imDATA.DBO.IM_MPI_MAPPING IM ON GLOBAL_ID = PATIENT_NUM 
				  WHERE PM.SOURCESYSTEM_CD = 'EPIC') pm
				  on pm.nyp_mrn = dem.nyp_mrn
	  inner join ( select encounter_num, patient_num, encounter_ide, provider_id, location_cd from encounter_mapping where SOURCESYSTEM_CD = 'EPIC' ) wm on wm.patient_num = pm.patient_num
	  where HISTOLOGIC_TYPE is not null) as colorectalinfo;

COMMIT TRANSACTION;

BEGIN TRANSACTION;

insert into observation_fact (
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
	, download_date
	, import_date
	, sourcesystem_cd
	)
select   encounter_num
       , patient_num
	   , concept_cd
	   , provider_id
	   , isnull(contact_date, '1776-07-04')
	   , '@' as modifier_cd
	   , 1 as instance_num
	   , 'N' as valtype_cd
	   , 'E' as tval_char
	   , nval_num
	   , '@' as valueflag_cd
	   , '@' as units_cd
	   , end_date
	   , location_cd
	   , getDate() AS download_date
	   , getDate() AS import_date
	   , 'PROFILER' as sourcesystem_cd
from (select  999999999 as encounter_num
			, pm.patient_num
			, 'SPEC:TISS:'+ case when spec.field like '%anatomic%' then 'ANATOMIC' else spec.field end  + 
						    case when spec.field in('LN_TOTAL_HARVESTED','LN_NUM_POSITIVE','TUMOR_SIZE_1','TUMOR_SIZE_2','TUMOR_SIZE_3',
													'PROXIMAL_MARGIN','DISTAL_MARGIN','RADIAL_MARGIN') then '' 
								 else ':' + cast(spec.value as varchar) end as concept_cd
			, substring(spec.date_of_surgery,1,10) as contact_date
			, substring(spec.date_of_surgery,1,10) as end_date
			, spec.value as nval_num
			, wm.location_cd
			, wm.provider_id
	  from <prefix>i2b2metadata.dbo.specimen_data spec
	  inner join arch.dbo.GIC_PATIENT_DEM_INFO dem on dem.DEM_ID = spec.dem_id
            INNER JOIN (select PATIENT_NUM, PATIENT_IDE, LCL_ID AS NYP_MRN FROM PATIENT_MAPPING PM
				  INNER JOIN heroni2b2imDATA.DBO.IM_MPI_MAPPING IM ON GLOBAL_ID = PATIENT_NUM 
				  WHERE PM.SOURCESYSTEM_CD = 'EPIC') pm
				  on pm.nyp_mrn = dem.nyp_mrn
	  inner join ( select encounter_num, patient_num, encounter_ide, provider_id, location_cd from encounter_mapping where SOURCESYSTEM_CD = 'EPIC' ) wm on wm.patient_num = pm.patient_num
	  where spec.value is not null) as specinfo;

COMMIT TRANSACTION;