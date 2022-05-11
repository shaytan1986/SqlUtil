/**********************************************************
* dbo.StringSplit
* Creator:      Gabe Tower
* Created:      9:05 AM
* Description:	Original version written by Jeff Moden: 
*               https://www.sqlservercentral.com/articles/tally-oh-an-improved-sql-8k-%E2%80%9Ccsv-splitter%E2%80%9D-function                
* Sample Usage

		select *
        from dbo.StringSplit('a,b,c,d', ',')

* Modifications
User            Date        Comment
-----------------------------------------------------------

**********************************************************/
create function dbo.StringSplit
(
    @Input varchar(8000),
    @Delim char(1)
)
returns table
with schemabinding
as
    return
    -- 1..10_000
    with E1(N) as
    (
        select 1 union all
        select 1 union all
        select 1 union all
        select 1 union all
        select 1 union all
        select 1 union all
        select 1 union all
        select 1 union all
        select 1 union all
        select 1
    ), E2(N) as --10E+1 or 10 rows
    (
        select 1
        from E1 a, E1 b
    ), E4(N) as --10E+2 or 100 rows
    (
        select 1
        from E2 a, E2 b
    ), cteTally(N) as --10E+4 or 10,000 rows max
    (    --==== This provides the "base" CTE and limits the number of rows right up front
        -- for both a performance gain and prevention of accidental "overruns"
        select top (isnull(datalength(@Input), 0))
            row_number() over (order by (select null))
        from E4
    ), cteStart(N1) as
    (    --==== This returns N+1 (starting position of each "element" just once for each delimiter)
        select 1 union all
        select t.N + 1
        from cteTally t
        where substring(@Input, t.N, 1) = @Delim
    ), cteLen(N1, L1) as
    (    --==== Return start and length (for use in substring)
        select
            s.N1,
            isnull(nullif(charindex(@Delim, @Input, s.N1), 0) - s.N1, 8000)
        from cteStart s
    )
    --===== Do the actual split. The ISNULL/NULLIF combo handles the length for the final element when no delimiter is found.
    select
        ItemNumber = row_number() over (order by l.N1),
        Item = substring(@Input, l.N1, l.L1)
    from cteLen l;

go