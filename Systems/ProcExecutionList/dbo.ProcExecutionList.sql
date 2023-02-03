use util
go
set nocount, xact_abort on
go

/**********************************************************
* dbo.ProcExecutionList
* Creator:      TRIO\GTower
* Created:      3:49 PM
* Description:	System Versioned Temporal Table
* Sample Usage

-- TO DROP:
--
exec dbo.sp_DropTemporalTable 
    @TwoPartName = N'dbo.ProcExecutionList',
    @DropHistory = 1,
    @HistorySuffix = N'_History',
    @Debug = 1

select top 100 *
from dbo.ProcExecutionList

select top 100 *
from dbo.ProcExecutionList_History

* Modifications
User            Date        Comment
-----------------------------------------------------------

**********************************************************/
if object_id('dbo.ProcExecutionList') is null
begin

    create table dbo.ProcExecutionList
    (
        ProcExecutionListSK int identity(0,1) not null, 
        Name varchar(128) not null,
        Label varchar(128) null,
        Description varchar(1000) null,
	    SystemName varchar(100) null,
        SystemTag varchar(100) null,
        CreatedBy nvarchar(128) not null constraint DF__dbo_ProcExecutionList__CreatedBy default suser_sname(),
        ModifiedBy nvarchar(128) null,
        StartDateUtc datetime2 generated always as row start not null,
        EndDateUtc datetime2 generated always as row end not null,
        
        period for system_time (StartDateUtc, EndDateUtc),
        constraint PKC__dbo_ProcExecutionList__ProcExecutionListSK
            primary key clustered (ProcExecutionListSK) on [PRIMARY]
    )
    with (system_versioning = on (history_table = dbo.[ProcExecutionList_History]))

    raiserror('Created System Versioned Temporal Table: [dbo].[ProcExecutionList] with History Table [dbo].[ProcExecutionList_History]', 0, 1) with nowait
end
go

if not exists 
(
	select 1
    from sys.indexes
    where name = 'IXNU__dbo_ProcExecutionList__Name'
		and [object_id] = object_id('dbo.ProcExecutionList')
)
begin
    create unique nonclustered index IXNU__dbo_ProcExecutionList__Name
        on dbo.ProcExecutionList (Name)
        with (data_compression = none, maxdop = 4, online = off)
        
    raiserror('Created Index: [IXNU__dbo_ProcExecutionList__Name] on [dbo].[ProcExecutionList]', 0, 1) with nowait
end
go


if not exists
(
    select 1
    from dbo.ProcExecutionList
)
begin
    insert into dbo.ProcExecutionList
    (
        Name,
        Label,
        Description,
        SystemName,
        SystemTag
    )
    select
        Name = 'LoadCDMData',
        Label = 'Load CDM Data',
        Description = 'Execute all procs which transform source data into the common data model',
        SystemName = 'CDMLoad',
        SystemTag = 'Orchestrator'
end

go
/*****************************
INLINE TABLE-VALUED FUNCTION: dbo.GetProcExecutionList

select *
from dbo.GetProcExecutionList('LoadCDMData')
*****************************/
create or alter function dbo.GetProcExecutionList
(
    @Name nvarchar(128)
)
returns table
as
return
(
    select
        ProcExecutionListSK,
        Name,
        Label,
        Description,
        SystemName,
        SystemTag
    from dbo.ProcExecutionList
    where Name = @Name
)

go

