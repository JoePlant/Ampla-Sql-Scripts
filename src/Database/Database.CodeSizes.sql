/*
	SQL Statement to get the size of stored procedures and functions in a database
*/

select 
	t.name as [Name], 
	SUM(t.statements) as [Number of Statements],
	SUM(t.lines_of_code) - 1 as [Lines of Code],
	t.object_type as [Object Type]
from
(
    select o.name as [name], 
    1 as statements,
    (len(c.text) - len(replace(c.text, char(10), ''))) as lines_of_code,
    case 
		when o.xtype = 'P' then 'Stored Procedure'
		when o.xtype in ('FN', 'IF', 'TF') then 'Function'
    end as object_type
    from sysobjects o
    inner join syscomments c
    on c.id = o.id
    where o.xtype in ('P', 'FN', 'IF', 'TF')
    and o.category = 0
    and o.name not in ('fn_diagramobjects', 'sp_alterdiagram', 'sp_creatediagram', 'sp_dropdiagram', 'sp_helpdiagramdefinition', 'sp_helpdiagrams', 'sp_renamediagram', 'sp_upgraddiagrams', 'sysdiagrams')
) t
group by t.name, t.object_type
order by t.name