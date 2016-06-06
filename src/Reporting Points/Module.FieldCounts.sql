
/*
  Module.FieldCounts.sql
  This script will get a record count for each field, showing Inactive, Active and Total values.
*/

select 
	 counts.Module
	,rp.ItemFullName as ReportingPoint
	,f.Name as [FieldName]
	,(counts.TotalRecords - counts.ActiveRecords) as [InactiveRecords]
	,counts.ActiveRecords
	,counts.TotalRecords
	, cast(100.0 * counts.ActiveRecords / counts.TotalRecords as numeric(36,2)) as [Active Percent]
	/* ,rp.ReportingPointId */
from (
		select FieldId, 'Production' as Module, sum(IsActive) as [ActiveRecords], count(1) as [TotalRecords]
		from dbo.ProductionDataField
		group by FieldId
	union all
		select FieldId, 'Downtime' as Module, sum(IsActive) as [ActiveRecords], count(1) as [TotalRecords]
		from dbo.DowntimeDataField
		group by FieldId
/*	-- Include the Energy module in V4.2
	union all 
		select FieldId, 'Energy' as Module, sum(IsActive) as [ActiveRecords], count(1) as [TotalRecords]
		from dbo.EnergyDataField
		group by FieldId
*/	union all
		select FieldId, 'Quality' as Module, sum(IsActive) as [ActiveRecords], count(1) as [TotalRecords]
		from dbo.QualityDataField
		group by FieldId
	union all
		select FieldId, 'Metrics' as Module, sum(IsActive) as [ActiveRecords], count(1) as [TotalRecords]
		from dbo.MetricsDataField
		group by FieldId
	union all
		select FieldId, 'Maintenance' as Module, sum(IsActive) as [ActiveRecords], count(1) as [TotalRecords]
		from dbo.MaintenanceDataField
		group by FieldId
	union all
		select FieldId, 'Knowledge' as Module, sum(IsActive) as [ActiveRecords], count(1) as [TotalRecords]
		from dbo.KnowledgeDataField
		group by FieldId
	union all
		select FieldId, 'Planning' as Module, sum(IsActive) as [ActiveRecords], count(1) as [TotalRecords]
		from dbo.PlanningDataField
		group by FieldId
	union all
		select FieldId, 'Recipe' as Module, sum(IsActive) as [ActiveRecords], count(1) as [TotalRecords]
		from dbo.RecipeDataField
		group by FieldId
	) counts
inner join
	dbo.Field f
	on 
		f.FieldId = counts.FieldId
inner join 
	dbo.ReportingPoint rp
	on	
		f.ReportingPointId = rp.ReportingPointId
order by 
	counts.TotalRecords desc, rp.ItemFullName,  f.Name, counts.Module


