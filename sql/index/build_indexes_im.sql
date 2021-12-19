/*
	Indexes for IM_MPI_MAPPING
	Copyright (c) 2014-2017 Weill Cornell Medical College
*/


USE [heroni2b2imdata];


IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'IDX_GLOBAL_ID'
			AND object_id = OBJECT_ID('IM_MPI_MAPPING')
		)
	CREATE CLUSTERED INDEX IDX_GLOBAL_ID ON [dbo].[IM_MPI_MAPPING] ([GLOBAL_ID]
		, [LCL_ID]) 
		;

IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'IDX_IM_SOURCESYSTEM_CD'
			AND object_id = OBJECT_ID('IM_MPI_MAPPING')
		)
		CREATE NONCLUSTERED INDEX IDX_IM_SOURCESYSTEM_CD ON [dbo].[IM_MPI_MAPPING] ([SOURCESYSTEM_CD])
			INCLUDE ([GLOBAL_ID],[LCL_SITE],[LCL_ID])
/*
 * Enhances specimens facts
 */
IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'IDX_LCL_ID'
			AND object_id = OBJECT_ID('IM_MPI_MAPPING')
		)
		CREATE NONCLUSTERED INDEX IDX_LCL_ID ON [dbo].[IM_MPI_MAPPING] ([LCL_ID])
			INCLUDE ([GLOBAL_ID])
	
IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'IDX_LCL_SITE'
			AND object_id = OBJECT_ID('IM_MPI_MAPPING')
		)
	CREATE NONCLUSTERED INDEX IDX_LCL_SITE ON [dbo].[IM_MPI_MAPPING] ([LCL_SITE]);

	/*
	 * IM_PROJECT_PATIENTS
	 */
	IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'IDX_GLOBALID'
			AND object_id = OBJECT_ID('IM_PROJECT_PATIENTS')
		)
	CREATE CLUSTERED INDEX IDX_GLOBALID ON [dbo].[IM_PROJECT_PATIENTS] ([GLOBAL_ID]);

	IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'IDX_PROJID'
			AND object_id = OBJECT_ID('IM_PROJECT_PATIENTS')
		)
	CREATE NONCLUSTERED INDEX IDX_PROJID ON [dbo].[IM_PROJECT_PATIENTS] ([PROJECT_ID]);