/*
  Builds observation facts for all information from CompuRecord schema. 
  CompuRecord schema is conceptualized as each patient having an anesthesia
  case. These anesthesia cases are then augmented with modifiers to represent 
  the different aspects.
 */

use <prefix>i2b2demodata;


BEGIN TRANSACTION;

--COMPU|CASE base facts
INSERT INTO observation_fact(
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
	, import_date
	, sourcesystem_cd
	)
SELECT DISTINCT 
      encounter_num
	, patient_num
	, 'COMPU|CASE' AS concept_cd
	, provider_id
	, crdet.servicedate
	, '@' AS modifier_cd
	, 1 AS instance_num
	, '@' AS valueflag_cd
	, '@' AS units_cd
	, location_cd
	, getDate() AS update_date
	, getDate() AS import_date
	, 'COMPURECORD' AS sourcesystem_cd
FROM jupiter.compurecord.details crdet
INNER JOIN jupiter.compurecord.demographics crdem
	ON crdet.internalcaseid = crdem.internalcaseid
		AND crdet.servicedate = crdem.servicedate
INNER JOIN (
	SELECT encounter_num
		, patient_num
		, encounter_ide
		, contact_Date
		, provider_id
		, location_cd
		, sourcesystem_Cd
	FROM encounter_mapping
	WHERE SOURCESYSTEM_CD = 'COMPURECORD'
	) wem
	ON cast(encounter_ide AS VARCHAR) = crdem.ACCOUNTNUMBER

COMMIT TRANSACTION;

/*
 * FACTS FOR MRN, HEIGHT, WEIGHT, ASA SCORE DERIVED FROM compurecord.demographics
 */

BEGIN TRANSACTION;

insert into observation_fact(
	encounter_num
	, patient_num
	, concept_cd
	, provider_id
	, start_date
	, modifier_cd
	, instance_num
	, VALTYPE_CD
	, TVAL_CHAR
	, NVAL_NUM
	, valueflag_cd
	, units_cd
	, location_cd
	, update_date
	, import_date
	, sourcesystem_cd
	)
select      	  encounter_num
			    , patient_num
				, 'COMPU|CASE' as concept_cd
				, provider_id
				, COALESCE(SERVICEDATE, CONTACT_DATE, '1776-07-04') as start_date
			    , 'COMPU|ASA:' + CAST([asa] as VARCHAR) as modifier_cd
			    , 1 as instance_num
				, 'N' as valtype_cd
				, 'E' as tval_char
				, CAST([asa] as VARCHAR) as nval_num
			    , '@' as valueflag_cd
			    , '@' as units_cd
			    , location_cd
			    , getDate() as update_date
			    , getDate() as import_date
			    , 'COMPURECORD'  as sourcesystem_cd
from [Jupiter].[Compurecord].[Demographics] crdem
INNER JOIN (
	SELECT encounter_num
		, patient_num
		, encounter_ide
		, contact_Date
		, provider_id
		, location_cd
		, sourcesystem_Cd
	FROM encounter_mapping
	WHERE SOURCESYSTEM_CD = 'COMPURECORD'
	) wem
	ON cast(encounter_ide AS VARCHAR) = crdem.ACCOUNTNUMBER
where [asa] IS NOT NULL;

COMMIT TRANSACTION;


/*
 * Facts for most other CompuRecord categories
 * First come the ones that use [value description] from 
 * CR_DICTIONARY
 */

BEGIN TRANSACTION;

INSERT INTO observation_fact(
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
	, import_date
	, sourcesystem_cd
	)
SELECT DISTINCT 
      encounter_num
	, patient_num
	, 'COMPU|CASE' AS concept_cd
	, provider_id
	, crdet.servicedate
	, 'COMPU|' + [CATEGORY] + ':' + LEFT([VALUE DESCRIPTION], 20) AS modifier_cd
	, 1 AS instance_num
	, '@' AS valueflag_cd
	, '@' AS units_cd
	, location_cd
	, getDate() AS update_date
	, getDate() AS import_date
	, 'COMPURECORD' AS sourcesystem_cd
FROM jupiter.compurecord.details crdet
INNER JOIN jupiter.dbo.cr_dictionary CRI ON CRDET.NUMVALUE = CRI.Value
	AND ISNUMERIC(CRI.Value) = 1
	AND crdet.CATEGORY = cri.VARIABLE
INNER JOIN jupiter.compurecord.demographics crdem
	ON crdet.internalcaseid = crdem.internalcaseid
		AND crdet.servicedate = crdem.servicedate
INNER JOIN (
	SELECT encounter_num
		, patient_num
		, encounter_ide
		, contact_Date
		, provider_id
		, location_cd
		, sourcesystem_Cd
	FROM encounter_mapping
	WHERE SOURCESYSTEM_CD = 'COMPURECORD'
	) wem
	ON cast(encounter_ide AS VARCHAR) = crdem.ACCOUNTNUMBER
WHERE category IN (
		  'AIRWAYMNGT'
		, 'MONITORS'
		, 'MONITORSMG'
		, 'MONITORSNM'
		, 'MONITORSSTETH'
		, 'MONITORSTEMP'
		, 'ADMISSION'
		, 'ANESTECH'
		, 'ANESALERTS'
		, 'ANTIBIOTICPROP'
		, 'AL1LOC'	
		, 'AL2LOC'	
		, 'AL2CATH'	
		, 'AL2LOC'	
		, 'AL2PLACE'
		, 'AL1CATH'	
		, 'AL1PLACE'
		, 'CVL1CATH'
		, 'CVL1LOC'	
		, 'CVL1PLACE'
		, 'CVL2CATH'
		, 'CVL2LOC'	
		, 'CVL2PLACE'
		, 'CVL3CATH'
		, 'CVL3LOC'	
		, 'CVL3PLACE'
		, 'DENTITION'
		, '[MONITORSFOLEY]'
		, 'MONITORSNMNERVLAT'
		, 'MONITORSNMNERVSTIM'
		, 'MONITORSNMSTIM'
		, 'MONITORSSTETH'
		, 'MONITORSTEMP'
		, '[NPO]'
		, 'POSITIONING'
		, 'POSTPOCLOC'
		, 'RHCCATH'
		, 'RHCCATHLOC'
		, 'RHCCATHPLACE'
		, 'SPECMONITORS'
		, 'TEEECHO'
		, 'WARMCOOL'
		)
	AND crdet.servicedate IS NOT NULL;

/*
 * Next come the set value entries
 */

insert into observation_fact(
	encounter_num
	, patient_num
	, concept_cd
	, provider_id
	, start_date
	, modifier_cd
	, instance_num
	, VALTYPE_CD
	, TVAL_CHAR
	, valueflag_cd
	, units_cd
	, location_cd
	, update_date
	, import_date
	, sourcesystem_cd
	)
select      	  encounter_num
			    , patient_num
				, 'COMPU|CASE' as concept_cd
				, provider_id
				, COALESCE(crdet.SERVICEDATE, CONTACT_DATE, '1776-07-04') as start_date
			    , 'COMPU|' + [category] as modifier_cd
			    , 1 as instance_num
				, 'T' as valtype_cd
				, [value description] as tval_char
			    , '@' as valueflag_cd
			    , '@' as units_cd
			    , location_cd
			    , getDate() as update_date
			    , getDate() as import_date
			    , 'COMPURECORD'  as sourcesystem_cd
FROM jupiter.compurecord.details crdet
INNER JOIN jupiter.dbo.CR_DICTIONARY CRI ON crdet.CATEGORY = cri.VARIABLE
INNER JOIN jupiter.compurecord.demographics crdem
	ON crdet.internalcaseid = crdem.internalcaseid
		AND crdet.servicedate = crdem.servicedate
INNER JOIN (
	SELECT encounter_num
		, patient_num
		, encounter_ide
		, contact_Date
		, provider_id
		, location_cd
		, sourcesystem_Cd
	FROM encounter_mapping
	WHERE SOURCESYSTEM_CD = 'COMPURECORD'
	) wem
	ON cast(encounter_ide AS VARCHAR) = crdem.ACCOUNTNUMBER
WHERE category IN (
		  'PREINDFI02'			
		, 'PREIND02SAT'
		, 'PREINDPULSE'
		, 'PREINDRESP'
		, 'PREINDBP'
		, 'MONITORSNMSTIMCUR');


COMMIT TRANSACTION;

BEGIN TRANSACTION;

/*
 * Modifiers for ICD-9 and CPT codes from CompuRecord
 */
insert into observation_fact(
	encounter_num
	, patient_num
	, concept_cd
	, provider_id
	, start_date
	, modifier_cd
	, instance_num
	, VALTYPE_CD
	, valueflag_cd
	, units_cd
	, location_cd
	, update_date
	, import_date
	, sourcesystem_cd
	)
select  distinct  encounter_num
			    , patient_num
				, 'ICD9:' + CAST (DX_ID AS VARCHAR) as concept_cd
				, provider_id
				, crd.SERVICEDATE as start_date
			    , 'ICD9:COMPURECORD' as modifier_cd
			    , 1 as instance_num
				, '@' as valtype_cd
			    , '@' as valueflag_cd
			    , '@' as units_cd
			    , location_cd
			    , getDate() as update_date
			    , getDate() as import_date
			    , 'COMPURECORD'  as sourcesystem_cd
FROM [Jupiter].[Compurecord].[DETAILS] crd 
inner join jupiter.compurecord.COMPURECORD_ICD9 ci9 
	on crd.numvalue=ci9.DX_ID 
inner join jupiter.compurecord.demographics cd 
	on crd.internalcaseid = cd.internalcaseid
INNER JOIN ENCOUNTER_MAPPING EM
	on em.encounter_ide = accountnumber 
where category ='DXCODE' and len(accountnumber) > 0

insert into observation_fact(
	encounter_num
	, patient_num
	, concept_cd
	, provider_id
	, start_date
	, modifier_cd
	, instance_num
	, VALTYPE_CD
	, valueflag_cd
	, units_cd
	, location_cd
	, update_date
	, import_date
	, sourcesystem_cd
	)
select  distinct  encounter_num
			    , patient_num
				, 'CPT:' + CAST (cpt_code AS VARCHAR) as concept_cd
				, provider_id
				, crd.SERVICEDATE as start_date
			    , 'CPT:COMPURECORD' as modifier_cd
			    , 1 as instance_num
				, '@' as valtype_cd
			    , '@' as valueflag_cd
			    , '@' as units_cd
			    , location_cd
			    , getDate() as update_date
			    , getDate() as import_date
			    , 'COMPURECORD'  as sourcesystem_cd
FROM [Jupiter].[Compurecord].[DETAILS] crd 
inner join jupiter.compurecord.COMPURECORD_CPT ccpt 
	on crd.numvalue=ccpt.CPT_ID
inner join jupiter.compurecord.demographics cd 
	on crd.internalcaseid = cd.internalcaseid
INNER JOIN ENCOUNTER_MAPPING EM
	on em.encounter_ide = accountnumber 
where category ='CPT' and len(accountnumber) > 0

COMMIT TRANSACTION;

