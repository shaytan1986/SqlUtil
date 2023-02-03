use Admin
GO
set nocount ON
go
/**********************************************************
* PROCEDURE log.SetLoggingContext
* Creator:      TRIO\GTower
* Created:      2/2/2023 9:10 AM
* Notes:
	
* Sample Usage

		exec log.SetLoggingContext
            @DefaultCategory = 'TestCategory',
            @DefaultSubCategory = 'TestSubCategory',
            @DefaultSeverity = 'INFO',
            @SourceName = 'Admin.log.SetLoggingContext',
            @RunGuid = newid(),
            @Readonly = 0,
            @Debug = 1

* Modifications
User            Date        Comment
-----------------------------------------------------------

**********************************************************/
create or alter procedure log.SetLoggingContext
	@DefaultCategory varchar(100) = null,
    @DefaultSubCategory varchar(100) = null,
    @DefaultSeverity char(5) = null,
    @DefaultUserName nvarchar(128) = null,
    @RunGuid uniqueidentifier = null,
    @SourceName nvarchar(512) = null,
    @Readonly bit = 0,
    @Debug bit = 0
as
begin

	set nocount, xact_abort on
    declare 
        @msg nvarchar(max),
        @Key nvarchar(128),
        @Value sql_variant

    declare @props table
    (
        _key nvarchar(128),
        _value sql_variant
    )
    insert into @props select N':DefaultCategory', @DefaultCategory
    insert into @props select N':DefaultSubCategory', @DefaultSubCategory
    insert into @props select N':DefaultSeverity', @DefaultSeverity
    insert into @props select N':DefaultUserName', @DefaultUserName
    insert into @props select N':RunGuid', @RunGuid
    insert into @props select N':SourceName', @SourceName

    declare c cursor local fast_forward for
        select _key, _value
        from @props
    open c
    
    fetch next from c into @Key, @Value
    
    while @@fetch_status = 0
    begin
    
        if @Value is null and @Debug = 1
            begin
                select @Msg = concat('[DEBUG]: Skipping key: ', quotename(@Key), ' (Value is null)')
                raiserror(@Msg, 0, 1) with nowait
            end
        else
            begin
                exec sys.sp_set_session_context
                    @key = @Key,
                    @value = @Value,
                    @read_only = @Readonly

                if @Debug = 1
                begin
                    select @Msg = concat('[DEBUG]: Set key: ', quotename(@Key, '"'), ' = ', quotename(convert(nvarchar(4000), @Value), '"'), ' (', convert(nvarchar(4000), sql_variant_property(@Value, 'BaseType')), ')')
                    raiserror(@Msg, 0, 1) with nowait
                end
            end

        fetch next from c into @Key, @Value

    end
    
    deallocate c

end
return
go