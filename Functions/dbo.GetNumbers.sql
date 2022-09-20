/**********************************************************
* TABLE-VALUED FUNCTION: dbo.GetNumbers
* Creator:      Gabe Tower
* Created:      9/13/2022 11:58 AM
* Notes:

    It generates an itzik ben-gan style tally table (which can accommodate more numbers than the entire range of an Int32 datatype)
    It then selects the top n rows with a row_number() over it, offset by the provided start).
    There are a couple guard conditions in there which will cause the function to return nothing
    * Start is null
    * End is null
    * Start > End

* Sample Usage

    ;with src (Id, low, high, expectedCt) as
    (
        select 1, null, null, 0 union all
        select 2, 1, null, 0 union all
        select 3, null, 1, 0 union all
        select 4, -1000, 200, 1201 union all
        select 5, 1000, -200, 0 union all
        select 6, 10, 10, 1
    )
    select
        Id,
        InputLow = max(s.Low),
        OutputLow = min(n.Number),
        InputHigh = max(s.High),
        OutputHigh = max(n.Number),   
        ExpectedCt = max(s.ExpectedCt),
        OutputCt = count(1)
    from src s
    cross apply dbo.GetNumbers(s.Low, s.High) n
    group by s.Id

* Modifications
User            Date        Comment
-----------------------------------------------------------

**********************************************************/
create or alter function dbo.GetNumbers
(  
    @Start int,  
    @End int  
)  
returns table  
as  
return  
with a (num) as  
(  
    select num  
    from   
    (  
        values (1),(1),(1),(1),(1),(1),(1),(1)  
    ) a (num)  
), b as  
(  
    select a.num  
    from a a, a b, a c, a d, a e  
)     
select top 
    (
        iif
        (
            -- Guard conditions against invalid inputs
            @Start is null 
                or @End is null
                or @Start > @End, 
            0, 
            @End - (@Start - 1)
        )
    )  
    Number = row_number() over (order by (select null)) + (@start - 1)  
from b a, b b  
go
