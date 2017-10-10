/*
 * Drops mapping table indexes 
 * Copyright (c) 2014-2017 Weill Cornell Medical College
 */
use <prefix>i2b2demodata;

-- MAPPING TABLES
DECLARE @qrym1 NVARCHAR(max);

SELECT @qrym1 = (
		SELECT 'DROP INDEX ' + ix.NAME + ' ON ' + 'PATIENT_MAPPING' + '; '
		FROM sys.indexes ix
		WHERE object_id = OBJECT_ID('PATIENT_MAPPING')
		FOR XML path('')
		);

EXEC sp_executesql @qrym1;

DECLARE @qrym2 NVARCHAR(max);

SELECT @qrym2 = (
		SELECT 'DROP INDEX ' + ix.NAME + ' ON ' + 'ENCOUNTER_MAPPING' + '; '
		FROM sys.indexes ix
		WHERE object_id = OBJECT_ID('ENCOUNTER_MAPPING')
		FOR XML path('')
		);

EXEC sp_executesql @qrym2;

