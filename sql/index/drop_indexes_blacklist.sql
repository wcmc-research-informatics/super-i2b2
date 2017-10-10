/*
 * Drops indexes for i2b2 blacklist tables.
 * Copyright (c) 2014-2017 Weill Cornell Medical College
 */


use super_monthly;


-- BLACKLISTS

DECLARE @qrybl1 NVARCHAR(max);

SELECT @qrybl1 = (
		SELECT 'DROP INDEX ' + ix.NAME + ' ON ' + 'super_diagnoses_dxid_blacklist' + '; '
		FROM sys.indexes ix
		WHERE object_id = OBJECT_ID('super_diagnoses_dxid_blacklist')
		FOR XML path('')
		);

EXEC sp_executesql @qrybl1;

DECLARE @qrybl2 NVARCHAR(max);

SELECT @qrybl2 = (
		SELECT 'DROP INDEX ' + ix.NAME + ' ON ' + 'super_encounter_location_blacklist' + '; '
		FROM sys.indexes ix
		WHERE object_id = OBJECT_ID('super_encounter_location_blacklist')
		FOR XML path('')
		);

EXEC sp_executesql @qrybl2;

DECLARE @qrybl3 NVARCHAR(max);

SELECT @qrybl3 = (
		SELECT 'DROP INDEX ' + ix.NAME + ' ON ' + 'super_patient_blacklist' + '; '
		FROM sys.indexes ix
		WHERE object_id = OBJECT_ID('super_patient_blacklist')
		FOR XML path('')
		);

EXEC sp_executesql @qrybl3;

DECLARE @qrybl4 NVARCHAR(max);

SELECT @qrybl4 = (
		SELECT 'DROP INDEX ' + ix.NAME + ' ON ' + 'super_provider_blacklist' + '; '
		FROM sys.indexes ix
		WHERE object_id = OBJECT_ID('super_provider_blacklist')
		FOR XML path('')
		);

EXEC sp_executesql @qrybl4;

DECLARE @qrybl5 NVARCHAR(max);

SELECT @qrybl5 = (
		SELECT 'DROP INDEX ' + ix.NAME + ' ON ' + 'proc_blacklist' + '; '
		FROM sys.indexes ix
		WHERE object_id = OBJECT_ID('proc_blacklist')
		FOR XML path('')
		);

EXEC sp_executesql @qrybl5;

