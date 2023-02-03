/**********************************************************
* TABLE: px.RunConfigItem
* Creator:		TRIO\GTower
* Created:		1/30/2023 1:06 PM
* Notes:
	
* Sample Usage:

	select top 100 * 
	from [px].[RunConfigItem]

* Modifications:
User			Date		Comment
----------------------------------------------------------

**********************************************************/
drop table if exists [px].[RunConfigItem]
go
create table [px].[RunConfigItem]
(
    RunConfigItemSK int identity(1,1) not null, 
	RunConfigSK int not null,
    ListItemSK int not null,
    InsertDateUtc datetime2(0) not null constraint DF__px_RunConfigItem__InsertDateUtc default sysutcdatetime(),
    UpdateDateUtc datetime2(0) not null constraint DF__px_RunConfigItem__UpdateDateUtc default sysutcdatetime()
    constraint PKC__px_RunConfigItem__RunConfigItemSK primary key clustered (RunConfigItemSK) 
        with (data_compression = none)
)

go