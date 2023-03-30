use Admin
go
set nocount on
go
/**********************************************************
* TABLE: px.ProcedureListExecutionArg
* Creator:		TRIO\GTower
* Created:		3/30/2023 9:53 AM
* Notes:
	Logs the literal values passed in to the execution
* Sample Usage:

	select top 100 * 
	from [px].[ProcedureListExecutionArg]

* Modifications:
User			Date		Comment
----------------------------------------------------------

**********************************************************/
if object_id('px.ProcedureListExecutionArg') is null
begin
    create table [px].[ProcedureListExecutionArg]
    (
        ProcedureListExecutionArgSK bigint identity(1,1) not null, 
	    ProcedureListExecutionSK bigint not null,
        DatabaseName varchar(128) null,
        SchemaName varchar(128) null,
        ProcedureName varchar(128) null,
        ExecutionOrder int null,
        ParamName nvarchar(128) not null,
        ParamValue nvarchar(4000) null
        constraint PKC__px_ProcedureListExecutionArg__ProcedureListExecutionArgSK primary key clustered (ProcedureListExecutionArgSK) 
            with (data_compression = page)
    )
end
go

/*****************************
Foreign Key: 
    px.ProcedureListExecutionArg > px.ProcedureListExecution
*****************************/
if not exists 
(
	select 1
    from sys.indexes
    where name = 'IXN__px_ProcedureListExecutionArg__ProcedureListExecutionSK'
		and [object_id] = object_id('px.ProcedureListExecutionArg')
)
begin
    create nonclustered index IXN__px_ProcedureListExecutionArg__ProcedureListExecutionSK
        on px.ProcedureListExecutionArg (ProcedureListExecutionSK)
        with (data_compression = page, maxdop = 4, online = off)
end
go

if not exists 
(
	select 1
    from sys.foreign_keys
    where parent_object_id = object_id('px.ProcedureListExecutionArg')
		and name = 'FK__px_ProcedureListExecutionArg__px_ProcedureListExecution__ProcedureListExecutionSK'
)
begin
    alter table px.ProcedureListExecutionArg
		add constraint FK__px_ProcedureListExecutionArg__px_ProcedureListExecution__ProcedureListExecutionSK
		foreign key (ProcedureListExecutionSK) references px.ProcedureListExecution (ProcedureListExecutionSK)
end
go