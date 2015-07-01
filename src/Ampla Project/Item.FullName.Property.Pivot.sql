

SELECT 
	cols.TypeFullName,
	cols.NumProperties,
	COALESCE(ic.ItemCount, 0) as NumItems,

+ '/*--- CTE ---*/ ' 
+ 'WITH Item_CTE(ID, FullName, Parent, Name, TypeID, Depth) '
+ '  AS '
+ '( '
+ '	SELECT ID, Cast(Name as VARCHAR(MAX)) as FullName, Cast('''' as VARCHAR(MAX)) as Parent, Name, TypeID, 1 as Depth '
+ '	FROM Items '
+ ' WHERE ParentID = ''00000000-0000-0000-0000-000000000000'''
+ ' UNION ALL '
+ ' SELECT item.ID,  Cast(cte.FullName + ''.'' + item.Name as VARCHAR(MAX)) as FullName, cte.FullName as Parent, item.Name, item.TypeID, cte.Depth + 1 as Depth '
+ ' FROM Items as item '
+ ' INNER JOIN Item_CTE as cte '
+ '	    ON item.ParentID = cte.ID '
+ ') '
+ '/*------------*/ '
+ '/*---SELECT---*/ '	
+ '/*------------*/ '
+ ' SELECT items.FullName, '
+ ' /* items.Parent,*/ '
+ ' items.Name, '
+ ' /* items.Depth, */ '
+ ' /* items.TypeID, */'
+ ' /* pvt.* */ '
+ cols.[Columns] 
+ ' FROM '
+ '   Item_CTE items '
+ ' LEFT JOIN '
+ ' ( '
+ '   SELECT ItemID, ' + cols.[Columns] + ' FROM '
+ '   ( SELECT ItemID, PropertyName, CAST(Value as NVARCHAR(MAX)) as [prop.Value]'
+ '     FROM ItemProperties ) x'
+ ' PIVOT ('
+ '   Max([prop.Value]) for PropertyName in ( '
+ cols.[Columns]
+ '  )) as firstValue '
+ ' 	) '
+ ' pvt	'
+ '  ON pvt.ItemID = items.ID ' 
+ ' where items.TypeID = ''' + CAST(cols.TypeID as NVARCHAR(36))+ ''''
+ '/*---------------*/ '
+ '/*---ORDER BY ---*/ '	
+ '/*---------------*/ '
+ ' ORDER BY items.FullName, items.Name'
+ ''  as [Pivot-Data-SQL]
-- , cols.TypeID 
FROM 
	(
	SELECT 
		it.TypeFullName,
		it.ID as TypeID, 
		(	SELECT 
				Count(1)
			FROM 
				dbo.PropertyDescriptors pd
			WHERE
				pd.Name not like '%.Overridden' 
				and pd.BehaviorName = 'Config'
				and pd.DeclaringTypeID = it.ID
		) as NumProperties,
		ISNULL(
			STUFF((
				SELECT 
					',' + QUOTENAME(pd.Name) 
				FROM 
					dbo.PropertyDescriptors pd
				WHERE
					pd.Name not like '%.Overridden' 
					and pd.BehaviorName = 'Config'
					and pd.DeclaringTypeID = it.ID
				GROUP BY 
					pd.Name
				ORDER BY 
					pd.Name
				FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)')
			,1,1,''),
			'') as [Columns]
	FROM 
		dbo.ItemTypes it
	) cols
LEFT JOIN
	(
		SELECT TypeID as TypeID, COUNT(1) as ItemCount 
		from dbo.Items 
		GROUP BY TypeID
	) ic
	ON cols.TypeID = ic.TypeID
WHERE NumProperties > 0
ORDER BY 
	--ic.ItemCount desc,
	cols.TypeFullName
