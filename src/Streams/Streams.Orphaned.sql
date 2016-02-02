/* -------------------------------------------------------------------
--  Determines if there is any orphaned streams in the state database 
--  and creates a SQL Script to remove them
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
select 
	streams.StreamId,
	streams.ItemId,
	streams.PropertyName,
	COALESCE(samples.SampleCount, 0) as SampleCount,
	[' + @stateDB + '].dbo.udfTicksToDateTime(streams.StartTimeTicks) as StartTime,
	[' + @stateDB + '].dbo.udfTicksToDateTime(streams.EndTimeTicks) as EndTime,
	CASE WHEN COALESCE(samples.SampleCount,0) > 0 THEN 
	''DELETE FROM [' + @stateDB + '].dbo.SampleStoreSample WHERE StreamId='' + cast(streams.StreamId as varchar(10)) + CHAR(13) 
	ELSE '''' END + 
	''DELETE FROM [' + @stateDB + '].dbo.SampleStoreSampleStream WHERE StreamId='' + cast(streams.StreamId as varchar(10)) 
	as [Delete SQL]
from 
	[' + @stateDB + '].dbo.SampleStoreSampleStream streams
	left join (
		select StreamId, count(1) as SampleCount
		from [' + @stateDB + '].dbo.SampleStoreSample
		group by StreamId
	) samples 
	on 
		streams.StreamId = samples.StreamId
where ItemId not in (
	select Id 
	from [' + @configDB + '].dbo.Items
	)		

order by 
	samples.SampleCount desc,
	streams.PropertyName'

--print @sql
exec sp_executesql @sql


