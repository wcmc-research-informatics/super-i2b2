
use <prefix>i2b2demodata;

/*
 * An index to cover all other fields of interest. Some queries may want
 * to return one or more of the following fields. The advantage of a
 * columnstore index is that each column can be accessed independently and
 * the added compression involved with this style of index results in
 * increased retrieval performance. Ideally, this should be a nonclustered
 * index that should include all columns of the table but we here only include
 * the most important. No other indexes can be created offline on a table after a
 * columnstore index is created so make this the last one.
 */
IF NOT EXISTS (
		SELECT *
		FROM SYS.INDEXES
		WHERE NAME = 'OBS_FACT_COLUMNSTORE_BI'
			AND OBJECT_ID = OBJECT_ID('OBSERVATION_FACT')
		)
BEGIN
	CREATE NONCLUSTERED COLUMNSTORE INDEX OBS_FACT_COLUMNSTORE_BI ON [DBO].[OBSERVATION_FACT] 
		(
		  [ENCOUNTER_NUM]
		, [PATIENT_NUM]
		);
END