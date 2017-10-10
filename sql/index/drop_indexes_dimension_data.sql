/*
 * Drops indexes for PATIENT, VISIT dimension
 * Copyright (c) 2014-2017 Weill Cornell Medical College
 */

use <prefix>i2b2demodata;


/*
 * Looks at the system table for all indexes currently on the table and drops them
 */


-- VISIT_DIMENSION
DECLARE @qryVISDIM NVARCHAR(max);

SELECT @qryVISDIM = (
		SELECT 'DROP INDEX ' + ix.NAME + ' ON ' + 'VISIT_DIMENSION' + '; '
		FROM sys.indexes ix
		WHERE object_id = OBJECT_ID('VISIT_DIMENSION')
		FOR XML path('')
		);

EXEC sp_executesql @qryVISDIM;

-- PATIENT_DIMENSION
DECLARE @qryPATDIM NVARCHAR(max);

SELECT @qryPATDIM = (
		SELECT 'DROP INDEX ' + ix.NAME + ' ON ' + 'PATIENT_DIMENSION' + '; '
		FROM sys.indexes ix
		WHERE object_id = OBJECT_ID('PATIENT_DIMENSION')
		FOR XML path('')
		);

EXEC sp_executesql @qryPATDIM;

-- TIME_DIMENSION
DECLARE @qryTIMEDIM NVARCHAR(max);

SELECT @qryTIMEDIM = (
		SELECT 'DROP INDEX ' + ix.NAME + ' ON ' + 'TIME_DIMENSION' + '; '
		FROM sys.indexes ix
		WHERE object_id = OBJECT_ID('TIME_DIMENSION')
		FOR XML path('')
		);

EXEC sp_executesql @qryTIMEDIM;