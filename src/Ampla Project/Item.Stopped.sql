/* 
	Item.Stopped.sql
*/
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

select cte.FullName as [Stopped Items], ip.Value as [StartupMode], it.TypeFullName
from ItemProperties ip
inner join Item_CTE cte on ip.ItemID = cte.ID
inner join ItemTypes it on cte.TypeID = it.ID
where PropertyName = 'StartupMode'