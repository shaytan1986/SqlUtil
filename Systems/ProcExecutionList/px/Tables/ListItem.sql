use util
go
set nocount, xact_abort on
go

/**********************************************************
* px.ListItem
* Creator:      TRIO\GTower
* Created:      3:49 PM
* Description:	System Versioned Temporal Table
* Sample Usage

-- TO DROP:
--
exec dbo.sp_DropTemporalTable 
    @TwoPartName = N'px.ListItem',
    @DropHistory = 1,
    @HistorySuffix = N'_History',
    @Debug = 1

select top 100 *
from px.ListItem

select top 100 *
from px.ListItem_History

* Modifications
User            Date        Comment
-----------------------------------------------------------

**********************************************************/
if object_id('px.ListItem') is null
begin

    create table px.ListItem
    (
        ListItemSK int identity(0,1) not null, 
        ListSK int not null 
            constraint FK__px_ListItem__px_List__ListSK
                references px.List (ListSK),
        DatabaseName nvarchar(128) not null,
        SchemaName nvarchar(128) not null,
        ProcName nvarchar(128) not null,
        ExecOrder int not null,
        CreatedBy nvarchar(128) not null constraint DF__px_ListItem__CreatedBy default suser_sname(),
        ModifiedBy nvarchar(128) null,
        StartDateUtc datetime2 generated always as row start not null,
        EndDateUtc datetime2 generated always as row end not null,
        
        period for system_time (StartDateUtc, EndDateUtc),
        constraint PKC__px_ListItem__ListItemSK
            primary key clustered (ListItemSK) on [PRIMARY]
    )
    with (system_versioning = on (history_table = px.[ListItem_History]))

    raiserror('Created System Versioned Temporal Table: [px].[ListItem] with History Table [px].[ListItem_History]', 0, 1) with nowait
end
go

if not exists 
(
	select 1
    from sys.indexes
    where name = 'IXNU__px_ListItem__DatabaseName_SchemaName_ProcName_ExecOrder'
		and [object_id] = object_id('px.ListItem')
)
begin
    create unique nonclustered index IXNU__px_ListItem__DatabaseName_SchemaName_ProcName_ExecOrder
        on px.ListItem (DatabaseName, SchemaName, ProcName, ExecOrder)
        with (data_compression = none, maxdop = 4, online = off)
        
    raiserror('Created Index: [IXNU__px_ListItem__DatabaseName_SchemaName_ProcName_ExecOrder] on [px].[ListItem]', 0, 1) with nowait
end
go

--;with src
--(
--    DatabaseName,
--    SchemaName,
--    ProcName,
--    ExecOrder
--) as
--(
--    select 'ECW', 'dbo', 'LoadOMOPVocab', 0 union all
--    select 'HealthJump', 'dbo', 'LoadOMOPVocab', 1 union all
--    select 'OMOPVocab', 'dbo', 'VisitHelper', 2 
--)
--insert into px.ListItem
--(
--    ListSK,
--    DatabaseName,
--    SchemaName,
--    ProcName,
--    ExecOrder
--)
--select
--    ListSK = l.ListSK,
--    DatabaseName = s.DatabaseName,
--    SchemaName = s.SchemaName,
--    ProcName = s.ProcName,
--    ExecOrder = s.ExecOrder
--from src s
--cross join px.GetList('LoadCDMData') l