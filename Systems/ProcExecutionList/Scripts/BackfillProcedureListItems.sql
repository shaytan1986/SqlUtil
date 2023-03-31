use Admin
go
set nocount on
go

drop table if exists ##Items
create table ##Items
(
    SourceDatabase nvarchar(128) not null,
    SourceSchema nvarchar(128) not null,
    SourceTable nvarchar(128) not null,
    HomeDatabase nvarchar(128) not null,
    ProcedureListName nvarchar(128) not null,
    ExecutionOrder int not null,
    DatabaseName nvarchar(128) not null,
    SchemaName nvarchar(128) not null,
    ProcedureName nvarchar(128) not null,
    IsEnabled bit not null
)

go

insert into ##Items
(
    SourceDatabase,
    SourceSchema,
    SourceTable,
    HomeDatabase,
    ProcedureListName,
    ExecutionOrder,
    DatabaseName,
    SchemaName,
    ProcedureName,
    IsEnabled
)
select
    SourceDatabase = 'Augmedix',
    SourceSchema = 'Form',
    SourceTable = 'FormProcedure',
    HomeDatabase = 'Augmedix',
    ProcedureListName = 'GenerateNewForms',
    ExecutionOrder = FormProcedureOrder,
    DatabaseName = 'Augmedix',
    SchemaName = parsename(FormProcedureName, 2),
    ProcedureName = parsename(FormProcedureName, 1),
    IsEnabled = FormProcedureEnabled
from Augmedix.Form.FormProcedure
union all
select
    SourceDatabase = 'Augmedix',
    SourceSchema = 'Reporting',
    SourceTable = 'DownloadProcedure',
    HomeDatabase = 'Augmedix',
    ProcedureListName = 'ReportingDownloadProcedures',
    ExecutionOrder = DownloadProcedureSK,
    DatabaseName = 'Augmedix',
    SchemaName = parsename(DownloadProcedureName, 2),
    ProcedureName = parsename(DownloadProcedureName, 1),
    IsEnabled = DownloadProcedureEnabled
from Augmedix.Reporting.DownloadProcedure
union all
select
    SourceDatabase = 'Mdx',
    SourceSchema = 'Core',
    SourceTable = 'ScrubProcedure',
    HomeDatabase = 'Mdx',
    ProcedureListName = 'ScrubData',
    ExecutionOrder = ScrubProcedureOrder,
    DatabaseName = 'Mdx',
    SchemaName = parsename(ScrubProcedureName, 2),
    ProcedureName = parsename(ScrubProcedureName, 1),
    IsEnabled = ScrubProcedureEnabled
from Mdx.Core.ScrubProcedure
union all
select
    SourceDatabase = 'Mdx',
    SourceSchema = 'Rar',
    SourceTable = 'ProcedureList',
    HomeDatabase = 'OMOP',
    ProcedureListName = 'PopulateOMOPFromRar',
    ExecutionOrder = ProcedureListOrder,
    DatabaseName = 'Mdx',
    SchemaName = 'Rar',
    ProcedureName = ProcedureListName,
    IsEnabled = ProcedureListEnabled
from OMOP.Mdx.ProcedureList
union all
select
    SourceDatabase = 'OMOP',
    SourceSchema = 'Mdx',
    SourceTable = 'TrioOMOPProcedureList',
    HomeDatabase = 'OMOP',
    ProcedureListName = 'PopulateTrioOMOPFromCore',
    ExecutionOrder = ProcedureListOrder,
    DatabasesName = 'Mdx',
    SchemaName = 'Core',
    ProcedureName = ProcedureListName,
    IsEnabled = ProcedureListEnabled
from OMOP.Mdx.TrioOMOPProcedureList
union all
select
    SourceDatabase = 'Portal',
    SourceSchema = 'Form',
    SourceTable = 'FormProcedure',
    HomeDatabase = 'Portal',
    ProcedureListName = 'GenerateNewForms',
    ExecutionOrder = FormProcedureOrder,
    DatabaseName = 'Portal',
    SchemaName = parsename(FormProcedureName, 2),
    ProcedureName = parsename(FormProcedureName, 1),
    IsEnabled = FormProcedureEnabled
from Portal.Form.FormProcedure
union all
select
    SourceDatabase = 'Portal',
    SourceSchema = 'Reporting',
    SourceTable = 'DownloadProcedure',
    HomeDatabase = 'Portal',
    ProcedureListName = 'ReportingDownloadProcedures',
    ExecutionOrder = DownloadProcedureSK,
    DatabaseName = 'Portal',
    SchemaName = parsename(DownloadProcedureName, 2),
    ProcedureName = parsename(DownloadProcedureName, 1),
    IsEnabled = DownloadProcedureEnabled
from Portal.Reporting.DownloadProcedure
union all
select
    SourceDatabase = 'StageOMOP',
    SourceSchema = 'Mdx',
    SourceTable = 'ETLProcedureList',
    HomeDatabase = 'StageOMOP',
    ProcedureListName =
        case g.ETLProcedureGroupName
            when 'Migrate OMOP to TrioOMOP' then 'MigrateOMOPToTrioOMOP'
            when 'Migrate StageOMOP to StageOMOPWork' then 'MigrateStageOMOPToStageOMOPWork'
            when 'Migrate StageOMOPWork to OMOP' then 'MigrateStageOMOPWorkToOMOP'
            when 'Start Mirth' then 'StartMirth'
            when 'Stop Mirth' then 'StopMirth'
            when 'Update/Add Concept IDs in StageOMOP' then 'UpdateStageOMOPConcepts'
        end,
    ExecutionOrder = l.ExecutionOrder,
    DatabaseName = l.ETLProcedureDatabase,
    SchemaName = l.ETLProcedureSchema,
    ProcedureName = l.ETLProcedureName,
    IsEnabled = l.IsActive
from StageOMOP.Mdx.ETLProcedureList l
inner join StageOMOP.Mdx.ETLProcedureGroup g
    on l.ETLProcedureGroupID = g.ETLProcedureGroupID
union all
select
    SourceDatabase = 'TrioOMOP',
    SourceSchema = 'Mdx',
    SourceTable = 'ProcedureList',
    HomeDatabase = 'TrioOMOP',
    ProcedureListName = 'PopulateTrioOMOPFromCore',
    ExecutionOrder = ProcedureListOrder,
    DatabaseName = 'Mdx',
    SchemaName = 'Core',
    ProcedureName = ProcedureListName,
    IsEnabled = ProcedureListEnabled    
from TrioOMOP.Mdx.ProcedureList
union all
select
    SourceDatabase = 'TrioOMOP',
    SourceSchema = 'Mdx',
    SourceTable = 'TrioOMOPProcedureList',
    HomeDatabase = 'TrioOMOP',
    ProcedureListName = 'PopulateTrioOMOPDerivedTables',
    ExecutionOrder = ProcedureListOrder,
    DatabaseName = 'TrioOMOP',
    SchemaName = parsename(ProcedureListName, 2),
    ProcedureName = parsename(ProcedureListName, 1),
    IsEnabled = ProcedureListEnabled    
from TrioOMOP.Mdx.TrioOMOPProcedureList

insert into Admin.px.ProcedureListItem
(
    ProcedureListSK,
    ExecutionOrder,
    DatabaseName,
    SchemaName,
    ProcedureName,
    IsEnabled
)
select
    ProcedureListSK = l.ProcedureListSK,
    ExecutionOrder = i.ExecutionOrder,
    DatabaseName = i.DatabaseName,
    SchemaName = i.SchemaName,
    ProcedureName = i.ProcedureName,
    IsEnabled = i.IsEnabled
from ##Items i
inner join Admin.px.ProcedureList l    
    on i.HomeDatabase = l.HomeDatabase
        and i.ProcedureListName = l.Name
left outer join Admin.px.ProcedureListItem t
    on l.ProcedureListSK = t.ProcedureListSK
        and i.ExecutionOrder = t.ExecutionOrder
where t.ProcedureListSK is null