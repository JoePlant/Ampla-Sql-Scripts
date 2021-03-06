/* -------------------------------------------------------------------
--   Usage
--		set @configDB = 'AmplaProject'
----------------------------------------------------------------------*/

declare @configDB varchar(25)
declare @dataDB_override varchar(25)
declare @showDeleteSQL int

set @configDB = 'AmplaProject'    			/* <-- specify the config database here */
set @showDeleteSQL = 1			 			/* Show the delete SQL command */

/* uncomment following line to override the DataRepository name */
--set @dataDB_override = 'MyData'			/* overide the data database */

/*--------------------------------------------------------------------*/

declare @dataDB varchar(20)
declare @sql nvarchar(500)
declare @nl varchar(2)
/*
	Data Repository Data Integrity Check - Output Fields that have been deleted from reporting point configuration
*/

set @dataDB = COALESCE(@dataDB_override, @configDB + 'Data');
set @nl = CHAR(13) + CHAR(10)

set @sql = 
	  'SELECT ' + @nl
	+ '		f.FieldId, ' + @nl
	+ '		f.ItemFullName, ' + @nl  
	+ '		''Field: '''''' + f.ItemFullName + '''''' appears to be deleted.'' as [Message], ' + @nl 
	+ CASE WHEN @ShowDeleteSQL = 1 THEN
	  '		''DELETE FROM ' + @dataDB + '.dbo.Field where FieldId = '' + cast(f.FieldId as varchar(10))'
		ELSE 
	  '		''SELECT * FROM ' + @dataDB + '.dbo.Field where FieldId = '' + cast(f.FieldId as varchar(10))'
	  END
	+ ' as [SQL] ' + @nl
	+ 'FROM ' + @dataDB + '.dbo.Field f ' + @nl
    + 'WHERE f.ItemId NOT IN ' + @nl
	+ '( ' + @nl
	+ '		SELECT i.Id ' + @nl
	+ '		FROM ' + @configDB + '.dbo.Items i ' + @nl
	+ ')' + @nl

print @sql
exec sp_executesql @sql