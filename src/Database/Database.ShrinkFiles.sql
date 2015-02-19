
/*
-- Script to generate DBCC SHRINKFILE statements for all the databases 
--
-- Do NOT use in a production environment
*/

SELECT 
      'USE [' + d.name + N']' + CHAR(13) + CHAR(10) 
    + 'DBCC SHRINKFILE (N''' + mf.name + N''' , 0, TRUNCATEONLY)' 
    + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) as [DBCC SHRINKFILE SQL]
FROM 
         sys.master_files mf 
    JOIN sys.databases d 
        ON mf.database_id = d.database_id 
WHERE d.database_id > 4 and d.name like '%AmplaProject%'