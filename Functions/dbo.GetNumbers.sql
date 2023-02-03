/**********************************************************
* TABLE-VALUED FUNCTION: dbo.GetNumbers
* Creator:      Gabe Tower
* Created:      9/13/2022 11:58 AM
* Notes:

    It generates an itzik ben-gan style tally table,
        which can accommodate 1_073_741_824 numbers. 
        (If you need more, add an extra cross join to [b] [c] in the last select to get well over Int32 values)

    It then selects the top n rows with a row_number() over it, offset by the provided start).
    There are a couple guard conditions in there which will cause the function to return nothing
    * Start is null
    * End is null
    * Start > End

* Sample Usage

    ;with src (Id, InputLow, InputHigh, ExpectedCt) as
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
        InputLow = max(s.InputLow),
        OutputLow = min(n.Number),
        InputHigh = max(s.InputHigh),
        OutputHigh = max(n.Number),   
        ExpectedCt = max(s.ExpectedCt),
        OutputCt = count(1)
    from src s
    cross apply dbo.GetNumbers(s.InputLow, s.InputHigh) n
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
with a as  
(  
    select i
    from   
    (  
        values (1),(1),(1),(1),(1),(1),(1),(1)  --8
    ) a (i)  
), b as  
(  
    select a.i
    from a a, a b, a c, a d, a e  -- power(8, 5) = 32_768
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
from b a, b b, b c  -- power(32768, 2) = 1_073_741_824
go
