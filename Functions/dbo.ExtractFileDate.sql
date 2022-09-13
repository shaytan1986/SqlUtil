/**********************************************************
* TABLE-VALUED FUNCTION: dbo.ExtractFileDate
* Creator:      TRIO\GTower
* Created:      9/13/2022 3:19 PM
* Notes:
	Attempts to extract a FileDate from a FileName based on a hierarchy of wildcard case statements
* Sample Usage
    
    select b.FileDate, a.cFileDate, a.*
    from Tokens.dbo.vSourceFile a
    outer apply dbo.ExtractFileDate(a.FileName) b
    where a.Filename = 'LL850312_5.xml'

* Modifications
User            Date        Comment
-----------------------------------------------------------

**********************************************************/
create or alter function dbo.ExtractFileDate
(
    @FileName nvarchar(1000)   
)
returns table
as
return
with parts as
(
    select
        YYYY = '2[0-2][0-9][0-9]',
        MM = '[0-1][0-9]',
        DD = '[0-3][0-9]',
        YY = '[0-9][0-9]'
), wc as
(
    select
        yyyy_mm_dd = concat('%', YYYY, '-', MM, '-', DD, '%'),
        yyyymmdd = concat('%', YYYY, MM, DD, '%'),
        mmddyyyy = concat('%', MM, DD, YYYY, '%'),
        mm_dd_yyyy = concat('%', MM, '-', DD, '-', YYYY, '%'),
        yymmdd = concat('%', YY, MM, DD, '%')
    from parts
), a as
(
    select
        DateStyle =
            case
                when @FileName like wc.yyyy_mm_dd then 23
                when @FileName like wc.mm_dd_yyyy then 110
                when @FileName like wc.yyyymmdd then 112
                when @FileName like wc.mmddyyyy then 110
                when @FileName like wc.yymmdd then 112
            end,
        sFileDate =
            case
                when @FileName like wc.yyyy_mm_dd
                    then substring(@FileName, patindex(wc.yyyy_mm_dd, @FileName), 10)
                when @FileName like wc.mm_dd_yyyy
                    then substring(@FileName, patindex(wc.mm_dd_yyyy, @FileName), 10)
                when @FileName like wc.yyyymmdd
                    then substring(@FileName, patindex(wc.yyyymmdd, @FileName), 8)
                when @FileName like wc.mmddyyyy
                    then stuff
                        (
                            stuff
                            (
                                substring(@FileName, patindex(wc.mmddyyyy, @FileName), 8),
                                3,
                                0,
                                '-'
                            ),
                            6,
                            0,
                            '-'
                        )
                when @FileName like wc.yymmdd
                    then '20' + substring(@FileName, patindex(wc.yymmdd, @FileName), 6)
            end
    from wc
)
select
    FileName = @FileName,
    FileDate = iif
        (
            try_convert(date, sFileDate, DateStyle) < dateadd(week, 1, getdate()),
            try_convert(date, sFileDate, DateStyle),
            null
        )
from a
go