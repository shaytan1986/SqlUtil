use util
go
set nocount, xact_abort on
go

-- Params
declare
    @ListName nvarchar(128) = 'LoadCDMData',
    @RunConfigName nvarchar(128) = null

-- Variables
declare
    @Msg nvarchar(max),
    @ListSK int,
    @RunConfigSK int,
    @RC int


/*****************************
BODY
*****************************/
/** Get ListSK **/
select @ListSK = px.GetListSK(@ListName)

select @msg = concat(quotename(sysutcdatetime()), ': ListSK = ', @ListSK); raiserror(@msg, 0, 1) with nowait

/** Get RunConfigSK **/
select @RunConfigSK = RunConfigSK
from px.RunConfig
where ListSK = @ListSK
    and 
    (
        (@RunConfigName is null and IsDefault = 1)
        or
        (@RunConfigName = Name)
    )

-- If no config name was specified, 
--  and no default config exists...
if @RunConfigSK is null
begin
    select @RunConfigSK = RunConfigSK
    from px.RunConfig
    where ListSK = @ListSK
    

    select @Rc = @@rowcount
    --   and there is only one run config for the given list..
    if @rc > 1
    begin
        select @msg = concat(quotename(sysutcdatetime()), ': Cannot infer default RunConfigSK; ', quotename(@Rc), ' RunConfigs found.'); raiserror(@msg, 0, 1) with nowait
        ;throw 50000, @msg, 1
    end
end

select @msg = concat(quotename(sysutcdatetime()), ': RunConfigSK = ', @RunConfigSK); raiserror(@msg, 0, 1) with nowait

--select top 1000 *
--from px.RunConfig
--where RunConfigSK = @RunConfigSK

--select top 1000 *
--from px.List
--where ListSK = @ListSK

declare 
    @SQL nvarchar(max),
    @DBName nvarchar(128)

drop table if exists #ItemParams
create table #ItemParams
(
    ListItemSK int,
    qThreePartName nvarchar(384),
    ParamName nvarchar(128),
    ParamID int,
    UserType nvarchar(128),
    MaxLen int,
    Precision int,
    Scale int,
    HasDefaultValue bit,
    DefaultValue sql_variant
)


declare c cursor local fast_forward for
    select distinct DatabaseName
    from px.ListItem
    where ListSK = @ListSK
open c

fetch next from c into @DBName

while @@fetch_status = 0
begin

    select @SQL = concat
    ('
        insert into #ItemParams
        (
            ListItemSK,
            qThreePartName,
            ParamName,
            ParamID,
            UserType,
            MaxLen,
            Precision,
            Scale,
            HasDefaultValue,
            DefaultValue
        )
        select
            ListItemSK = li.ListItemSK,
            qThreePartName = concat
            (
                quotename(li.DatabaseName),
                ''.'',
                quotename(li.SchemaName),
                ''.'',
                quotename(li.ProcName)
            ),
            ParamName = p.name,
            ParamId = p.parameter_id,
            UserType = type_name(p.user_type_id),
            MaxLen = p.max_length,
            Precision = p.precision,
            Scale = p.scale,
            HasDefaultValue = p.has_default_value,
            DefaultValue = p.default_value
        from px.ListItem li
        inner join ', quotename(@DBName), '.sys.parameters p
            on object_id
            (
                concat
                (
                    quotename(li.DatabaseName),
                    ''.'',
                    quotename(li.SchemaName),
                    ''.'',
                    quotename(li.ProcName)
                )
            ) = p.object_id
        where li.ListSK = @ListSK'
    )

    exec sp_executesql
        @SQL,
        N'@ListSK int',
        @ListSK
    
    fetch next from c into @DBName

end

deallocate c


select top 1000 *
from px.RunCOnfig
where RunConfigSK = @RunConfigSK