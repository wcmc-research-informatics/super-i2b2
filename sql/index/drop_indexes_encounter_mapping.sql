/*
 * Drops mapping table indexes 
 * Copyright (c) 2014-2017 Weill Cornell Medical College
 */
use <prefix>i2b2demodata;


DECLARE @qrym2 NVARCHAR(max);

SELECT @qrym2 = (
		SELECT 'DROP INDEX ' + ix.NAME + ' ON ' + 'ENCOUNTER_MAPPING' + '; '
		FROM sys.indexes ix
		WHERE object_id = OBJECT_ID('ENCOUNTER_MAPPING')
		FOR XML path('')
		);

EXEC sp_executesql @qrym2;
