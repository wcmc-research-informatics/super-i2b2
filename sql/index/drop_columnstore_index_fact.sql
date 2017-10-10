/*
 * Drops all indexes on observation fact
 * Copyright (c) 2014-2017 Weill Cornell Medical College
 */

use <prefix>i2b2demodata;

/*
 * Explicitly drops the columnstore index
 * before truncating data from table as this
 * type of index prevents data modifications
 * after creation
 */
IF EXISTS (
		SELECT *
		FROM SYS.INDEXES
		WHERE NAME = 'OBS_FACT_COLUMNSTORE_BI'
			AND OBJECT_ID = OBJECT_ID('OBSERVATION_FACT')
		)
BEGIN
	DROP INDEX OBS_FACT_COLUMNSTORE_BI ON observation_fact;
END