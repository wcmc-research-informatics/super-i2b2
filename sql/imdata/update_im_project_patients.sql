/* 
 * The IM_PROJECT_PATIENTS table stores the patients that are part of a project. 
 * The logic which determines what patients belong to a particular project is 
 * here and the PATIENT and ENCOUNTER MAPPING tables of each project check this 
 * table first. Unlike the other IM tables, this table will be reconstructed each 
 * refresh cycle. 
 */ 
USE heroni2b2imdata; 

/* 
 * Patient cohort for Anesthesiology TBD 
 */ 
INSERT INTO im_project_patients 
SELECT DISTINCT (SELECT project_id 
                 FROM   [heroni2b2pm].[dbo].[pm_project_data] 
                 WHERE  project_name = 'Anesthesiology RDR'), 
                imm.global_id AS global_id, 
                'A'           AS patient_project_status, 
                Getdate()     AS update_date, 
                Getdate()     AS download_date, 
                Getdate()     AS import_date, 
                sourcesystem_cd, 
                NULL          AS upload_id 
FROM   im_mpi_mapping imm 
       INNER JOIN ( 
                  -- Grab the MRN and Z-ID for each patient, removing junk 
                  -- via the blacklist 
                  SELECT DISTINCT I.pat_id, 
                                  Min(identity_id) AS IDENTITY_ID 
                   FROM   super_monthly.dbo.identity_id I 
                   WHERE  identity_type_id = 3 
                   GROUP  BY I.pat_id) AS IDENTITY_TRICK 
               ON identity_id = imm.lcl_id 
       INNER JOIN (SELECT DISTINCT pat_id 
                   FROM   jupiter.compurecord.demographics crd 
                          INNER JOIN super_monthly.dbo.identity_id p 
                                  ON 
       Substring(crd.medicalrecordnumber, 
       Patindex('%[^0]%', crd.medicalrecordnumber), 15) = p.identity_id 
       WHERE  identity_type_id = '3') AS pt 
               ON [IDENTITY_TRICK].[pat_id] = [pt].[pat_id]; 
