/* -------------------------------------------------------------------
--   Usage
--		set @configDB = 'AmplaProject'
----------------------------------------------------------------------*/

declare @configDB varchar(25)
declare @stateDB_override varchar(25)

set @configDB = 'AmplaProject'    /* specify the config database here */

/* uncomment following line to override the default state database */
--set @stateDB_override = 'overide the state database'

/*--------------------------------------------------------------------*/

declare @sql nvarchar(1000)
declare @stateDB varchar(25)

set @stateDB = COALESCE(@stateDB_override, @configDB + 'State');

set @sql = 
'select 
	streams.StreamId,
	config.Name, 
	streams.PropertyName,
	config.TypeFullName,
	samples.SampleCount,
	((100.0 * samples.SampleCount) / summary.TotalCount) as Percentage,
	' + @stateDB +'.dbo.udfTicksToDateTime(streams.StartTimeTicks) as StartTime,
	' + @stateDB +'.dbo.udfTicksToDateTime(streams.EndTimeTicks) as EndTime
from 
	(select count(1) as TotalCount from ' + @stateDB +'.dbo.SampleStoreSample) summary,
	' + @stateDB +'.dbo.SampleStoreSampleStream streams
	left join (
		select StreamId, count(1) as SampleCount
		from '+ @stateDB +'.dbo.SampleStoreSample
		group by StreamId
	) samples 
	on 
		streams.StreamId = samples.StreamId
	left join (
		select items.ID, items.[Name], types.TypeFullName
		from ' + @configDB + '.dbo.Items items
		inner join ' + @configDB + '.dbo.ItemTypes types on 
		items.TypeId = types.ID
	) config 
	on 
		config.ID = streams.ItemId
order by 
	samples.SampleCount desc,
	config.Name desc'

--print @sql
exec sp_executesql @sql


