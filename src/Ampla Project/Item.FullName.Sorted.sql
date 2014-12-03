
WITH Item_CTE(ID, Parent, Name, FullName, TypeID, Depth, DisplayOrder, SortOrder)
AS
(
	SELECT ID, Cast('' as VARCHAR(MAX)) as Parent, Name, cast(Name as VARCHAR(MAX)) as FullName, TypeID, 1 as Depth, DisplayOrder, Cast(ROW_NUMBER() OVER (ORDER BY DisplayOrder, Name) as VARCHAR(MAX)) as SortOrder
	FROM Items
	WHERE ParentID = '00000000-0000-0000-0000-000000000000'
	UNION ALL
	SELECT item.ID,  cte.FullName, item.Name, Cast(cte.FullName + '.' + item.Name as VARCHAR(MAX)) as FullName, item.TypeID, cte.Depth + 1 as Depth, item.DisplayOrder, cte.SortOrder + '.' + cast(ROW_NUMBER() OVER (ORDER BY item.DisplayOrder, item.Name) as VARCHAR(MAX)) as SortOrder
	FROM Items as item
	INNER JOIN Item_CTE as cte
		ON item.ParentID = cte.ID
)

SELECT Id, FullName, /*Name, Parent, */ Depth, SortOrder
from Item_CTE 
order by SortOrder

