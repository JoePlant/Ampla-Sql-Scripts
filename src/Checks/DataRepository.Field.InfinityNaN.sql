/*
	DataRepository.Field.InfinityNaN.sql
	SQL Script to detect and remove Infinity and NaN values in the DataRepository
*/

SELECT 
	Module,
	FieldCount AS InvalidFieldCount, 
	CASE WHEN FieldCount = 0 THEN '-- ' ELSE'' END 
		+ ' UPDATE dbo.' + Module + 'DataField' 
		+ ' SET DataValue = NULL ' 
		+ ' WHERE DataValue in (N''NaN'', N''Infinity'')'
	AS [UpdateSQL]
FROM (
	SELECT 'Downtime' AS Module, COUNT(1) AS FieldCount
	FROM dbo.DowntimeDataField 
	WHERE DataValue in (N'NaN', N'Infinity')
UNION ALL 
	SELECT 'Energy' AS Module, COUNT(1) AS FieldCount 
	FROM dbo.EnergyDataField 
	WHERE DataValue in (N'NaN', N'Infinity')	
UNION ALL 
	SELECT 'Knowledge' AS Module, COUNT(1) AS FieldCount 
	FROM dbo.KnowledgeDataField 
	WHERE DataValue in (N'NaN', N'Infinity')
UNION ALL 
	SELECT 'Metrics' AS Module, COUNT(1) AS FieldCount 
	FROM dbo.MetricsDataField 
	WHERE DataValue in (N'NaN', N'Infinity')
UNION ALL 
	SELECT 'Lot' AS Module, COUNT(1) AS FieldCount 
	FROM dbo.LotDataField 
	WHERE DataValue in (N'NaN', N'Infinity')
UNION ALL 
	SELECT 'Planning' AS Module, COUNT(1) AS FieldCount 
	FROM dbo.PlanningDataField 
	WHERE DataValue in (N'NaN', N'Infinity')
UNION ALL 
	SELECT 'Production' AS Module, COUNT(1) AS FieldCount 
	FROM dbo.ProductionDataField 
	WHERE DataValue in (N'NaN', N'Infinity')
UNION ALL 
	SELECT 'Quality' AS Module, COUNT(1) AS FieldCount 
	FROM dbo.ProductionDataField 
	WHERE DataValue in (N'NaN', N'Infinity')
UNION ALL 
	SELECT 'Recipe' AS Module, COUNT(1) AS FieldCount 
	FROM dbo.RecipeDataField 
	WHERE DataValue in (N'NaN', N'Infinity')
	) modules
ORDER BY modules.FieldCount DESC
