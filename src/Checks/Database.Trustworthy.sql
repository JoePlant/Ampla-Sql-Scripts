/*

	Database.Trustworthy.sql
	Sometimes a database may have .NET assemblies installed but not have the permission to run them.
	This can occur when restoring databases from other servers with .NET assemblies in the database.
	
	This script will check for installed .NET assemblies and check the TRUSTWORTHY database setting.
	
*/

declare @numCLR int

SELECT
        O.name,
        A.name AS assembly_name, 
        AM.assembly_class, 
        cast(ASSEMBLYPROPERTY(A.name, 'VersionMajor') as varchar) + '.' 
			+ cast(ASSEMBLYPROPERTY(A.name, 'VersionMinor') as varchar) + '.'
			+ cast(ASSEMBLYPROPERTY(A.name, 'VersionBuild') as varchar) + '.'
			+ cast(ASSEMBLYPROPERTY(A.name, 'VersionRevision') as varchar) as [AssemblyVersion],
        A.permission_set_desc,
        O.[type_desc]
FROM
        sys.assembly_modules AM
        INNER JOIN sys.assemblies A ON A.assembly_id = AM.assembly_id
        INNER JOIN sys.objects O ON O.object_id = AM.object_id
ORDER BY
        A.name, AM.assembly_class

set @numCLR = @@ROWCOUNT 

SELECT
	Name, 
	'Check TRUSTWORTHY' as [Checking],
--	is_trustworthy_on as [RawResult],
	case when is_trustworthy_on = 1 then 'TRUSTWORTHY IS ON' else 'TRUSTWORTHY IS OFF' end as [Result],
--	case when @numCLR > 0 then cast(@numCLR as varchar(3)) + ' CLR objects listed' else 'No CLR objects' end as [.NET objects],
	case when is_trustworthy_on = 0 and @numCLR > 0 then '' else '-- ' end + 
	'ALTER DATABASE [' + DB_NAME() +'] SET TRUSTWORTHY ON' as [Sql],
	case when is_trustworthy_on = 0 and @numCLR > 0 then 'Errors may occur called .NET assemblies if TRUSTWORTHY is OFF' else 'No change to TRUSTWORTHY required' end as [Description]
FROM sys.databases 
WHERE
	database_id = DB_ID()
UNION	
SELECT
	Name, 
	'Check DB Owner' as [Checking],
--	owner_sid as [RawResult],
	'Owner: ' + suser_sname(owner_sid) as [Result],
--	case when @numCLR > 0 then cast(@numCLR as varchar(3)) + ' CLR objects listed' else 'No CLR objects' end as [.NET objects],
	case when owner_sid = 0x01 or (owner_sid <> 0x01 and @numCLR = 0) then '-- ' else '' end + 
	'ALTER AUTHORIZATION ON DATABASE::[' + name + '] TO sa' as [Sql],
	case when owner_sid <> 0x01 and @numCLR > 0 then 'Errors may occur called .NET assemblies if owner is not ''sa''' else 'No change to owner required' end as [Description]
FROM sys.databases
WHERE
	database_id = DB_ID()

