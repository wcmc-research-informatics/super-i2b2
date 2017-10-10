/*
 * Looks at the system table for all indexes currently on the table and drops them
 * Copyright (c) 2014-2017 Weill Cornell Medical College
 */

use <prefix>i2b2demodata;

-- CODE LOOKUP
DECLARE @qryCODLOO NVARCHAR(max);

SELECT @qryCODLOO = (
		SELECT 'DROP INDEX ' + ix.NAME + ' ON ' + 'CODE_LOOKUP' + '; '
		FROM sys.indexes ix
		WHERE object_id = OBJECT_ID('CODE_LOOKUP')
		FOR XML path('')
		);

EXEC sp_executesql @qryCODLOO;

-- CONCEPT_DIMENSION
DECLARE @qryCONDIM NVARCHAR(max);

SELECT @qryCONDIM = (
		SELECT 'DROP INDEX ' + ix.NAME + ' ON ' + 'CONCEPT_DIMENSION' + '; '
		FROM sys.indexes ix
		WHERE object_id = OBJECT_ID('CONCEPT_DIMENSION')
		FOR XML path('')
		);

EXEC sp_executesql @qryCONDIM;

-- MODIFIER_DIMENSION
DECLARE @qryCONMOD NVARCHAR(max);

SELECT @qryCONMOD = (
		SELECT 'DROP INDEX ' + ix.NAME + ' ON ' + 'MODIFIER_DIMENSION' + '; '
		FROM sys.indexes ix
		WHERE object_id = OBJECT_ID('MODIFIER_DIMENSION')
		FOR XML path('')
		);

EXEC sp_executesql @qryCONMOD;

-- PROVIDER_DIMENSION
DECLARE @qryPROVDIM NVARCHAR(max);

SELECT @qryPROVDIM = (
		SELECT 'DROP INDEX ' + ix.NAME + ' ON ' + 'PROVIDER_DIMENSION' + '; '
		FROM sys.indexes ix
		WHERE object_id = OBJECT_ID('PROVIDER_DIMENSION')
		FOR XML path('')
		);

EXEC sp_executesql @qryPROVDIM;