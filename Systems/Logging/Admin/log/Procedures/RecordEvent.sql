use admin
go
set nocount, xact_abort on
go

/**********************************************************
* PROCEDURE log.RecordEvent
* Creator:      TRIO\GTower
* Created:      2/3/2023 2:50 PM
* Notes:
	Records a log event
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

	exec @RetVal  = log.RecordEvent
        @Category = 'TestCat',
        @SubCategory = 'TestSubCat',
        @Severity = 'I',
        @Msg = @Msg,
        @EventID = @EventID output

    select *
    from log.vEvent
    where EventID = @EventID



* Modifications
User            Date        Comment
-----------------------------------------------------------

**********************************************************/
create or alter procedure log.RecordEvent
	@Category varchar(100),
    @SubCategory varchar(100),
    @Severity varchar(5),
    @Msg nvarchar(max),
    @RunGuid uniqueidentifier = null,
    @SourceName nvarchar(512) = null,
    @StructuredDetails xml = null,
    @UserName nvarchar(128) = null,
    @Print bit = 0,
    @EventID bigint = null output
as
begin

    declare 
        @Rc int = @@rowcount,
        @DateStamp datetime2(7) = sysutcdatetime(),
        @eMsg nvarchar(max)

	set nocount, xact_abort on

    declare 
        @SeverityID tinyint,
        @ErrorMessage nvarchar(max)

    select 
        @Category = nullif(trim(@Category), ''),
        @SubCategory = nullif(trim(@SubCategory), ''),
        @Msg = nullif(trim(@Msg), ''),
        @SeverityID = log.GetSeverityID(@Severity),
        @UserName = isnull(@UserName, suser_sname())

    if @Category is null or @SubCategory is null or @Msg is null
        return 1 -- Missing required parameters

    if @Severity is null
        return 2 -- Invalid Severity

    begin try

        select
            @Msg = replace(@Msg, '${rowcount}', @Rc),
            @Msg = replace(@Msg, '${datestamp}', @DateStamp)

        insert into log.Event
        (
            ServerName,
            SeverityID,
            Category,
            SubCategory,
            RunGuid,
            SourceName,
            Msg,
            StructuredDetails,
            CreatedBy
        )
        select
            ServerName = @@servername,
            SeverityID = @SeverityID,
            Category = @Category,
            SubCategory = @SubCategory,
            RunGuid = @RunGuid,
            SourceName = @SourceName,
            Msg = @Msg,
            StructuredDetails = @StructuredDetails,
            CreatedBy = @UserName
            
        select @EventID = scope_identity()


        if @Print = 1
        begin
            select @eMsg = concat(sysutcdatetime(), '|', @Severity, '|',  @Msg); 
            raiserror(@eMsg, 0, 1) with nowait
        end

    end try
    begin catch

        if @@trancount > 0
            rollback tran

        select @ErrorMessage = error_message()
        raiserror(@ErrorMessage, 0, 1) with nowait
        return 3 -- Unknown Error

    end catch

    return 0 -- Success
end
return
go