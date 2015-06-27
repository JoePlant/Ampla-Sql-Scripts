/* 
	Item.TraceLevel.sql
*/
WITH Item_CTE(ID, FullName, TypeID, Depth, TraceLevel)
AS
(
	SELECT ID, Cast(Name as VARCHAR(MAX)) as FullName, TypeID, 1 as Depth, TraceLevel as TraceLevel
	FROM Items
	WHERE ParentID = '00000000-0000-0000-0000-000000000000'
	UNION ALL
	SELECT item.ID,  Cast(cte.FullName + '.' + item.Name as VARCHAR(MAX)) as FullName, item.TypeID, cte.Depth + 1 as Depth, item.TraceLevel as TraceLevel
	FROM Items as item
	INNER JOIN Item_CTE as cte
		ON item.ParentID = cte.ID
)

select cte.FullName as [FullName], cte.TraceLevel
FROM 
	Item_CTE cte 
where TraceLevel > 1