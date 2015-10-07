/* 
Script to list the databases and Data and Log file sizes.
*/

select *, [LogFileSize(KB)]-[LogFileUsedSize(KB)] as [LogFileFreeSize(KB)], 100 * ([LogFileSize(KB)]-[LogFileUsedSize(KB)]) / [LogFileSize(KB)] as [LogFileFreePercent]
from 
(
	select 
		pc_dmv.instance_name as [InstanceName]
		, sum(case WHEN counter_name = 'Data File(s) Size (KB)' THEN cntr_value ELSE 0 END) as [DataFileSize(KB)]
		, sum(case WHEN counter_name = 'Log File(s) Size (KB)' THEN cntr_value ELSE 0 END) as [LogFileSize(KB)]
		, sum(case WHEN counter_name = 'Log File(s) Used Size (KB)' THEN cntr_value ELSE 0 END) as [LogFileUsedSize(KB)]
	from 
	( 
		SELECT object_name, counter_name, instance_name, cntr_value
		FROM sys.dm_os_performance_counters 
		WHERE object_name like '%SQL%Database%' -- support both default and names instances
	) pc_dmv
	group by pc_dmv.instance_name
) filesizes
order by 
	[DataFileSize(KB)] DESC
