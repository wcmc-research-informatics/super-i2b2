/*
 * Creates indexes on I2B2 metadata
 * Copyright (c) 2014-2017 Weill Cornell Medical College
 */

use <prefix>i2b2metadata;

/*
 i2b2
 */

IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'PK_PRIMARY'
			AND object_id = OBJECT_ID('i2b2')
		)
	CREATE CLUSTERED INDEX PK_PRIMARY ON i2b2 (C_FULLNAME) with (data_compression=page);

IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'idx_i2b2_ontology'
			AND object_id = OBJECT_ID('i2b2')
		)
	CREATE INDEX idx_i2b2_ontology ON i2b2 (
		C_HLEVEL
		, M_APPLIED_PATH
		, M_EXCLUSION_CD
		, C_SYNONYM_CD
		, C_BASECODE
		) include (
		C_NAME
		, C_FULLNAME
		) with (data_compression=page);

IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'idx_i2b2_searching'
			AND object_id = OBJECT_ID('i2b2')
		)
	CREATE INDEX idx_i2b2_searching ON i2b2 (
		C_FACTTABLECOLUMN
		, C_TABLENAME
		, C_COLUMNNAME
		, C_COLUMNDATATYPE
		, C_OPERATOR
		, C_DIMCODE
		) with (data_compression=page);

IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE object_id = object_id('i2b2')
			AND NAME = 'IDX_SSID'
		)
	CREATE INDEX IDX_SSID ON i2b2 ([SOURCESYSTEM_CD]) with (data_compression=page);

-- Increases processing of visit dimension eagle facts by 35%
IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE object_id = object_id('i2b2')
			AND NAME = 'IDX_BASECODE'
		)
	CREATE NONCLUSTERED INDEX IDX_BASECODE
		ON [dbo].[i2b2] ([C_BASECODE]) INCLUDE ([C_FULLNAME]) with (data_compression=page);


/*
 * ICD10_ICD9
 */
IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'PK_PRIMARY'
			AND object_id = OBJECT_ID('icd10_icd9')
		)
	CREATE CLUSTERED INDEX PK_PRIMARY ON icd10_icd9 (C_FULLNAME) with (data_compression = page);

IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'idx_ICD10_ICD9_ontology'
			AND object_id = OBJECT_ID('ICD10_ICD9')
		)
	CREATE INDEX idx_ICD10_ICD9_ontology ON ICD10_ICD9 (
		C_HLEVEL
		, M_APPLIED_PATH
		, M_EXCLUSION_CD
		, C_SYNONYM_CD
		, C_BASECODE
		) include (
		C_NAME
		, C_FULLNAME
		) with (data_compression = page);

/*
 * CUSTOM_META
 */
IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'PK_PRIMARY'
			AND object_id = OBJECT_ID('custom_meta')
		)
	CREATE CLUSTERED INDEX PK_PRIMARY ON custom_meta (C_FULLNAME);

IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'idx_cm_ontology'
			AND object_id = OBJECT_ID('CUSTOM_META')
		)
	CREATE INDEX idx_cm_ontology ON CUSTOM_META (
		C_HLEVEL
		, M_APPLIED_PATH
		, M_EXCLUSION_CD
		, C_SYNONYM_CD
		, C_BASECODE
		) include (
		C_NAME
		, C_FULLNAME
		);

IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'idx_cm_searching'
			AND object_id = OBJECT_ID('CUSTOM_META')
		)
	CREATE INDEX idx_cm_searching ON CUSTOM_META (
		C_FACTTABLECOLUMN
		, C_TABLENAME
		, C_COLUMNNAME
		, C_COLUMNDATATYPE
		, C_OPERATOR
		, C_DIMCODE
		);

IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'idx_namescodes'
			AND object_id = OBJECT_ID('CUSTOM_META')
		)
	CREATE INDEX idx_namescodes ON CUSTOM_META (
		C_BASECODE
		, C_FULLNAME
		);

IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE object_id = object_id('CUSTOM_META')
			AND NAME = 'IDX_SSID'
		)
	CREATE INDEX IDX_SSID ON CUSTOM_META ([SOURCESYSTEM_CD]);

IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE object_id = object_id('CUSTOM_META')
			AND NAME = 'IDX_CUSTOM_BASECODES'
		)
	CREATE NONCLUSTERED INDEX [IDX_CUSTOM_BASECODES] ON [dbo].[CUSTOM_META] (
		[C_HLEVEL] ASC
		, [C_BASECODE] ASC
		) INCLUDE (
		[C_FULLNAME]
		, [C_SYMBOL]
		)

		
IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE object_id = object_id('custom_meta')
			AND NAME = 'IDX_CM_COUNTING'
		)
	CREATE INDEX IDX_CM_COUNTING ON custom_meta ([C_TOTALNUM],[C_VISUALATTRIBUTES])
		INCLUDE ([C_FULLNAME],[C_NAME],[C_PATH],[C_BASECODE], [C_HLEVEL]);

-- Increases copying of patient counts back into ontology tables
IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE object_id = object_id('custom_meta')
			AND NAME = 'IDX_CTOTALNUM'
		)
	CREATE NONCLUSTERED INDEX IDX_CTOTALNUM
		ON [dbo].[custom_meta] ([C_FULLNAME]) INCLUDE ([C_TOTALNUM]);

/* BIRN */
IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'PK_PRIMARY'
			AND object_id = OBJECT_ID('BIRN')
	)
	CREATE CLUSTERED INDEX PK_PRIMARY ON BIRN (C_FULLNAME);


IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE object_id = object_id('BIRN')
			AND NAME = 'IDX_BIRN_COUNTING'
		)
	CREATE INDEX IDX_BIRN_COUNTING ON birn ([C_TOTALNUM],[C_VISUALATTRIBUTES])
		INCLUDE ([C_FULLNAME],[C_NAME],[C_PATH],[C_BASECODE], [C_HLEVEL]);

-- Increases copying of patient counts back into ontology tables
IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE object_id = object_id('BIRN')
			AND NAME = 'IDX_CTOTALNUM'
		)
	CREATE NONCLUSTERED INDEX IDX_CTOTALNUM
		ON [dbo].[BIRN] ([C_FULLNAME]) INCLUDE ([C_TOTALNUM]);