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

declare @sql nvarchar(max)
declare @stateDB varchar(25)

set @stateDB = COALESCE(@stateDB_override, @configDB + 'State');

set @sql = 
'
WITH Item_CTE(ID, FullName, TypeID, Depth)
AS
(
	SELECT ID, Cast(Name as VARCHAR(MAX)) as FullName, TypeID, 1 as Depth
	FROM ' + @configDB + '.dbo.Items
	WHERE ParentID = ''00000000-0000-0000-0000-000000000000''
	UNION ALL
	SELECT item.ID,  Cast(cte.FullName + ''.'' + item.Name as VARCHAR(MAX)) as FullName, item.TypeID, cte.Depth + 1 as Depth
	FROM ' + @configDB + '.dbo.Items as item
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
		SELECT items.ID, items.FullName, items.Depth, types.TypeFullName
		from Item_CTE items
		inner join ' + @configDB + '.dbo.ItemTypes types
		on items.TypeID = types.ID
	) config 
	on 
		config.ID = streams.ItemId
order by 
	samples.SampleCount desc,
	config.FullName desc'

--print @sql
exec sp_executesql @sql


