use Admin
go
set nocount on
go

/*****************************
Execute Procedure List
*****************************/
/*****************************
Parameters
*****************************/
declare
    @HomeDatabase nvarchar(128) = 'Portal',
    @ProcedureListName nvarchar(128) = 'PopulateClinicalProtocols',
    @ThrowExceptions bit = 1,
    @Log bit = 1

/*****************************
Body
*****************************/
declare
    @ProcedureListSK int,
    @Msg nvarchar(max),
    @SQL nvarchar(max),
    @PLSystemName varchar(100),
    @PLSystemTag varchar(100),
    @ProcedureListExecutionSK bigint,
    @ProcedureListItemSK int,
    @ExecutionOrder int,
    @DatabaseName nvarchar(128),
    @SchemaName nvarchar(128),
    @ProcedureName nvarchar(128),
    @ProcedureListExecutionItemSK bigint

select
    @ProcedureListSK = ProcedureListSK,
    @PLSystemName = SystemName,
    @PLSystemTag = SystemTag
from px.ProcedureList
where HomeDatabase = @HomeDatabase
    and Name = @ProcedureListName

drop table if exists #Items
create table #Items
(
    ProcedureListItemSK int not null,
    ExecutionOrder int not null,
    DatabaseName nvarchar(128) not null,
    SchemaName nvarchar(128) not null,
    ProcedureName nvarchar(128) not null
)

insert into #Items
(
    ProcedureListItemSK,
    ExecutionOrder,
    DatabaseName,
    SchemaName,
    ProcedureName
)
select
    ProcedureListItemSK,
    ExecutionOrder,
    DatabaseName,
    SchemaName,
    ProcedureName
from px.ProcedureListItem pli
where ProcedureListSK = @ProcedureListSK

select @Msg = 
    (
        select
            HomeDatabase = @HomeDatabase,
            ProcedureListName = @ProcedureListName,
            ProcedureListSK = @ProcedureListSK
        for json path, without_array_wrapper
    )

raiserror(@Msg, 0, 1) with nowait

declare
    @qThreePartName nvarchar(518),
    @ProcedureId int

/*****************************
Start Execution
*****************************/
begin try

    if @Log = 1
    begin
        insert into px.ProcedureListExecution (ProcedureListSK)
        select ProcedureListSK = @ProcedureListSK

        select @ProcedureListExecutionSK = scope_identity()
    end
    
    declare c cursor local fast_forward for
        select
            ProcedureListItemSK,
            ExecutionOrder,
            DatabaseName,
            SchemaName,
            ProcedureName
        from #Items
        order by ExecutionOrder
    open c

    fetch next from c into
        @ProcedureListItemSK,
        @ExecutionOrder,
        @DatabaseName,
        @SchemaName,
        @ProcedureName

    while @@fetch_status = 0
    begin

        if @Log = 1
        begin
            insert into px.ProcedureListExecutionItem
            (
                ProcedureListExecutionSK,
                ProcedureListItemSK
            )
            select
                ProcedureListExecutionSK = @ProcedureListExecutionSK,
                ProcedureListItemSK = @ProcedureListItemSK

            select @ProcedureListExecutionItemSK = scope_identity()
        end

        select 
            @qThreePartName = concat(quotename(@DatabaseName), '.', quotename(@SchemaName), '.', quotename(@ProcedureName)),
            @ProcedureId = object_id(@qThreePartName)
        
        select @SQL = concat('exec ', @qThreePartName)

        exec sp_executesql @SQL

        update px.ProcedureListExecutionItem
        set EndDateUtc = sysutcdatetime()
        where ProcedureListExecutionItemSK = @ProcedureListExecutionItemSK

        fetch next from c into
            @ProcedureListItemSK,
            @ExecutionOrder,
            @DatabaseName,
            @SchemaName,
            @ProcedureName

    end

    deallocate c

    update px.ProcedureListExecution
    set EndDateUtc = sysutcdatetime()
    where ProcedureListExecutionSK = @ProcedureListExecutionSK


end try
begin catch

    if exists
    (
        select 1
        from px.ProcedureListExecutionItem
        where ProcedureListExecutionItemSK = @ProcedureListExecutionItemSK
            and IsComplete = 0
    )
    begin

        update px.ProcedureListExecutionItem
        set EndDateUtc = sysutcdatetime(),
            ErrorMessage = error_message()
        where ProcedureListExecutionItemSK = @ProcedureListExecutionItemSK

    end

    update px.ProcedureListExecution
    set EndDateUtc = sysutcdatetime(),
        ErrorMessage = error_message()
    where ProcedureListExecutionSK = @ProcedureListExecutionSK

    if @ThrowExceptions = 1
        throw

end catch