/*
 * Adds indexes to the patient and encounter lookup tables
 * Copyright (c) 2014-2017 Weill Cornell Medical College
 */
 use <prefix>i2b2demodata;

BEGIN TRANSACTION;

IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'PK_ENCOUNTER_IDE'
			AND object_id = OBJECT_ID('encounter_mapping')
		)
	CREATE CLUSTERED INDEX PK_ENCOUNTER_IDE ON ENCOUNTER_MAPPING ([ENCOUNTER_IDE], [ENCOUNTER_IDE_SOURCE]);

-- Used by CompuRecord when constructing facts. Good index to have all around.
IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE object_id = object_id('ENCOUNTER_MAPPING')
			AND NAME = 'IDX_ENCOUNTER_KEY'
		)
BEGIN
	CREATE NONCLUSTERED INDEX IDX_ENCOUNTER_KEY ON ENCOUNTER_MAPPING (
		  [ENCOUNTER_NUM]
		, [PATIENT_IDE]
		, [PATIENT_IDE_SOURCE]
		, [ENCOUNTER_IDE_SOURCE]
		, [PROJECT_ID]
		, [PATIENT_NUM]
		, [LOCATION_CD]
		, [PROVIDER_ID]
		, [CONTACT_DATE]
		, [UPDATE_DATE]
		, [DOWNLOAD_DATE]
		, [IMPORT_DATE]
		);
END

IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'idx_patnum'
			AND object_id = OBJECT_ID('encounter_mapping')
		)
	CREATE NONCLUSTERED INDEX IDX_PATNUM ON [DBO].[ENCOUNTER_MAPPING] ([PATIENT_NUM]) INCLUDE (
		  [ENCOUNTER_NUM]
		, [CONTACT_DATE]
		, [PROVIDER_ID]
		, [LOCATION_CD]
		, [SOURCESYSTEM_CD]	 -- eliminates an expensive key lookup operation from specimens facts
		)




-- Helps to process Eagle procedures facts 70% faster
IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'IDX_ENC_SOURCE_AND_DATES'
			AND object_id = OBJECT_ID('encounter_mapping')
		)
	CREATE NONCLUSTERED INDEX IDX_ENC_SOURCE_AND_DATES ON [dbo].[ENCOUNTER_MAPPING] ([ENCOUNTER_IDE_SOURCE])
	INCLUDE ([ENCOUNTER_NUM],[ENCOUNTER_IDE],[CONTACT_DATE],[PATIENT_NUM],[PROVIDER_ID],[LOCATION_CD],[SOURCESYSTEM_CD])


IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'IDX_SOURCESYSTEM'
			AND object_id = OBJECT_ID('encounter_mapping')
		)
	CREATE NONCLUSTERED INDEX IDX_SOURCESYSTEM ON [dbo].[ENCOUNTER_MAPPING] ([SOURCESYSTEM_CD]) INCLUDE (
		[ENCOUNTER_NUM]
		, [ENCOUNTER_IDE]
		, [contact_date]
		, [PATIENT_NUM]
		, [patient_ide]
		, [provider_id]
		, [location_cd]
		, [update_date]
		, [download_date]
		, [import_date]
		)


COMMIT TRANSACTION;
