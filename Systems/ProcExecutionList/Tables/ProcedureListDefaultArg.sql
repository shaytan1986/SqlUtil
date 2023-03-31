use Admin
go
set nocount on
go
/**********************************************************
* TABLE: px.ProcedureListDefaultArg
* Creator:		TRIO\GTower
* Created:		3/30/2023 4:39 PM
* Notes:
	Default arguments which will be applied at a level even more generic than that of Global @Args provided to ExecuteProcedureList

    NOTE: As of 2023-03-30, this table is NOT hooked up to anything. If we decide we need this, we'll need to add something
        similar to what we do for @Args in ExecuteProcedureList
* Sample Usage:

	select top 100 * 
	from [px].[ProcedureListDefaultArg]

* Modifications:
User			Date		Comment
----------------------------------------------------------

**********************************************************/
drop table if exists [px].[ProcedureListDefaultArg]
go
create table [px].[ProcedureListDefaultArg]
(
    ProcedureListDefaultArgSK int identity(1,1) not null, 
	ProcedureListSK int not null,
    DatabaseName varchar(128) null,
    SchemaName varchar(128) null,
    ProcedureName varchar(128) null,
    ExecutionOrder int null,
    ParamName nvarchar(128) not null,
    ParamValue nvarchar(4000) null,
    InsertDateUtc datetime2(0) not null constraint DF__px_ProcedureListDefaultArg__InsertDateUtc default sysutcdatetime(),
    UpdateDateUtc datetime2(0) not null constraint DF__px_ProcedureListDefaultArg__UpdateDateUtc default sysutcdatetime()
    constraint PKC__px_ProcedureListDefaultArg__ProcedureListDefaultArgSK primary key clustered (ProcedureListDefaultArgSK) 
        with (data_compression = none)
)

go

/*****************************
Foreign Key: 
    px.ProcedureListDefaultArg > px.ProcedureList
*****************************/
if not exists 
(
	select 1
    from sys.indexes
    where name = 'IXN__px_ProcedureListDefaultArg__ProcedureListSK'
		and [object_id] = object_id('px.ProcedureListDefaultArg')
)
begin
    create nonclustered index IXN__px_ProcedureListDefaultArg__ProcedureListSK
        on px.ProcedureListDefaultArg (ProcedureListSK)
        with (data_compression = none, maxdop = 4, online = off)
end
go

if not exists 
(
	select 1
    from sys.foreign_keys
    where parent_object_id = object_id('px.ProcedureListDefaultArg')
		and name = 'FK__px_ProcedureListDefaultArg__px_ProcedureList__ProcedureListSK'
)
begin
    alter table px.ProcedureListDefaultArg
		add constraint FK__px_ProcedureListDefaultArg__px_ProcedureList__ProcedureListSK
		foreign key (ProcedureListSK) references px.ProcedureList (ProcedureListSK)
end
go