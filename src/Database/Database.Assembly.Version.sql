/*
	Database.Assembly.Version.sql
	
	Lists the CLR Stored Procedures and the Assembly Versions
*/

SELECT
        O.name,
        cast(ASSEMBLYPROPERTY(A.name, 'VersionMajor') as varchar) + '.' 
			+ cast(ASSEMBLYPROPERTY(A.name, 'VersionMinor') as varchar) + '.'
			+ cast(ASSEMBLYPROPERTY(A.name, 'VersionBuild') as varchar) + '.'
			+ cast(ASSEMBLYPROPERTY(A.name, 'VersionRevision') as varchar) as [AssemblyVersion]
FROM
        sys.assembly_modules AM
        INNER JOIN sys.assemblies A ON A.assembly_id = AM.assembly_id
        INNER JOIN sys.objects O ON O.object_id = AM.object_id
ORDER BY
        A.name, AM.assembly_class