/*
 * Create indexes on CDW data
 * Copyright (c) 2014-2017 Weill Cornell Medical College
 */

USE [CDW];

/*
 * 90% increase in performance for building visit dimension
 */
 IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE object_id = object_id('[NICKEAST].[PATIENT]')
			AND NAME = 'IDX_PATIENT_ID_2'
		)
	 CREATE NONCLUSTERED INDEX IDX_PATIENT_ID_2
		ON [NICKEAST].[PATIENT] ([PATIENT_ID])
		INCLUDE ([SEX_CODE],[BIRTH_DATE],[STATE_CODE],[ZIP]
					,[MARITAL_STATUS_CODE],[RACE_CODE],[RELIGION_CODE]);

/*
 * Clustered index for VISIT table
 */

   IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE object_id = object_id('[NICKEAST].[VISIT]')
			AND NAME = 'IDX_ACCOUNT'
		)
	 CREATE CLUSTERED INDEX IDX_ACCOUNT ON [NICKEAST].[VISIT] ([ACCOUNT]) 

/*
 * 16% increase in CompuRecord filtering
 */
  IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE object_id = object_id('[NICKEAST].[VISIT]')
			AND NAME = 'IDX_PATIENT_ID'
		)
	 CREATE NONCLUSTERED INDEX IDX_PATIENT_ID ON [NICKEAST].[VISIT] ([ACCOUNT]) 
				INCLUDE ([PATIENT_ID],[CASE_STATUS_CODE],[ADMIT_DATE],[UPDATEDDTM_CDW])
				
--Helps EAGLE mapping fly
  IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE object_id = object_id('[NICKEAST].[VISIT]')
			AND NAME = 'IDX_FACILITY_CODE'
		)
	CREATE NONCLUSTERED INDEX IDX_FACILITY_CODE ON [NICKEAST].[VISIT] ([PATIENT_CLASS_CODE],[FACILITY_CODE])
INCLUDE ([ACCOUNT],[PATIENT_ID],[CASE_STATUS_CODE],[UPDATEDDTM_CDW])

/*
 * ECLIPSYS_EAST.VISIT
 */
--The Query Processor estimates that implementing the following index could improve the query cost by 99.4428%.
--Used when building ENCOUNTER_MAPPING for CDW data.
*/
IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE object_id = object_id('[CDW].[ECLIPSYS_EAST].[VISIT]')
			AND NAME = 'IDX_ECL_PATIENT_ID'
		)
	CREATE NONCLUSTERED INDEX IDX_ECL_PATIENT_ID ON [ECLIPSYS_EAST].[VISIT] ([PATIENT_ID]) INCLUDE (
		  [ACCOUNTNUM]
		, [ADMITDTM]
		, [VISITSTATUS]

		);


IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'IDX_ACCOUNTNUM'
			AND object_id = OBJECT_ID('[ECLIPSYS_EAST].[VISIT]')
		)
	CREATE NONCLUSTERED INDEX IDX_ACCOUNTNUM ON [ECLIPSYS_EAST].[VISIT] ([ACCOUNTNUM] ASC, PATIENT_ID ASC) 
		INCLUDE ([CLIENTVISITGUID])


--The Query Processor estimates that implementing the following index could improve the query cost by 36%.
--Used for eagle procedures observation facts
IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE object_id = object_id('[NICKEAST].[VISIT_DIAGNOSIS]')
			AND NAME = 'IDX_DIAGNOSIS_CODE_TYPE'
		)
		CREATE NONCLUSTERED INDEX IDX_DIAGNOSIS_CODE_TYPE ON [NICKEAST].[VISIT_DIAGNOSIS] ([CODE_TYPE],[DIAGNOSIS_CODE])
			INCLUDE ([ACCOUNT],[PRIMARY_TIME]);


--The Query Processor estimates that implementing the following index could improve the query cost by 99.9115%.
IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE object_id = object_id('[NICKEAST].[VISIT_DIAGNOSIS]')
			AND NAME = 'IDX_VISIT_DIAGNOSIS_ACC'
		)
	CREATE NONCLUSTERED INDEX [IDX_VISIT_DIAGNOSIS_ACC] ON [NICKEAST].[VISIT_DIAGNOSIS] ([ACCOUNT]) INCLUDE (
		[PRIMARY_TIME]
		, [DIAGNOSIS_CODE]
		);

/*
 * nickeast.code_icd9_diagnosis
 */
--The Query Processor estimates that implementing the following index could improve the query cost by 48.2572%.
IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE object_id = object_id('[NICKEAST].[CODE_ICD9_DIAGNOSIS]')
			AND NAME = 'IDX_ICD9_DIAG'
		)
	CREATE NONCLUSTERED INDEX IDX_ICD9_DIAG ON [NICKEAST].[CODE_ICD9_DIAGNOSIS] ([ICD9_DIAGNOSIS_CODE])

/*
 * nickeast.VISIT_PROCEDURE
 */
IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE object_id = object_id('[NICKEAST].[VISIT_PROCEDURE]')
			AND NAME = 'IDX_VP_ACCT'
		)
	CREATE NONCLUSTERED INDEX IDX_VP_ACCT ON [NICKEAST].[VISIT_PROCEDURE] ([ACCOUNT]) INCLUDE (
		[PROCEDURE_CODE]
		, [EAGLE_PROC_DATE]
		);

/*
 * ECLIPSYS_EAST.MAR_INFO
 */
--The Query Processor estimates that implementing the following index could improve the query cost by 23.0558%.
IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE object_id = object_id('[ECLIPSYS_EAST].[MAR_INFO]')
			AND NAME = 'IDX_CLIENTVISITGUID'
		)
	CREATE NONCLUSTERED INDEX IDX_CLIENTVISITGUID ON [ECL].[MAR_INFO] ([CLIENTVISITGUID]) INCLUDE ([ORDERENTEREDDTM])

/*
 * eclipsys_east.demographics
 */
--The Query Processor estimates that implementing the following index could improve the query cost by 43.4849%.
IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE object_id = object_id('[ECLIPSYS_EAST].[DEMOGRAPHICS]')
			AND NAME = 'IDX_ECL_RACE'
		)
CREATE NONCLUSTERED INDEX IDX_ECL_RACE ON [ECLIPSYS_EAST].[DEMOGRAPHICS] ([RACE])

IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE object_id = object_id('[ECLIPSYS_EAST].[DEMOGRAPHICS]')
			AND NAME = 'IDX_ECL_LANGUAGE'
		)
CREATE NONCLUSTERED INDEX IDX_ECL_LANGUAGE ON [ECLIPSYS_EAST].[DEMOGRAPHICS] ([language])

/*
 * ECL.ORDER_DRUG
 */
--The Query Processor estimates that implementing the following index could improve the query cost by 80%.
IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE object_id = object_id('[ECLIPSYS_EAST].[DEMOGRAPHICS]')
			AND NAME = 'IDX_ORDER_DRUG'
		)
	CREATE NONCLUSTERED INDEX IDX_ORDER_DRUG ON [ECL].[ORDER_DRUG] (
		[CLIENTIDCODE]
		, [CLIENTVISITGUID]
		) INCLUDE (
		[RXNORMCODE]
		, [STOCKITEMUOMCODE]
		);

/*
 * ECLIPSYS_EAST.HEALTHISSUE
 */
--The Query Processor estimates that implementing the following index could improve the query cost by 72.8%.
IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE object_id = object_id('[ECLIPSYS_EAST].[HEALTHISSUE]')
			AND NAME = 'IDX_HEALTHISSUE'
		)
	CREATE NONCLUSTERED INDEX IDX_HEALTHISSUE ON [ECLIPSYS_EAST].[HEALTHISSUE] (
		  [CLIENTVISITGUID]
		, [CODINGSCHEMA]
		, [CODE]
		) INCLUDE (
		  [PATIENT_ID]
		, [PRIMARY_TIME]
		, [TOUCHEDWHEN]
		)


--The Query Processor estimates that implementing the following index could improve the query cost by 70%.
IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE object_id = object_id('[ECLIPSYS_EAST].[HEALTHISSUE]')
			AND NAME = 'IDX_TYPECODES'
		)
	CREATE NONCLUSTERED INDEX idx_typecodes ON [ECLIPSYS_EAST].[HEALTHISSUE] (
		[TYPECODE]
		, [CODINGSCHEMA]
		, [CODE]
		) INCLUDE (
		[PATIENT_ID]
		, [PRIMARY_TIME]
		, [CLIENTVISITGUID]
		, [TOUCHEDWHEN]
		)




IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'idx_healthissue'
			AND object_id = OBJECT_ID('[ECLIPSYS_EAST].[HEALTHISSUE]')
		)
	CREATE NONCLUSTERED INDEX idx_healthissue ON eclipsys_east.healthissue (
		clientvisitguid
		,patient_id
		,code
		)

/*
 * nickeast.visit_location
 */
 
IF NOT EXISTS (
		SELECT *
		FROM SYS.INDEXES
		WHERE NAME = 'PK_SEQNUM'
			AND OBJECT_ID = OBJECT_ID('[NICKEAST].[VISIT_LOCATION]')
		)
	CREATE UNIQUE CLUSTERED INDEX PK_SEQNUM ON NICKEAST.VISIT_LOCATION (SQ_NUM);

IF NOT EXISTS (
		SELECT *
		FROM SYS.INDEXES
		WHERE NAME = 'IDX_FACILITY_CODE'
			AND OBJECT_ID = OBJECT_ID('[NICKEAST].[VISIT_LOCATION]')
		)
	CREATE NONCLUSTERED INDEX IDX_FACILITY_CODE ON NICKEAST.VISIT_LOCATION (FACILITY_CODE)
		INCLUDE ([ACCOUNT], [PATIENT_ID], [PRIMARY_TIME], [LOCATION_CODE], [room], [BED], [PROVIDER_ID], [MEDICAL_SERVICE_CODE], [UPDATEDDTM_CDW], [EVENT_CODE], [SEQUENCE_NO]);

IF NOT EXISTS (
		SELECT *
		FROM SYS.INDEXES
		WHERE NAME = 'IDX_ACCOUNT'
			AND OBJECT_ID = OBJECT_ID('[NICKEAST].[VISIT_LOCATION]')
		)		
	CREATE NONCLUSTERED INDEX IDX_ACCOUNT ON [NICKEAST].[VISIT_LOCATION] ([ACCOUNT])
		INCLUDE ([PRIMARY_TIME],[LOCATION_CODE],[PROVIDER_ID])	

--8% improvement for Eagle mapping
IF NOT EXISTS (
		SELECT *
		FROM SYS.INDEXES
		WHERE NAME = 'IDX_PRIMARY_TIME'
			AND OBJECT_ID = OBJECT_ID('[NICKEAST].[VISIT_LOCATION]')
		)		
		CREATE NONCLUSTERED INDEX IDX_PRIMARY_TIME ON [NICKEAST].[VISIT_LOCATION] ([PRIMARY_TIME])
			INCLUDE ([ACCOUNT],[LOCATION_CODE],[PROVIDER_ID])

IF NOT EXISTS (
		SELECT *
		FROM SYS.INDEXES
		WHERE NAME = 'IDX_CDW_ASPIRE'
			AND OBJECT_ID = OBJECT_ID('[NICKEAST].[VISIT_DIAGNOSIS]')
		)	
CREATE NONCLUSTERED INDEX IDX_CDW_ASPIRE ON [NICKEAST].[VISIT_DIAGNOSIS] ([ACCOUNT])
	INCLUDE ([PATIENT_ID],[PRIMARY_TIME],[CODE_TYPE],[DIAGNOSIS_CODE],[DESCRIPTION])