use Admin
go
set nocount on
go


/**********************************************************
* TABLE: px.ProcedureListExecutionItem
* Creator:		TRIO\GTower
* Created:		3/28/2023 10:11 AM
* Notes:
	Logs information about specific components of a ProcedureListExecution
* Sample Usage:

	select top 100 * 
	from [px].[ProcedureListExecutionItem]

* Modifications:
User			Date		Comment
----------------------------------------------------------

**********************************************************/
if object_id('px.ProcedureListExecutionItem') is null
begin
    create table [px].[ProcedureListExecutionItem]
    (
        ProcedureListExecutionItemSK bigint identity(1,1) not null, 
        ProcedureListExecutionSK bigint not null,
        ProcedureListItemSK int not null ,
        StartDateUtc datetime2(7) not null constraint DF__px_ProcedureListExecutionItem__StartDateUtc default sysutcdatetime(),
        EndDateUtc datetime2(7) null,
        ErrorMessage nvarchar(4000) null,
        IsComplete as convert(bit, iif(EndDateUtc is not null, 1, 0)),
        IsError as convert
            (
                bit, 
                case
                    when EndDateUtc is null then null
                    when ErrorMessage is null then 0
                    else 1
                end
            ),
        ExecutionStatement nvarchar(max) null
        constraint PKC__px_ProcedureListExecutionItem__ProcedureListExecutionItemSK primary key clustered (ProcedureListExecutionItemSK) 
            with (data_compression = none)
    )
end
go

/*****************************
Foreign Key: 
    px.ProcedureListExecutionItem > px.ProcedureListItem
*****************************/
if not exists 
(
	select 1
    from sys.indexes
    where name = 'IXN__px_ProcedureListExecutionItem__ProcedureListItemSK'
		and [object_id] = object_id('px.ProcedureListExecutionItem')
)
begin
    create nonclustered index IXN__px_ProcedureListExecutionItem__ProcedureListItemSK
        on px.ProcedureListExecutionItem (ProcedureListItemSK)
        with (data_compression = none, maxdop = 4, online = off)
end
go

if not exists 
(
	select 1
    from sys.foreign_keys
    where parent_object_id = object_id('px.ProcedureListExecutionItem')
		and name = 'FK__px_ProcedureListExecutionItem__px_ProcedureListItem__ProcedureListItemSK'
)
begin
    alter table px.ProcedureListExecutionItem
		add constraint FK__px_ProcedureListExecutionItem__px_ProcedureListItem__ProcedureListItemSK
		foreign key (ProcedureListItemSK) references px.ProcedureListItem (ProcedureListItemSK)
        on delete cascade
end
go