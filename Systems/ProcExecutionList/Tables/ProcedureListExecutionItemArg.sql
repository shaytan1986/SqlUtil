use Admin
go
set nocount on
go

/**********************************************************
* TABLE: px.ProcedureListExecutionItemArg
* Creator:		TRIO\GTower
* Created:		3/30/2023 9:53 AM
* Notes:
	
* Sample Usage:
    Logs the interpreted value provided to the execution after application of hierarchical rules
	select top 100 * 
	from [px].[ProcedureListExecutionItemArg]

* Modifications:
User			Date		Comment
----------------------------------------------------------

**********************************************************/
if object_id('px.ProcedureListExecutionItemArg') is null
begin
    create table [px].[ProcedureListExecutionItemArg]
    (
        ProcedureListExecutionItemArgK bigint identity(1,1) not null,
        ProcedureListExecutionItemSK bigint not null,
        ParamName nvarchar(128) not null,
        ParamValue nvarchar(4000) null
        constraint PKC__px_ProcedureListExecutionItemArg__ProcedureListExecutionItemArgK primary key clustered (ProcedureListExecutionItemArgK) 
            with (data_compression = none)
    )
end
go

/*****************************
Foreign Key: 
    px.ProcedureListExecutionItemArg > px.ProcedureListExecutionItem
*****************************/
if not exists 
(
	select 1
    from sys.indexes
    where name = 'IXN__px_ProcedureListExecutionItemArg__ProcedureListExecutionItemSK'
		and [object_id] = object_id('px.ProcedureListExecutionItemArg')
)
begin
    create nonclustered index IXN__px_ProcedureListExecutionItemArg__ProcedureListExecutionItemSK
        on px.ProcedureListExecutionItemArg (ProcedureListExecutionItemSK)
        with (data_compression = page, maxdop = 4, online = off)
end
go

if not exists 
(
	select 1
    from sys.foreign_keys
    where parent_object_id = object_id('px.ProcedureListExecutionItemArg')
		and name = 'FK__px_ProcedureListExecutionItemArg__px_ProcedureListExecutionItem__ProcedureListExecutionItemSK'
)
begin
    alter table px.ProcedureListExecutionItemArg
		add constraint FK__px_ProcedureListExecutionItemArg__px_ProcedureListExecutionItem__ProcedureListExecutionItemSK
		foreign key (ProcedureListExecutionItemSK) references px.ProcedureListExecutionItem (ProcedureListExecutionItemSK)
end
go