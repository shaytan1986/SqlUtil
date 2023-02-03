use master
GO
set nocount on
go
/*****************************
* SYSTEM-MARKED PROCEDURE


declare 
    @EventID0 bigint,
    @EventID1 bigint,
    @EventID2 bigint

declare
    @Print bit = 1,
    @RunGuid uniqueidentifier = newid(),
    @ProcId int = object_id('master.dbo.sp_log_proc_start')

exec Master.dbo.sp_log_proc_start
    @ProcID = @procid,
    @DefaultCategory = 'TestCategory',
    @DefaultSubCategory = 'TestSubCategory',
    @DefaultSeverity = 'DEBUG',
    @RunGuid = @RunGuid,
    @Print = @Print,
    @EventID = @EventID0 output

exec Admin.log.RecordContextEvent
    @Msg = N'TestMessage',
    @Print = 1,
    @Debug = 1,
    @EventID = @EventID1 output

exec Admin.log.RecordContextEvent
    @Msg = N'TestMessage',
    @Print = 1,
    @Debug = 1,
    @EventID = @EventID2 output

select *
from Admin.log.vEvent
where RunGuid = @RunGuid
*****************************/
create or alter procedure dbo.sp_log_proc_start
    @ProcId int,
    @DefaultCategory varchar(100),
    @DefaultSubCategory varchar(100),
    @DefaultSeverity char(5) = 'INFO',
    @RunGuid uniqueidentifier = null,
    @SessionContextReadonly bit = 0,
    @Debug bit = 0,    
    @Print bit = 0,
    @EventID bigint = null output
as
begin
	set nocount, xact_abort on
    
    declare  
        @User nvarchar(128) = current_user,  
        @SourceName nvarchar(255) = concat(quotename(db_name()), '.', quotename(object_schema_name(@Procid)), '.', quotename(object_name(@Procid))),
        @Msg nvarchar(max)

    select @RunGuid = isnull(@RunGuid, newid())
        
    exec Admin.log.SetLoggingContext
        @DefaultCategory = @DefaultCategory,
        @DefaultSubCategory = @DefaultSubCategory,
        @DefaultSeverity = @DefaultSeverity,
        @Debug = @Debug,
        @Readonly = @SessionContextReadonly,
        @RunGuid = @RunGuid,
        @SourceName = @SourceName

    select @Msg = concat('Starting proc ', @SourceName)
    exec Admin.log.RecordContextEvent
        @Msg = @Msg,
        @Print = @Print,
        @EventID = @EventID output

end
return
go

exec sys.sp_MS_marksystemobject N'dbo.sp_log_proc_start'
go