use Admin
go
set nocount on
go
/**********************************************************
* PROCEDURE px.ExecuteProcedureList
* Creator:      TRIO\GTower
* Created:      3/28/2023 4:36 PM
* Notes:
	
* Sample Usage

        declare @Args px.tExecutionArgs

        insert into @args
        (
            DatabaseName,
            SchemaName,
            ProcedureName,
            ExecutionOrder,
            ParamName,
            ParamValue
        )
        values
            (null, null, null, null, '@SystemName', 'DefaultSystemName'),
            (null, null, null, null, '@SystemTag', 'DefaultSystemTag'),
            ('OMOP', 'dbo', 'Proc1', null, '@SystemName', 'Proc1SystemName'),
            ('OMOP', 'dbo', 'Proc1', null, '@SystemTag', 'Proc1SystemTag'),
            -- The ExecutionOrder uniquely identifies a proc, so you don't have to provide the proc naming info. 
            -- You MAY, but it will just be ignored.
            (null, null, null, 3, '@SystemName', 'ExecOrder3SystemName'),
            (null, null, null, 3, '@SystemTag', 'ExecOrder3SystemTag')

		exec px.ExecuteProcedureList
            @HomeDatabase = 'Admin',
            @ProcedureListName = 'TestList',
            @Args = @Args

* Modifications
User            Date        Comment
-----------------------------------------------------------
Gabe Tower      2023-03-30  Adding args functionality
**********************************************************/
create or alter procedure px.ExecuteProcedureList
	@HomeDatabase nvarchar(128),
    @ProcedureListName nvarchar(128),
    @ThrowExceptions bit = 1,
    @Log bit = 1,
    @ProcedureListExecutionSK bigint = null output,
    @Args px.tExecutionArgs readonly
as
begin

    ---------------------------------------------
    -- declare variables
    ---------------------------------------------
    declare
        @ProcedureListSK int,
        @ProcedureListItemSK int,
        @ProcedureListExecutionItemSK bigint,
        @qThreePartName nvarchar(518),
        @SQL nvarchar(max),
        @Msg nvarchar(max),
        @DatabaseName nvarchar(128),
        @ObjectId int
    ---------------------------------------------
    -- create temp tables
    ---------------------------------------------
    drop table if exists #Items
    create table #Items
    (
        ProcedureListItemSK int not null,
        DatabaseName nvarchar(128) not null,
        SchemaName nvarchar(128) not null,
        ProcedureName nvarchar(128) not null,
        ExecutionOrder int not null,
        qThreePartName nvarchar(400) not null,
        ObjectId int null
    )

    drop table if exists #ItemParams
    create table #ItemParams
    (
        ProcedureListItemSK int not null,
        ParamName nvarchar(128) not null,
        ParamType nvarchar(128) not null,
        Precision int null,
        Scale int null,
        MaxLength int null,
        ParamValue nvarchar(max) null,
        ValueIsSet bit not null default 0
    )
    ---------------------------------------------
    -- set session variables
    ---------------------------------------------
    set nocount, xact_abort on
    ---------------------------------------------
    -- body of stored procedure
    ---------------------------------------------
    select @ProcedureListSK = px.GetProcedureListSK(@HomeDatabase, @ProcedureListName)

    begin try

        -- Get all Items (i.e. Procedures)    
        insert into #Items
        (
            ProcedureListItemSK,
            DatabaseName,
            SchemaName,
            ProcedureName,
            ExecutionOrder,
            qThreePartName,
            ObjectId
        )
        select
            ProcedureListItemSK,
            DatabaseName,
            SchemaName,
            ProcedureName,
            ExecutionOrder,
            qThreePartName = concat(quotename(DatabaseName), '.', quotename(SchemaName), '.', quotename(ProcedureName)),
            ObjectId = object_id(concat(quotename(DatabaseName), '.', quotename(SchemaName), '.', quotename(ProcedureName)))
        from px.ProcedureListItem
        where ProcedureListSK = @ProcedureListSk
        order by ExecutionOrder

        -- Error if any items in the list don't resolve to an actual object.
        if exists
        (
            select 1
            from #Items
            where ObjectId is null
        )
        begin
            select @Msg = concat('The following Items do not resolve to an object_id: ', char(13),
                (
                    select *
                    from #Items
                    where ObjectId is null
                    for json path
                ))

            ;throw 50000, @Msg, 1
        end

        if @Log = 1
        begin
            insert into px.ProcedureListExecution (ProcedureListSK)
            select ProcedureListSK = @ProcedureListSK

            select @ProcedureListExecutionSK = scope_identity()

            insert into px.ProcedureListExecutionArg
            (
                ProcedureListExecutionSK,
                DatabaseName,
                SchemaName,
                ProcedureName,
                ExecutionOrder,
                ParamName,
                ParamValue
            )
            select
                ProcedureListExecutionSK = @ProcedureListExecutionSK,
                DatabaseName,
                SchemaName,
                ProcedureName,
                ExecutionOrder,
                ParamName,
                ParamValue
            from @Args
        end
    
        /*****************************
        Get Provided Parameters
        *****************************/
        -- Look up all the parameters from the database-specific sys.parameters table
        declare c cursor local fast_forward for
            select 
                ProcedureListItemSK,
                DatabaseName,
                ObjectId
            from #Items
        open c

        fetch next from c into @ProcedureListItemSK, @DatabaseName, @ObjectId

        while @@fetch_status = 0
        begin

            select @SQL = concat
            (
                'use ', quotename(@DatabaseName), '

                insert into #ItemParams
                (
                    ProcedureListItemSK,
                    ParamName,
                    ParamType,
                    Precision,
                    Scale,
                    MaxLength
                )
                select
                    ProcedureListItemSK = @ProcedureListItemSK,
                    ParamName = s.name,
                    ParamType = type_name(s.user_type_id),
                    Precision = s.precision,
                    Scale = s.scale,
                    MaxLength = s.max_length
                from sys.parameters s
                where s.object_id = @ObjectId'

            )
    
            exec sp_executesql
                @SQL,
                N'
                    @ProcedureListItemSK int,
                    @DatabaseName nvarchar(128),
                    @ObjectId int',
                @ProcedureListItemSK, 
                @DatabaseName, 
                @ObjectId
            fetch next from c into @ProcedureListItemSK, @DatabaseName, @ObjectId

        end

        deallocate c

        /*****************************
        Set values based on rules.
        Highest priority are values set by ExecutionOrder (since that's as precise a natural key as you can get)
        Second priority are values set by procedure.
            In otherwords, all instances of a procedure will have matching parameters given this value (overridden by ExecutionOrder params)
        Lowest priority are values set globally
            In otherwords, all procedures with matching parameters are given this value as a default
        *****************************/
        -- Update stuff specific to an execution order
        update t
        set ParamValue = s.ParamValue,
            ValueIsSet = 1
        from #ItemParams t
        inner join #Items i
            on t.ProcedureListItemSK = i.ProcedureListItemSK
        inner join @Args s
            on t.ParamName = s.ParamName
                and i.ExecutionOrder = s.ExecutionOrder

        -- Update stuff generalized to all executions of a stored procedure
        update t
        set ParamValue = s.ParamValue,
            ValueIsSet = 1
        from #ItemParams t
        inner join #Items i
            on t.ProcedureListItemSK = i.ProcedureListItemSK
        inner join @Args s
            on t.ParamName = s.ParamName
                and i.DatabaseName = s.DatabaseName
                and i.SchemaName = s.SchemaName
                and i.ProcedureName = s.ProcedureName
                and s.ExecutionOrder is null
        where t.ValueIsSet = 0

        -- Update stuff generalized to all instances of the parameters
        update t
        set ParamValue = s.ParamValue,
            ValueIsSet = 1
        from #ItemParams t
        inner join #Items i
            on t.ProcedureListItemSK = i.ProcedureListItemSK
        inner join @Args s
            on t.ParamName = s.ParamName
                and s.ExecutionOrder is null
                and s.DatabaseName is null
                and s.SchemaName is null
                and s.ProcedureName is null
        where t.ValueIsSet = 0

        /*****************************
        Execute List
        *****************************/
        declare c cursor local fast_forward for
            select
                ProcedureListItemSK,
                qThreePartName = concat
                (
                    quotename(DatabaseName), '.',
                    quotename(SchemaName), '.',
                    quotename(ProcedureName)
                )
            from px.ProcedureListItem
            where ProcedureListSK = @ProcedureListSK
            order by ExecutionOrder
        open c

        fetch next from c into
            @ProcedureListItemSK,
            @qThreePartName

        while @@fetch_status = 0
        begin

            select @SQL = 
                concat
                (
                    'exec ', 
                    @qThreePartName,
                    ' ',
                    (
                        select string_agg(concat(ParamName, ' = ', quotename(ParamValue, '''')), ',')
                        from #ItemParams
                        where ProcedureListItemSK = @ProcedureListItemSk
                            -- If there are parameters that weren't passed, just ignore them.
                            -- Note, parameters explicitly passed as null will have ValueIsSet = 1
                            and ValueIsSet = 1
                    )
                )


            if @Log = 1
            begin
                insert into px.ProcedureListExecutionItem
                (
                    ProcedureListExecutionSK,
                    ProcedureListItemSK,
                    ExecutionStatement
                )
                select
                    ProcedureListExecutionSK = @ProcedureListExecutionSK,
                    ProcedureListItemSK = @ProcedureListItemSK,
                    ExecutionStatement = @SQL

                select @ProcedureListExecutionItemSK = scope_identity()

                insert into px.ProcedureListExecutionItemArg
                (
                    ProcedureListExecutionItemSK,
                    ParamName,
                    ParamValue
                )
                select
                    ProcedureListExecutionItemSK = @ProcedureListExecutionItemSK,
                    ParamName,
                    ParamValue
                from #ItemParams
                where ProcedureListItemSK = @ProcedureListItemSk
                    -- If there are parameters that weren't passed, just ignore them.
                    -- Note, parameters explicitly passed as null will have ValueIsSet = 1
                    and ValueIsSet = 1
            end


            exec sp_executesql @SQL

            if @Log = 1
            begin
                update px.ProcedureListExecutionItem
                set EndDateUtc = sysutcdatetime()
                where ProcedureListExecutionItemSK = @ProcedureListExecutionItemSK
            end

            fetch next from c into
                @ProcedureListItemSK,
                @qThreePartName

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

            if @Log = 1
            begin
                update px.ProcedureListExecutionItem
                set EndDateUtc = sysutcdatetime(),
                    ErrorMessage = error_message()
                where ProcedureListExecutionItemSK = @ProcedureListExecutionItemSK
            end
        end

        if @Log = 1
        begin
            update px.ProcedureListExecution
            set EndDateUtc = sysutcdatetime(),
                ErrorMessage = error_message()
            where ProcedureListExecutionSK = @ProcedureListExecutionSK
        end

        if @ThrowExceptions = 1
            throw

    end catch


end
return
go