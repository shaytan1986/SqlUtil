use Admin
GO
set nocount ON
go
/**********************************************************
* PROCEDURE log.RecordContextEvent
* Creator:      TRIO\GTower
* Created:      2/2/2023 9:35 AM
* Notes:
	Same as RecordEvent, but uses default values from the session_context
* Sample Usage


    declare 
        @Msg nvarchar(max) = N'inserted ${rowcount} row(s) into table at ${datestamp}',
        @EventID bigint,
        @RetVal int

    declare @bogus table
    (
        Id int
    )

    insert into @bogus
    select top 10 row_number() over (order by (select null))
    from sys.all_objects

	exec log.RecordContextEvent
        @Msg,
        @CategoryOverride = 'C',
        @SubCategoryOverride = 'SC',
        @Print = 1

* Modifications
User            Date        Comment
-----------------------------------------------------------

**********************************************************/
create or alter procedure log.RecordContextEvent
	@Msg nvarchar(max),
    @CategoryOverride varchar(100) = null,
    @SubCategoryOverride varchar(100) = null,
    @SeverityOverride char(5) = null,
    @UserNameOverride nvarchar(128) = null,
    @StructuredDetails xml = null,
    @Print bit = 1,
    @Debug bit = 0,
    @EventID bigint = null output
as
begin

	set nocount, xact_abort on
   
    declare
        @Category varchar(100),
        @SubCategory varchar(100),
        @Severity char(5),
        @UserName nvarchar(128),
        @eMsg nvarchar(max),
        @RunGuid uniqueidentifier,
        @SourceName nvarchar(512)
	
    select 
        @Category =   nullif(trim(coalesce(@CategoryOverride, try_convert(varchar(100), session_context(N':DefaultCategory')))), ''),
        @SubCategory =    nullif(trim(coalesce(@SubCategoryOverride, try_convert(varchar(100), session_context(N':DefaultSubCategory')))), ''),
        @Severity =     nullif(trim(coalesce(@SeverityOverride, try_convert(char(5), session_context(N':DefaultSeverity')))), ''),
        @UserName =     nullif(trim(coalesce(@UserNameOverride, try_convert(nvarchar(128), session_context(N':DefaultUserName')))), ''),
        @RunGuid =      try_convert(uniqueidentifier, session_context(N':RunGuid')),
        @SourceName = nullif(trim(coalesce(@SourceName, try_convert(nvarchar(512), session_context(N':SourceName')))), '')

    -- System Name
    if @Category is null
        begin
            select @eMsg = 'Category not provided or in session_context key :DefaultCategory. Provide overrides or run Admin.log.SetLoggingContext'
            ;throw 50000, @eMsg, 1
        end
    else if @Debug = 1
        begin
            select @eMsg = concat('[DEBUG] Category: ', quotename(@Category, '"'))
            raiserror(@eMsg, 0, 1) with nowait
        end

    -- System Tag
    if @SubCategory is null
        begin
            select @eMsg = 'SubCategory not provided or in session_context key :DefaultSubCategory. Provide overrides or run Admin.log.SetLoggingContext'   
            ;throw 50000, @eMsg, 1
        end
    else if @Debug = 1
        begin
            select @eMsg = concat('[DEBUG] SubCategory: ', quotename(@SubCategory, '"'))
            raiserror(@eMsg, 0, 1) with nowait
        end
    
    -- Severity
    if @Severity is null
    begin
        select 
            @eMsg = '[DEBUG] Severity not provided or in session_context key :DefaultSeverity. Defaulting to "INFO"',
            @Severity = 'INFO'
        raiserror(@eMsg, 0, 1) with nowait
    end

    -- SourceName
    if @SourceName is null
    begin
        select 
            @eMsg = '[DEBUG] SourceName not provided or in session_context key :SourceName.',
            @SourceName = 'INFO'
        raiserror(@eMsg, 0, 1) with nowait
    end

    if @Debug = 1
    begin
        select @eMsg = concat('[DEBUG] Severity: ', quotename(@Severity, '"'))
        raiserror(@eMsg, 0, 1) with nowait
    end

    -- User Name
    if @Debug = 1 and @UserName is not null
    begin
        select @eMsg = concat('[DEBUG] UserName: ', quotename(@UserName, '"'))
        raiserror(@eMsg, 0, 1) with nowait
    end

    exec log.RecordEvent
        @Category = @Category,
        @SubCategory = @SubCategory,
        @Severity = @Severity,
        @Msg = @Msg,
        @RunGuid = @RunGuid,
        @SourceName = @SourceName,
        @StructuredDetails = @StructuredDetails,
        @UserName = @UserName,
        @Print = @Print,
        @EventID = @EventID output


end
return
go