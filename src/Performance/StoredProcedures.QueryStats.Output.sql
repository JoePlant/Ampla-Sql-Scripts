declare @dateTime datetime
declare @lastMinutes int

set @lastMinutes = 60 -- only go back a certain number of minutes

set @dateTime = dateadd(minute, -@lastMinutes, GETDATE())
declare @dbName nvarchar(50)

-- Check what database it should check for.
-- default is the current database
set @dbName = db_name()
--set @dbName = 'AmplaProjectState'

-- This statement works best by executing the procedure and then saving the results as a output.sql file.
-- It will be possible to open it in SQL Server Management Studio when to view the output

select 
	
	'---------------------------------' + CHAR(13) + CHAR(10)
	+ ' -- Database: ' + coalesce(db_name(q.dbid),'<none>') + CHAR(13) + CHAR(10)
	+ ' -- Object: ' + coalesce(object_name(q.objectid, q.dbid), '<none>') + CHAR(13) + CHAR(10)
	+ ' -- Execution Count: ' + convert(varchar(10), qs.execution_count) + CHAR(13) + CHAR(10)
	+ ' -- Plan Generation: ' + convert(varchar(10), qs.plan_generation_num) + CHAR(13) + CHAR(10)
	+ ' -- Total Worker time: ' + convert(varchar(10), qs.total_worker_time) + CHAR(13) + CHAR(10)
	+ ' -- Total Physical Reads : ' + convert(varchar(10), qs.total_physical_reads) + CHAR(13) + CHAR(10)
	+ ' -- Total Logical Reads  : ' + convert(varchar(10), qs.total_logical_reads) + CHAR(13) + CHAR(10)
	+ ' -- Total Logical Writes : ' + convert(varchar(10), qs.total_logical_writes) + CHAR(13) + CHAR(10)
	+ ' -- Last Executed: ' + convert(varchar(20), qs.last_execution_time) + CHAR(13) + CHAR(10)
	+ '---------------------------------' + CHAR(13) + CHAR(10)
	+ substring(q.text, (qs.statement_start_offset/2)+1
                        , ((case qs.statement_end_offset
                              when -1 then datalength(q.text)
                              else qs.statement_end_offset
                           end - qs.statement_start_offset)/2) + 1)
	+ CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) as statement_text

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