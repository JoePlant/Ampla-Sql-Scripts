/*
	Database.BackupScript.sql
	Generates a set of backup scripts for Ampla Databases with the date in the file name
	
	Adjust the name of the database as required.
	Script can be modified to execute directly
*/

declare @date varchar (10)
declare @sqlFormat varchar(1000)
declare @sql varchar(max)
declare @backupDir varchar(100)

set @date = convert(varchar(10),getDate(),120)

set @backupDir = 'C:\Backups\Databases\'

set @sqlFormat = 'BACKUP DATABASE [' 
			+ '<<db-name>>' 
			+ '] TO DISK = N''' 
			+ @backupDir
			+ @date 
			+ ' ' 
			+ '<<db-name>>'
			+ '.bak'' WITH NOFORMAT, INIT, NAME = N''' 
			+ '<<db-name>>'
			+ '-Full Backup'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10'

set @sql = Replace (@sqlFormat, '<<db-name>>', 'AmplaProject')
print @sql
--exec (@sql)

set @sql = Replace (@sqlFormat, '<<db-name>>', 'AmplaProjectData')
print @sql
--exec (@sql)

set @sql = Replace (@sqlFormat, '<<db-name>>', 'AmplaProjectState')
print @sql
--exec (@sql)

set @sql = Replace (@sqlFormat, '<<db-name>>', 'AmplaProjectExtras')
print @sql
--exec (@sql)
GO
