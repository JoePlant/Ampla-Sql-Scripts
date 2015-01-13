declare @date varchar (10)
declare @sqlFormat varchar(1000)
declare @sql varchar(max)

set @date = convert(varchar(10),getDate(),120)

set @sqlFormat = 'BACKUP DATABASE [' 
			+ '<<db-name>>' 
			+ '] TO  DISK = N''E:\Backup\AmplaProject\' 
			+ @date 
			+ ' ' 
			+ '<<db-name>>'
			+ '.bak'' WITH NOFORMAT, INIT,  NAME = N''' 
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
