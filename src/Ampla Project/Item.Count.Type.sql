SELECT it.TypeFullName, ISNULL(i.ItemCount, 0) as [ItemCount], it.ID as TypeID
FROM 
	dbo.ItemTypes it
	LEFT JOIN
		(SELECT 
			i.TypeID, COUNT(1) as [ItemCount] 
		FROM 
			dbo.Items i
		GROUP BY 
			i.TypeID) i
	ON it.ID = i.TypeID

ORDER BY i.ItemCount DESC, it.TypeFullName

