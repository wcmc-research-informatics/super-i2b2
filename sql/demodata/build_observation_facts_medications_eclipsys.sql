/*
 
  Models medications data from the medical administration record (MAR)
  into i2b2. The unit of analysis for these medications are RxNORM.
  The date associated with these records is the date the medication
  order was put into the system.

  Copyright (c) 2014-2017 Weill Cornell Medical College
 
 */

use <prefix>i2b2demodata;


INSERT INTO observation_fact(
	  encounter_num
	, patient_num
	, concept_cd
	, provider_id
	, [start_date]
	, modifier_cd
	, instance_num
	, valtype_cd
	, tval_char
	, nval_num
	, VALUEFLAG_CD
	, quantity_num
	, UNITS_CD
	, END_DATE
	, location_cd
	, UPDATE_DATE
	, IMPORT_DATE
	, sourcesystem_cd
	)
SELECT			  ENCOUNTER_NUM
				, patient_num
				, 'RXNORM:' + RxNormCode as concept_cd
				, toe.PerformedProviderGUID as provider_id
				, performedfromdtm as [start_date]
				, 'INPATIENTMEDS' as modifier_cd
				, CONVERT(INT, CONVERT(VARBINARY, HASHBYTES('MD5', cast(visitidcode as varchar) + cast(performedfromdtm as varchar)), 1)) as instance_num
				, 'N' as valtype_cd
				, 'E' AS TVAL_CHAR
				, toe.taskdose as nval_num
				, '@' as valueflag_cd
				, 1 as quantity_num
				, taskuom as units_cd
				, PerformedToDtm as [end_date]
				, currentlocationguid as location_cd
				, toe.createdwhen [update_date]
				, getDate() as import_date
				, 'ECLIPSYS' as sourcesystem_cd
  FROM [Jupiter].[JupiterSCM].[CV3ClientVisit_East] cve
  join [jupiter].[jupiterscm].[CV3Order_East] oe 
	on oe.clientvisitGUID = cve.GUID
  join [Jupiter].[JupiterSCM].[CV3OrderTaskOccurrence_East] [toe] 
	on [toe].OrderGUID = oe.GUID
  join [jupiter].[jupiterscm].[CV3DrugMapping_East] [dme] 
	on [dme].CatalogItemGUID = oe.OrderCatalogMasterItemGUID
  join [Jupiter].[JupiterSCM].[SXAMTDnumRxNormCodeXRef_East] [rxnorm] 
	on [rxnorm].MultumDnum = dme.DrugKey
  join [Jupiter].[JupiterSCM].[CV3ClientID_East] cie 
	on cie.ClientGUID = cve.ClientGUID
	   and cie.TypeCode = 'Hospital MRN1' 
	   and IDStatus = 'ACT'	
	   and taskstatuscode = 'Performed'
	   and visitidcode <> '000000000 000       ' 
	   and cve.TypeCode = 'Inpatient'
	   and visitstatus <> 'CAN' -- canceled?
   INNER JOIN (
   SELECT patient_num
		, ENCOUNTER_NUM
		, ENCOUNTER_IDE
	FROM ENCOUNTER_MAPPING
	WHERE [ENCOUNTER_IDE_SOURCE] = 'ECLIPSYS'
	) EM
	ON ENCOUNTER_IDE = replace(substring(VisitIDCode, patindex('%[^0]%',VisitIDCode),len(VisitIDCode)), ' ', '');