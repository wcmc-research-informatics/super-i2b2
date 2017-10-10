/*
  Builds observation facts for all information from ORManager schema. 
  ORManager schema is conceptualized as each patient having a surgery
  case and/or a surgery note. These surgery cases/notes are then
  augmented with modifiers to represent the different aspects of the
  notes.

  ADMTYPE	-	Admission Type
  PREOPDX	-	Pre Op Diagnosis
  POSTOPDX	-	Post Op Diagnosis
  SURGTYPE	-	Surgery Type
  CANCELMNC	-	Cancel MNC
  FACILITYMNC - Facility MNC
  SURGDESC	-	Surgery Description
  PROCDESC	-	Procedure Description

  Copyright (c) 2014-2017 Weill Cornell Medical College
 */

use <prefix>i2b2demodata;

-- Admission Type
INSERT INTO observation_fact
(
	  encounter_num
	, patient_num
	, concept_cd
	, provider_id
	, start_date
	, modifier_cd
	, instance_num
	, end_date
	, location_cd
	, update_date
	, import_date
	, sourcesystem_cd
	)
SELECT encounter_num
	, w.patient_num
	, 'SURG|CASE'
	, provider_id
	, procdate
	, 'OR|ADMTYPE:' + AdmissionType AS modifier_cd
	, 1 AS instance_num
	, procdate AS end_date
	, location_cd
	, getDate() AS update_date
	, getDate() AS import_date
	, 'ORMANAGER' AS sourcesystem_cd
FROM (
	SELECT encounter_num
		, patient_num
		, encounter_ide
		, provider_id
		, location_cd
		, sourcesystem_Cd
	FROM encounter_mapping
	WHERE SOURCESYSTEM_CD = 'ORMANAGER'
	) w
INNER JOIN arch.dbo.orcases o
	ON w.encounter_ide = cast(o.acctnbr AS VARCHAR(20))
WHERE admissiontype IS NOT NULL;

-- PreOpDx
INSERT INTO observation_fact
(
	  encounter_num
	, patient_num
	, concept_cd
	, provider_id
	, start_date
	, modifier_cd
	, instance_num
	, end_date
	, location_cd
	, update_date
	, import_date
	, sourcesystem_cd
	)
SELECT encounter_num
	, w.patient_num
	, 'SURG|CASE'
	, provider_id
	, procdate
	, 'OR|PREOPDX:' + left(PreOpDx, 30) AS modifier_cd
	, 1 AS instance_num
	, procdate AS end_date
	, location_cd
	, getDate() AS update_date
	, getDate() AS import_date
	, 'ORMANAGER' AS sourcesystem_cd
FROM (
	SELECT encounter_num
		, patient_num
		, encounter_ide
		, provider_id
		, location_cd
		, sourcesystem_Cd
	FROM encounter_mapping
	WHERE SOURCESYSTEM_CD = 'ORMANAGER'
	) w
INNER JOIN arch.dbo.orcases o
	ON w.encounter_ide = cast(o.acctnbr AS VARCHAR(20))
WHERE preopdx IS NOT NULL;

--PostOpDx
INSERT INTO observation_fact
(
	  encounter_num
	, patient_num
	, concept_cd
	, provider_id
	, start_date
	, modifier_cd
	, instance_num
	, end_date
	, location_cd
	, update_date
	, import_date
	, sourcesystem_cd
	)
SELECT encounter_num
	, w.patient_num
	, 'SURG|CASE'
	, provider_id
	, procdate
	, 'OR|POSTOPDX:' + left(PostOpDx, 30) AS modifier_cd
	, 1 AS instance_num
	, procdate AS end_date
	, location_cd
	, getDate() AS update_date
	, getDate() AS import_date
	, 'ORMANAGER' AS sourcesystem_cd
FROM (
	SELECT encounter_num
		, patient_num
		, encounter_ide
		, provider_id
		, location_cd
		, sourcesystem_Cd
	FROM encounter_mapping
	WHERE SOURCESYSTEM_CD = 'ORMANAGER'
	) w
INNER JOIN arch.dbo.orcases o
	ON w.encounter_ide = cast(o.acctnbr AS VARCHAR(20))
WHERE postopdx IS NOT NULL;

-- Surgery Type
INSERT INTO observation_fact
(
	  encounter_num
	, patient_num
	, concept_cd
	, provider_id
	, start_date
	, modifier_cd
	, instance_num
	, end_date
	, location_cd
	, update_date
	, import_date
	, sourcesystem_cd
	)
SELECT encounter_num
	, w.patient_num
	, 'SURG|CASE'
	, provider_id
	, procdate
	, 'OR|SURGTYPE:' + TypeofSurgery AS modifier_cd
	, 1 AS instance_num
	, procdate AS end_date
	, location_cd
	, getDate() AS update_date
	, getDate() AS import_date
	, 'ORMANAGER' AS sourcesystem_cd
FROM (
	SELECT encounter_num
		, patient_num
		, encounter_ide
		, provider_id
		, location_cd
		, sourcesystem_Cd
	FROM encounter_mapping
	WHERE SOURCESYSTEM_CD = 'ORMANAGER'
	) w
INNER JOIN arch.dbo.orcases o
	ON w.encounter_ide = cast(o.acctnbr AS VARCHAR(20))
WHERE typeofsurgery IS NOT NULL;

--Cancel MNC
INSERT INTO observation_fact
(
	  encounter_num
	, patient_num
	, concept_cd
	, provider_id
	, start_date
	, modifier_cd
	, instance_num
	, end_date
	, location_cd
	, update_date
	, import_date
	, sourcesystem_cd
	)
SELECT encounter_num
	, w.patient_num
	, 'SURG|CASE'
	, provider_id
	, procdate
	, 'OR|CANCELMNC:' + cancelMnc AS modifier_cd
	, 1 AS instance_num
	, procdate AS end_date
	, location_cd
	, getDate() AS update_date
	, getDate() AS import_date
	, 'ORMANAGER' AS sourcesystem_cd
FROM (
	SELECT encounter_num
		, patient_num
		, encounter_ide
		, provider_id
		, location_cd
		, sourcesystem_Cd
	FROM encounter_mapping
	WHERE SOURCESYSTEM_CD = 'ORMANAGER'
	) w
INNER JOIN arch.dbo.orcases o
	ON w.encounter_ide = cast(o.acctnbr AS VARCHAR(20))
WHERE cancelmnc IS NOT NULL;

-- Facility MNC
INSERT INTO observation_fact(
	  encounter_num
	, patient_num
	, concept_cd
	, provider_id
	, start_date
	, modifier_cd
	, instance_num
	, end_date
	, location_cd
	, update_date
	, import_date
	, sourcesystem_cd
	)
SELECT encounter_num
	, w.patient_num
	, 'SURG|CASE'
	, provider_id
	, procdate
	, 'OR|FACILITYMNC:' + facilityMnc AS modifier_cd
	, 1 AS instance_num
	, procdate AS end_date
	, location_cd
	, getDate() AS update_date
	, getDate() AS import_date
	, 'ORMANAGER' AS sourcesystem_cd
FROM (
	SELECT encounter_num
		, patient_num
		, encounter_ide
		, provider_id
		, location_cd
		, sourcesystem_Cd
	FROM encounter_mapping
	WHERE SOURCESYSTEM_CD = 'ORMANAGER'
	) w
INNER JOIN arch.dbo.orcases o
	ON w.encounter_ide = cast(o.acctnbr AS VARCHAR(20))
WHERE facilitymnc IS NOT NULL;

-- Surgery Description
INSERT INTO observation_fact(
	  encounter_num
	, patient_num
	, concept_cd
	, provider_id
	, start_date
	, modifier_cd
	, instance_num
	, end_date
	, location_cd
	, observation_blob
	, update_date
	, import_date
	, sourcesystem_cd
	)
SELECT encounter_num
	, w.patient_num
	, 'SURG|CASE'
	, provider_id
	, procdate
	, 'OR|SURGDESC:' + Surg_descr AS modifier_cd
	, 1 AS instance_num
	, procdate AS end_date
	, location_cd
	, cast(surg_descr AS TEXT) AS observation_blob
	, getDate() AS update_date
	, getDate() AS import_date
	, 'ORMANAGER' AS sourcesystem_cd
FROM (
	SELECT encounter_num
		, patient_num
		, encounter_ide
		, provider_id
		, location_cd
		, sourcesystem_Cd
	FROM encounter_mapping
	WHERE SOURCESYSTEM_CD = 'ORMANAGER'
	) w
INNER JOIN arch.dbo.orcases o
	ON w.encounter_ide = cast(o.acctnbr AS VARCHAR(20))
WHERE Surg_descr IS NOT NULL;

-- Procedure Description
INSERT INTO observation_fact
(
	  encounter_num
	, patient_num
	, concept_cd
	, provider_id
	, start_date
	, modifier_cd
	, instance_num
	, end_date
	, location_cd
	, observation_blob
	, update_date
	, import_date
	, sourcesystem_cd
	)
SELECT encounter_num
	, w.patient_num
	, 'SURG|CASE'
	, provider_id
	, procdate
	, 'OR|PROCDESC:' + left(ProcDescrs, 15) AS modifier_cd
	, 1 AS instance_num
	, procdate AS end_date
	, location_cd
	, cast(ProcDescrs AS TEXT) AS observation_blob
	, getDate() AS update_date
	, getDate() AS import_date
	, 'ORMANAGER' AS sourcesystem_cd
FROM (
	SELECT encounter_num
		, patient_num
		, encounter_ide
		, provider_id
		, location_cd
		, sourcesystem_Cd
	FROM encounter_mapping
	WHERE SOURCESYSTEM_CD = 'ORMANAGER'
	) w
INNER JOIN arch.dbo.orcases o
	ON w.encounter_ide = cast(o.acctnbr AS VARCHAR(20))
WHERE procdescrs IS NOT NULL;

