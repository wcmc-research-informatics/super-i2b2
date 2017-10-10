use <prefix>i2b2demodata;


/*
 * Create temporary table to hold data before transformation
 * to avoid parsing source tables more than once
 */

select top 0 encounter_num
	, patient_num
	, concept_cd
	, provider_id
	, [start_date]
	, modifier_cd
	, tval_char
	, nval_num
	, valueflag_cd
	, units_cd
	, location_cd
	, update_date
	, import_date
into #OBS_FACT FROM dbo.OBSERVATION_FACT;

/*
 * Insert all relevant rows including data for primary/secondary diagnosis
 * and type code (admitting dx, etc.)
 */
insert into #OBS_FACT
SELECT DISTINCT ENCOUNTER_NUM
	, PATIENT_NUM
	, 'ICD9:' + cast(DX_ID AS VARCHAR) AS CONCEPT_CD
	, userGUID AS PROVIDER_ID
	, [PRIMARY_TIME] AS [START_DATE]
	, 'ICD9:ECLDXPRIMSEC' as modifier_cd
	, [primsec] as TVAL_CHAR
	, null as NVAL_NUM
	, '@' AS VALUEFLAG_CD
	, '@' AS UNITS_CD
	, currentLocationGuid AS LOCATION_CD
	, CAST(TOUCHEDWHEN AS DATETIME2) AS UPDATE_DATE
	, GETDATE() AS IMPORT_DATE
FROM (
	SELECT CLIENTIDCODE AS PATIENT_ID
		, replace(substring(VisitIDCode, patindex('%[^0]%',VisitIDCode),len(VisitIDCode)), ' ', '') [ACCOUNTNUM]
		, HI2.TOUCHEDWHEN
		, HI2.ICD9CODE AS [CODE]
		, cast(HI2.CREATEDWHEN as datetime2) AS PRIMARY_TIME
		, cve.CurrentLocationGUID
		, hi2.UserGUID
		, hi2.typecode as [primsec]
	FROM [JUPITER].[JUPITERSCM].[CV3HEALTHISSUEDECLARATION_EAST] HI2
	INNER JOIN [JUPITER].[JUPITERSCM].[CV3CODEDHEALTHISSUE_EAST] HIEAST ON HI2.[CODEDHEALTHISSUEGUID]=[HIEAST].[GUID]
	inner join Jupiter.JupiterSCM.CV3ClientVisit_East cve on hi2.clientvisitguid = cve.[GUID]
	INNER JOIN [JUPITER].[JUPITERSCM].[CV3CLIENTID_EAST] IDEAST ON HI2.[CLIENTGUID] = IDEAST.[CLIENTGUID] AND IDEAST.TYPECODE = 'Hospital MRN1' and IDSTATUS = 'ACT'
	WHERE HI2.ICD9CODE IS NOT NULL 
		AND HI2.CREATEDWHEN IS NOT NULL
		AND visitidcode <> '000000000 000       '
		AND HIEAST.TYPECODE LIKE 'I%9%'
		AND HIEAST.TYPECODE <> 'ICD9CM'
		and cve.TypeCode = 'Inpatient'
	    and visitstatus <> 'CAN' -- canceled?
	) HI
INNER JOIN (
	SELECT patient_num
		, ENCOUNTER_NUM
		, ENCOUNTER_IDE
	FROM ENCOUNTER_MAPPING
	WHERE [ENCOUNTER_IDE_SOURCE] = 'ECLIPSYS'
	) EM
	ON ENCOUNTER_IDE = accountnum
INNER JOIN (
	SELECT DISTINCT [CODE]
		, min([dx_id]) AS dx_id
	FROM SUPER_MONTHLY.dbo.EDG_CURRENT_ICD9 edg
		WHERE line=1
	GROUP BY CODE
	) [MAP]
	ON [MAP].CODE = hi.CODE;


INSERT INTO #OBS_FACT
SELECT DISTINCT ENCOUNTER_NUM 
	, PATIENT_NUM
	, 'ICD10:' + cast([CODE] AS VARCHAR) AS CONCEPT_CD
	, userGUID AS PROVIDER_ID
	, [PRIMARY_TIME] AS [START_DATE]
	, 'ICD10:ECLDXPRIMSEC' as modifier_cd
	, [primsec] as TVAL_CHAR
	, null as NVAL_NUM
	, '@' AS VALUEFLAG_CD
	, '@' AS UNITS_CD
	, currentLocationGUID AS LOCATION_CD
	, CAST(TOUCHEDWHEN AS DATETIME2) AS UPDATE_DATE
	, GETDATE() AS IMPORT_DATE
FROM (
	SELECT CLIENTIDCODE AS PATIENT_ID
		, replace(substring(VisitIDCode, patindex('%[^0]%',VisitIDCode),len(VisitIDCode)), ' ', '') [ACCOUNTNUM]
		, HI2.TOUCHEDWHEN
		, HI2.ICD10CODE AS [CODE]
		, cast(HI2.CREATEDWHEN as datetime2) AS PRIMARY_TIME
		, HI2.TYPECODE
		, cve.CurrentLocationGUID
		, hi2.UserGUID
		, hi2.typecode as [primsec]
	FROM [JUPITER].[JUPITERSCM].[CV3HEALTHISSUEDECLARATION_EAST] HI2
	INNER JOIN [JUPITER].[JUPITERSCM].[CV3CODEDHEALTHISSUE_EAST] HIEAST ON HI2.[CODEDHEALTHISSUEGUID]=[HIEAST].[GUID]
	inner join Jupiter.JupiterSCM.CV3ClientVisit_East cve on hi2.clientguid = cve.ClientGUID
	INNER JOIN [JUPITER].[JUPITERSCM].[CV3CLIENTID_EAST] IDEAST ON HI2.[CLIENTGUID] = IDEAST.[CLIENTGUID] AND IDEAST.TYPECODE = 'Hospital MRN1' and IDSTATUS = 'ACT'
	WHERE HI2.ICD9CODE IS NOT NULL 
		AND HI2.CREATEDWHEN IS NOT NULL
		AND HIEAST.TYPECODE in('ICD-10', 'I0-REG')
		and visitidcode <> '000000000 000       ' and cve.TypeCode = 'Inpatient'
	    and visitstatus <> 'CAN' -- canceled?
	) HI
INNER JOIN (
	SELECT patient_num
		, ENCOUNTER_NUM
		, ENCOUNTER_IDE
	FROM ENCOUNTER_MAPPING
	WHERE [ENCOUNTER_IDE_SOURCE] = 'ECLIPSYS'
	) EM
	ON ENCOUNTER_IDE = ACCOUNTNUM;

create nonclustered index [COVER_INDEX] on #OBS_FACT
	([encounter_num], [patient_num], [concept_cd], [provider_id]
	,[start_date], [valueflag_cd], [units_cd], [location_cd], [import_date], [update_date])


INSERT INTO OBSERVATION_FACT (
	encounter_num
	, patient_num
	, concept_cd
	, provider_id
	, start_date
	, modifier_cd
	, instance_num
	, valtype_cd
	, tval_char
	, valueflag_cd
	, units_cd
	, location_cd
	, update_date
	, import_date
	, sourcesystem_cd
)
select			encounter_num
			  , patient_num
			  , concept_cd
			  , provider_id
			  , [start_date]
			  , modifier_cd
			  , 1 as instance_num
			  , 'T' as valtype_cd
			  , tval_char
			  , valueflag_cd
			  , units_cd
			  , location_cd
			  , update_date
			  , import_date
			  , 'ECLIPSYS' as sourcesystem_cd
from #OBS_FACT;

drop table #OBS_FACT;