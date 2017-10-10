/*
 * Builds clustered indexes for all tables in I2B2.
 * Copyright (c) 2014-2017 Weill Cornell Medical College
 */
USE <prefix>i2b2demodata;

IF NOT EXISTS (
		SELECT *
		FROM SYS.INDEXES
		WHERE NAME = 'PK_CONCEPT_CD'
			AND OBJECT_ID = OBJECT_ID('OBSERVATION_FACT')
		)
BEGIN
	SET STATISTICS PROFILE ON;
	CREATE CLUSTERED INDEX PK_CONCEPT_CD ON [DBO].[OBSERVATION_FACT] ([CONCEPT_CD],[MODIFIER_CD]) 
		on [PART_schem_CON_CD_<prefix>]([concept_cd]);
	SET STATISTICS PROFILE OFF;
END