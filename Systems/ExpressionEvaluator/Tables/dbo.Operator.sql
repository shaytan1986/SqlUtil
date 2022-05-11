/**********************************************************
* dbo.Operator
* Creator:		Shaytan1986
* Created:		4/11/2022 4:08 PM
* Description:  A binary operator to be performed between two values
                Special symbols for expr are 
                    @arg - the incoming value you want to check against the expression
                    @comparator - The saved value against which the @arg should be compared
* Sample Usage:

select top 100 * 
from [dbo].[Operator]

* Modifications:
User			Date		Comment
----------------------------------------------------------

**********************************************************/
drop table if exists [dbo].[Operator]
go
create table [dbo].[Operator]
(
    Code varchar(10) not null,
    Description varchar(1000) not null,
    Expr nvarchar(max) not null
    constraint PKC__dbo_Operator__Code primary key clustered (Code) 
        with (data_compression = none)
)

go

;with src (Code, Description, Expr) as
(
    select 'EQ', 'Argument equals comparator', N'@arg = @comparator' union all
    select 'NEQ', 'Argument does not equal comparator', N'@arg <> @comparator' union all
    select 'IN', 'Argument exists in a pipe-delimited list of comparators', N'@arg in (select value from string_split(@comparator, ''|'')' union all
    select 'NOTIN', 'Argument does not exist in a pipe-delimited list of comparators', N'@arg not in (select value from string_split(@comparator, ''|'')' union all
    select 'LIKE', 'Argument matches a wildcard comparator expression', N'@arg like @comparator' union all
    select 'NOTLIKE', 'Argument does not match a wildcard comparator expression', N'@arg not like @comparator' union all
    select 'LT', 'Argument is less than comparator', N'@arg < @comparator' union all
    select 'LTE', 'Argument is less than or equal to comparator', N'@arg <= @comparator' union all
    select 'GT', 'Argument is greater than comparator', N'@arg > @comparator' union all
    select 'GTE', 'Argument is greater than or equal to comparator', N'@arg >= @comparator' 
)
insert into dbo.Operator
(
    Code,
    Description,
    Expr
)
select
    Code = s.Code,
    Description = s.Description,
    Expr = s.Expr
from src s
left outer join dbo.Operator t
    on s.Code = t.Code
where t.Code is null