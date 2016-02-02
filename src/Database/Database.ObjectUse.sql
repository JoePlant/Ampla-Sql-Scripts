/* -------------------------------------------------------------------
--  Determines how source objects are used within other objects in a database
---------------------------------------------------------------------- */


SELECT DISTINCT
	tbl.name as [Source Name], 
	tbl.type_desc as [Source Type],
	sp.name as [Found In], 
	sp.type_desc as [Found In Type],
	sm.definition as [SQL Definition],
	CHARINDEX(tbl.name, sm.definition) as [SQL position]
FROM 
	sys.objects tbl 
INNER JOIN
	sys.sql_expression_dependencies sd 
	ON tbl.object_id = sd.referenced_id
INNER JOIN
	sys.objects sp 
	ON sd.referencing_id = sp.object_id
INNER JOIN
	sys.sql_modules sm
	on sp.object_id = sm.object_id
ORDER BY
	sp.Name, [SQL position]