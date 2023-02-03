use util
go
set nocount, xact_abort on
go

/**********************************************************
* px.List
* Creator:      TRIO\GTower
* Created:      3:49 PM
* Description:	System Versioned Temporal Table
* Sample Usage

-- TO DROP:
--
exec dbo.sp_DropTemporalTable 
    @TwoPartName = N'px.List',
    @DropHistory = 1,
    @HistorySuffix = N'_History',
    @Debug = 1

select top 100 *
from px.List

select top 100 *
from px.List_History

* Modifications
User            Date        Comment
-----------------------------------------------------------

**********************************************************/
if object_id('px.List') is null
begin

    create table px.List
    (
        ListSK int identity(0,1) not null, 
        Name varchar(128) not null,
        Label varchar(128) null,
        Description varchar(1000) null,
        SystemName varchar(100) null,
        SystemTag varchar(100) null,
        CreatedBy nvarchar(128) not null constraint DF__px_List__CreatedBy default suser_sname(),
        ModifiedBy nvarchar(128) null,
        StartDateUtc datetime2 generated always as row start not null,
        EndDateUtc datetime2 generated always as row end not null,
        
        period for system_time (StartDateUtc, EndDateUtc),
        constraint PKC__px_List__ListSK
            primary key clustered (ListSK) on [PRIMARY]
    )
    with (system_versioning = on (history_table = px.[List_History]))

    raiserror('Created System Versioned Temporal Table: [px].[List] with History Table [px].[List_History]', 0, 1) with nowait
end
go

if not exists 
(
	select 1
    from sys.indexes
    where name = 'IXNU__px_List__Name'
		and [object_id] = object_id('px.List')
)
begin
    create unique nonclustered index IXNU__px_List__Name
        on px.List (Name)
        with (data_compression = none, maxdop = 4, online = off)
        
    raiserror('Created Index: [IXNU__px_List__Name] on [px].[List]', 0, 1) with nowait
end
go


if not exists
(
    select 1
    from px.List
)
begin
    insert into px.List
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
INLINE TABLE-VALUED FUNCTION: px.GetList

select *
from px.GetList('LoadCDMData')
*****************************/
create or alter function px.GetList
(
    @Name nvarchar(128)
)
returns table
as
return
(
    select
        ListSK,
        Name,
        Label,
        Description,
        SystemName,
        SystemTag
    from px.List
    where Name = @Name
)

go

go
/**********************************************************
* SCALAR FUNCTION: px.GetListSK
* Creator:      TRIO\GTower
* Created:      11/16/2022 9:12 AM
* Notes:	
    get list sk
* Sample Usage

	select px.GetListSK()

* Modifications
User            Date        Comment
-----------------------------------------------------------

**********************************************************/
create or alter function px.GetListSK
(
    @Name nvarchar(128)
)
returns int
as
begin

return
(
	select top 1 ListSK
    from px.List
    where Name = @Name
)

end
go