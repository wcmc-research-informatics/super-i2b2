/*
  Builds observation facts for patient MRNs from EPIC Clarity schema. This is
  identifying information so it does not make its way into i2b2 GREEN (de-id
  production instance). These are for convenience when using ExportXLS plug-in
  to prepare lists of MRNs for investigators. They are not tied to any particular
  encounter so all encounter numbers are -1.
  Copyright (c) 2014-2017 Weill Cornell Medical College
 */

use <prefix>i2b2demodata;

INSERT INTO observation_fact (
	encounter_num
	, patient_num
	, concept_cd
	, provider_id
	, [start_date]
	, modifier_cd
	, instance_num
	, valtype_cd
	, tval_char
	, location_cd
	, update_date
	, download_date
	, import_date
	, sourcesystem_cd
	)
SELECT DISTINCT '-1' AS encounter_num
	, global_id AS patient_num
	, 'MRN' AS concept_cd
	, '@' AS provider_id
	, getDate() AS [start_date]
	, '@' AS modifier_cd
	, 1 AS instance_num
	, 'T' AS valtype_cd
	, ltrim(rtrim(lcl_id)) AS tval_char
	, '@' AS location_cd
	, pm.update_date
	, pm.download_date
	, pm.import_date
	, pm.sourcesystem_cd
FROM heroni2b2imdata.dbo.im_mpi_mapping
inner join patient_mapping pm on patient_num = global_id AND pm.SOURCESYSTEM_CD = 'EPIC'
WHERE LCL_SITE = 'WCM';


-- Be sure to update concept dimension as well!
insert into concept_dimension
(concept_path,concept_cd,name_char,update_date,
download_date,import_date,sourcesystem_cd) VALUES
(       '\i2b2\Demographics\MRN\'
      , 'MRN'
	  , 'MRN'
	  , getdate()
	  , getdate()
	  , getdate()
	  ,'EPIC' 
);