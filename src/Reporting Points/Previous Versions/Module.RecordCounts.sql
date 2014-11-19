
declare @dateTime datetime
set @dateTime = getutcdate()

select 
	 counts.Module
	,counts.ItemFullName as ReportingPoint
	,counts.RecordCount
	,counts.FirstRecord
	,counts.LastRecord
	,datediff(wk, counts.LastRecord, @dateTime) as WeeksAgo
	,datediff(mm, counts.LastRecord, @dateTime) as MonthsAgo

from 
	(	select ObjectId as ItemFullName, 'Production' as Module, count(1) as [RecordCount], min(SampleDateTime) as FirstRecord, max(SampleDateTime) as LastRecord
		from dbo.ProductionDataSet
		group by ObjectId
	union all
		select ObjectId as ItemFullName, 'Downtime' as Module, count(1) as [RecordCount], min(StartDateTime) as FirstRecord, max(StartDateTime) as LastRecord
		from dbo.DowntimeDataSet
		group by ObjectId
	union all
		select ObjectId as ItemFullName, 'Quality' as Module, count(1) as [RecordCount], min(SampleDateTime) as FirstRecord, max(SampleDateTime) as LastRecord
		from dbo.QualityDataSet
		group by ObjectId
	union all
		select ObjectId as ItemFullName, 'Metrics' as Module, count(1) as [RecordCount], min(StartDateTime) as FirstRecord, max(StartDateTime) as LastRecord
		from dbo.MetricsDataSet
		group by ObjectId
	union all
		select ObjectId as ItemFullName, 'Maintenance' as Module, count(1) as [RecordCount], min(SampleDateTime) as FirstRecord, max(SampleDateTime) as LastRecord
		from dbo.MaintenanceDataSet
		group by ObjectId
	union all
		select ObjectId as ItemFullName, 'Knowledge' as Module, count(1) as [RecordCount], min(StartDateTime) as FirstRecord, max(StartDateTime) as LastRecord
		from dbo.KnowledgeDataSet
		group by ObjectId
	union all
		select ObjectId as ItemFullName, 'Planning' as Module, count(1) as [RecordCount], min(PlannedStartDateTime) as FirstRecord, max(PlannedStartDateTime) as LastRecord
		from dbo.PlanningDataSet
		group by ObjectId
	union all
		select ObjectId as ItemFullName, 'Recipe' as Module, count(1) as [RecordCount], min(StateChangedDateTime) as FirstRecord, max(StateChangedDateTime) as LastRecord
		from dbo.RecipeDataSet
		group by ObjectId
	) counts
order by 
    counts.Module,counts.ItemFullName,
	counts.LastRecord asc, counts.RecordCount desc--, counts.Module


