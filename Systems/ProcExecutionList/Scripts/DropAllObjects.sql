use Admin
go
set nocount on
go

/**********************************************************
* SCRIPT:       Drop PX Objects
* Creator:      TRIO\GTower
* Created:      3/30/2023 3:13 PM
* Notes:	
	You can run this if you need to nuke an existing instance of the Proc Execution framework (like, to rebuild it after a breaking change)

    There are some FK things to consider, but the easiest way to deal with it is just run this till everything is dropped

* Modifications
User            Date        Comment
-----------------------------------------------------------

**********************************************************/
declare @Objects table
(
    Name nvarchar(128) not null,
    ObjectType nvarchar(128) not null
)

;with src as
(
    select 
        Name,
        ObjectType = 
            case 
                when type_desc like '%func%' then 'function'
                when type_desc like '%view%' then 'view'
                when type_desc like '%proc%' then 'procedure'
                when type_desc like '%table%' then 'table'
            end
    from sys.objects
    where schema_id = schema_id('px')
        and parent_object_id = 0
)
insert into @Objects
(
    Name,
    ObjectType
)
select Name, ObjectType
from src
union all
select Name, ObjectType = 'type'
from sys.types
where schema_id = schema_id('px')


declare @Sql nvarchar(max)
declare c cursor local fast_forward for
    select concat('drop ', ObjectType, ' if exists px.', quotename(Name))
    from @Objects
    order by 
        case ObjectType
            when 'procedure' then 0
            when 'view' then 1
            when 'table' then 2
            when 'function' then 3
            when 'type' then 4
            else 5
        end
open c

fetch next from c into @Sql

while @@fetch_status = 0
begin

    print @sql

    
    fetch next from c into @Sql

end

deallocate c