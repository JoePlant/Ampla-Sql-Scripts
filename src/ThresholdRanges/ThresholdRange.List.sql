
/* 
	Threshold Range items are listed from the project using a Common Table Expression (CTE) 
	and joining to the ItemTypes table.
*/

-- Update for the Ampla Project configuration
Use AmplaProject;

WITH Item_CTE(ID, FullName, TypeID, Depth)
AS
(
	SELECT ID, Cast(Name as VARCHAR(MAX)) as FullName, TypeID, 1 as Depth
	FROM Items
	WHERE ParentID = '00000000-0000-0000-0000-000000000000'
	UNION ALL
	SELECT item.ID,  Cast(cte.FullName + '.' + item.Name as VARCHAR(MAX)) as FullName, item.TypeID, cte.Depth + 1 as Depth
	FROM Items as item
	INNER JOIN Item_CTE as cte
		ON item.ParentID = cte.ID
)

SELECT items.FullName as ThresholdRanges
from Item_CTE items
inner join ItemTypes types
	on items.TypeID = types.ID
where types.TypeFullName = 'Citect.Ampla.General.Server.ThresholdRange'
order by FullName