/*
	Database.Connections.sql
	
	Lists details about the number of connections into the different databases.
*/

SELECT 
    DB_NAME(dbid) as DBName, 
    RTRIM(hostname) as HostName,
	RTRIM(PROGRAM_NAME) as ProgramName,
    COUNT(dbid) as NumberOfConnections,
    RTRIM(loginame) as LoginName
FROM
    sys.sysprocesses
WHERE 
    dbid > 0
GROUP BY 
    dbid, loginame, hostname, PROGRAM_NAME
    
    
    