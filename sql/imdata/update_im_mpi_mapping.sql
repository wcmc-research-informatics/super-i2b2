/*
 * The IM_MPI_MAPPING table maps the patient's i2b2 number and their local ID from the
 * source system. For WCM, the local ID is the NYP MRN. This table should be filled out
 * first for all tables in the imdata database as it contains the link between i2b2 and
 * EPIC/other source systems.
 * Copyright (c) 2014-2017 Weill Cornell Medical College
 */
use heroni2b2imdata;

-- Patient information is added to the IDENTITY_ID table, so when possible only refresh
-- the table instead of truncating and re-creating data anew. Using the last time the
-- table was created before the ETL is run should create a good enough idea for us of
-- when the information in IDENTITY_ID is updated. Check to see if the IM_MPI_MAPPING
-- table is empty and populate it with data from all source systems if it is. If it is
-- not, use the [UPDATE_DATE] column to change rows that have new information and add
-- new patients after.


-- Map all patients and MRNs from EPIC. 
-- Create a Sequence to construct the i2b2 patient_num
IF EXISTS (
		SELECT *
		FROM sys.sequences
		WHERE object_id = object_id('[DBO].[PATIENTNUM]')
		)
BEGIN
	DROP sequence [DBO].[PATIENTNUM];
END

-- Initialize at 100k if the IM table is empty
DECLARE @NEXTPATNUM BIGINT = coalesce((SELECT max(cast(global_id as bigint)+1) FROM [heroni2b2imdata].[dbo].[IM_MPI_MAPPING]), 100000);

-- Dynamic execution is the only way to ensure sequence is created with the proper value
-- no matter the state of IM_MPI_MAPPING
EXEC('
	CREATE SEQUENCE [DBO].[PATIENTNUM] AS BIGINT
	START WITH '+@nextpatnum+' INCREMENT BY 1;
')

/*
 * If the IM_MPI_MAPPING table is empty, the clauses in each of the SQL predicates below should return
 * an empty set. This causes the INSERT statement to insert rows for all patients from a particular source
 * system. If the IM_MPI_MAPPING table is populated, it should only return rows for recently added patients
 * and should assign them a new i2b2 patient identifier.
 */

-- Update EPIC data by looking only for patients not already mapped
INSERT INTO IM_MPI_MAPPING (
	  global_id
	, lcl_site
	, lcl_id
	, lcl_Status
	, update_date
	, download_date
	, import_date
	, sourcesystem_cd
	)
SELECT (NEXT VALUE FOR DBO.PATIENTNUM)	AS global_id
	, 'WCM' AS lcl_site
	, IDENTITY_ID AS lcl_id
	, 'A' AS lcl_status
	 -- There is no UPDATE_DATE field available in IDENTITY_ID, so as a proxy when we
	 -- generate a row for a new patient we record the "version" of identity_id we receive
	 -- from POIS.
	, (select create_date from super_daily.sys.tables where name='IDENTITY_ID') AS update_date
	, getDate() AS download_date
	, GETDATE() AS import_date
	, 'EPIC' AS sourcesystem_cd
FROM (
	-- The MRN that is taken needs to be the smallest value, but leading zeroes
	-- are significant in distinguishing patients from each other. We use the
	-- actual length of the string to determine which of the two are smaller.
	SELECT DISTINCT I.PAT_ID
		, im.IDENTITY_ID
	FROM super_daily.dbo.identity_id I
	INNER JOIN (
		SELECT pat_id
			, identity_id
			, row_number() over (partition by pat_id order by len(identity_id),identity_id) as [length]
		FROM super_daily.dbo.IDENTITY_ID i
		WHERE IDENTITY_TYPE_ID = 3
		) im
		ON i.pat_id = im.pat_id and [length] = 1
	LEFT JOIN IM_MPI_MAPPING [IM3] ON IM.IDENTITY_ID = IM3.LCL_ID AND SOURCESYSTEM_CD = 'EPIC'
	) [identity_id]
WHERE IDENTITY_ID NOT IN 
	(SELECT LCL_ID FROM HERONI2B2IMDATA.DBO.IM_MPI_MAPPING WHERE SOURCESYSTEM_CD = 'EPIC');
	
-- Update CompuRecord data by adding only unmapped patients
INSERT INTO IM_MPI_MAPPING (
	  global_id
	, lcl_site
	, lcl_id
	, lcl_Status
	, update_date
	, download_date
	, import_date
	, sourcesystem_cd
	)
SELECT (NEXT VALUE FOR DBO.PATIENTNUM)	AS global_id
	, 'COMPURECORD' AS lcl_site
	, MEDICALRECORDNUMBER AS lcl_id
	, 'A' AS lcl_status
	, (select create_date from  [Jupiter].sys.tables where name='Demographics') AS update_date
	, getDate() AS download_date
	, GETDATE() AS import_date
	, 'COMPURECORD' AS sourcesystem_cd
FROM (
	SELECT DISTINCT substring(MEDICALRECORDNUMBER,patindex('%[^0]%',MEDICALRECORDNUMBER),15) as MEDICALRECORDNUMBER
	FROM [Jupiter].[Compurecord].[Demographics]
	) cr
LEFT JOIN IM_MPI_MAPPING im
	ON LCL_ID = MEDICALRECORDNUMBER AND SOURCESYSTEM_CD = 'COMPURECORD'
WHERE MEDICALRECORDNUMBER NOT IN 
	(SELECT LCL_ID FROM HERONI2B2IMDATA.DBO.IM_MPI_MAPPING WHERE SOURCESYSTEM_CD = 'COMPURECORD');
	
-- OR Manager is legacy and not currently being updated
INSERT INTO IM_MPI_MAPPING (
	global_id
	, lcl_site
	, lcl_id
	, lcl_Status
	, update_date
	, download_date
	, import_date
	, sourcesystem_cd
	)
SELECT (NEXT VALUE FOR DBO.PATIENTNUM)	AS global_id
	, 'ORMANAGER' AS lcl_site
	, MRN AS lcl_id
	, 'A' AS lcl_status
	, (select create_date from  [ARCH].sys.tables where name='ORCASES') AS update_date
	, getDate() AS download_date
	, GETDATE() AS import_date
	, 'ORMANAGER' AS sourcesystem_cd
FROM (
	SELECT DISTINCT mrn
	FROM arch.dbo.ORCases
	WHERE mrn IS NOT NULL
	) cr
-- We need to have this cast in the join or we will come across a conversion
-- error because MRNs are stored in ORManager as varchar
LEFT JOIN IM_MPI_MAPPING im
	ON im.lcl_id = cast(mrn AS VARCHAR) AND SOURCESYSTEM_CD = 'ORMANAGER'
WHERE MRN NOT IN 
	(SELECT LCL_ID FROM HERONI2B2IMDATA.DBO.IM_MPI_MAPPING WHERE SOURCESYSTEM_CD = 'ORMANAGER');
	
-- Update REDCap data by adding only unmapped patients
INSERT INTO IM_MPI_MAPPING (
	  global_id
	, lcl_site
	, lcl_id
	, lcl_Status
	, update_date
	, download_date
	, import_date
	, sourcesystem_cd
	)
SELECT (NEXT VALUE FOR DBO.PATIENTNUM)	AS global_id
	, 'REDCAP' AS lcl_site
	, MRN AS lcl_id
	, 'A' AS lcl_status
	, (select create_date from  [super_staging].sys.tables where name='redcap_data_Adj') AS update_date
	, getDate() AS download_date
	, GETDATE() AS import_date
	, 'REDCAP' AS sourcesystem_cd
FROM (
	SELECT DISTINCT value AS mrn
	FROM super_staging.dbo.redcap_data_Adj
	WHERE field_name LIKE '%mrn%'
	) [rcap]
LEFT JOIN IM_MPI_MAPPING im
	ON im.lcl_id = mrn
WHERE MRN NOT IN 
	(SELECT LCL_ID FROM HERONI2B2IMDATA.DBO.IM_MPI_MAPPING WHERE SOURCESYSTEM_CD = 'REDCAP');

-- Unmapped patients from tumor registry
INSERT INTO IM_MPI_MAPPING (
	global_id
	, lcl_site
	, lcl_id
	, lcl_Status
	, update_date
	, download_date
	, import_date
	, sourcesystem_cd
	)
SELECT (NEXT VALUE FOR DBO.PATIENTNUM)	AS global_id
	, 'TUMORREGISTRY' AS lcl_site
	, [Medical Record Number] AS lcl_id
	, 'A' AS lcl_status
	, (select create_date from  [SUPER_ADHOC].sys.tables where name='TumorRegistryData') AS update_date
	, getDate() AS download_date
	, GETDATE() AS import_date
	, 'TUMORREGISTRY' AS sourcesystem_cd
FROM [SUPER_ADHOC].[dbo].[TumorRegistryData] [TRD]
left join HERONI2B2IMDATA.DBO.IM_MPI_MAPPING im 
	on trd.[Medical Record Number] = lcl_id 
	and SOURCESYSTEM_CD = 'TUMORREGISTRY'
WHERE trd.[Medical Record Number] NOT IN 
	(SELECT LCL_ID FROM HERONI2B2IMDATA.DBO.IM_MPI_MAPPING WHERE SOURCESYSTEM_CD = 'TUMORREGISTRY');

-- CREST
INSERT INTO IM_MPI_MAPPING (
	global_id
	, lcl_site
	, lcl_id
	, lcl_Status
	, update_date
	, download_date
	, import_date
	, sourcesystem_cd
	)
-- New patients
SELECT (NEXT VALUE FOR DBO.PATIENTNUM)	AS global_id
	, 'CREST' AS lcl_site
	, NYPH_MRN AS lcl_id
	, 'A' AS lcl_status
	, (select create_date from  [SUPER_DAILY].sys.tables where name='CREST_SUBJECTS') AS update_date
	, getDate() AS download_date
	, GETDATE() AS import_date
	, 'CREST' AS sourcesystem_cd
FROM (
	SELECT DISTINCT NYPH_MRN
	FROM SUPER_DAILY.DBO.CREST_SUBJECTS
	) CS
LEFT JOIN IM_MPI_MAPPING im
	ON NYPH_MRN = LCL_ID
WHERE NYPH_MRN NOT IN 
	(SELECT LCL_ID FROM HERONI2B2IMDATA.DBO.IM_MPI_MAPPING WHERE SOURCESYSTEM_CD = 'CREST');

-- EAGLE
INSERT INTO IM_MPI_MAPPING (
	global_id
	, lcl_site
	, lcl_id
	, lcl_Status
	, update_date
	, download_date
	, import_date
	, sourcesystem_cd
	)
SELECT (NEXT VALUE FOR DBO.PATIENTNUM)	AS global_id
	, 'EAGLE' AS lcl_site
	, NYPH_MRN AS lcl_id
	, 'A' AS lcl_status
	, (select create_date from  [CDW].sys.tables where name='PATIENT') AS update_date
	, getDate() AS download_date
	, GETDATE() AS import_date
	, 'EAGLE' AS sourcesystem_cd
FROM (
	SELECT DISTINCT case when PATIENT_ID LIKE '0[^0]%' then cast(RIGHT(P.patient_id,8) as varchar)
						 when PATIENT_ID LIKE '00%' THEN cast(RIGHT(P.patient_id,7) as varchar)
						 WHEN PATIENT_ID LIKE '[^0]%' THEN cast(P.patient_id as varchar) END AS NYPH_MRN
	FROM [CDW].[NICKEAST].[PATIENT] P
	WHERE PATIENT_ID IS NOT NULL
	) CS
   LEFT JOIN IM_MPI_MAPPING IM ON NYPH_MRN = LCL_ID AND SOURCESYSTEM_CD = 'EAGLE'
WHERE NYPH_MRN NOT IN 
	(SELECT LCL_ID FROM HERONI2B2IMDATA.DBO.IM_MPI_MAPPING WHERE SOURCESYSTEM_CD = 'EAGLE');

-- Eclipsys
INSERT INTO IM_MPI_MAPPING (
	global_id
	, lcl_site
	, lcl_id
	, lcl_Status
	, update_date
	, download_date
	, import_date
	, sourcesystem_cd
	)
SELECT (NEXT VALUE FOR DBO.PATIENTNUM)	AS global_id
	, 'ECLIPSYS' AS lcl_site
	, NYPH_MRN AS lcl_id
	, 'A' AS lcl_status
	, (select create_date from  [Jupiter].sys.tables where name='CV3ClientID_East') AS update_date
	, getDate() AS download_date
	, GETDATE() AS import_date
	, 'ECLIPSYS' AS sourcesystem_cd
FROM (
	SELECT DISTINCT ClientIDCode AS NYPH_MRN
	FROM JUPITER.JUPITERSCM.CV3ClientID_East
	   WHERE TypeCode = 'Hospital MRN1' and IDStatus = 'ACT'
	) CS
LEFT JOIN IM_MPI_MAPPING im
	ON NYPH_MRN=im.lcl_id
WHERE NYPH_MRN NOT IN 
	(SELECT LCL_ID FROM HERONI2B2IMDATA.DBO.IM_MPI_MAPPING WHERE SOURCESYSTEM_CD = 'ECLIPSYS');

/*
*	Map all patients from IDX. IDX is legacy data and doesn't get new patients
*/
INSERT INTO IM_MPI_MAPPING (
	global_id
	, lcl_site
	, lcl_id
	, lcl_Status
	, update_date
	, download_date
	, import_date
	, sourcesystem_cd
	)
SELECT DISTINCT im.global_id AS global_id
	, 'IDX' AS lcl_site
	, NYP_MRN AS lcl_id
	, 'A' AS lcl_status
	, (select create_date from  [SUPER_STAGING].sys.tables where name='IDX_DATA_SLIM') AS update_date
	, getDate() AS download_date
	, GETDATE() AS import_date
	, 'IDX' AS sourcesystem_cd
FROM (
	SELECT DISTINCT PAT_ID
		, NYP_MRN
	FROM SUPER_STAGING.DBO.IDX_DATA_SLIM
	) CS
inner JOIN IM_MPI_MAPPING im
	ON NYP_MRN = LCL_ID
WHERE NYP_MRN NOT IN 
	(SELECT LCL_ID FROM HERONI2B2IMDATA.DBO.IM_MPI_MAPPING WHERE SOURCESYSTEM_CD = 'IDX');

DROP SEQUENCE DBO.PATIENTNUM;
