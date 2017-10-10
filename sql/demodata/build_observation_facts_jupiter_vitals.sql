/*
  Builds observation facts for height and weight from Eclipsys. 

    Copyright (c) 2014-2017 Weill Cornell Medical College
 */

use <prefix>I2B2demodata;

-- Building temp tables for the GUIDs for ObsCatalogMasterItem
select guid 
into ##height
from jupiter.jupiterscm.CV3ObsCatalogMasterItem_East where name in (
											 'note_md_pedres_height',             
											 'vs_amb_men_clin_height_cm',            
											 'vs_amb_men_clin_height_inch',             
											 'amb_aim_pe_ht_in',             
											 'amb_init_nut_adult_ht',             
											 'amb_obgyn_antprt_nut_ht_inch',             
											 'note_mdped_onc_pe_height_cm',             
											 'amb_fam_plan_visit_pe_ht_cm',             
											 'amb_fam_plan_visit_pe_ht_inch',             
											 'as_nut_height1',             
											 'initial_nutrition_assess_note_height1',             
											 'vs_amb_intnal_med_height_cm',             
											 'vs_amb_intnal_med_height_inches1',             
											 'vs_height_amb_inch',             
											 'vs_height_amb_cm',             
											 'vs_height'
											 )


select guid 
into ##weight
from jupiter.jupiterscm.CV3ObsCatalogMasterItem_East where name in (
																'note_delrec_infants_weight_B',
																'amb_peds_nut_obj_wt2',
																'amb_obgyn_anterpart_pastp_1_bweight',
																'amb_obgyn_anterpart_pastp_3_bweight_lbs',
																'amb_obgyn_birthweight_oz',
																'amb_obgyn_birthweight_lbs',
																'vs_amb_men_clin_weight_kg',
																'vs_amb_men_clin_weight_lbs', --'afm_peds_PE_weight', --this is percentile
																'note_md_ob_pit_est_fetal_wt',
																'amb_foodnut_prenatal_wt2',
																'amb_init_nut_body_wt2',
																'amb_obgyn_anterpart_pastp_2_bweight_lbs',
																'amb_aim_pe_wt_lb',
																'amb_init_nut_body_wt',
																'amb_init_nut_adult_wt',
																'md_delrec_birthwt_a',
																'note_ob_csec_BABYDAT_bweight',
																'amb_obgyn_birthweight_kg_calc1',
																'amb_obgyn_antprt_nut_wt_lbs',
																'amb_obgyn_anterpart_pastp_1_bweight_lbs',
																'amb_peds_med_note_bweight',
																'note_newnur_PE_weight',
																'note_mdped_onc_pe_weight_kg',
																'note_nsg_hemdialy_pst_tx_wt',
																'vs_weight_oz1',
																'note_nicu_adm_PE_cur_weight -',
																'vs_weight_amb_lb_cal',
																'vs_weight_kg1',
																'amb_fam_plan_visit_pe_wt_lbs',
																'amb_fam_plan_visit_pe_wt_kg',
																'note_delrec_infants_weight_A',
																'note_nicu_adm_PE_current_weight',
																'vs_weight_lbs_calc',
																'as_nut_admission_adm_weight',
																'initial_nutrition_assess_note_admit_weight1',
																'vs_weight_lbs1',
																'vs_amb_intnal_med_weight_kg',
																'vs_amb_intnal_med_weight_lbs1',
																'vs_weight_amb_ozs',
																'vs_weight_amb_lbs',
																'vs_weight_amb_lb_calc2',
																'vs_weight_amb_kg_cal',
																'vs_dry_wt',
																'vs_weight')


--Build temp tables for Height and Weight ObservationDocument. Runtime is 1 minute total
if object_id('tempdb..##height_ode') is not null
    drop table ##height_ode

select OwnerGUID, ObservationGUID, CreatedWhen
into ##height_ode
from jupiter.jupiterscm.cv3observationdocument_east
where ObsMasterItemGUID in (select * from ##height)

if object_id('tempdb..##weight_ode') is not null
    drop table ##weight_ode

select OwnerGUID, ObservationGUID, CreatedWhen
into ##weight_ode
from jupiter.jupiterscm.cv3observationdocument_east
where ObsMasterItemGUID in (select * from ##weight)

-- Create clustered indexes to make runtime go faster
create clustered index idx_guid on ##weight_ode (observationGUID)

create clustered index idx_guid on ##height_ode (observationGUID)

create nonclustered index idx_owner_created on ##weight_ode (ownerguid, createdwhen) include (observationGUID)

create nonclustered index idx_owner_created on ##height_ode (ownerguid, createdwhen) include (observationGUID)


--Build temp tables for Height and Weight Observation. Runtime is a couple minutes
if object_id('tempdb..##height_oe') is not null
    drop table ##height_oe
select guid, UnitOfMeasure, ValueText
into ##height_oe
from jupiter.jupiterscm.CV3Observation_East
where guid in (Select observationguid from ##height_ode) and UnitOfMeasure in ('inch', 'cm', null) and valuetext is not null

if object_id('tempdb..##weight_oe') is not null
    drop table ##weight_oe
select guid, UnitOfMeasure, ValueText
into ##weight_oe
from jupiter.jupiterscm.CV3Observation_East
where guid in (Select observationguid from ##weight_ode) and unitofmeasure in (null, 'lb', 'kg') and valuetext is not null 

-- Create clustered indexes to make runtime go faster
create clustered index idx_guid on ##weight_oe (guid)

create clustered index idx_guid on ##height_oe (guid)


create nonclustered index idx_value on ##weight_oe (guid, unitofmeasure) include (valuetext)

create nonclustered index idx_value on ##height_oe (guid, unitofmeasure) include (valuetext)


if object_id('tempdb..##cde') is not null
    drop table ##cde
select hi2.guid, --clientvisitguid
			  replace(substring(VisitIDCode, patindex('%[^0]%',VisitIDCode),len(VisitIDCode)), ' ', '') [ACCOUNTNUM]
			  into ##cde
			from Jupiter.JupiterSCM.CV3ClientDocument_East hi2
		 inner join Jupiter.JupiterSCM.CV3ClientVisit_East cve on hi2.ClientVisitGUID = cve.guid
		 where hi2.GUID in (Select ownerguid 
					   from ##height_ode
					   union
					 select ownerguid
					   from ##weight_ode)


create clustered index idx_guid on ##cde (guid)

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
	, import_date
	, sourcesystem_cd
	)
select distinct rv.encounter_num
		, rv.patient_num
		, 'HEIGHT' as concept_cd
		, provider_id
	    , ode.createdwhen
	    , '@' as modifier_cd
	    , 1 as instance_num
	    , 'N' as valtype_cd
	    , 'E' as tval_char
		, case when UnitOfMeasure = 'inch' then  cast(valuetext as float) * (2.54)
					 when UnitOfMeasure = 'cm' then cast(valuetext as varchar) end as valuetext
	    , '@' as valueflag_cd
	    , 'cm' as units_cd
	    , ode.createdwhen
	    , location_cd
	    , getDate() as update_date
	    , getDate() as import_date
	    , 'ECLIPSYS'  as sourcesystem_cd
from (select encounter_num, 
		  patient_num, 
		  encounter_ide, 
		  provider_id, 
		  location_cd, 
		  sourcesystem_Cd 
    from encounter_mapping 
    where SOURCESYSTEM_CD = 'ECLIPSYS') rv
     join ##cde cde on [ACCOUNTNUM] = rv.ENCOUNTER_IDE
	join ##height_ode ode on ode.OwnerGUID = cde.GUID and ode.CreatedWhen is not null
	join ##height_oe oe on try_cast(valuetext as float) is not null 
				and oe.guid = ode.observationguid
				

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
	, import_date
	, sourcesystem_cd
	)
select distinct rv.encounter_num
		, rv.patient_num
		, 'WEIGHT' as concept_cd
		, provider_id
	    , ode.createdwhen
	    , '@' as modifier_cd
	    , 1 as instance_num
	    , 'N' as valtype_cd
	    , 'E' as tval_char
		, case when UnitOfMeasure = 'lb' then cast(cast(ValueText as float) * (0.45359237) as varchar)
				       when UnitOfMeasure = 'kg' then cast(valuetext as varchar) 
					   when UnitOfMeasure is null and len(valuetext) < 4 then cast(valuetext as varchar)
					   when UnitOfMeasure is null and len(valuetext) >= 4 and charindex('.', valuetext) > 0 then cast(valuetext as varchar)
					   when UnitOfMeasure is null and len(valuetext) >= 4 and charindex('.',valuetext) = 0 then cast(ValueText as float) / 1000
				  end as valuetext
	    , '@' as valueflag_cd
	    , 'kg' as units_cd
	    , ode.createdwhen
	    , location_cd
	    , getDate() as update_date
	    , getDate() as import_date
	    , 'ECLIPSYS'  as sourcesystem_cd
from (select encounter_num, 
		  patient_num, 
		  encounter_ide, 
		  provider_id, 
		  location_cd, 
		  sourcesystem_Cd 
    from encounter_mapping 
    where SOURCESYSTEM_CD = 'ECLIPSYS') rv
     join ##cde cde on [ACCOUNTNUM] = rv.ENCOUNTER_IDE
	join ##weight_ode ode on ode.OwnerGUID = cde.GUID and createdwhen is not null
	join ##weight_oe oe on try_cast(valuetext as float) is not null 
				and oe.guid = ode.observationguid