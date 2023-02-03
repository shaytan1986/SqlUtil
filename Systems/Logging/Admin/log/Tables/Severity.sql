/**********************************************************
* TABLE: log.Severity
* Creator:		TRIO\GTower
* Created:		2/3/2023 2:37 PM
* Notes:
	notes
* Sample Usage:

	select top 100 * 
	from [log].[Severity]

* Modifications:
User			Date		Comment
----------------------------------------------------------

**********************************************************/
drop table if exists [log].[Severity]
go
create table [log].[Severity]
(
    SeverityID tinyint not null, 
	Code char(1) not null,
    Name varchar(5) not null constraint CHK__log_Severity__Name check (len(Name) > 1),
    Description varchar(500) not null,
    InsertDateUtc datetime2(0) not null constraint DF__log_Severity__InsertDateUtc default sysutcdatetime(),
    UpdateDateUtc datetime2(0) not null constraint DF__log_Severity__UpdateDateUtc default sysutcdatetime()
    constraint PKC__log_Severity__SeverityID primary key clustered (SeverityID) 
        with (data_compression = none)
)

go

if not exists 
(
	select 1
    from sys.indexes
    where name = 'IXNU__log_Severity__Code'
		and [object_id] = object_id('log.Severity')
)
begin
    create unique nonclustered index IXNU__log_Severity__Code
        on log.Severity (Code)
        with (data_compression = none, maxdop = 4, online = off)
        
    raiserror('Created Index: [IXNU__log_Severity__Code] on [log].[Severity]', 0, 1) with nowait
end
go

if not exists 
(
	select 1
    from sys.indexes
    where name = 'IXNU__log_Severity__Name'
		and [object_id] = object_id('log.Severity')
)
begin
    create unique nonclustered index IXNU__log_Severity__Name
        on log.Severity (Name)
        with (data_compression = none, maxdop = 4, online = off)
        
    raiserror('Created Index: [IXNU__log_Severity__Name] on [log].[Severity]', 0, 1) with nowait
end
go

;with src (SeverityID, Code, Name, Description) as
(
    select 0, 'D', 'DEBUG', 'Information that only a programmer could love. Usually disabled in production versions. Will not normally appear in a dashboard.' union all
    select 1, 'A', 'AUDIT', 'Information that is only useful audit purposes.  Would not show on a dashboard.' union all
    select 2, 'I', 'INFO', 'This is not a problem, just logging some useful information. These should be limited to things that operators of the system will be interested in -- use DEBUG for programmer details. Would be a green light in the dashboard.' union all
    select 3, 'W', 'WARN', 'This is an event to notice, but may not require intervention. Would show up as a yellow light on a dashboard.' union all
    select 4, 'E', 'ERROR', 'This is an event that someone should investigate and fix. Would show up as a red light on a dashboard.'
)

merge into log.Severity t
using src s
    on t.Code = s.Code
when matched and exists
    (
        select
            s.Name,
            s.Description
        except
        select
            t.Name,
            t.Description
    ) then update
    set Name = s.Name,
        Description = s.Description,
        UpdateDateUtc = sysutcdatetime()
when not matched by target then insert
    (
        SeverityID,
        Code,
        Name,
        Description
    )
    values
    (
        s.SeverityID,
        s.Code,
        s.Name,
        s.Description
    )
output $action, inserted.*;


