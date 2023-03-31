use Admin
go
set nocount on
go

/**********************************************************
* TABLE: px.ProcedureList
* Creator:		TRIO\GTower
* Created:		3/27/2023 3:09 PM
* Notes:
	notes
* Sample Usage:

	select top 100 * 
	from [px].[ProcedureList]

* Modifications:
User			Date		Comment
----------------------------------------------------------

**********************************************************/
if object_id('px.ProcedureList') is null
begin
    create table [px].[ProcedureList]
    (
        ProcedureListSK int identity(1,1) not null, 
        HomeDatabase nvarchar(128) not null, -- Documentation property, but gives some idea of where you imagine most of the Procedures or work is done for this list
        Name nvarchar(128) not null constraint CHK__px_ProcedureList_Name check (Name not like '% %'),
        Description nvarchar(4000) not null,    
        SystemName varchar(100) not null, -- If set, will be provided as the default
        SystemTag varchar(100) not null,
        InsertDateUtc datetime2(0) not null constraint DF__px_ProcedureList__InsertDateUtc default sysutcdatetime(),
        UpdateDateUtc datetime2(0) not null constraint DF__px_ProcedureList__UpdateDateUtc default sysutcdatetime(),
        IsEnabled bit not null constraint DF__px_ProcedureList__IsEnabled default 0
        constraint PKC__px_ProcedureList__ProcedureListSK primary key clustered (ProcedureListSK) 
            with (data_compression = none)
    )
end
if not exists 
(
	select 1
    from sys.indexes
    where name = 'IXNU__px_ProcedureList__HomeDatabase_Name'
		and [object_id] = object_id('px.ProcedureList')
)
begin
    create unique nonclustered index IXNU__px_ProcedureList__HomeDatabase_Name
        on px.ProcedureList (HomeDatabase, Name)
        with (data_compression = none, maxdop = 4, online = off)
        
    raiserror('Created Index: [IXNU__px_ProcedureList__HomeDatabase_Name] on [px].[ProcedureList]', 0, 1) with nowait
end
go

-- insert into px.ProcedureList 
-- (
--     Name,
--     Description,    
--     HomeDatabase,
--     SystemName,
--     SystemTag
-- )
-- select
--     s.Name,
--     s.Description,    
--     s.HomeDatabase,
--     s.SystemName,
--     s.SystemTag
-- from
-- (
--     values
--         ('PopulateClinicalProtocols', 'Physicians Opportunity Dashboard Clinical Protocol population procedures', 'Portal', 'POD', 'ClinicalProtocols'),
--         ('GeneratePortalForms', 'Procedures for generating forms, culminating in the execution of the Measure view population procedures', 'Portal', 'Forms', 'FormGeneration'),
--         ('TestList', 'Test list', 'Admin', 'ProcExecution', 'Testing')
-- ) s
-- (
--     Name,
--     Description,    
--     HomeDatabase,
--     SystemName,
--     SystemTag
-- )
-- left outer join px.ProcedureList t
--     on s.HomeDatabase = t.HomeDatabase
--         and s.Name = t.Name
-- where t.HomeDatabase is null
-- go
