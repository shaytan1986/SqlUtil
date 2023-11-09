go
/**********************************************************
* IN-LINE TABLE-VALUED FUNCTION dbo.DynamicDateAdd
	notes
* Sample Usage

declare @Now date = getdate()

;with inputs (Interval, Increment) as
(
    select 'day',   checksum(newid()) % 3 union all
    select 'week',  checksum(newid()) % 3 union all
    select 'month', checksum(newid()) % 3 union all
    select 'year',  checksum(newid()) % 3 union all
    select 'not-an-input', checksum(newid()) % 3 
)
select
    Now = @Now,
    Increment,
    Interval,
    NewDate
from inputs
cross apply dbo.DynamicDateAdd(interval, Increment, @Now)

* Modifications
User            Date        Comment
-----------------------------------------------------------

**********************************************************/
create or alter function dbo.DynamicDateAdd
(
    @Interval varchar(30),
    @Increment int,
    @Date date
)
returns table
as
return
select
    NewDate = case
        when @Interval in ('year', 'yy', 'yyyy') then dateadd(year, @Increment, @Date)
        when @Interval in ('quarter', 'qq', 'q') then dateadd(quarter, @Increment, @Date)
        when @Interval in ('month', 'mm', 'm') then dateadd(month, @Increment, @Date)
        when @Interval in ('dayofyear', 'dy', 'y') then dateadd(dayofyear, @Increment, @Date)
        when @Interval in ('day', 'dd', 'd') then dateadd(day, @Increment, @Date)
        when @Interval in ('week', 'wk', 'ww') then dateadd(week, @Increment, @Date)
        when @Interval in ('weekday', 'dw', 'w') then dateadd(weekday, @Increment, @Date)
        when @Interval in ('hour','hh') then dateadd(hour, @Increment, @Date)
        when @Interval in ('minute','mi', 'n') then dateadd(minute, @Increment, @Date)
        when @Interval in ('second', 'ss', 's') then dateadd(second, @Increment, @Date)
        when @Interval in ('millisecond', 'ms') then dateadd(millisecond, @Increment, @Date)
        when @Interval in ('microsecond', 'mcs') then dateadd(microsecond, @Increment, @Date)
        when @Interval in ('nanosecond', 'ns') then dateadd(nanosecond, @Increment, @Date)
        else null
    end

go

