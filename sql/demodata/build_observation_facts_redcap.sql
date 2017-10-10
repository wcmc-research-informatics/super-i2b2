/*
 * Transforms REDCap case report forms into an i2b2 queryable format.
 * This file is intended to work in tandem with the SQL metadata script
 * that creates the REDCap hierarchy as it assumes concept codes are
 * generated in the same fashion. This script flattens the REDCap data
 * on the fly before turning them into facts.
 *
 * authors: David Kreamer, Marcos Davila
 * Copyright (c) 2014-2017 Weill Cornell Medical College
 */
USE <prefix>i2b2demodata;

BEGIN TRANSACTION;

/*
 * Create a lookup table that relates a basecode in the metadata to a project_id and a field_name
 * Take these values out of the REDCAP_BASECODES table generated during metadata creation.
 *  
 * columns are project_id, form_name, field_name, data, c_fullname, c_basecode
 */

	SELECT DISTINCT c_hlevel
		, c_fullname
		, project_id
		, field_name
		, case when c_hlevel <> 5 then NULL else left(c_symbol, len(c_symbol) - 1) end AS data
		, mapped_basecode AS c_basecode
	INTO #redcapmagic
	FROM super_Staging.dbo.REDCAP_BASECODES rb
	INNER JOIN <prefix>i2b2metadata.dbo.CUSTOM_META cm
		ON mapped_basecode = C_BASECODE
	WHERE c_hlevel between 4 and 6;

	CREATE CLUSTERED INDEX idx_pk_magic ON #redcapmagic (c_basecode);

	CREATE NONCLUSTERED INDEX idx_magic ON #redcapmagic (
		c_fullname
		, c_hlevel
		);

/*
 * Create another lookup table which will assist in creating #flattenedredcap table

	Aggregate this information together in a meaningful way, making sure to include the redcap encounter number
	(concat of project_id, event_id, and record) and the generated encounter number which is a smaller number
	that uniquely maps to the redcap encounter number. All blank strings are returned here as NULL

	The union operator applies distinct across all domains and removes implicit NULLs for terms that do not have
	basecodes (this happens when terms exist in REDCAP_DATA_ADJ that do not exist in REDCAP_METADATA_ADJ).
 */
SELECT r2.mrn
	, nullif(r1.[value], '') AS [value]
	, r1.encounter_num
	, r1.field_name
	, c_basecode
INTO #redcapdates
FROM super_staging.dbo.redcap_data_adj r1
-- Then look for level 4 leaf node elements with enumerated values
INNER JOIN #redcapmagic rm
	ON rm.project_id = r1.project_id
		AND rm.field_name = r1.field_name
INNER JOIN (
	-- Associate MRN with each event and all values
	SELECT DISTINCT [mrn_getter].*
		, r.event_id
		, r.value
		, r.field_name
		, r.encounter_num
	FROM super_staging.dbo.redcap_data_adj r
	INNER JOIN (
		-- Gets the MRN for all patients per project
		SELECT [value] AS mrn
			, project_id
			, record
		FROM super_staging.dbo.redcap_data_adj r1
		WHERE field_name LIKE '%mrn%'
		) [mrn_getter]
		ON [mrn_getter].project_id = r.project_id
			AND [mrn_getter].record = r.record
	) r2
	ON r1.encounter_num = r2.encounter_num
where   rm.data IS NULL
		AND c_hlevel between 4 and 6

UNION ALL

SELECT r2.mrn
	, nullif(r1.[value], '') AS [value]
	, r1.encounter_num
	, r1.field_name
	, c_basecode
FROM super_staging.dbo.redcap_data_adj r1
-- Then look for level 4 leaf node elements with enumerated values
INNER JOIN #redcapmagic rm
	ON rm.project_id = r1.project_id
		AND rm.field_name = r1.field_name
		AND CASE 
			WHEN nullif(r1.[value], '') = '1'
				THEN 'Yes'
			WHEN nullif(r1.[value], '') = '2'
				THEN 'No'
			ELSE nullif(r1.[value], '')
			END = rm.data
		AND c_hlevel = 5
INNER JOIN (
	-- Associate MRN with each event and all values
	SELECT DISTINCT [mrn_getter].*
		, r.event_id
		, r.value
		, r.field_name
		, r.encounter_num
	FROM super_staging.dbo.redcap_data_adj r
	INNER JOIN (
		-- Gets the MRN for all patients per project
		SELECT [value] AS mrn
			, project_id
			, record
		FROM super_staging.dbo.redcap_data_adj r1
		WHERE field_name LIKE '%mrn%'
		) [mrn_getter]
		ON [mrn_getter].project_id = r.project_id
			AND [mrn_getter].record = r.record
	) r2
	ON r1.encounter_num = r2.encounter_num
		AND r1.project_id = r2.project_id

	

CREATE CLUSTERED INDEX idx_basecode ON #redcapdates (c_basecode);

CREATE NONCLUSTERED INDEX idx_Cover ON #redcapdates (mrn) include (
	value
	, encounter_num
	);

/*
 * A temporary table which associates a REDCap "encounter" (created by smashing together project, event, and record ids)
 * with the associated i2b2 information and including additional information to get at the type of encounter.
 * This will be more useful than encounter_mapping because we can be more informed about what facts each 
 * encounter should represent (meanwhile the mapping table only records one instance of this encounter).
 *
 */
SELECT DISTINCT r.encounter_num
	, value
	, i.pat_id
	, [patient_num]
	, c_basecode
	, min(identity_id) AS mrn
INTO #flattenedredcap
FROM super_monthly.dbo.identity_id i
INNER JOIN #redcapdates r
	ON identity_id = mrn
INNER JOIN patient_mapping pm
	on patient_ide = i.pat_id
WHERE identity_type_id = 3
	AND c_basecode IS NOT NULL
-- The cause of loss of rows is due to elements in data which are not included in metadata.
-- These rows will have no concept code so we have to filter them out for now.
GROUP BY r.encounter_num
	, value
	, i.pat_id
	, pm.patient_num
	, c_Basecode;

-- Don't bother trying to pull out information such as provider and start_date
-- and associating them with facts. The forms are too unstructured with very
-- few context clues to be able to determine this algorithmically
insert into observation_fact(
	  encounter_num
	, patient_num
	, concept_cd
	, provider_id
	, start_date
	, modifier_cd
	, instance_num
	, valtype_cd
	, tval_char
	, nval_num
	, valueflag_cd
	, units_cd
	, location_cd
	, download_date
	, import_date
	, sourcesystem_cd
	)
SELECT DISTINCT em.encounter_num
	, em.patient_num
	, c_basecode AS concept_cd
	, '@' AS provider_id
	, em.contact_date AS start_date
	, '@' AS modifier_cd
	, 1 AS instance_num
	, CASE 
		WHEN try_convert(FLOAT, value) IS NOT NULL
			THEN 'N'
		ELSE 'T'
		END AS [VALTYPE_CD]
	-- For lab results, detect units and remove them
	, CASE 
		WHEN try_convert(FLOAT, value) IS NOT NULL
			THEN 'E'
		ELSE CASE 
				WHEN value LIKE '[0-9]%mcg'
					THEN replace(left(value, 255), 'mcg', '')
				WHEN value LIKE '[0-9]%mg%'
					THEN replace(left(value, 255), 'mg', '')
				WHEN value LIKE '[0-9]%u/gm'
					THEN replace(left(value, 255), 'u/gm', '')
				WHEN value LIKE '[0-9]%U'
					THEN replace(left(value, 255), 'U', '')
				WHEN value LIKE '[0-9]%g'
					THEN replace(left(value, 255), 'g', '')
				WHEN value LIKE '[0-9]%mL'
					THEN replace(left(value, 255), 'mL', '')
				ELSE left(value, 255)
				END
		END AS [TVAL_CHAR] --[TVAL_CHAR]
	, try_convert(FLOAT, value) AS [NVAL_NUM] --[NVAL_NUM]
	, '@' AS [VALUEFLAG_CD] --[VALUEFLAG_CD]
	-- For lab results, detect units and parse them out
	, CASE 
		WHEN value LIKE '[0-9]%mcg'
			THEN 'mcg'
		WHEN value LIKE '[0-9]%mg%'
			THEN 'mg'
		WHEN value LIKE '[0-9]%u/gm'
			THEN 'u/gm'
		WHEN value LIKE '[0-9]%U'
			THEN 'U'
		WHEN value LIKE '[0-9]%g'
			THEN 'g'
		WHEN value LIKE '[0-9]%mL'
			THEN 'mL'
		ELSE '@'
		END AS [UNITS_CD] --[UNITS_CD]
	, '@' AS [LOCATION_CD] --[LOCATION_CD]
	, GETDATE() AS [DOWNLOAD_DATE] --[DOWNLOAD_DATE]
	, GETDATE() AS [IMPORT_DATE] --[IMPORT_DATE]
	, 'REDCAP' AS [SOURCESYSTEM_CD] --[SOURCESYSTEM_CD]
FROM #flattenedredcap fr
inner join ENCOUNTER_MAPPING EM on encounter_ide = fr.encounter_num and sourcesystem_cd = 'REDCAP'
WHERE fr.PATIENT_NUM IS NOT NULL
ORDER BY patient_num
	, concept_cd;

COMMIT TRANSACTION;

DROP TABLE [#flattenedredcap];

DROP TABLE [#redcapmagic];

DROP TABLE [#redcapdates];