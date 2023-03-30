use admin
go
set nocount, xact_abort on
go

/**********************************************************
* VIEW: px.vProcedureListItem
* Creator:      TRIO\GTower
* Created:      3/29/2023 1:56 PM
* Notes:	
    

* Sample Usage:

	select top 1000 *
    from px.vProcedureListItem

* Modifications
User            Date        Comment
-----------------------------------------------------------

**********************************************************/
create or alter view px.vProcedureListItem
as

select
    ProcedureListSK = pl.ProcedureListSK,
    ListHomeDatabase = HomeDatabase,
    ListName = Name,
    ListSystemName = SystemName,
    ListSystemTag = SystemTag,
    ProcedureListItemSK = pli.ProcedureListItemSK,
    ItemExecutionOrder = pli.ExecutionOrder,
    ItemDatabaseName = pli.DatabaseName,
    ItemSchemaName = pli.SchemaName,
    ItemProcedureName = pli.ProcedureName
from px.ProcedureList pl
inner join px.ProcedureListItem pli
    on pl.ProcedureListSK = pli.ProcedureListSK

go