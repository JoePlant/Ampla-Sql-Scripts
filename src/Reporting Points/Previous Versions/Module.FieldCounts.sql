
/*
  Module.FieldCounts.sql
  This script will get a record count for each field, showing Inactive, Active and Total values.
*/

select 
	 counts.Module
	,counts.ObjectId as ReportingPoint
	,counts.Field as FieldName
	,(counts.TotalRecords - counts.ActiveRecords) as [InactiveRecords]
	,counts.ActiveRecords
	,counts.TotalRecords
from (
		select dataSet.ObjectId, dataField.Field, 'Production' as Module, sum(dataField.IsActive) as [ActiveRecords], count(1) as [TotalRecords]
		from dbo.ProductionDataField dataField
		inner join 
			dbo.ProductionDataSet dataSet
		on dataField.SetId = dataSet.Id
		group by dataSet.ObjectId, dataField.Field
	union all
		select dataSet.ObjectId, dataField.Field, 'Downtime' as Module, sum(dataField.IsActive) as [ActiveRecords], count(1) as [TotalRecords]
		from dbo.DowntimeDataField dataField
		inner join 
			dbo.DowntimeDataSet dataSet
		on dataField.SetId = dataSet.Id
		group by dataSet.ObjectId, dataField.Field
	union all
		select dataSet.ObjectId, dataField.Field, 'Quality' as Module, sum(dataField.IsActive) as [ActiveRecords], count(1) as [TotalRecords]
		from dbo.QualityDataField dataField
		inner join 
			dbo.QualityDataSet dataSet
		on dataField.SetId = dataSet.Id
		group by dataSet.ObjectId, dataField.Field
	union all
		select dataSet.ObjectId, dataField.Field, 'Metrics' as Module, sum(dataField.IsActive) as [ActiveRecords], count(1) as [TotalRecords]
		from dbo.MetricsDataField dataField
		inner join 
			dbo.MetricsDataSet dataSet
		on dataField.SetId = dataSet.Id
		group by dataSet.ObjectId, dataField.Field
	union all
		select dataSet.ObjectId, dataField.Field, 'Maintenance' as Module, sum(dataField.IsActive) as [ActiveRecords], count(1) as [TotalRecords]
		from dbo.MaintenanceDataField dataField
		inner join 
			dbo.MaintenanceDataSet dataSet
		on dataField.SetId = dataSet.Id
		group by dataSet.ObjectId, dataField.Field
	union all
		select dataSet.ObjectId, dataField.Field, 'Knowledge' as Module, sum(dataField.IsActive) as [ActiveRecords], count(1) as [TotalRecords]
		from dbo.KnowledgeDataField dataField
		inner join 
			dbo.KnowledgeDataSet dataSet
		on dataField.SetId = dataSet.Id
		group by dataSet.ObjectId, dataField.Field
	union all
		select dataSet.ObjectId, dataField.Field, 'Planning' as Module, sum(dataField.IsActive) as [ActiveRecords], count(1) as [TotalRecords]
		from dbo.PlanningDataField dataField
		inner join 
			dbo.PlanningDataSet dataSet
		on dataField.SetId = dataSet.Id
		group by dataSet.ObjectId, dataField.Field
	union all
		select dataSet.ObjectId, dataField.Field, 'Recipe' as Module, sum(dataField.IsActive) as [ActiveRecords], count(1) as [TotalRecords]
		from dbo.RecipeDataField dataField
		inner join 
			dbo.RecipeDataSet dataSet
		on dataField.SetId = dataSet.Id
		group by dataSet.ObjectId, dataField.Field
	) counts
order by 
	counts.ObjectId, counts.TotalRecords desc, counts.Field, counts.Module


