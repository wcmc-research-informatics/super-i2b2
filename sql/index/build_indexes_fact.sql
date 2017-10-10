/*
 * Builds nonclustered indexes for all tables in I2B2.
 * Copyright (c) 2014-2017 Weill Cornell Medical College
 */
USE <prefix>i2b2demodata;

/*
 * This index is required for ontology elements that leverage TIME_DIMENSION
 * through the START_DATE field of OBSERVATION_FACT. Filters out rows with
 * placeholder dates as those should never be returned through the web client.
 */
IF NOT EXISTS (
		SELECT *
		FROM SYS.INDEXES
		WHERE NAME = 'FK_OBS_FACT_START_DATE'
			AND OBJECT_ID = OBJECT_ID('OBSERVATION_FACT')
		)
BEGIN
		
		create nonclustered index FK_OBS_FACT_START_DATE on dbo.OBSERVATION_FACT ([START_DATE])
			INCLUDE ([PATIENT_NUM],[ENCOUNTER_NUM])
			WHERE [START_DATE] > '1776-07-04'
		WITH (
				SORT_IN_TEMPDB = OFF
				, ONLINE = OFF
				, ALLOW_ROW_LOCKS = ON
				, ALLOW_PAGE_LOCKS = ON
				);
END

/*
 * This index is required for ontology elements that leverage PROVIDER_DIMENSION
 * through the PROVIDER_ID field of OBSERVATION_FACT. Filters out rows with
 * placeholder provider IDs as those should never be returned through the web client.
 */
IF NOT EXISTS (
		SELECT *
		FROM SYS.INDEXES
		WHERE NAME = 'FK_OBS_FACT_PROVIDERS'
			AND OBJECT_ID = OBJECT_ID('OBSERVATION_FACT')
		)
BEGIN
		CREATE NONCLUSTERED INDEX FK_OBS_FACT_PROVIDERS ON [DBO].[OBSERVATION_FACT] ([PROVIDER_ID]) 
			INCLUDE([PATIENT_NUM],[ENCOUNTER_NUM])
		WITH (
				SORT_IN_TEMPDB = OFF
				, ONLINE = OFF
				, ALLOW_ROW_LOCKS = ON
				, ALLOW_PAGE_LOCKS = ON
				, DATA_COMPRESSION = PAGE
				) ;	
END

/*
 * This index is required for ontology elements that leverage SOURCE_MASTER
 * through the SOURCESYSTEM_CD field of OBSERVATION_FACT. Data compression
 * yields massive savings for this index in particular due to low cardinality
 * of SOURCESYSTEM_CD field.
 */
IF NOT EXISTS (
		SELECT *
		FROM SYS.INDEXES
		WHERE NAME = 'FK_OBS_FACT_SOURCE'
			AND OBJECT_ID = OBJECT_ID('OBSERVATION_FACT')
		)
BEGIN
		
		CREATE NONCLUSTERED INDEX FK_OBS_FACT_SOURCE ON [DBO].[OBSERVATION_FACT] ( [SOURCESYSTEM_CD] )
			INCLUDE([ENCOUNTER_NUM], [PATIENT_NUM]) with (data_compression=page);		
		
END

/* 
 * For rapid deletion of rows from OBSERVATION_FACT by using the following style of query:
 * 
 * DELETE FROM FACT WHERE TEXT_SEARCH_INDEX IN (SELECT TEXT_SEARCH_INDEX FROM FACT WHERE ... )
 */
--IF NOT EXISTS (
--		SELECT *
--		FROM SYS.INDEXES
--		WHERE NAME = 'IDX_TSI'
--			AND OBJECT_ID = OBJECT_ID('OBSERVATION_FACT')
--		)
--BEGIN
--		CREATE UNIQUE NONCLUSTERED INDEX IDX_TSI ON [DBO].[OBSERVATION_FACT] ( [TEXT_SEARCH_INDEX], [CONCEPT_CD], [MODIFIER_CD] )
--			INCLUDE([ENCOUNTER_NUM],[PATIENT_NUM]);	
--END

/*
 * Supports project views
 */
IF NOT EXISTS (
		SELECT *
		FROM SYS.INDEXES
		WHERE NAME = 'IDX_INDEX_FOR_PROJECT_VIEWS'
			AND OBJECT_ID = OBJECT_ID('OBSERVATION_FACT')
		)
BEGIN
		
     create nonclustered index IDX_INDEX_FOR_PROJECT_VIEWS on DBO.observation_fact ( [PATIENT_NUM] )
			INCLUDE ([START_DATE], [ENCOUNTER_NUM], [PROVIDER_ID], [INSTANCE_NUM], [VALTYPE_CD]
						 ,[TVAL_CHAR], [NVAL_NUM], [VALUEFLAG_CD], [QUANTITY_NUM], [UNITS_CD], [END_DATE], [LOCATION_CD], [CONFIDENCE_NUM]
						 ,[UPDATE_DATE],[DOWNLOAD_DATE],[IMPORT_DATE],[SOURCESYSTEM_CD],[TEXT_SEARCH_INDEX])
		
END


-- IF NOT EXISTS (
--		SELECT *
--		FROM SYS.INDEXES
--		WHERE NAME = 'FK_LABS'
--			AND OBJECT_ID = OBJECT_ID('OBSERVATION_FACT')
--		)
--BEGIN
--     create nonclustered index FK_LABS on heroni2b2demodata.dbo.observation_fact ( [CONCEPT_CD], [MODIFIER_CD], [START_DATE], [VALTYPE_CD], [NVAL_NUM], [TVAL_CHAR]  )
--			INCLUDE ([PATIENT_NUM], [ENCOUNTER_NUM], [TEXT_SEARCH_INDEX], [provider_id], [INSTANCE_NUM])

--END

