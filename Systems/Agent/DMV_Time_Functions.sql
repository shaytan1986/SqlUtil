     use msdb
go
/**********************************************************  
* SCALAR FUNCTION: dbo.IntToTime  
* Creator:      TRIO\GTower  
* Created:      9/1/2022 2:12 PM  
* Notes:   
    notes  
* Sample Usage  
  
 select dbo.IntToTime()  
  
* Modifications  
User            Date        Comment  
-----------------------------------------------------------  
  
**********************************************************/  
create or alter function dbo.AGIntToTime  
(  
    @IntTime int  
)  
returns time(0)  
as  
begin  
return  try_convert(time, stuff(stuff(right('000000' + cast(@IntTime as varchar(6)), 6), 3, 0, ':'), 6, 0, ':'))  
end  
go

create or alter function dbo.AGIntToDate
(
    @IntDate int
)
returns date
as
begin
    return try_convert(date, cast(@IntDate as char(8)), 112)
end
go

create or alter function dbo.AGIntToDateTime
(
    @IntDate int,
    @IntTime int
)
returns datetime
as
begin
return cast(dbo.AgIntToDate(@IntDate) as datetime)
    + cast(dbo.AgIntToTime(@IntTime) as datetime)
end