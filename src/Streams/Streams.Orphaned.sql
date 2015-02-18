/* -------------------------------------------------------------------
--  Determines if there is any orphaned streams in the state database 
--  and creates a SQL Script to remove them
--
--   Usage
--		set @configDB = 'AmplaProject'
----------------------------------------------------------------------*/

declare @configDB varchar(25)
declare @stateDB_override varchar(25)

set @configDB = 'AmplaProject'    /* specify the config database here */

/* uncomment following line to override the default state database */
--set @stateDB_override = 'overide the state database'

/*--------------------------------------------------------------------*/

declare @sql nvarchar(max)
declare @stateDB varchar(25)

set @stateDB = COALESCE(@stateDB_override, @configDB + 'State');

set @sql = 
'
select 
	streams.StreamId,
	streams.ItemId,
	streams.PropertyName,
	COALESCE(samples.SampleCount, 0) as SampleCount,
	' + @stateDB + '.dbo.udfTicksToDateTime(streams.StartTimeTicks) as StartTime,
	' + @stateDB + '.dbo.udfTicksToDateTime(streams.EndTimeTicks) as EndTime,
	CASE WHEN COALESCE(samples.SampleCount,0) > 0 THEN 
	''DELETE FROM ' + @stateDB + '.dbo.SampleStoreSample WHERE StreamId='' + cast(streams.StreamId as varchar(10)) + CHAR(13) 
	ELSE '''' END + 
	''DELETE FROM ' + @stateDB + '.dbo.SampleStoreSampleStream WHERE StreamId='' + cast(streams.StreamId as varchar(10)) 
	as [Delete SQL]
from 
	' + @stateDB + '.dbo.SampleStoreSampleStream streams
	left join (
		select StreamId, count(1) as SampleCount
		from ' + @stateDB + '.dbo.SampleStoreSample
		group by StreamId
	) samples 
	on 
		streams.StreamId = samples.StreamId
where ItemId not in (
	select Id 
	from ' + @configDB + '.dbo.Items
	)		

order by 
	samples.SampleCount desc,
	streams.PropertyName'

--print @sql
exec sp_executesql @sql


