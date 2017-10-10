/*
 * Creates code_lookup and dimension indexes
 * Copyright (c) 2014-2017 Weill Cornell Medical College
 */

use <prefix>i2b2demodata;

-- CODE LOOKUP
IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE object_id = object_id('CODE_LOOKUP')
			AND NAME = 'CL_IDX_NAME_CHAR'
		)
	CREATE INDEX CL_IDX_NAME_CHAR ON CODE_LOOKUP ([name_char]);

IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE object_id = object_id('CODE_LOOKUP')
			AND NAME = 'CODE_LOOKUP_PK'
		)
	CREATE CLUSTERED INDEX CODE_LOOKUP_PK ON CODE_LOOKUP (
		[table_cd]
		, [column_cd]
		, [code_cd]
		);

/*
 * Concept Dimension
 * Primary key constraint on CONCEPT_CD to function as FK for OBSERVATION_FACT
 */

IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'PK_CONCEPT_CD'
			AND object_id = OBJECT_ID('concept_dimension')
		)
	CREATE CLUSTERED INDEX PK_CONCEPT_CD ON concept_dimension (concept_CD) with (data_compression = page);

IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'IDX_CONCEPT_CD'
			AND object_id = OBJECT_ID('concept_dimension')
		)
	CREATE NONCLUSTERED INDEX IDX_CONCEPT_CD ON concept_dimension (concept_path) include (sourcesystem_cd) with (data_compression = page);

/*
 * Patient Dimension
 * Primary key constraint on PATIENT_NUM to function as FK for OBSERVATION_FACT and
 * is included in every other index. Multiple filtered indexes on demographics fields
 */
IF NOT EXISTS (SELECT * 
               FROM   information_schema.table_constraints 
               WHERE  constraint_type = 'PRIMARY KEY' 
                      AND table_name = 'PATIENT_DIMENSION' 
                      AND table_schema = 'dbo') 
  ALTER TABLE dbo.patient_dimension 
    ADD CONSTRAINT pk_patient_num PRIMARY KEY CLUSTERED (PATIENT_NUM); 

-- Useful for quickly calculating age at encounter
IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'IDX_BIRTH_DATE'
			AND object_id = OBJECT_ID('patient_dimension')
		)
		CREATE NONCLUSTERED INDEX IDX_BIRTH_DATE ON [dbo].[patient_dimension] ([BIRTH_DATE])

IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'IDX_SEX_CD'
			AND object_id = OBJECT_ID('patient_dimension')
		)
		CREATE NONCLUSTERED INDEX IDX_SEX_CD ON [dbo].[patient_dimension] ([SEX_CD])
			WHERE SEX_CD <> '@'

IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'IDX_LANGUAGE_CD'
			AND object_id = OBJECT_ID('patient_dimension')
		)
		CREATE NONCLUSTERED INDEX IDX_LANGUAGE_CD ON [dbo].[patient_dimension] ([LANGUAGE_CD])
			WHERE LANGUAGE_CD <> '@'

IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'IDX_RACE_CD'
			AND object_id = OBJECT_ID('patient_dimension')
		)
		CREATE NONCLUSTERED INDEX IDX_RACE_CD ON [dbo].[patient_dimension] ([RACE_CD])
			WHERE RACE_CD <> '@'

IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'IDX_MARITAL_STATUS_CD'
			AND object_id = OBJECT_ID('patient_dimension')
		)
		CREATE NONCLUSTERED INDEX IDX_MARITAL_STATUS_CD ON [dbo].[patient_dimension] ([MARITAL_STATUS_CD])
			WHERE MARITAL_STATUS_CD <> '@'

IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'IDX_RELIGION_CD'
			AND object_id = OBJECT_ID('patient_dimension')
		)
		CREATE NONCLUSTERED INDEX IDX_RELIGION_CD ON [dbo].[patient_dimension] ([RELIGION_CD])
			WHERE RELIGION_CD <> '@'

IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'IDX_STATE_CD'
			AND object_id = OBJECT_ID('patient_dimension')
		)
		CREATE NONCLUSTERED INDEX IDX_STATE_CD ON [dbo].[patient_dimension] ([STATE_CD])
			WHERE STATE_CD <> '@'

IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'IDX_ETHNICITY_CD'
			AND object_id = OBJECT_ID('patient_dimension')
		)
		CREATE NONCLUSTERED INDEX IDX_ETHNICITY_CD ON [dbo].[patient_dimension] ([ETHNICITY_CD])
			WHERE ETHNICITY_CD <> '@'

IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'IDX_VITAL_STATUS_CD'
			AND object_id = OBJECT_ID('patient_dimension')
		)
		CREATE NONCLUSTERED INDEX IDX_VITAL_STATUS_CD ON [dbo].[patient_dimension] ([VITAL_STATUS_CD])
			WHERE VITAL_STATUS_CD <> '@'

/*
 * Visit Dimension
 */
IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'PK_ENCOUNTER_NUM'
			AND object_id = OBJECT_ID('visit_dimension')
		)
	CREATE CLUSTERED INDEX PK_ENCOUNTER_NUM ON [dbo].[VISIT_DIMENSION] ([ENCOUNTER_NUM],[PATIENT_NUM]) 
			WITH (DATA_COMPRESSION = PAGE);

IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'IX_INOUT_CD'
			AND object_id = OBJECT_ID('visit_dimension')
		)
	CREATE NONCLUSTERED INDEX IX_INOUT_CD ON [dbo].[VISIT_DIMENSION] ([sourcesystem_cd], [INOUT_CD])
		WITH (DATA_COMPRESSION = PAGE)

IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'IX_LOCATION_CD'
			AND object_id = OBJECT_ID('visit_dimension')
		)
		CREATE NONCLUSTERED INDEX IX_LOCATION_CD ON [dbo].[VISIT_DIMENSION] ([LOCATION_CD],[LOCATION_PATH])
			WHERE LOCATION_CD <> '@'
			WITH (DATA_COMPRESSION = PAGE)

IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'IX_ENCOUNTER_TYPE'
			AND object_id = OBJECT_ID('visit_dimension')
		)
		CREATE NONCLUSTERED INDEX IX_ENCOUNTER_TYPE ON [dbo].[VISIT_DIMENSION] ([ENC_TYPE_PATH])
			WHERE ENC_TYPE_PATH <> '@'
			WITH (DATA_COMPRESSION = PAGE)


/* 
 * Modifier Dimension
 * No constraints here since INPATIENT/OUTPATIENT modifiers look for the same modifier of INPATIENT/OUTPATIENT
 * and distinguish based on SOURCESYSTEM_CD
 */
IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'PK_MODIFIER_CD'
			AND object_id = OBJECT_ID('modifier_dimension')
		)
	CREATE CLUSTERED INDEX PK_MODIFIER_CD ON modifier_dimension (MODIFIER_CD);

IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE object_id = object_id('modifier_dimension')
			AND NAME = 'IDX_MODIFIER_PATH'
		)
	CREATE INDEX IDX_MODIFIER_PATH ON modifier_dimension ([modifier_path]);

/* 
 * Provider Dimension
 */
IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'PK_PROV_ID'
			AND object_id = OBJECT_ID('provider_dimension')
		)
	CREATE UNIQUE CLUSTERED INDEX PK_PROV_ID ON provider_dimension (PROVIDER_ID) with (data_compression=page);

IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE object_id = object_id('provider_dimension')
			AND NAME = 'IDX_PROVIDER_PATH'
		)
	CREATE UNIQUE NONCLUSTERED INDEX IDX_PROVIDER_PATH ON provider_dimension ([PROVIDER_PATH]) with (data_compression=page);

/*
 * Time dimension
 */

IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'pk_START_DATE'
			AND object_id = OBJECT_ID('TIME_dimension')
		)
/****** Object:  Index [pk_encounter_num]    Script Date: 5/8/2017 2:08:41 PM ******/
CREATE CLUSTERED INDEX [pk_START_DATE] ON [dbo].[TIME_DIMENSION] ([START_DATE] ASC)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF
	    , DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON
		, DATA_COMPRESSION = PAGE) ON [PRIMARY]

IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'IDX_DOW'
			AND object_id = OBJECT_ID('TIME_dimension')
		)
CREATE NONCLUSTERED INDEX IDX_DOW ON [dbo].[TIME_DIMENSION] ([DAY_OF_WEEK]) WITH (DATA_COMPRESSION = PAGE)




