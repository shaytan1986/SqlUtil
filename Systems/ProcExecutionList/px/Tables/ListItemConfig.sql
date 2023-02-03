/**********************************************************
* TABLE: px.ListItemConfig
* Creator:		TRIO\GTower
* Created:		1/30/2023 2:47 PM
* Notes:
	notes
* Sample Usage:

	select top 100 * 
	from [px].[ListItemConfig]

* Modifications:
User			Date		Comment
----------------------------------------------------------

**********************************************************/
drop table if exists [px].[ListItemConfig]
go
create table [px].[ListItemConfig]
(
    ListItemConfigSK int identity(1,1) not null, 
	ListItemSK int null,
    InsertDateUtc datetime2(0) not null constraint DF__px_ListItemConfig__InsertDateUtc default sysutcdatetime(),
    UpdateDateUtc datetime2(0) not null constraint DF__px_ListItemConfig__UpdateDateUtc default sysutcdatetime()
    constraint PKC__px_ListItemConfig__ListItemConfigSK primary key clustered (ListItemConfigSK) 
        with (data_compression = none)
)

go

/*****************************
select top 100 * from [px].[ListItemConfigValue]
*****************************/
drop table if exists [px].[ListItemConfigValue]
go
create table [px].[ListItemConfigValue]
(
    ListItemConfigValueSK int identity(1,1) not null, 
	ListItemConfigSK int not null,
    PropName varchar(128) not null,
    PropKind varchar(128) not null,
    PropValue sql_variant null,
    LiteralNull bit not null,
    InsertDateUtc datetime2(0) not null constraint DF__px_ListItemConfigValue__InsertDateUtc default sysutcdatetime(),
    UpdateDateUtc datetime2(0) not null constraint DF__px_ListItemConfigValue__UpdateDateUtc default sysutcdatetime()
    constraint PKC__px_ListItemConfigValue__ListItemConfigValueSK primary key clustered (ListItemConfigValueSK) 
)

