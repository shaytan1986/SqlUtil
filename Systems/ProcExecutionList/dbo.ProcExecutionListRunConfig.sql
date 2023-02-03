use util
go
set nocount, xact_abort on
go

/**********************************************************
* TABLE: dbo.ProcExecutionListRunConfig
* Creator:		TRIO\GTower
* Created:		11/15/2022 2:45 PM
* Notes:
	A collection of settings which can be applied to a proc execution list execution controlling behavior
* Sample Usage:

    Configs prioritize item level configurations first, falling back to list level configurations, falling back to static list data (e.g. System(Name|Tag))
	select top 100 * 
	from [dbo].[ProcExecutionListRunConfig]

* Modifications:
User			Date		Comment
----------------------------------------------------------

**********************************************************/
drop table if exists [dbo].[ProcExecutionListRunConfig]
go
create table [dbo].[ProcExecutionListRunConfig]
(
    ProcExecutionListRunConfigSK int identity(1,1) not null, 
	ProcExecutionListSK int not null,
        --constraint FK__dbo_ProcExecutionListRunConfig__dbo_ProcExecutionList__ProcExecutionListSK
        	--references dbo.ProcExecutionList (ProcExecutionListSK),
    Name nvarchar(128) not null,
    Label nvarchar(128) null,
    Description varchar(1000) null,
    IsDefault bit not null 
        constraint DF__dbo_ProcExecutionListRunConfig__IsDefault default 1, -- to set the first insert to default

    /* START CONFIG ITEMS */

    /*****************************
    1. System Name/Tag
    If there are item-level considerations which require SystemName/SystemTag
    *****************************/    
    UseDefaultSystemInfo bit,
    OverrideSystemName varchar(100),
    OverrideSystemTag varchar(100),

    /*****************************
    2. CONTEXT_INFO
    You can set this binary(128) string to be leveraged by procs during the execution
    *****************************/
    ContextInfo binary(128),

    /* END CONFIG ITEMS */
    InsertDateUtc datetime2(0) not null constraint DF__dbo_ProcExecutionListRunConfig__InsertDateUtc default sysutcdatetime(),
    UpdateDateUtc datetime2(0) not null constraint DF__dbo_ProcExecutionListRunConfig__UpdateDateUtc default sysutcdatetime()
    constraint PKC__dbo_ProcExecutionListRunConfig__ProcExecutionListRunConfigSK primary key clustered (ProcExecutionListRunConfigSK) 
        with (data_compression = none)
)

go

-- Can only have one default set at any given time. 
-- This means if you want to change the default, you must first set whichever is default to 0, then run a second statement updating it to 1.
if not exists 
(
	select 1
    from sys.indexes
    where name = 'IXNU__dbo_ProcExecutionListRunConfig__ProcExecutionListSK_IsDefault'
		and [object_id] = object_id('dbo.ProcExecutionListRunConfig')
)
begin
    create unique nonclustered index IXNU__dbo_ProcExecutionListRunConfig__ProcExecutionListSK_IsDefault
        on dbo.ProcExecutionListRunConfig (ProcExecutionListSK, IsDefault)
        where (IsDefault = 1)
        with (data_compression = none, maxdop = 4, online = off)
        
    raiserror('Created Index: [IXNU__dbo_ProcExecutionListRunConfig__ProcExecutionListSK_IsDefault] on [dbo].[ProcExecutionListRunConfig]', 0, 1) with nowait
end
go