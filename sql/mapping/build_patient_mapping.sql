/* 
 *
 *  Adds patients to the master lookup table, which drives SUPER.
 *  This is used for the Big Red RDR as well as any RDR that doesn't
 *  require a particular patient cohort.
 *
 *  Copyright (c) 2014-2017 Weill Cornell Medical College
 */
 
use <prefix>i2b2demodata;

/**

DROP TABLE PATIENT_MAPPING;

CREATE TABLE [dbo].[PATIENT_MAPPING] (
	[PATIENT_NUM] [int] NOT NULL,
	[PATIENT_IDE] [varchar](200) NOT NULL,
	[PATIENT_IDE_SOURCE] [varchar](50) NOT NULL,
	[PATIENT_IDE_STATUS] [varchar](50) NULL,
	[PROJECT_ID] [varchar](50) NOT NULL,
	[UPLOAD_DATE] [datetime] NULL,
	[UPDATE_DATE] [datetime] NULL,
	[DOWNLOAD_DATE] [datetime] NULL,
	[IMPORT_DATE] [datetime] NULL,
	[SOURCESYSTEM_CD] [varchar](50) NULL,
	[UPLOAD_ID] [int] NULL
 )

*/


-- Find the project id based on the prefix value
INSERT INTO PATIENT_MAPPING
	(patient_num
	, patient_ide
	, patient_ide_source
	, patient_ide_status
	, project_id
	, upload_date
	, update_date
	, download_date
	, import_date
	, sourcesystem_cd)
SELECT distinct	im.GLOBAL_ID as patient_num 
	  , CASE WHEN IM.LCL_SITE = 'WCM' THEN COALESCE(PAT_ID, LCL_ID)
			 ELSE LCL_ID END AS PATIENT_IDE
	  , IM.LCL_SITE AS PATIENT_IDE_SOURCE
	  , 'A' AS PATIENT_IDE_STATUS
	  , IMPP.PROJECT_ID AS PROJECT_ID
	  , GETDATE() AS UPLOAD_DATE
	  , GETDATE() AS UPDATE_DATE
	  , GETDATE() AS DOWNLOAD_DATE
	  , GETDATE() AS IMPORT_DATE
	  , im.SOURCESYSTEM_CD
FROM HERONI2B2IMDATA.DBO.IM_MPI_MAPPING IM
INNER JOIN HERONI2B2IMDATA.DBO.IM_PROJECT_PATIENTS IMPP ON IM.GLOBAL_ID = IMPP.GLOBAL_ID 
inner join heroni2b2pm.dbo.PREFIX_MAPPINGS pref on pref.project_id = impp.project_id
INNER JOIN (
		-- The MRN that is taken needs to be the smallest value, but leading zeroes
		-- are significant in distinguishing patients from each other. We use the
		-- actual length of the string to determine which of the two are smaller.
		SELECT pat_id
			, identity_id AS mrn
			, row_number() over (partition by pat_id order by len(identity_id),identity_id) as [length]
		FROM super_monthly.dbo.IDENTITY_ID i
		WHERE IDENTITY_TYPE_ID = 3
		) i
		ON mrn = im.LCL_ID and [length] = 1
inner join heroni2b2imdata.dbo.IM_PROJECT_SITES imsites on imsites.project_id = impp.PROJECT_ID
where pref.prefix = '<prefix>'
order by patient_num;

/*
 * Self mapping
 */
insert into patient_mapping
	(patient_num, patient_ide, patient_ide_source, patient_ide_status, project_id, upload_date, update_date, import_date, sourcesystem_cd) 
select distinct
       PATIENT_NUM
	 , cast(patient_num as varchar) as patient_ide
	 , 'HIVE' as PATIENT_IDE_SOURCE
	 , 'A' AS PATIENT_IDE_STATUS
	 , pref.project_id AS PROJECT_ID
	 , getDate() AS UPLOAD_DATE
	 , getDate() as UPDATE_DATE
	 , getDate() AS IMPORT_DATE
	 , 'I2B2' AS SOURCESYSTEM_CD
from patient_mapping pm
INNER JOIN HERONI2B2IMDATA.DBO.IM_PROJECT_PATIENTS IMPP ON pm.patient_num = IMPP.GLOBAL_ID 
inner join heroni2b2pm.dbo.PREFIX_MAPPINGS pref on pref.project_id = impp.project_id
where pref.prefix = '<prefix>';

