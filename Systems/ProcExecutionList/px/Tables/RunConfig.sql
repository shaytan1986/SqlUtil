use util
go
set nocount, xact_abort on
go


/**********************************************************
* TABLE: px.RunConfig
* Creator:		TRIO\GTower
* Created:		11/16/2022 9:08 AM
* Notes:
	Master table of run configurations usable in a list run
* Sample Usage:

	select top 100 * 
	from [px].[RunConfig]

* Modifications:
User			Date		Comment
----------------------------------------------------------

**********************************************************/
drop table if exists [px].[RunConfig]
go
create table [px].[RunConfig]
(
    RunConfigSK int identity(1,1) not null, 
	ListSK int not null, -- fk to px.List
    Name nvarchar(128) not null,
    IsDefault bit not null constraint DF__px_RunConfig__IsDefault default (1),
    InsertDateUtc datetime2(0) not null constraint DF__px_RunConfig__InsertDateUtc default sysutcdatetime(),
    UpdateDateUtc datetime2(0) not null constraint DF__px_RunConfig__UpdateDateUtc default sysutcdatetime()
    constraint PKC__px_RunConfig__RunConfigSK primary key clustered (RunConfigSK) 
        with (data_compression = none)
)

go

if not exists 
(
	select 1
    from sys.indexes
    where name = 'IXNU__px_RunConfig__ListSK_Name'
		and [object_id] = object_id('px.RunConfig')
)
begin
    create unique nonclustered index IXNU__px_RunConfig__ListSK_Name
        on px.RunConfig (ListSK, Name)
        with (data_compression = none, maxdop = 4, online = off)
        
    raiserror('Created Index: [IXNU__px_RunConfig__ListSK_Name] on [px].[RunConfig]', 0, 1) with nowait
end
go

if not exists 
(
	select 1
    from sys.indexes
    where name = 'IXNU__px_RunConfig__ListSK_IsDefault'
		and [object_id] = object_id('px.RunConfig')
)
begin
    create unique nonclustered index IXNU__px_RunConfig__ListSK_IsDefault
        on px.RunConfig (ListSK, IsDefault)
        where IsDefault = 1
        with (data_compression = none, maxdop = 4, online = off)
        
    raiserror('Created Index: [IXNU__px_RunConfig__ListSK_IsDefault] on [px].[RunConfig]', 0, 1) with nowait
end
go

insert into px.RunConfig
(
    ListSK,
    Name,
    IsDefault
)
values
    (px.GetListSK('LoadCDMData'), 'Default', 1),
    (px.GetListSK('LoadCDMData'), 'Full Refresh', 0)