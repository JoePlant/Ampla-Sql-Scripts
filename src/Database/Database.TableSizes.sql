/*

	SQL Statement to get the number of rows per table in a database

*/

SELECT 
    t.name AS TableName,
    i.name AS IndexName,
    p.rows as [Rows],
    sum(a.total_pages) as TotalPages, 
    sum(a.used_pages) as UsedPages, 
    sum(a.data_pages) as DataPages,
    (sum(a.total_pages) * 8) / 1024 as TotalSpaceMB, 
    (sum(a.used_pages) * 8) / 1024 as UsedSpaceMB, 
    (sum(a.data_pages) * 8) / 1024 as DataSpaceMB
FROM 
    sys.tables t
INNER JOIN      
    sys.indexes i ON t.object_id = i.object_id
INNER JOIN 
    sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
INNER JOIN 
    sys.allocation_units a ON p.partition_id = a.container_id
WHERE 
		t.name NOT LIKE 'dt%' 
    AND i.object_id > 255 
    AND i.index_id <= 1
GROUP BY 
    t.name, i.object_id, i.index_id, i.name, p.rows
ORDER BY 
    p.rows desc, object_name(i.object_id) 