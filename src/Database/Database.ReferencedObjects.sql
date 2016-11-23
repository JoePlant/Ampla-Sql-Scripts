select 
	so.object_id as [Object.Id],
	so.name as [Object.Name],
	so.type_desc as [Object.Type],
	COALESCE(COL_NAME(d.referencing_id, d.referencing_minor_id), '(n/a)') AS [Object.Column],
	ro.object_id as [Referenced.Id],
	ro.name as [Referenced.Name],
	ro.type_desc as [Referenced.Type],
	d.* 
from 
	sys.sql_expression_dependencies d
left join
	sys.objects so on d.referencing_id = so.object_id
left join
	sys.objects ro on d.referenced_id = ro.object_id