
/**
 *
 * Creates the facts for Antibiotic Sensitivity. 
 * 
 */
USE <prefix>i2b2demodata;

-- Microbiology Observation Facts from Order Sensitivity
--    For these sets of facts, the concept code is 'Microbio' followed by the organism id, the modifier code is the CPT Code and the tvalchar is + because this data is coming from ORDER SENSITIVITY.
--		In this case, ORDER SENSITIVITY informs toward a positive result for these organisms because you can't have sensitivity to an organism that isn't there.
INSERT INTO observation_fact (
	encounter_num
	,patient_num
	,concept_cd
	,provider_id
	,start_date
	,modifier_cd
	,instance_num
	,VALTYPE_CD
	,TVAL_CHAR
	,valueflag_cd
	,units_cd
	,location_cd
	,update_date
	,import_date
	,sourcesystem_cd
	)
SELECT ENCOUNTER_NUM
	,PATIENT_NUM
	,'MICROBIO:' + cast(organism_id as varchar) AS CONCEPT_CD
	,PROVIDER_ID
	,E.CONTACT_DATE
	,COALESCE(MOD_CD, '@') AS MODIFIER_CD
	,1 AS INSTANCE_NUM
	,'T' AS VALTYPE_CD
	,[STATUS] AS TVAL_CHAR
	,'@' AS VALUEFLAG_CD
	,'@' AS UNITS_CD
	,LOCATION_CD
	,GETDATE() AS UPDATE_DATE
	,GETDATE() AS IMPORT_DATE
	,'EPIC' AS SOURCESYSTEM_CD
FROM (
	SELECT PAT_ID
		,OP.PAT_ENC_CSN_ID
		,'MOD:' + cast(PROC_CODE AS VARCHAR) AS MOD_CD
		,cast(OS.organism_id AS VARCHAR) AS organism_id
		,'+' AS [STATUS]
	FROM SUPER_MONTHLY.DBO.ORDER_SENSITIVITY OS
	INNER JOIN (
		SELECT PAT_ENC_CSN_ID
			,ORDER_PROC_ID
			,EAP.PROC_CODE
		FROM SUPER_MONTHLY.DBO.ORDER_PROC OP
		JOIN SUPER_MONTHLY.DBO.CLARITY_EAP EAP ON EAP.PROC_ID = OP.PROC_ID 
		) OP ON OP.ORDER_PROC_ID = OS.ORDER_PROC_ID
	) ORR
INNER JOIN (
	SELECT encounter_num
		,patient_num
		,encounter_ide
		,provider_id
		,location_cd
		,contact_date
		,sourcesystem_Cd
	FROM encounter_mapping
	WHERE SOURCESYSTEM_CD = 'EPIC'
	) e ON ENCOUNTER_IDE = ORR.PAT_ENC_CSN_ID

INSERT INTO observation_fact (
	encounter_num
	,patient_num
	,concept_cd
	,provider_id
	,start_date
	,modifier_cd
	,instance_num
	,VALTYPE_CD
	,TVAL_CHAR
	,valueflag_cd
	,units_cd
	,location_cd
	,update_date
	,import_date
	,sourcesystem_cd
	)
--    For these sets of facts, the concept code is 'Microbio' followed by the organism id, the modifier code is the '@' symbol (to account for the tvalchar which needs the @ symbol to query against) and the tvalchar is +.
SELECT ENCOUNTER_NUM
	,PATIENT_NUM
	,'MICROBIO:' + cast(organism_id as varchar) AS CONCEPT_CD
	,PROVIDER_ID
	,E.CONTACT_DATE
	,'@' AS MODIFIER_CD
	,1 AS INSTANCE_NUM
	,'T' AS VALTYPE_CD
	,[STATUS] AS TVAL_CHAR
	,'@' AS VALUEFLAG_CD
	,'@' AS UNITS_CD
	,LOCATION_CD
	,GETDATE() AS UPDATE_DATE
	,GETDATE() AS IMPORT_DATE
	,'EPIC' AS SOURCESYSTEM_CD
FROM (
	SELECT PAT_ID
		,OP.PAT_ENC_CSN_ID
		,cast(OS.organism_id AS VARCHAR) AS organism_id
		,'+' AS [STATUS]
	FROM SUPER_MONTHLY.DBO.ORDER_SENSITIVITY OS
	INNER JOIN (
		SELECT PAT_ENC_CSN_ID
			,ORDER_PROC_ID
			,EAP.PROC_CODE
		FROM SUPER_MONTHLY.DBO.ORDER_PROC OP
		JOIN SUPER_MONTHLY.DBO.CLARITY_EAP EAP ON EAP.PROC_ID = OP.PROC_ID 
		) OP ON OP.ORDER_PROC_ID = OS.ORDER_PROC_ID
	) ORR
INNER JOIN (
	SELECT encounter_num
		,patient_num
		,encounter_ide
		,provider_id
		,location_cd
		,contact_date
		,sourcesystem_Cd
	FROM encounter_mapping
	WHERE SOURCESYSTEM_CD = 'EPIC'
	) e ON ENCOUNTER_IDE = ORR.PAT_ENC_CSN_ID

INSERT INTO observation_fact (
	encounter_num
	,patient_num
	,concept_cd
	,provider_id
	,start_date
	,modifier_cd
	,instance_num
	,VALTYPE_CD
	,TVAL_CHAR
	,valueflag_cd
	,units_cd
	,location_cd
	,update_date
	,import_date
	,sourcesystem_cd
	)
--    For these sets of facts, the concept code is 'Micro' followed by the CPT Code, the modifier code is the  and the tvalchar is +.
SELECT ENCOUNTER_NUM
	,PATIENT_NUM
	,'MICRO:' + cast(PROC_CODE as varchar) AS CONCEPT_CD
	,PROVIDER_ID
	,E.CONTACT_DATE
	,COALESCE(MOD_CD, '@') AS MODIFIER_CD
	,1 AS INSTANCE_NUM
	,'T' AS VALTYPE_CD
	,[STATUS] AS TVAL_CHAR
	,'@' AS VALUEFLAG_CD
	,'@' AS UNITS_CD
	,LOCATION_CD
	,GETDATE() AS UPDATE_DATE
	,GETDATE() AS IMPORT_DATE
	,'EPIC' AS SOURCESYSTEM_CD
FROM (
	SELECT PAT_ID
		,OP.PAT_ENC_CSN_ID
		,cast(PROC_CODE AS VARCHAR) AS proc_code
		,'MOD:' + cast(OS.organism_id AS VARCHAR) AS MOD_CD
		,'+' AS [STATUS]
	FROM SUPER_MONTHLY.DBO.ORDER_SENSITIVITY OS
	INNER JOIN (
		SELECT PAT_ENC_CSN_ID
			,ORDER_PROC_ID
			,EAP.PROC_CODE
		FROM SUPER_MONTHLY.DBO.ORDER_PROC OP
		JOIN SUPER_MONTHLY.DBO.CLARITY_EAP EAP ON EAP.PROC_ID = OP.PROC_ID 
		) OP ON OP.ORDER_PROC_ID = OS.ORDER_PROC_ID
	) ORR
INNER JOIN (
	SELECT encounter_num
		,patient_num
		,encounter_ide
		,provider_id
		,location_cd
		,contact_date
		,sourcesystem_Cd
	FROM encounter_mapping
	WHERE SOURCESYSTEM_CD = 'EPIC'
	) e ON ENCOUNTER_IDE = ORR.PAT_ENC_CSN_ID

INSERT INTO observation_fact (
	encounter_num
	,patient_num
	,concept_cd
	,provider_id
	,start_date
	,modifier_cd
	,instance_num
	,VALTYPE_CD
	,TVAL_CHAR
	,valueflag_cd
	,units_cd
	,location_cd
	,update_date
	,import_date
	,sourcesystem_cd
	)
--    For these sets of facts, the concept code is 'Micro' followed by the CPT Code, the modifier code is the '@' symbol (to account for the tvalchar which needs the @ symbol to query against) and the tvalchar is +.
SELECT ENCOUNTER_NUM
	,PATIENT_NUM
	,'MICRO:' + cast(PROC_CODE as varchar) AS CONCEPT_CD
	,PROVIDER_ID
	,E.CONTACT_DATE
	,'@' AS MODIFIER_CD
	,1 AS INSTANCE_NUM
	,'T' AS VALTYPE_CD
	,[STATUS] AS TVAL_CHAR
	,'@' AS VALUEFLAG_CD
	,'@' AS UNITS_CD
	,LOCATION_CD
	,GETDATE() AS UPDATE_DATE
	,GETDATE() AS IMPORT_DATE
	,'EPIC' AS SOURCESYSTEM_CD
FROM (
	SELECT PAT_ID
		,OP.PAT_ENC_CSN_ID
		,cast(PROC_CODE AS VARCHAR) AS proc_code
		,'+' AS [STATUS]
	FROM SUPER_MONTHLY.DBO.ORDER_SENSITIVITY OS
	INNER JOIN (
		SELECT PAT_ENC_CSN_ID
			,ORDER_PROC_ID
			,EAP.PROC_CODE
		FROM SUPER_MONTHLY.DBO.ORDER_PROC OP
		JOIN SUPER_MONTHLY.DBO.CLARITY_EAP EAP ON EAP.PROC_ID = OP.PROC_ID 
		) OP ON OP.ORDER_PROC_ID = OS.ORDER_PROC_ID
	) ORR
INNER JOIN (
	SELECT encounter_num
		,patient_num
		,encounter_ide
		,provider_id
		,location_cd
		,contact_date
		,sourcesystem_Cd
	FROM encounter_mapping
	WHERE SOURCESYSTEM_CD = 'EPIC'
	) e ON ENCOUNTER_IDE = ORR.PAT_ENC_CSN_ID



-- This set of observation facts is pulling all those values from ORDER_SENSITIVITY to inform the Antibiotic Sensitivity ontology
--    For these sets of facts, the concept code is 'Microbio' followed by the organism id, the modifier code is the sensitivity and the tvalchar is the antibiotic id.
INSERT INTO OBSERVATION_FACT (
	encounter_num
	,patient_num
	,concept_cd
	,provider_id
	,start_date
	,modifier_cd
	,instance_num
	,VALTYPE_CD
	,TVAL_CHAR
	,valueflag_cd
	,units_cd
	,location_cd
	,update_date
	,import_date
	,sourcesystem_cd
	)
SELECT ENCOUNTER_NUM
	,PATIENT_NUM 
	,'MICROBIO:' + cast(ORGANISM_ID as varchar) AS CONCEPT_CD
	,PROVIDER_ID
	,E.CONTACT_DATE
	,COALESCE(MOD_CD, '@') AS MODIFIER_CD
	,1 AS INSTANCE_NUM
	,'T' AS VALTYPE_CD
	,ANTIBIOTIC_C AS TVAL_CHAR
	,'@' AS VALUEFLAG_CD
	,'@' AS UNITS_CD
	,LOCATION_CD
	,GETDATE() AS UPDATE_DATE
	,GETDATE() AS IMPORT_DATE
	,'EPIC' AS SOURCESYSTEM_CD
FROM (
	SELECT PAT_ID
		,OP.PAT_ENC_CSN_ID
		,cast(ORGANISM_ID AS VARCHAR) AS ORGANISM_ID
		,'MOD:' + cast(OS.SUSCEPT_C AS VARCHAR) AS MOD_CD
		,CAST(ANTIBIOTIC_C AS VARCHAR) ANTIBIOTIC_C
	FROM SUPER_MONTHLY.DBO.ORDER_SENSITIVITY OS
	INNER JOIN (
		SELECT PAT_ENC_CSN_ID
			,ORDER_PROC_ID
			,EAP.PROC_CODE
		FROM SUPER_MONTHLY.DBO.ORDER_PROC OP
		JOIN SUPER_MONTHLY.DBO.CLARITY_EAP EAP ON EAP.PROC_ID = OP.PROC_ID 
		) OP ON OP.ORDER_PROC_ID = OS.ORDER_PROC_ID
	WHERE SUSCEPT_C IS NOT NULL
	) ORR
INNER JOIN (
	SELECT encounter_num
		,patient_num
		,encounter_ide
		,provider_id
		,location_cd
		,contact_date
		,sourcesystem_Cd
	FROM encounter_mapping
	WHERE SOURCESYSTEM_CD = 'EPIC'
	) e ON ENCOUNTER_IDE = ORR.PAT_ENC_CSN_ID

INSERT INTO observation_fact (
	encounter_num
	,patient_num
	,concept_cd
	,provider_id
	,start_date
	,modifier_cd
	,instance_num
	,VALTYPE_CD
	,TVAL_CHAR
	,valueflag_cd
	,units_cd
	,location_cd
	,update_date
	,import_date
	,sourcesystem_cd
	)
--    For these sets of facts, the concept code is 'Microbio' followed by the organism id, the modifier code is the @ symbol (to account for the tvalchar which needs the @ symbol to query against) and the tvalchar is the antibiotic id.
SELECT ENCOUNTER_NUM
	,PATIENT_NUM
	,'MICROBIO:' + cast(ORGANISM_ID as varchar) AS CONCEPT_CD
	,PROVIDER_ID
	,E.CONTACT_DATE
	,'@' AS MODIFIER_CD
	,1 AS INSTANCE_NUM
	,'T' AS VALTYPE_CD
	,ANTIBIOTIC_C AS TVAL_CHAR
	,'@' AS VALUEFLAG_CD
	,'@' AS UNITS_CD
	,LOCATION_CD
	,GETDATE() AS UPDATE_DATE
	,GETDATE() AS IMPORT_DATE
	,'EPIC' AS SOURCESYSTEM_CD
FROM (
	SELECT PAT_ID
		,OP.PAT_ENC_CSN_ID
		,cast(ORGANISM_ID AS VARCHAR) AS ORGANISM_ID
		,CAST(ANTIBIOTIC_C AS VARCHAR) ANTIBIOTIC_C
	FROM SUPER_MONTHLY.DBO.ORDER_SENSITIVITY OS
	INNER JOIN (
		SELECT PAT_ENC_CSN_ID
			,ORDER_PROC_ID
			,EAP.PROC_CODE
		FROM SUPER_MONTHLY.DBO.ORDER_PROC OP
		JOIN SUPER_MONTHLY.DBO.CLARITY_EAP EAP ON EAP.PROC_ID = OP.PROC_ID 
		) OP ON OP.ORDER_PROC_ID = OS.ORDER_PROC_ID
	WHERE SUSCEPT_C IS NOT NULL
	) ORR
INNER JOIN (
	SELECT encounter_num
		,patient_num
		,encounter_ide
		,provider_id
		,location_cd
		,contact_date
		,sourcesystem_Cd
	FROM encounter_mapping
	WHERE SOURCESYSTEM_CD = 'EPIC'
	) e ON ENCOUNTER_IDE = ORR.PAT_ENC_CSN_ID

INSERT INTO observation_fact (
	encounter_num
	,patient_num
	,concept_cd
	,provider_id
	,start_date
	,modifier_cd
	,instance_num
	,VALTYPE_CD
	,TVAL_CHAR
	,valueflag_cd
	,units_cd
	,location_cd
	,update_date
	,import_date
	,sourcesystem_cd
	)
-- This set of observation facts is utilizing a transformation to catch those with suscept_c values as null in ORDER_SENSITIVITY
--    For these sets of facts, the concept code is 'Microbio' followed by the organism id, the modifier code is the sensitivity and the tvalchar is the antibiotic id.
SELECT ENCOUNTER_NUM
	,PATIENT_NUM
	,'MICROBIO:' + cast(ORGANISM_ID as varchar) AS CONCEPT_CD
	,PROVIDER_ID
	,E.CONTACT_DATE
	,COALESCE(MOD_CD, '@') AS MODIFIER_CD
	,1 AS INSTANCE_NUM
	,'T' AS VALTYPE_CD
	,ANTIBIOTIC_C AS TVAL_CHAR
	,'@' AS VALUEFLAG_CD
	,'@' AS UNITS_CD
	,LOCATION_CD
	,GETDATE() AS UPDATE_DATE
	,GETDATE() AS IMPORT_DATE
	,'EPIC' AS SOURCESYSTEM_CD
FROM (
	SELECT PAT_ID
		,OP.PAT_ENC_CSN_ID
		,cast(ORGANISM_ID AS VARCHAR) AS ORGANISM_ID
		,'MOD:' + cast(ZC.SUSCEPT_C AS VARCHAR) AS MOD_CD
		,CAST(ANTIBIOTIC_C AS VARCHAR) ANTIBIOTIC_C
	FROM SUPER_MONTHLY.DBO.ORDER_SENSITIVITY OS
	INNER JOIN (
		SELECT PAT_ENC_CSN_ID
			,ORDER_PROC_ID
			,PROC_CODE
		FROM SUPER_MONTHLY.DBO.ORDER_PROC
		) OP ON OP.ORDER_PROC_ID = OS.ORDER_PROC_ID
	JOIN (
		SELECT DISTINCT SENSITIVITY_VALUE
			,ZC.SUSCEPT_C
		FROM SUPER_MONTHLY.DBO.ORDER_SENSITIVITY OS
		JOIN SUPER_MONTHLY.DBO.ZC_SUSCEPT ZC ON ZC.ABBR = OS.SENSITIVITY_VALUE
			OR OS.SENSITIVITY_VALUE = zc.NAME
		WHERE OS.SUSCEPT_C IS NULL
		) ZC ON ZC.SENSITIVITY_VALUE = OS.SENSITIVITY_VALUE
	WHERE OS.SUSCEPT_C IS NULL
	) ORR
INNER JOIN (
	SELECT encounter_num
		,patient_num
		,encounter_ide
		,provider_id
		,location_cd
		,contact_date
		,sourcesystem_Cd
	FROM encounter_mapping
	WHERE SOURCESYSTEM_CD = 'EPIC'
	) e ON ENCOUNTER_IDE = ORR.PAT_ENC_CSN_ID

INSERT INTO observation_fact (
	encounter_num
	,patient_num
	,concept_cd
	,provider_id
	,start_date
	,modifier_cd
	,instance_num
	,VALTYPE_CD
	,TVAL_CHAR
	,valueflag_cd
	,units_cd
	,location_cd
	,update_date
	,import_date
	,sourcesystem_cd
	)
--    For these sets of facts, the concept code is 'Microbio' followed by the organism id, the modifier code is the @ symbol (to account for the tvalchar which needs the @ symbol to query against) and the tvalchar is the antibiotic id.
SELECT ENCOUNTER_NUM
	,PATIENT_NUM
	,'MICROBIO:' + cast(ORGANISM_ID as varchar) AS CONCEPT_CD
	,PROVIDER_ID
	,E.CONTACT_DATE
	,'@' AS MODIFIER_CD
	,1 AS INSTANCE_NUM
	,'T' AS VALTYPE_CD
	,ANTIBIOTIC_C AS TVAL_CHAR
	,'@' AS VALUEFLAG_CD
	,'@' AS UNITS_CD
	,LOCATION_CD
	,GETDATE() AS UPDATE_DATE
	,GETDATE() AS IMPORT_DATE
	,'EPIC' AS SOURCESYSTEM_CD
FROM (
	SELECT PAT_ID
		,OP.PAT_ENC_CSN_ID
		,cast(ORGANISM_ID AS VARCHAR) AS ORGANISM_ID
		,CAST(ANTIBIOTIC_C AS VARCHAR) ANTIBIOTIC_C
	FROM SUPER_MONTHLY.DBO.ORDER_SENSITIVITY OS
	INNER JOIN (
		SELECT PAT_ENC_CSN_ID
			,ORDER_PROC_ID
			,EAP.PROC_CODE
		FROM SUPER_MONTHLY.DBO.ORDER_PROC OP
		JOIN SUPER_MONTHLY.DBO.CLARITY_EAP EAP ON EAP.PROC_ID = OP.PROC_ID 
		) OP ON OP.ORDER_PROC_ID = OS.ORDER_PROC_ID
	JOIN (
		SELECT DISTINCT SENSITIVITY_VALUE
			,ZC.SUSCEPT_C
		FROM SUPER_MONTHLY.DBO.ORDER_SENSITIVITY OS
		JOIN SUPER_MONTHLY.DBO.ZC_SUSCEPT ZC ON ZC.ABBR = OS.SENSITIVITY_VALUE
			OR OS.SENSITIVITY_VALUE = zc.NAME
		WHERE OS.SUSCEPT_C IS NULL
		) ZC ON ZC.SENSITIVITY_VALUE = OS.SENSITIVITY_VALUE
	WHERE OS.SUSCEPT_C IS NULL
	) ORR
INNER JOIN (
	SELECT encounter_num
		,patient_num
		,encounter_ide
		,provider_id
		,location_cd
		,contact_date
		,sourcesystem_Cd
	FROM encounter_mapping
	WHERE SOURCESYSTEM_CD = 'EPIC'
	) e ON ENCOUNTER_IDE = ORR.PAT_ENC_CSN_ID;