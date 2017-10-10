/*
 * Drops all indexes on observation fact
 * Copyright (c) 2014-2017 Weill Cornell Medical College
 */

use <prefix>i2b2demodata;

/*
 * Looks at the system table for all indexes currently on the table and drops them
 */

DECLARE @qry NVARCHAR(max);

SELECT @qry = (
		SELECT 'DROP INDEX ' + ix.NAME + ' ON ' + 'observation_fact' + '; '
		FROM sys.indexes ix
		WHERE object_id = OBJECT_ID('observation_fact')
		FOR XML path('')
		);

EXEC sp_executesql @qry;

