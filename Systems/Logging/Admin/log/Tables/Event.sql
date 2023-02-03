use admin
go
set nocount, xact_abort on
go

/**********************************************************
* TABLE: log.Event
* Creator:		TRIO\GTower
* Created:		2/3/2023 2:29 PM
* Notes:
	Main logging table
* Sample Usage:

	select top 100 * 
	from [log].[Event]

* Modifications:
User			Date		Comment
----------------------------------------------------------

**********************************************************/
drop table if exists [log].[Event]
go
create table [log].[Event]
(
    EventID bigint IDentity(1,1) not null, 
	ServerName nvarchar(128) not null,
    SeverityID tinyint not null,
    Category varchar(100) not null,
    SubCategory varchar(100) not null,
    RunGuid uniqueidentifier null,
    SourceName nvarchar(512) null,
    Msg nvarchar(max) not null,
    StructuredDetails xml null,
    CreatedBy nvarchar(128) not null constraint DF__log_Event__CreatedBy default suser_sname(),
    InsertDateUtc datetime2(7) not null constraint DF__log_Event__InsertDateUtc default sysutcdatetime()
    constraint PKC__log_Event__EventID primary key clustered (EventID) 
        with (data_compression = page)
)

go

/*****************************
Foreign Key: 
    log.Event > log.Severity
*****************************/
if not exists 
(
	select 1
    from sys.indexes
    where name = 'IXN__log_Event__SeverityID'
		and [object_ID] = object_ID('log.Event')
)
begin
    create nonclustered index IXN__log_Event__SeverityID
        on log.Event (SeverityID)
        with (data_compression = page, maxdop = 4, online = off)
end
go

if not exists 
(
	select 1
    from sys.foreign_keys
    where parent_object_ID = object_ID('log.Event')
		and name = 'FK__log_Event__log_Severity__SeverityID'
)
begin
    alter table log.Event
		add constraint FK__log_Event__log_Severity__SeverityID
		foreign key (SeverityID) references log.Severity (SeverityID)
end
go