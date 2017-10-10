/*
 * The IM_MPI_DEMOGRAPHICS table contains general demographic information for the
 * patients. We do not store any demographics in the demographics column. This information
 * is taken directly from heroni2b2demodata.
 Copyright (c) 2014-2017 Weill Cornell Medical College
 */

use heroni2b2imdata;

-- The MRN that is taken needs to be the smallest value, but leading zeroes
-- are significant in distinguishing patients from each other. We use the
-- actual length of the string to determine which of the two are smaller.
INSERT INTO IM_MPI_DEMOGRAPHICS
		(global_id, global_status, demographics, update_date, import_date, sourcesystem_cd)
	SELECT DISTINCT global_id
		, 'A' AS global_status
		, PAT_NAME AS [demographics]
		, getDate() AS update_date
		, GETDATE() AS import_date
		, 'EPIC' AS sourcesystem_cd
	FROM IM_MPI_MAPPING im
	INNER JOIN (
		SELECT p.pat_id
			, pat_name
			, mrn
		FROM super_daily.dbo.patient p
		INNER JOIN (
			SELECT pat_id
				, identity_id AS mrn
				, row_number() over (partition by pat_id order by len(identity_id),identity_id) as [length]
			FROM super_monthly.dbo.IDENTITY_ID i
			WHERE IDENTITY_TYPE_ID = 3
			) im
			ON p.pat_id = im.pat_id and [length] = 1
		) [patientdem]
		ON mrn = im.lcl_id
WHERE GLOBAL_ID NOT IN (SELECT GLOBAL_ID FROM IM_MPI_DEMOGRAPHICS);