use Admin
go
set nocount on
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
    select 1, 'OMOP', 'dbo', 'Procedure1' union all
    select 2, 'Portal', 'dbo', 'CreateClinicalProtocolForms' union all
    select 3, 'Portal', 'dbo', 'CreateClinicalProtocolForms'
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

