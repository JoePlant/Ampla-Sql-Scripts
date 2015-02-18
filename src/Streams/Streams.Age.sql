/* -------------------------------------------------------------------
--  Determines the age of streams in the State database to assist in 
--  understanding streams that stop updating.
--  This script will generate SQL and combine the information 
--  from the state and config databases.
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
DECLARE @utcNow DATETIME
SET @utcNow = GETUTCDATE();

WITH 
Item_CTE(ID, FullName, TypeID, Depth)
AS
(
	SELECT 
		ID, 
		Cast(Name as VARCHAR(MAX)) AS FullName, 
		TypeID, 
		1 AS Depth
	FROM 
		' + @configDB + '.dbo.Items
	WHERE 
		ParentID = ''00000000-0000-0000-0000-000000000000''
	UNION ALL
	SELECT 
		item.ID,  
		Cast(cte.FullName + ''.'' + item.Name as VARCHAR(MAX)) AS FullName, 
		item.TypeID, 
		cte.Depth + 1 AS Depth
	FROM 
		' + @configDB + '.dbo.Items AS item
	INNER JOIN Item_CTE AS cte
		ON item.ParentID = cte.ID
)
, Stream_CTE (StreamId, ItemId, PropertyName, StartTime, EndTime)
AS
(
	SELECT
		StreamId,
		ItemId, 
		PropertyName,
		' + @stateDB + '.dbo.udfTicksToDateTime(StartTimeTicks) as StartTime,
		' + @stateDB + '.dbo.udfTicksToDateTime(EndTimeTicks) as EndTime
	FROM 
		' + @stateDB + '.dbo.SampleStoreSampleStream
	WHERE 
		StartTimeTicks IS NOT NULL
)

SELECT 
	ss.StreamId,
	config.FullName, 
	ss.PropertyName,
	DATEDIFF(DAY, ss.EndTime, @utcNow) AS AgeDays,
	DATEDIFF(HOUR, ss.EndTime, @utcNow) AS AgeHours,
	DATEDIFF(MI, ss.EndTime, @utcNow) AS AgeMinutes,
	config.TypeFullName,
	ss.StartTime,
	ss.EndTime
FROM 
	Stream_CTE ss
	LEFT JOIN (
		SELECT items.ID, items.FullName, items.Depth, types.TypeFullName
		FROM Item_CTE items
		INNER JOIN ' + @configDB + '.dbo.ItemTypes types
		ON items.TypeID = types.ID
	) config 
	on 
		config.ID = ss.ItemId
WHERE 
	config.FullName IS NOT NULL
	
ORDER BY
	ss.EndTime ASC,
	config.FullName DESC,
	ss.PropertyName
'

--print @sql
exec sp_executesql @sql


