/*
 * Miscellaneous indexes
 *Copyright (c) 2014-2017 Weill Cornell Medical College
 */

use <prefix>i2b2demodata;

IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'idx_qt_result_ids'
			AND object_id = OBJECT_ID('QT_PATIENT_SET_COLLECTION')
		)
BEGIN
	-- This index does not need to be created but it should be created if it doesn't exist
	-- Helps to speed up queries involving large patient sets in Export Excel
	CREATE NONCLUSTERED INDEX idx_qt_result_ids ON [dbo].[QT_PATIENT_SET_COLLECTION] ([RESULT_INSTANCE_ID]) INCLUDE ([PATIENT_NUM]);
END
