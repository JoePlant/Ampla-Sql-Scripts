declare @dateTime datetime
declare @lastMinutes int

set @lastMinutes = 60 -- only go back a certain number of minutes

set @dateTime = dateadd(minute, -@lastMinutes, GETDATE())
declare @dbName nvarchar(50)

-- Check what database it should check for.
-- default is the current database
set @dbName = db_name()
--set @dbName = 'AmplaProjectState'

select 
	substring(q.text, (qs.statement_start_offset/2)+1
                        , ((case qs.statement_end_offset
                              when -1 then datalength(q.text)
                              else qs.statement_end_offset
                           end - qs.statement_start_offset)/2) + 1) as statement_text,
	--q.text, 
	db_name(q.dbid) as [database], 
	object_name(q.objectid, q.dbid) as [objectname],
	qs.execution_count, 
	qs.plan_generation_num,
	qs.total_worker_time, 
	qs.total_physical_reads, 
	qs.total_logical_writes, 
	qs.total_logical_reads,
	qs.last_execution_time
	--,qs.*
from 
	sys.dm_exec_query_stats qs
cross apply 
	sys.dm_exec_sql_text(plan_handle) as q
where 
	qs.last_execution_time >= @dateTime
	--and object_name(q.objectid, q.dbid) is not null
	--and ((db_name(q.dbid) = @dbName) or (q.dbid is null))
order by 
	qs.total_logical_reads desc,
	--qs.total_worker_time desc, 
	qs.last_execution_time desc