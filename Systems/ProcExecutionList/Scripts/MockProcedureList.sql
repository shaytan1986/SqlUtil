use Admin
go
set nocount on
go

drop proc if exists px.TestProc1
go
create procedure px.TestProc1
    @SystemName nvarchar(128),
    @SystemTag nvarchar(128)
as
begin
    return
end

drop proc if exists px.TestProc2
go
create procedure px.TestProc1
    @SystemName nvarchar(128),
    @SystemTag nvarchar(128)
as
begin
    return
end

go
if not exists
(
    select 1
    from Admin.px.ProcedureList
    where HomeDatabase = 'Admin'
        and Name = 'TestList'
)
begin
    insert into px.ProcedureList
    (
        
        Name,
        Description,
        HomeDatabase,
        SystemName,
        SystemTag
    )
    values
        ('TestList', 'Test list', 'Admin', 'ProcExecution', 'Testing')

end

declare @ProcedureListSK int = Admin.px.GetProcedureListSK('Admin', 'TestList')

delete px.ProcedureListItem
where ProcedureListSK = @ProcedureListSK

;with items
(
    ExecutionOrder,
    DatabaseName,
    SchemaName,
    ProcedureName
) as
(
    select 1, 'Admin', 'px', 'Proc1' union all
    select 2, 'Admin', 'px', 'Proc2' union all
    select 3, 'Admin', 'px', 'Proc2'
)
insert into px.ProcedureListItem
(
    ProcedureListSK,
    ExecutionOrder,
    DatabaseName,
    SchemaName,
    ProcedureName
)
select
    ProcedureListSK = @ProcedureListSK,
    ExecutionOrder,
    DatabaseName,
    SchemaName,
    ProcedureName
from items

select top 1000 *
from admin.px.ProcedureListItem

