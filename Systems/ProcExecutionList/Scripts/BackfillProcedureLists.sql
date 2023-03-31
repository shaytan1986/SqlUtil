use Admin
go
set nocount on
go


drop table if exists ##Lists
create table ##Lists
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
insert into ##Lists
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
    SourceSchema = 'Reporting',
    SourceTable = 'DownloadProcedure',
    HomeDatabase = 'Portal',
    Name = 'ReportingDownloadProcedures',
    Description = 'Reporting Download Procedures',
    SystemName = 'Portal',
    SystemTag = 'Reporting'
union all
select
    SourceDatabase = 'Augmedix',
    SourceSchema = 'Reporting',
    SourceTable = 'DownloadProcedure',
    HomeDatabase = 'Augmedix',
    Name = 'ReportingDownloadProcedures',
    Description = 'Reporting Download Procedures',
    SystemName = 'Augmedix',
    SystemTag = 'Reporting'
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
from ##Lists s
left outer join Admin.px.ProcedureList t
    on s.HomeDatabase = t.HomeDatabase
        and s.Name = t.Name
where t.HomeDatabase is null