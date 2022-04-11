use master
go
set nocount on
go

/*****************************
* SYSTEM-MARKED PROCEDURE

exec dbo.sp_db_size

*****************************/
drop proc if exists dbo.sp_db_size
go

create procedure dbo.sp_db_size
    @Schemas nvarchar(max) = null
as
begin

    declare 
        @RID int = 1,
        @MaxRID int,
        @TwoPartName nvarchar(256),
        @ObjectId int,
        @SchemaName nvarchar(128),
        @TableName nvarchar(128),
        @eMsg nvarchar(4000),
        @ProcName nvarchar(512) = concat(db_name() + '.' + quotename(object_schema_name(@@procid)), '.', quotename(object_name(@@procid)))

    declare @Tabs table
    (
        RID int identity(1,1) primary key clustered,
        ObjectId int,
        SchemaName nvarchar(128),
        TableName nvarchar(128),
        nRows int,
        nReserved as cast(replace(sReserved, ' KB', '') as int),
        nData as cast(replace(sData, ' KB', '') as int),
        nIndexSize as cast(replace(sIndexSize, ' KB', '') as int),
        nUnused as cast(replace(sUnused, ' KB', '') as int),
        sReserved varchar(30),
        sData varchar(30),
        sIndexSize varchar(30),
        sUnused varchar(30)
    )

    declare c cursor local fast_forward for
        select
            ObjectId = t.object_id,
            SchemaName = s.name,
            TableName = t.Name
        from sys.tables t
        inner join sys.schemas s
            on t.schema_id = s.schema_id
        where @Schemas is null
            or s.name in
            (
                select value
                from string_split(@Schemas, '|')
            )
    open c

    fetch next from c into @ObjectId, @SchemaName, @TableName

    while @@fetch_status = 0
    begin

        select @TwoPartName = concat(@SchemaName, '.', @TableName)

        begin try

            insert into @Tabs
            (
                TableName,
                nRows,
                sReserved,
                sData,
                sIndexSize,
                sUnused
            )
            exec sp_spaceused @TwoPartName

            select @RID = scope_identity()

            update @Tabs
            set ObjectId = @ObjectId,
                SchemaName = @SchemaName
            where RID = @RID

        end try
        begin catch

            select @eMsg = concat(quotename(sysutcdatetime()), ' ', @ProcName, ': ', error_message())
            raiserror(@eMsg, 10, 1)

        end catch

        fetch next from c into @ObjectId, @SchemaName, @TableName

    end

    close c
    deallocate c

    if object_id('tempdb.dbo.#Tabs') is not null
        begin

            insert into #Tabs
            (
                DbName,
                SchemaName,
                TableName,
                ObjectId,
                RowCt,
                ReservedKB,
                DataKB,
                IndexSizeKB,
                UnusedKB
            )
            select
                DbName = db_name(),
                SchemaName = SchemaName,
                TableName = TableName,
                ObjectId = ObjectId,
                RowCt = nRows,
                ReservedKB = nReserved,
                DataKB = nData,
                IndexSizeKB = nIndexSize,
                UnusedKB = nUnused
            from @Tabs

    end
    else
        begin

            select
                DbName = db_name(),
                SchemaName = SchemaName,
                TableName = TableName,
                ObjectId = ObjectId,
                RowCt = nRows,
                ReservedKB = nReserved,
                DataKB = nData,
                IndexSizeKB = nIndexSize,
                UnusedKB = nUnused
            from @Tabs
        end
end
return
go

exec sys.sp_MS_marksystemobject N'dbo.sp_db_size'
go


exec OMOP.dbo.sp_db_size 'dbo|mdx'


