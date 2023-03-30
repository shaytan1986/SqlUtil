use Admin
go
set nocount, xact_abort on
go
/**********************************************************
* PROCEDURE: px.AnalyzeProcedureListExecution
* Creator:      TRIO\GTower
* Created:      3/30/2023 11:14 AM
* Notes:
	Returns a bunch of data sets about proc executions. 
* Sample Usage

        -- Get most recent execution for the provided ProcedureList
	    declare 
            @HomeDatabase nvarchar(128) = 'Admin',
            @ProcedureListName nvarchar(128) = 'TestList'

		exec px.AnalyzeProcedureListExecution
            @HomeDatabase = @HomeDatabase,
            @ProcedureListName = @ProcedureListName

        -- Get a specific execution for the provided ProcedureListExecutionSK
        declare @ProcedureListExecutionSK bigint

        select top 1 @ProcedureListExecutionSk = x.ProcedureListExecutionSK
        from px.ProcedureListExecution x
        inner join px.ProcedureList pl
            on x.ProcedureListSK = pl.ProcedureListSK
                and pl.HomeDatabase = 'Admin'
                and pl.Name = 'TestList'

        exec px.AnalyzeProcedureListExecution
            @ProcedureListExecutionSK = @ProcedureListExecutionSK


        -- This will blow up on you
        exec px.AnalyzeProcedureListExecution
        



* Modifications
User            Date        Comment
-----------------------------------------------------------

**********************************************************/
create or alter procedure px.AnalyzeProcedureListExecution
	@HomeDatabase nvarchar(128) = null,
    @ProcedureListName nvarchar(128) = null,
    @ProcedureListExecutionSK bigint = null -- This takes priority over HomeDatabase/ProcedureListName
as
begin

    ---------------------------------------------
    -- declare variables
    ---------------------------------------------
    declare @Msg nvarchar(max)
    ---------------------------------------------
    -- create temp tables
    ---------------------------------------------

    ---------------------------------------------
    -- set session variables
    ---------------------------------------------
    set nocount, xact_abort on
    ---------------------------------------------
    -- body of stored procedure
    ---------------------------------------------
    /*****************************
    Get the ProcedureListExecutionSK
    *****************************/
    if @ProcedureListExecutionSK is null
    begin
        if (@HomeDatabase is null or @ProcedureListName is null)
        begin
            ;throw 50000, 'If @ProcedureListExecutionSK is null, you must provide both a @HomeDatabase and @ProcedureListName', 1
        end

        select top 1 @ProcedureListExecutionSK = x.ProcedureListExecutionSK
        from px.ProcedureListExecution x
        inner join px.ProcedureList pl
            on x.ProcedureListSK = pl.ProcedureListSK
                and pl.HomeDatabase = @HomeDatabase
                and pl.Name = @ProcedureListName
        order by x.StartDateUtc desc

    end

    if not exists
    (
        select 1
        from px.ProcedureListExecution
        where ProcedureListExecutionSK = @ProcedureListExecutionSK
    )
    begin
        select @msg = concat('Invalid ProcedureListExecutionSK: ', quotename(@ProcedureListExecutionSK, '"'))
        raiserror(@Msg, 0, 1) with nowait
        return
    end

    -- [0] Metrics of the top-level Procedure List
    select
        ProcedureListExecutionSK,
        ProcedureListSK,
        StartDateUtc,
        EndDateUtc,
        ErrorMessage,
        IsComplete,
        IsError,
        InvokedBy
    from px.ProcedureListExecution
    where ProcedureListExecutionSK = @ProcedureListExecutionSK

    -- [1] List of the provided args to the procedure
    select
        DatabaseName,
        SchemaName,
        ProcedureName,
        ExecutionOrder,
        ParamName,
        ParamValue
    from px.ProcedureListExecutionArg
    where ProcedureListExecutionSK = @ProcedureListExecutionSK

    -- [2] Metrics of individual item executions within the list
    select
        DatabaseName = li.DatabaseName,
        SchemaName = li.SchemaName,
        ProcedureName = li.ProcedureName,
        ExecutionOrder = li.ExecutionOrder,
        StartDateUtc = xi.StartDateUtc,
        EndDateUtc = xi.EndDateUtc,
        ErrorMessage = xi.ErrorMessage,
        IsComplete = xi.IsComplete,
        IsError = xi.IsError,
        ExecutionStatement = xi.ExecutionStatement
    from px.ProcedureListExecutionItem xi
    inner join px.ProcedureListItem li
        on xi.ProcedureListItemSK = li.ProcedureListItemSK
    where xi.ProcedureListExecutionSK = @ProcedureListExecutionSK

    -- [3] List of the actual evaluated args provided to each execution item
    select
        ExecutionOrder = li.ExecutionOrder,
        DatabaseName = li.DatabaseName,
        SchemaName = li.SchemaName,
        ProcedureName = li.ProcedureName,
        ParamName = xa.ParamName,
        ParamValue = xa.ParamValue
    from px.ProcedureListExecutionItem xi
    inner join px.ProcedureListItem li
        on xi.ProcedureListItemSK = li.ProcedureListItemSK
    left outer join px.ProcedureListExecutionItemArg xa
        on xi.ProcedureListExecutionItemSK = xa.ProcedureListExecutionItemSK
    where xi.ProcedureListExecutionSK = @ProcedureListExecutionSK

end
return
go