/* 
 *  Creates observation facts about clinical trial enrollments from CREST.
 *
 *  Copyright (c) 2014-2017 Weill Cornell Medical College
 */


use <prefix>i2b2demodata;

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
	, END_DATE
	, location_cd
	, update_date
	, import_date
	, sourcesystem_cd
	)
SELECT DISTINCT ENCOUNTER_NUM
	, PATIENT_NUM
	, 'CREST|' + CAST(PROTOCOL_NUMBER AS VARCHAR) + ':' + CAST(SYSPATIENTSTATUSID AS VARCHAR)
	, PROVIDER_ID
	, CS.[START_DATE]
	, '@' AS MODIFIER_CD
	, 1 AS INSTANCE_NUM
	, '@' AS VALUEFLAG_CD
	, '@' AS UNITS_CD
	, END_DATE AS END_DATE
	, LOCATION_CD
	, GETDATE() AS UPDATE_DATE
	, GETDATE() AS IMPORT_DATE
	, 'CREST' AS SOURCESYSTEM_CD
FROM (SELECT * FROM encounter_mapping WHERE sourcesystem_cd = 'CREST') WCM 
INNER JOIN SUPER_DAILY.DBO.CREST_SUBJECTS CS ON WCM.patient_ide = CS.NYPH_MRN AND convert(varchar(1000),convert(varbinary(8),(CS.SYSPATIENTSTUDYID)),1) = WCM.ENCOUNTER_IDE
where cs.[start_date] is not null;

COMMIT TRANSACTION;