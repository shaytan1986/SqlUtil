use util
go
set nocount, xact_abort on
go

/**********************************************************
* dbo.ProcExecutionListItem
* Creator:      TRIO\GTower
* Created:      3:49 PM
* Description:	System Versioned Temporal Table
* Sample Usage

-- TO DROP:
--
--exec dbo.sp_DropTemporalTable 
--    @TwoPartName = N'dbo.ProcExecutionListItem',
--    @DropHistory = 1,
--    @HistorySuffix = N'_History',
--    @Debug = 1

select top 100 *
from dbo.ProcExecutionListItem

select top 100 *
from dbo.ProcExecutionListItem_History

* Modifications
User            Date        Comment
-----------------------------------------------------------

**********************************************************/
if object_id('dbo.ProcExecutionListItem') is null
begin

    create table dbo.ProcExecutionListItem
    (
        ProcExecutionListItemSK int identity(0,1) not null, 
	    ProcExecutionListSK int not null 
            constraint FK__dbo_ProcExecutionListItem__dbo_ProcExecutionList__ProcExecutionListSK
	            references dbo.ProcExecutionList (ProcExecutionListSK),
        DatabaseName nvarchar(128) not null,
        SchemaName nvarchar(128) not null,
        ProcName nvarchar(128) not null,
        ExecOrder int not null,
        CreatedBy nvarchar(128) not null constraint DF__dbo_ProcExecutionListItem__CreatedBy default suser_sname(),
        ModifiedBy nvarchar(128) null,
        StartDateUtc datetime2 generated always as row start not null,
        EndDateUtc datetime2 generated always as row end not null,
        
        period for system_time (StartDateUtc, EndDateUtc),
        constraint PKC__dbo_ProcExecutionListItem__ProcExecutionListItemSK
            primary key clustered (ProcExecutionListItemSK) on [PRIMARY]
    )
    with (system_versioning = on (history_table = dbo.[ProcExecutionListItem_History]))

    raiserror('Created System Versioned Temporal Table: [dbo].[ProcExecutionListItem] with History Table [dbo].[ProcExecutionListItem_History]', 0, 1) with nowait
end
go


;with src
(
    DatabaseName,
    SchemaName,
    ProcName,
    ExecOrder
) as
(
    select 'ECW', 'dbo', 'LoadOMOPVocab', 0 union all
    select 'HealthJump', 'dbo', 'LoadOMOPVocab', 1 union all
    select 'OMOPVocab', 'dbo', 'VisitHelper', 2
)
insert into dbo.ProcExecutionListItem
(
    ProcExecutionListSK,
    DatabaseName,
    SchemaName,
    ProcName,
    ExecOrder
)
select
    ProcExecutionListSK = l.ProcExecutionListSK,
    DatabaseName = s.DatabaseName,
    SchemaName = s.SchemaName,
    ProcName = s.ProcName,
    ExecOrder = s.ExecOrder
from src s
cross join dbo.GetProcExecutionList('LoadCDMData') l