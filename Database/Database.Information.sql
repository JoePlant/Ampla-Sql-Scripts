/* 
Script to show some of the Database information 
*/

select 
	name,
	database_id,
	compatibility_level, 
	collation_name,
	is_auto_shrink_on,
	recovery_model_desc,
	is_auto_create_stats_on,
	is_auto_update_stats_on,
	is_auto_update_stats_async_on,
	is_fulltext_enabled,
	is_trustworthy_on,
	is_parameterization_forced
	--,* 
from 
	sys.databases