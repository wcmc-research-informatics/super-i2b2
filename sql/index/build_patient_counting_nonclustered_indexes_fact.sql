--/*
-- * Builds nonclustered indexes for all tables in I2B2.
-- * Copyright (c) 2014-2017 Weill Cornell Medical College
-- */
--USE <prefix>i2b2demodata;

--/*
-- * Four indexes to cover particular fields used by the patient and encounter counting algorithms.
-- * Separated out for logging convenience.
-- */

----IF NOT EXISTS (
----		SELECT *
----		FROM SYS.INDEXES
----		WHERE NAME = 'IDX_COUNTING_CONCEPTS'
----			AND OBJECT_ID = OBJECT_ID('OBSERVATION_FACT')
----		)
----BEGIN
----	CREATE NONCLUSTERED INDEX IDX_COUNTING_CONCEPTS ON [dbo].[observation_fact] ([CONCEPT_CD],[MODIFIER_CD],[INSTANCE_NUM])
----	INCLUDE ([PATIENT_NUM],[encounter_num],[provider_id],[start_date])
----			WITH (
----				SORT_IN_TEMPDB = OFF
----				, ONLINE = OFF
----				, ALLOW_ROW_LOCKS = ON
----				, ALLOW_PAGE_LOCKS = ON
----				);
----END

----IF NOT EXISTS (
----		SELECT *
----		FROM SYS.INDEXES
----		WHERE NAME = 'IDX_COUNTING_LOCATIONS'
----			AND OBJECT_ID = OBJECT_ID('OBSERVATION_FACT')
----		)
----BEGIN
----	CREATE NONCLUSTERED INDEX IDX_COUNTING_LOCATIONS ON [dbo].[observation_fact] ([LOCATION_CD],[MODIFIER_CD],[INSTANCE_NUM])
----	INCLUDE ([PATIENT_NUM],[encounter_num])
----			WITH (
----				SORT_IN_TEMPDB = OFF
----				, ONLINE = OFF
----				, ALLOW_ROW_LOCKS = ON
----				, ALLOW_PAGE_LOCKS = ON
----				);
----END

----IF NOT EXISTS (
----		SELECT *
----		FROM SYS.INDEXES
----		WHERE NAME = 'IDX_COUNTING_PROVIDERS'
----			AND OBJECT_ID = OBJECT_ID('OBSERVATION_FACT')
----		)
----BEGIN
----	CREATE NONCLUSTERED INDEX IDX_COUNTING_PROVIDERS ON [dbo].[observation_fact] ([PROVIDER_ID],[MODIFIER_CD],[INSTANCE_NUM])
----	INCLUDE ([PATIENT_NUM],[encounter_num])
----			WITH (
----				SORT_IN_TEMPDB = OFF
----				, ONLINE = OFF
----				, ALLOW_ROW_LOCKS = ON
----				, ALLOW_PAGE_LOCKS = ON
----				);
----END

----IF NOT EXISTS (
----		SELECT *
----		FROM SYS.INDEXES
----		WHERE NAME = 'IDX_COUNTING_SOURCESYSTEM'
----			AND OBJECT_ID = OBJECT_ID('OBSERVATION_FACT')
----		)
----BEGIN
----	CREATE NONCLUSTERED INDEX IDX_COUNTING_SOURCESYSTEM ON [dbo].[observation_fact] ([SOURCESYSTEM_CD],[MODIFIER_CD],[INSTANCE_NUM])
----	INCLUDE ([PATIENT_NUM],[encounter_num])
----			WITH (
----				SORT_IN_TEMPDB = OFF
----				, ONLINE = OFF
----				, ALLOW_ROW_LOCKS = ON
----				, ALLOW_PAGE_LOCKS = ON
----				);
----END


--/* 
-- * The following indexes were created when running the TriNetX data assessment
-- * scripts and may prove to be useful indexes outside of then
-- */

-- IF NOT EXISTS (
--		SELECT *
--		FROM SYS.INDEXES
--		WHERE NAME = 'IDX_TRINETXSEEK'
--			AND OBJECT_ID = OBJECT_ID('OBSERVATION_FACT')
--		)
--	create nonclustered index IDX_TRINETXSEEK on OBSERVATION_FACT ([PATIENT_NUM],[CONCEPT_CD])
--		INCLUDE ([encounter_num],[instance_num],[modifier_cd],[nval_num],[provider_id],[start_date],[tval_char],[units_cd],[valtype_cd],[valueflag_cd]);

-- IF NOT EXISTS (
--		SELECT *
--		FROM SYS.INDEXES
--		WHERE NAME = 'IDX_TRINETXPATNUM'
--			AND OBJECT_ID = OBJECT_ID('OBSERVATION_FACT')
--		)
	
--	CREATE NONCLUSTERED INDEX IDX_TRINETXPATNUM ON OBSERVATION_FACT ([PATIENT_NUM])
--		INCLUDE ([ENCOUNTER_NUM], [CONCEPT_CD], [PROVIDER_ID], [START_DATE], [END_DATE], [MODIFIER_CD], [VALTYPE_CD], [TVAL_CHAR], [UNITS_CD], [NVAL_NUM], [INSTANCE_NUM], [VALUEFLAG_CD])


IF NOT EXISTS (
		SELECT *
		FROM SYS.INDEXES
		WHERE NAME = 'OBS_FACT_COLUMNSTORE_BI'
			AND OBJECT_ID = OBJECT_ID('OBSERVATION_FACT')
		)
BEGIN
	
		SET STATISTICS PROFILE ON;
	CREATE NONCLUSTERED COLUMNSTORE INDEX OBS_FACT_COLUMNSTORE_BI ON [DBO].[OBSERVATION_FACT] 
		(
		  [PATIENT_NUM], [ENCOUNTER_NUM], [CONCEPT_CD], [MODIFIER_CD], [START_DATE], [VALTYPE_CD], [NVAL_NUM], [TVAL_CHAR],[VALUEFLAG_CD],[UNITS_CD]
		);
		
		SET STATISTICS PROFILE OFF;
END