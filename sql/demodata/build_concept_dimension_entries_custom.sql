/*
 * Adds metadata entries for custom concept paths to concept_dimension_local
 * CONCEPT_DIMENSION_LOCAL exists to hold the concept paths of custom ontology
 * entries specific to a project and are unioned with the CONCEPT_DIMENSION
 * table from OBSERVATION_FACT to form a project-specific view.
 *
 *   Copyright (c) 2014-2017 Weill Cornell Medical College
 */

use <prefix>i2b2demodata;

-------------------------------- Custom Entries ------------------------------------

-- Clear the table out
IF EXISTS (
		SELECT *
		FROM SYS.INDEXES
		WHERE NAME = 'idx_cd_local'
			AND OBJECT_ID = OBJECT_ID('concept_dimension_local')
		)
BEGIN
	drop index [idx_cd_local] on dbo.concept_dimension_local;
END

truncate table dbo.concept_dimension_local;

insert into dbo.concept_dimension_local
	(concept_path, concept_cd, name_char, update_date, import_date, sourcesystem_Cd)
select c_fullname,c_basecode,c_name,getdate(),getdate(),'CUSTOM' 
  from <prefix>i2b2metadata.dbo.custom_meta
  where C_FULLNAME like '\i2b2\custom\%'
  and c_basecode is not null;

-- Best to index this table now because it only exists in project specific databases
-- and not in the heron database.
create index [idx_cd_local] on  dbo.concept_dimension_local (concept_cd) include (concept_path);