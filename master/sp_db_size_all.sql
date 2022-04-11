use master
go
set nocount on
go

/*****************************
* SYSTEM-MARKED PROCEDURE

declare @Databases nvarchar(max)

exec dbo.sp_db_size_all
    @Databases = null,
    @ExclDatabases = default

*****************************/
drop procedure if exists dbo.sp_db_size_all
go
create procedure dbo.sp_db_size_all
    @Databases nvarchar(max) = null,
    @ExclDatabases nvarchar(max) = 'master|msdb|tempdb|model'
as
begin

    declare 
        @Sql nvarchar(max),
        @DbName nvarchar(128),
        @ProcName nvarchar(512) = concat(db_name() + '.' + quotename(object_schema_name(@@procid)), '.', quotename(object_name(@@procid))),
        @eMsg nvarchar(4000),
        @Inserting bit = 0

    if object_id('tempdb.dbo.#Tabs') is null
        begin
            create table #Tabs
            (
                DbName nvarchar(128),
                SchemaName nvarchar(128),
                TableName nvarchar(128),
                ObjectId int,
                RowCt bigint,
                ReservedKB bigint,
                DataKB bigint,
                IndexSizeKB bigint,
                UnusedKB bigint
            )
        end
    else
        begin
            select @Inserting = 1
            truncate table #Tabs
        end

    declare c cursor local fast_forward for
        select DbName = name
        from sys.databases
        where @Databases is null
            or name in
            (
                select value
                from string_split(@Databases, '|')
            )
        except
        select value
        from string_split(@ExclDatabases,'|')
    open c
    
    fetch next from c into @DbName
    
    while @@fetch_status = 0
    begin
    
        begin try
            select @SQL = concat('exec ', quotename(@DbName), '.dbo.sp_db_size')
        
            exec sp_executesql @SQL

            fetch next from c into @DbName
        end try
        begin catch

            select @eMsg = concat(quotename(sysutcdatetime()), ' ', @ProcName, ': ', error_message())
            raiserror(@eMsg, 10, 1)

        end catch
    
    end

    if @Inserting = 0
        select *
        from #Tabs

end
return
go

exec sys.sp_MS_marksystemobject N'dbo.sp_db_size_all'
go

drop table if exists #tabs

create table #Tabs
(
    DbName nvarchar(128),
    SchemaName nvarchar(128),
    TableName nvarchar(128),
    ObjectId int,
    RowCt bigint,
    ReservedKB bigint,
    DataKB bigint,
    IndexSizeKB bigint,
    UnusedKB bigint
)
exec dbo.sp_db_size_all 