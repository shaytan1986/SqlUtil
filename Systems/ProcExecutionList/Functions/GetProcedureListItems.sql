go
/*****************************
INLINE TABLE-VALUED FUNCTION: px.GetProcedureListItems

select 
    a.HomeDatabase, 
    ProcedureListName = a.Name, 
    b.*
from px.ProcedureList a
cross apply px.GetProcedureListItems(a.HomeDatabase, a.Name) b
order by a.ProcedureListSK, b.ItemExecutionOrder
*****************************/
create or alter function px.GetProcedureListItems
(
    @HomeDatabase nvarchar(128),
    @ProcedureListName nvarchar(128)
)
returns table
as
return
(
    select 
        ProcedureListSK = l.ProcedureListSK,
        ProcedureListSystemName = l.SystemName,
        ProcedureListSystemTag = l.SystemTag,
        ProcedureListItemSK = i.ProcedureListItemSK,
        ItemExecutionOrder = i.ExecutionOrder,
        ItemDatabaseName = i.DatabaseName,
        ItemSchemaName = i.SchemaName,
        ItemProcedureName = i.ProcedureName
    from px.ProcedureList l
    inner join px.ProcedureListItem i
        on l.ProcedureListSK = i.ProcedureListSK
    where l.HomeDatabase = @HomeDatabase
        and l.Name = @ProcedureListName
)

go

