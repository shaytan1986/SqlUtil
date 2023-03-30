use Admin
go
set nocount on
go

/**********************************************************
* TABLE: px.ProcedureListItem
* Creator:		TRIO\GTower
* Created:		3/28/2023 10:03 AM
* Notes:
	An individual procedure to be executed in a Procedure list
* Sample Usage:

	select top 100 * 
	from [px].[ProcedureListItem]

* Modifications:
User			Date		Comment
----------------------------------------------------------

**********************************************************/
if object_id('px.ProcedureListItem') is null
begin
    create table [px].[ProcedureListItem]
    (
        ProcedureListItemSK int identity(1,1) not null, 
        ProcedureListSK int not null,
        ExecutionOrder int not null,
        DatabaseName nvarchar(128) not null,
        SchemaName nvarchar(128) not null,
        ProcedureName nvarchar(128) not null,
        InsertDateUtc datetime2(0) not null constraint DF__px_ProcedureListItem__InsertDateUtc default sysutcdatetime(),
        UpdateDateUtc datetime2(0) not null constraint DF__px_ProcedureListItem__UpdateDateUtc default sysutcdatetime()
        constraint PKC__px_ProcedureListItem__ProcedureListItemSK primary key clustered (ProcedureListItemSK) 
            with (data_compression = none)
    )
end
go

if not exists 
(
	select 1
    from sys.indexes
    where name = 'IXNU__px_ProcedureListItem__ProcedureListSK_ExecutionOrder'
		and [object_id] = object_id('px.ProcedureListItem')
)
begin
    create unique nonclustered index IXNU__px_ProcedureListItem__ProcedureListSK_ExecutionOrder
        on px.ProcedureListItem (ProcedureListSK, ExecutionOrder)
        with (data_compression = none, maxdop = 4, online = off)
        
    raiserror('Created Index: [IXNU__px_ProcedureListItem__ProcedureListSK_ExecutionOrder] on [px].[ProcedureListItem]', 0, 1) with nowait
end
go

/*****************************
Foreign Key: 
    px.ProcedureListItem > px.ProcedureList
*****************************/
if not exists 
(
	select 1
    from sys.foreign_keys
    where parent_object_id = object_id('px.ProcedureListItem')
		and name = 'FK__px_ProcedureListItem__px_ProcedureList__ProcedureListSK'
)
begin
    alter table px.ProcedureListItem
		add constraint FK__px_ProcedureListItem__px_ProcedureList__ProcedureListSK
		foreign key (ProcedureListSK) references px.ProcedureList (ProcedureListSK)
        on delete cascade
end
go