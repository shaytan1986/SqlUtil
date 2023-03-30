use Admin
go
set nocount on
go

/**********************************************************
* TABLE: px.ExecutionConfig
* Creator:		TRIO\GTower
* Created:		3/28/2023 9:01 AM
* Notes:
	Object that ties together all the various things for the execution of a Procedure list
* Sample Usage:

	select top 100 * 
	from [px].[ExecutionConfig]

* Modifications:
User			Date		Comment
----------------------------------------------------------

**********************************************************/
if object_id('px.ExecutionConfig') is null
begin
    create table [px].[ExecutionConfig]
    (
        ExecutionConfigSK int identity(1,1) not null, 
        ProcedureListSK int not null,
        Name nvarchar(128) not null constraint CHK__px_ExecutionConfig__Name check (Name not like '% %'),
        IsDefault bit not null constraint DF__px_ExecutionConfig__IsDefault default 0,
        SystemName varchar(100) null,
        SystemTag varchar(100) null,
        Description varchar(8000) null,
        InsertDateUtc datetime2(0) not null constraint DF__px_ExecutionConfig__InsertDateUtc default sysutcdatetime(),
        UpdateDateUtc datetime2(0) not null constraint DF__px_ExecutionConfig__UpdateDateUtc default sysutcdatetime()
        constraint PKC__px_ExecutionConfig__ExecutionConfigSK primary key clustered (ExecutionConfigSK) 
            with (data_compression = none)
    )
end
go

/*****************************
Foreign Key: 
    px.ExecutionConfig > px.ProcedureList
*****************************/
if not exists 
(
	select 1
    from sys.indexes
    where name = 'IXNU__px_ExecutionConfig__ProcedureListSK_Name'
		and [object_id] = object_id('px.ExecutionConfig')
)
begin
    create unique nonclustered index IXNU__px_ExecutionConfig__ProcedureListSK_Name
        on px.ExecutionConfig (ProcedureListSK, Name)
        with (data_compression = none, maxdop = 4, online = off)
end
go

if not exists 
(
	select 1
    from sys.foreign_keys
    where parent_object_id = object_id('px.ExecutionConfig')
		and name = 'FK__px_ExecutionConfig__px_ProcedureList__ProcedureListSK'
)
begin
    alter table px.ExecutionConfig
		add constraint FK__px_ExecutionConfig__px_ProcedureList__ProcedureListSK
		foreign key (ProcedureListSK) references px.ProcedureList (ProcedureListSK)
end
go

if not exists 
(
	select 1
    from sys.indexes
    where name = 'IXNUF__px_ExecutionConfig__ProcedureListSK_IsDefault'
		and [object_id] = object_id('px.ExecutionConfig')
)
begin
    create unique nonclustered index IXNUF__px_ExecutionConfig__ProcedureListSK_IsDefault
        on px.ExecutionConfig (ProcedureListSK, IsDefault)
        where IsDefault = 1
        with (data_compression = none, maxdop = 4, online = off)
        
    raiserror('Created Index: [IXNUF__px_ExecutionConfig__ProcedureListSK_IsDefault] on [px].[ExecutionConfig]', 0, 1) with nowait
end
go