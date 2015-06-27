

SELECT 
	cols.TypeFullName,
	cols.NumProperties,
	
'	SELECT '
+ '	i.Name, pvt.* '
+ ' FROM ' 
+ '	dbo.Items i '
+ '	INNER JOIN '
+ '( '
+ 'SELECT ItemID, ' + cols.[Columns] + ' FROM '
+ ' ( SELECT ItemID, PropertyName, CAST(Value as NVARCHAR(MAX)) as [prop.Value]'
+ '   FROM ItemProperties ) x'
+ ' PIVOT ('
+ ' Max([prop.Value]) for PropertyName in ('
+ cols.[Columns]
+ ')) as firstValue '
+ '	) '
+ '	pvt	'
+ '	ON pvt.ItemID = i.ID ' 
 + ' where i.TypeID = ''' + CAST(cols.TypeID as NVARCHAR(36))+ ''''
+ ''  as [SQL],
	cols.TypeID
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
	
ORDER BY cols.TypeFullName