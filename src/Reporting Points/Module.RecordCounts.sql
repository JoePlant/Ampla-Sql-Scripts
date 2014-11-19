
/* 
  Module.RecordCounts.sql
  This is used to get a record count for each reporting point in the database.
*/

declare @dateTime datetime
set @dateTime = getutcdate()

select 
	counts.Module
	,rp.ItemFullName as ReportingPoint
	,counts.RecordCount
	,counts.FirstRecord
	,counts.LastRecord
	,datediff(wk, counts.LastRecord, @dateTime) as WeeksAgo
	,datediff(mm, counts.LastRecord, @dateTime) as MonthsAgo
from (
		select ReportingPointId, 'Production' as Module, count(1) as [RecordCount], min(SampleDateTime) as FirstRecord, max(SampleDateTime) as LastRecord
		from dbo.ProductionDataSet
		group by ReportingPointId
	union all
		select ReportingPointId, 'Downtime' as Module, count(1) as [RecordCount], min(StartDateTime) as FirstRecord, max(StartDateTime) as LastRecord
		from dbo.DowntimeDataSet
		group by ReportingPointId
/*	-- Include the Energy module
	union all 
		select ReportingPointId, 'Energy' as Module, count(1) as [RecordCount], min(StartDateTime) as FirstRecord, max(StartDateTime) as LastRecord
		from dbo.EnergyDataSet
		group by ReportingPointId
*/	union all
		select ReportingPointId, 'Quality' as Module, count(1) as [RecordCount], min(SampleDateTime) as FirstRecord, max(SampleDateTime) as LastRecord
		from dbo.QualityDataSet
		group by ReportingPointId
	union all
		select ReportingPointId, 'Metrics' as Module, count(1) as [RecordCount], min(StartDateTime) as FirstRecord, max(StartDateTime) as LastRecord
		from dbo.MetricsDataSet
		group by ReportingPointId
	union all
		select ReportingPointId, 'Maintenance' as Module, count(1) as [RecordCount], min(SampleDateTime) as FirstRecord, max(SampleDateTime) as LastRecord
		from dbo.MaintenanceDataSet
		group by ReportingPointId
	union all
		/* Some versions of Ampla use SampleDateTime and others use StartDateTime */
		select ReportingPointId, 'Knowledge' as Module, count(1) as [RecordCount], min(SampleDateTime) as FirstRecord, max(SampleDateTime) as LastRecord
		--select ReportingPointId, 'Knowledge' as Module, count(1) as [RecordCount], min(StartDateTime) as FirstRecord, max(StartDateTime) as LastRecord
		from dbo.KnowledgeDataSet
		group by ReportingPointId
	union all
		select ReportingPointId, 'Planning' as Module, count(1) as [RecordCount], min(PlannedStartDateTime) as FirstRecord, max(PlannedStartDateTime) as LastRecord
		from dbo.PlanningDataSet
		group by ReportingPointId
	union all
		select ReportingPointId, 'Recipe' as Module, count(1) as [RecordCount], min(StateChangedDateTime) as FirstRecord, max(StateChangedDateTime) as LastRecord
		from dbo.RecipeDataSet
		group by ReportingPointId
	) counts
inner join
	dbo.ReportingPoint rp
	on 
		rp.ReportingPointId = counts.ReportingPointId
order by 
	counts.RecordCount desc, rp.ItemFullName, counts.Module

