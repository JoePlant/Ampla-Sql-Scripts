/*
Script to output the SQL Performance Counters
*/

select 
	object_name,
	counter_name,
	instance_name,
	cntr_value,
	case cntr_type 
		when 65792 then 'Absolute Meaning' 
		when 65536 then 'Absolute Meaning' 
		when 272696576 then 'Per Second counter and is Cumulative in Nature'
		when 1073874176 then 'Bulk Counter. To get correct value, this value needs to be divided by Base Counter value'
		when 537003264 then 'Bulk Counter. To get correct value, this value needs to be divided by Base Counter value' 
	end as counter_comments
from 
	sys.dm_os_performance_counters
where 
	cntr_type not in (1073939712)