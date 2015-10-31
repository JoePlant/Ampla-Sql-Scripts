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
	SELECT 
		ID, 
		Cast(Name as VARCHAR(MAX)) AS FullName, 
		TypeID, 
		1 as Depth
	FROM 
		' + @configDB + '.dbo.Items
	WHERE 
		ParentID = ''00000000-0000-0000-0000-000000000000''
	UNION ALL
	SELECT 
		item.ID,  
		Cast(cte.FullName + ''.'' + item.Name as VARCHAR(MAX)) as FullName, 
		item.TypeID, 
		cte.Depth + 1 as Depth
	FROM 
		' + @configDB + '.dbo.Items as item
	INNER JOIN Item_CTE AS cte
		ON item.ParentID = cte.ID
)
, SampleStats_CTE (StreamId, LastSampleId, SampleCount)
AS
(
	SELECT 
		StreamId, 
		MAX(SampleId) as MaxSampleId,
		COUNT(1) as SampleCount
	from ' + @stateDB + '.dbo.SampleStoreSample
		GROUP BY StreamId
)
, Samples_CTE(SampleId, Value, QualityName, TimestampUtc)
AS 
(
	SELECT 
		 ss.SampleId, 
		 COALESCE(
			ss.Value_String,
			Cast(ss.Value_Double as NVARCHAR(4000)),
			Cast(ss.Value_Long as NVARCHAR(4000))
			) as [Value],
		 ssq.Value as [QualityName],
		 ' + @stateDB + '.dbo.udfTicksToDateTime(ss.TimestampTicks) as [TimestampUtc]
	FROM 
		' + @stateDB + '.dbo.SampleStoreSample ss
	INNER JOIN 
		' + @stateDB + '.dbo.SampleStoreQuality ssq
		ON ss.Quality = ssq.Code
)
, Streams_CTE(StreamId, ItemId, PropertyName, SampleType, EndTimeUtc)
AS 
(
	SELECT 
		s.StreamId,
		s.ItemId,
		s.PropertyName,
		sst.Value + case when s.DuplicatesAllowed = 1 THEN '' (Duplicates)'' ELSE '''' END as [SampleType],
		' + @stateDB + '.dbo.udfTicksToDateTime(s.EndTimeTicks) as [EndTimeUtc]
	FROM 
		' + @stateDB + '.dbo.SampleStoreSampleStream s
	INNER JOIN 
		' + @stateDB + '.dbo.SampleStoreSampleTypeCode sst
		ON s.SampleTypeCode = sst.Code
)

SELECT 
	items.FullName,
	s.PropertyName AS [Stream],
	s.SampleType,
	s.EndTimeUtc,
	COALESCE(ssts.SampleCount,0) AS [SampleCount],
	ss.Value AS [LastSample.Value],
	ss.TimestampUtc AS [LastSample.TimestampUtc], 
	ss.QualityName AS [LastSample.Quality]
FROM
	Streams_CTE s
INNER JOIN 
	Item_CTE items
	ON items.ID = s.ItemId
LEFT JOIN 
	SampleStats_CTE ssts
	ON s.StreamId = ssts.StreamId
LEFT JOIN 
	Samples_CTE ss
	ON ss.SampleId = ssts.LastSampleId
ORDER BY
	FullName
'

--print @sql
exec sp_executesql @sql


