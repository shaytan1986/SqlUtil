create type dbo.tNameValuePair as table
(
    Name nvarchar(max),
    Value nvarchar(max)
)
go

/**********************************************************
* dbo.NameValuePairs
* Creator:		TRIO\GTower
* Created:		12/22/2021 8:10 AM
* Description:  description
* Sample Usage:

select top 100 * 
from [dbo].[NameValuePairs]

* Modifications:
User			Date		Comment
----------------------------------------------------------

**********************************************************/
drop table if exists [dbo].[NameValuePairs]
go
create table [dbo].[NameValuePairs]
(
    NameValuePairsSK bigint identity(1,1) not null, 
    ExecutionId uniqueidentifier not null,
	Source nvarchar(128) not null,
    Name nvarchar(max),
    Value nvarchar(max),
    InsertDate datetime2(0) not null constraint DF__dbo_NameValuePairs__InsertDate default sysdatetime()
    constraint PKC__dbo_NameValuePairs__NameValuePairsSK primary key clustered (NameValuePairsSK) 
        with (data_compression = none)
)

go
create proc dbo.InsertNameValuePairs
    @Source nvarchar(128),
    @Truncate bit = 0,
    @tNameValuePair dbo.tNameValuePair readonly
as
begin

    declare @ExecutionId uniqueidentifier = newid()
    if @Truncate = 1
    begin
        truncate table dbo.NameValuePairs
    end

    insert into dbo.NameValuePairs
    (
        ExecutionId,
        Source,
        Name,
        Value
    )
    select
        ExecutionId = @ExecutionId,
        Source = @Source,
        Name = Name,
        Value = Value
    from @tNameValuePair

end