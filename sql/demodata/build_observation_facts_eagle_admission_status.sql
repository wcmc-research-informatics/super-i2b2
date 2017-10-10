/*
 * Builds facts for admission status from EAGLE
 */

use <prefix>i2b2demodata;

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
select e.encounter_num
	,  patient_num
	,  'ADMSNSTATUS' as [concept_cd]
	,  provider_id
	,  contact_date
	,  '@' as [modifier_cd]
	,  1 as instance_num
	,  'T' as valtype_cd
	,  [ADMIT_TYPE_CODE] as tval_char
	,  '@' as valueflag_cd
	,  '@' as units_cd
	,  location_cd
	,  getDate()
	,  getDate()
	,  'EAGLE'
from cdw.nickeast.visit v
inner join encounter_mapping e on v.account = e.encounter_ide and sourcesystem_cd = 'EAGLE'
and v.patient_class_code = 'I' and ADMIT_TYPE_CODE in ('2', '1', '4', 'A')
	-- ADMIT TYPE CODE should be Emergency, Elective, Newborn, or Urgent only