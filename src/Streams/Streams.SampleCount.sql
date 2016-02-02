/* -------------------------------------------------------------------
--  Matches the streams in the state database with the items in the project 
-- 
--   Usage 
--		set @configDB = DB_NAME()		/* to use the current database */
--		set @configDB = 'AmplaProject'	/* or specify the database     */
---------------------------------------------------------------------- */

declare @configDB varchar(50)
declare @stateDB_override varchar(50)

set @configDB = DB_NAME()			/* use the current database */
-- set @configDB = 'AmplaProject'	/* or specify the config database here */

/* uncomment following line to override the default state database */
--set @stateDB_override = 'overide the state database'

/*--------------------------------------------------------------------*/

declare @sql nvarchar(max)
declare @stateDB varchar(50)

set @stateDB = COALESCE(@stateDB_override, @configDB + 'State');

--print 'ConfigDB: ' + @configDB
--print 'StateDB: ' + @stateDB

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = @configDB)
BEGIN
	print '** ERROR - Unable to find Ampla Config Database : [' + @configDB + ']'
END

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = @stateDB)
BEGIN
	PRINT '** ERROR - Unable to find Ampla State Database : [' + @stateDB + ']'
END 

IF OBJECT_ID(@configDB +'.dbo.Items', 'U') IS NULL
BEGIN 
	PRINT '** ERROR - Ampla Config Database : [' + @configDB + '] is not a valid Ampla config database.'
END

IF OBJECT_ID(@stateDB +'.dbo.SampleStoreSample', 'U') IS NULL
BEGIN 
	PRINT '** ERROR - Ampla State Database : [' + @stateDB + '] is not a valid Ampla State database.'
END
set @sql = 
'
WITH Item_CTE(ID, FullName, TypeID, Depth)
AS
(
	SELECT ID, Cast(Name as VARCHAR(MAX)) as FullName, TypeID, 1 as Depth
	FROM [' + @configDB + '].dbo.Items
	WHERE ParentID = ''00000000-0000-0000-0000-000000000000''
	UNION ALL
	SELECT item.ID,  Cast(cte.FullName + ''.'' + item.Name as VARCHAR(MAX)) as FullName, item.TypeID, cte.Depth + 1 as Depth
	FROM [' + @configDB + '].dbo.Items as item
	INNER JOIN Item_CTE as cte
		ON item.ParentID = cte.ID
)

select 
	streams.StreamId,
	config.FullName, 
	streams.PropertyName,
	config.TypeFullName,
	samples.SampleCount,
	((100.0 * samples.SampleCount) / summary.TotalCount) as Percentage,
	[' + @stateDB +'].dbo.udfTicksToDateTime(streams.StartTimeTicks) as StartTime,
	[' + @stateDB +'].dbo.udfTicksToDateTime(streams.EndTimeTicks) as EndTime
from 
	(select count(1) as TotalCount from [' + @stateDB +'].dbo.SampleStoreSample) summary,
	[' + @stateDB +'].dbo.SampleStoreSampleStream streams
	left join (
		select StreamId, count(1) as SampleCount
		from ['+ @stateDB +'].dbo.SampleStoreSample
		group by StreamId
	) samples 
	on 
		streams.StreamId = samples.StreamId
	left join (
		SELECT items.ID, items.FullName, items.Depth, types.TypeFullName
		from Item_CTE items
		inner join [' + @configDB + '].dbo.ItemTypes types
		on items.TypeID = types.ID
	) config 
	on 
		config.ID = streams.ItemId
order by 
	samples.SampleCount desc,
	config.FullName desc'

--print @sql
exec sp_executesql @sql


