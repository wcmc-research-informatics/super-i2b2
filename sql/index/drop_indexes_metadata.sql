/*
 * Drops all metadata indexes
 * Copyright (c) 2014-2017 Weill Cornell Medical College
 */

USE <prefix>i2b2metadata;

DECLARE @qrymd1 NVARCHAR(max);

SELECT @qrymd1 = (
		SELECT 'DROP INDEX ' + ix.NAME + ' ON ' + 'I2B2' + '; '
		FROM sys.indexes ix
		WHERE object_id = OBJECT_ID('I2B2')
		FOR XML path('')
		);

EXEC sp_executesql @qrymd1;

SELECT @qrymd1 = (
		SELECT 'DROP INDEX ' + ix.NAME + ' ON ' + 'ICD10_ICD9' + '; '
		FROM sys.indexes ix
		WHERE object_id = OBJECT_ID('ICD10_ICD9')
		FOR XML path('')
		);

EXEC sp_executesql @qrymd1;

SELECT @qrymd1 = (
		SELECT 'DROP INDEX ' + ix.NAME + ' ON ' + 'custom_meta' + '; '
		FROM sys.indexes ix
		WHERE object_id = OBJECT_ID('custom_meta')
		FOR XML path('')
		);

EXEC sp_executesql @qrymd1;
