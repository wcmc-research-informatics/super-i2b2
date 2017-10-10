/*
 * The IM_PROJECT_SITES table contains information about the different sites.
 * This script fills up IM_PROJECT_SITES for all projects on ARCHSQLP02
 * Truncated and repopulated every refresh cycle.
 */

use heroni2b2imdata;

/*
 * Check to see if the table is empty. If the table is empty
 * initialize it with data from all PATIENT_MAPPING tables. If
 * it is not empty update the table to ensure all sites are
 * accounted for.
 */


/*
 * CADC sites
 */
INSERT INTO IM_PROJECT_SITES (
	PROJECT_ID
	, LCL_SITE
	, PROJECT_STATUS
	, UPDATE_dATE
	, DOWNLOAD_DATE
	, IMPORT_DATE
	, SOURCESYSTEM_CD
	, UPLOAD_ID
	)
VALUES (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'CADC RDR'
		)
	, 'COMPURECORD'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	),
	(
		(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'CADC RDR'
		)
	, 'I2B2'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	)
	, (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'CADC RDR'
		)
	, 'CREST'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	)
	, (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'CADC RDR'
		)
	, 'PROFILER'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	), (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'CADC RDR'
		)
	, 'ORMANAGER'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	)
	, (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'CADC RDR'
		)
	, 'TUMORREGISTRY'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	)
	, (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'CADC RDR'
		)
	, 'EPIC'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	)
	, (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'CADC RDR'
		)
	, 'IDX'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	)
	, (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'CADC RDR'
		)
	, 'EAGLE'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EAGLE'
	, NULL
	)
	, (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'CADC RDR'
		)
	, 'ECLIPSYS'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'ECLIPSYS'
	, NULL
	);


/*
 * Big Red Sites
 */
INSERT INTO IM_PROJECT_SITES (
	PROJECT_ID
	, LCL_SITE
	, PROJECT_STATUS
	, UPDATE_DATE
	, DOWNLOAD_DATE
	, IMPORT_DATE
	, SOURCESYSTEM_CD
	, UPLOAD_ID
	)
VALUES (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'BIG RED'
		)
	, 'CREST'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	), (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'BIG RED'
		)
	, 'COMPURECORD'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	)
	, (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'BIG RED'
		)
	, 'TUMORREGISTRY'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	)
	, (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'BIG RED'
		)
	, 'EPIC'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	)
	, (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'BIG RED'
		)
	, 'IDX'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	)
	, (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'BIG RED'
		)
	, 'EAGLE'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EAGLE'
	, NULL
	)
	, (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'BIG RED'
		)
	, 'ECLIPSYS'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'ECLIPSYS'
	, NULL
	),
	(
		(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'BIG RED'
		)
	, 'I2B2'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	);


/*
 * Little Red
 */
INSERT INTO IM_PROJECT_SITES (
	PROJECT_ID
	, LCL_SITE
	, PROJECT_STATUS
	, UPDATE_dATE
	, DOWNLOAD_DATE
	, IMPORT_DATE
	, SOURCESYSTEM_CD
	, UPLOAD_ID
	)
VALUES (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'Little Red'
		)
	, 'COMPURECORD'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	),
	(
		(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'Little Red'
		)
	, 'I2B2'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	)
	, (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'Little Red'
		)
	, 'CREST'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	), (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'Little Red'
		)
	, 'PROFILER'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	)
	, (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'Little Red'
		)
	, 'ORMANAGER'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	)
	, (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'Little Red'
		)
	, 'TUMORREGISTRY'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	)
	, (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'Little Red'
		)
	, 'EPIC'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	)
	, (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'Little Red'
		)
	, 'IDX'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	)
	, (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'Little Red'
		)
	, 'EAGLE'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EAGLE'
	, NULL
	)
	, (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'Little Red'
		)
	, 'ECLIPSYS'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'ECLIPSYS'
	, NULL
	);


/*
 * Leukemia sites 
 */
 INSERT INTO IM_PROJECT_SITES (
	PROJECT_ID
	, LCL_SITE
	, PROJECT_STATUS
	, UPDATE_dATE
	, DOWNLOAD_DATE
	, IMPORT_DATE
	, SOURCESYSTEM_CD
	, UPLOAD_ID
	)
VALUES (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'Leukemia RDR'
		)
	, 'EPIC'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	), (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'Leukemia RDR'
		)
	, 'IDX'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	),
	(
		(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'Leukemia RDR'
		)
	, 'I2B2'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	)
	, (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'Leukemia RDR'
		)
	, 'CREST'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	)
	, (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'Leukemia RDR'
		)
	, 'EAGLE'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EAGLE'
	, NULL
	)
	, (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'Leukemia RDR'
		)
	, 'ECLIPSYS'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'ECLIPSYS'
	, NULL
	);


/*
 * MPN sites 
 */
 INSERT INTO IM_PROJECT_SITES (
	PROJECT_ID
	, LCL_SITE
	, PROJECT_STATUS
	, UPDATE_dATE
	, DOWNLOAD_DATE
	, IMPORT_DATE
	, SOURCESYSTEM_CD
	, UPLOAD_ID
	)
VALUES (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'MPN RDR'
		)
	, 'EPIC'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	), (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'MPN RDR'
		)
	, 'IDX'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	)
	, (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'MPN RDR'
		)
	, 'CREST'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	)
	, (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'MPN RDR'
		)
	, 'EAGLE'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EAGLE'
	, NULL
	)
	, (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'MPN RDR'
		)
	, 'ECLIPSYS'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'ECLIPSYS'
	, NULL
	),
	(
		(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'MPN RDR'
		)
	, 'I2B2'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	);


/*
 * OPH sites TBD
 */
 INSERT INTO IM_PROJECT_SITES (
	PROJECT_ID
	, LCL_SITE
	, PROJECT_STATUS
	, UPDATE_dATE
	, DOWNLOAD_DATE
	, IMPORT_DATE
	, SOURCESYSTEM_CD
	, UPLOAD_ID
	)
VALUES (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'OPH RDR'
		)
	, 'EPIC'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	), (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'OPH RDR'
		)
	, 'IDX'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	)
	, (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'OPH RDR'
		)
	, 'CREST'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	)
	, (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'OPH RDR'
		)
	, 'EAGLE'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EAGLE'
	, NULL
	)
	, (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'OPH RDR'
		)
	, 'ECLIPSYS'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'ECLIPSYS'
	, NULL
	),
	(
		(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'OPH RDR'
		)
	, 'I2B2'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	);


--ANES
INSERT INTO IM_PROJECT_SITES (
	PROJECT_ID
	, LCL_SITE
	, PROJECT_STATUS
	, UPDATE_dATE
	, DOWNLOAD_DATE
	, IMPORT_DATE
	, SOURCESYSTEM_CD
	, UPLOAD_ID
	)
VALUES (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'Anesthesiology RDR'
		)
	, 'COMPURECORD'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	)
	,
	(
		(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'Anesthesiology RDR'
		)
	, 'I2B2'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	)
	, (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'Anesthesiology RDR'
		)
	, 'CREST'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	), (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'Anesthesiology RDR'
		)
	, 'PROFILER'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	)
	, (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'Anesthesiology RDR'
		)
	, 'ORMANAGER'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	)
	, (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'Anesthesiology RDR'
		)
	, 'TUMORREGISTRY'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	)
	, (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'Anesthesiology RDR'
		)
	, 'EPIC'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	)
	, (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'Anesthesiology RDR'
		)
	, 'IDX'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	)
	, (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'Anesthesiology RDR'
		)
	, 'EAGLE'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EAGLE'
	, NULL
	)
	, (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'Anesthesiology RDR'
		)
	, 'ECLIPSYS'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'ECLIPSYS'
	, NULL
	);
	

/*
 * TrinetX Sites
 */
INSERT INTO IM_PROJECT_SITES (
	PROJECT_ID
	, LCL_SITE
	, PROJECT_STATUS
	, UPDATE_DATE
	, DOWNLOAD_DATE
	, IMPORT_DATE
	, SOURCESYSTEM_CD
	, UPLOAD_ID
	)
VALUES (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'TriNetX'
		)
	, 'CREST'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	), (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'TriNetX'
		)
	, 'COMPURECORD'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	)
	, (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'TriNetX'
		)
	, 'TUMORREGISTRY'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	)
	, (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'TriNetX'
		)
	, 'EPIC'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	)
	, (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'TriNetX'
		)
	, 'IDX'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	)
	, (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'TriNetX'
		)
	, 'EAGLE'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EAGLE'
	, NULL
	)
	, (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'TriNetX'
		)
	, 'ECLIPSYS'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'ECLIPSYS'
	, NULL
	),
	(
		(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'TriNetX'
		)
	, 'I2B2'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	);	


/*
 * PUL Sites
 */
INSERT INTO IM_PROJECT_SITES (
	PROJECT_ID
	, LCL_SITE
	, PROJECT_STATUS
	, UPDATE_DATE
	, DOWNLOAD_DATE
	, IMPORT_DATE
	, SOURCESYSTEM_CD
	, UPLOAD_ID
	)
VALUES (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'PUL RDR'
		)
	, 'CREST'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	), (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'PUL RDR'
		)
	, 'EPIC'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	)
	, (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'PUL RDR'
		)
	, 'IDX'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	)
	, (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'PUL RDR'
		)
	, 'EAGLE'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EAGLE'
	, NULL
	)
	, (
	(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'PUL RDR'
		)
	, 'ECLIPSYS'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'ECLIPSYS'
	, NULL
	),
	(
		(
		SELECT project_id
		FROM [heroni2b2pm].[dbo].[PM_PROJECT_DATA] pmpd
		WHERE project_name = 'PUL RDR'
		)
	, 'I2B2'
	, 'A'
	, GETDATE()
	, GETDATE()
	, GETDATE()
	, 'EPIC'
	, NULL
	);	