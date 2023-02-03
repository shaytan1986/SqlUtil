use util
go
set nocount, xact_abort on
go

/**********************************************************
* VIEW: dbo.vProcExecutionListItem
* Creator:      TRIO\GTower
* Created:      11/15/2022 2:02 PM
* Notes:	
    

	select top 1000 *
    from dbo.vProcExecutionListItem

    --use omopvocab
    --create proc dbo.VisitHelper
    --    @SystemName nvarchar(128),
    --    @SystemTag nvarchar(128),
    --    @DoStuff bit
    --as
    --begin
    --select 1
    --end

  --use ECW
  --  create proc dbo.LoadOMOPVocab
  --      @SystemName nvarchar(128),
  --      @SystemTag nvarchar(128),
  --      @DoStuff bit
  --  as
  --  begin
  --  select 1
  --  end

* Sample Usage:

	select top 1000 *
    from dbo.vProcExecutionListItem

* Modifications
User            Date        Comment
-----------------------------------------------------------

**********************************************************/
create or alter view dbo.vProcExecutionListItem
as

with a as
(
    select
        ProcExecutionListSK = l.ProcExecutionListSK,
        ProcExecutionListName = l.Name,
        ProcExecutionListLabel = l.Label,
        ProcExecutionListDescription = l.Description,
        ProcExecutionListSystemName = l.SystemName,
        ProcExecutionListSystemTag = l.SystemTag,
        ProcExecutionListItemSK = i.ProcExecutionListItemSK,
        ItemDatabaseName = i.DatabaseName,
        ItemSchemaName = i.SchemaName,
        ItemProcName = i.ProcName,
        ItemExecOrder = i.ExecOrder,
        qThreePartName = concat
            (
                quotename(i.DatabaseName),
                '.',
                quotename(i.SchemaName),
                '.',
                quotename(i.ProcName)
            )
    from dbo.ProcExecutionListItem i
    inner join dbo.ProcExecutionList l
        on i.ProcExecutionListSK = l.ProcExecutionListSK
)
select
    ProcExecutionListSK,
    ProcExecutionListName,
    ProcExecutionListLabel,
    ProcExecutionListDescription,
    ProcExecutionListSystemName,
    ProcExecutionListSystemTag,
    ProcExecutionListItemSK,
    ItemDatabaseName,
    ItemSchemaName,
    ItemProcName,
    ItemExecOrder,
    qThreePartName,
    ObjectId = object_id(qThreePartName)
from a

go


