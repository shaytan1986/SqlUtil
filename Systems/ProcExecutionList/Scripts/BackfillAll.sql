use Admin
go
set nocount on
go

drop table if exists #Items
create table #Items
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

drop table if exists #Lists
create table #Lists
(
    SourceDatabase nvarchar(128) not null,
    SourceSchema nvarchar(128) not null,
    SourceTable nvarchar(128) not null,
    HomeDatabase nvarchar(128) not null,
    Name nvarchar(128) not null,
    Description nvarchar(4000) not null,
    SystemName varchar(100) not null,
    SystemTag varchar(100) not null
)
go

/*****************************
Lists
*****************************/
insert into #Lists
(
    SourceDatabase,
    SourceSchema,
    SourceTable,
    HomeDatabase,
    Name,
    Description,
    SystemName,
    SystemTag
)
select
    SourceDatabase = 'OMOP',
    SourceSchema = 'Mdx',
    SourceTable = 'ProcedureList',
    HomeDatabase = 'OMOP',
    Name = 'PopulateOMOPFromRar',
    Description = 'Run workoffs to transform MDX Rar data into OMOP',
    SystemName = 'MDX',
    SystemTag = 'OMOPLoad'
union all
select
    SourceDatabase = 'OMOP',
    SourceSchema = 'Mdx',
    SourceTable = 'TrioOMOPProcedureList',
    HomeDatabase = 'OMOP',
    Name = 'PopulateTrioOMOPFromCore',
    Description = 'Run workoffs to transform MDC Core data into TrioOMOP',
    SystemName = 'MDX',
    SystemTag = 'TrioOMOPLoad'
union all
select
    SourceDatabase = 'TrioOMOP',
    SourceSchema = 'Mdx',
    SourceTable = 'ProcedureList',
    HomeDatabase = 'TrioOMOP',
    Name = 'PopulateTrioOMOPFromCore',
    Description = 'Run workoffs to transform MDX Core data into TrioOMOP',
    SystemName = 'MDX',
    SystemTag = 'TrioOMOPLoad'
union all
select
    SourceDatabase = 'TrioOMOP',
    SourceSchema = 'Mdx',
    SourceTable = 'TrioOMOPProcedureList',
    HomeDatabase = 'TrioOMOP',
    Name = 'PopulateTrioOMOPDerivedTables',
    Description = 'Run workoffs to generate some derived tables off of a mist of existing TrioOMOP data and MDX',
    SystemName = 'MDX',
    SystemTag = 'TrioOMOPLoad'
union all
select
    SourceDatabase = 'StageOMOP',
    SourceSchema = 'Mdx',
    SourceTable = 'ETLProcedureGroup',
    HomeDatabase = 'StageOMOP',
    Name = Name,
    Description = Description,
    SystemName = 'OMOP',
    SystemTag =
        case Name
            when 'MigrateOMOPToTrioOMOP' then 'MirthInsert'
            when 'MigrateStageOMOPToStageOMOPWork' then 'StageOMOPLoad'
            when 'MigrateStageOMOPWorkToOMOP' then 'OMOPLoad'
            when 'StartMirth' then 'MirthInsert'
            when 'StopMirth' then 'MirthInsert'
            when 'UpdateStageOMOPConcepts' then 'StageOMOPLoad'
        end
from
(     
    select 
        Name = 
            case ETLProcedureGroupName
                when 'Migrate OMOP to TrioOMOP' then 'MigrateOMOPToTrioOMOP'
                when 'Migrate StageOMOP to StageOMOPWork' then 'MigrateStageOMOPToStageOMOPWork'
                when 'Migrate StageOMOPWork to OMOP' then 'MigrateStageOMOPWorkToOMOP'
                when 'Start Mirth' then 'StartMirth'
                when 'Stop Mirth' then 'StopMirth'
                when 'Update/Add Concept IDs in StageOMOP' then 'UpdateStageOMOPConcepts'
            end,
        Description = ETLProcedureGroupName
    from StageOMOP.Mdx.ETLProcedureGroup
) a
union all
select
    SourceDatabase = 'Portal',
    SourceSchema = 'Form',
    SourceTable = 'FormProcedure',
    HomeDatabase = 'Portal',
    Name = 'GenerateNewForms',
    Description = 'Run all procedures which generate form data, as well as any derivative measures based thereon',
    SystemName = 'Portal',
    SystemTag = 'Forms'
union all
select
    SourceDatabase = 'Augmedix',
    SourceSchema = 'Form',
    SourceTable = 'FormProcedure',
    HomeDatabase = 'Augmedix',
    Name = 'GenerateNewForms',
    Description = 'Run all procedures which generate form data, as well as any derivative measures based thereon',
    SystemName = 'Augmedix',
    SystemTag = 'Forms'
union all
select
    SourceDatabase = 'Mdx',
    SourceSchema = 'Core',
    SourceTable = 'ScrubProcedure',
    HomeDatabase = 'Mdx',
    Name = 'ScrubData',
    Description = 'Run all Scrub procedures in MDX to clean up data',
    SystemName = 'Mdx',
    SystemTag = 'Scrub'


insert into Admin.px.ProcedureList
(
    HomeDatabase,
    Name,
    Description,
    SystemName,
    SystemTag
)
select
    s.HomeDatabase,
    s.Name,
    s.Description,
    s.SystemName,
    s.SystemTag    
from #Lists s
left outer join Admin.px.ProcedureList t
    on s.HomeDatabase = t.HomeDatabase
        and s.Name = t.Name
where t.HomeDatabase is null

/*****************************
Items
*****************************/

insert into #Items
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
from #Items i
inner join Admin.px.ProcedureList l    
    on i.HomeDatabase = l.HomeDatabase
        and i.ProcedureListName = l.Name
left outer join Admin.px.ProcedureListItem t
    on l.ProcedureListSK = t.ProcedureListSK
        and i.ExecutionOrder = t.ExecutionOrder
where t.ProcedureListSK is null