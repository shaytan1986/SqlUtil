/**********************************************************
* dbo.numbers
* Creator:      GTower
* Created:      10:04 AM
* Description:	An improved tally table which takes advantage of the number to produce characters (via ASCII and UNICODE functions) and dates (via OADate conversion)
* Sample Usage

		select top 1000 *
        from dbo.numbers

* Modifications
User            Date        Comment
-----------------------------------------------------------

**********************************************************/
drop table if exists dbo.numbers
create table dbo.numbers
(
    Num int not null primary key clustered,

    _Char char(1) null,
    _CharIsDigit bit null,
    _CharIsLetter bit null,
    _CharIsLetter_EN bit null,
    _CharIsAlphaNum bit null,
    _CharIsUpper bit null,
    _CharIsLower bit null,

    _NChar char(1) null,
    _NCharIsDigit bit null,
    _NCharIsLetter bit null,
    _NCharIsLetter_EN bit null,
    _NCharIsAlphaNum bit null,
    _NCharIsUpper bit null,
    _NCharIsLower bit null,

    _Date date null
)


;with nums as
(
    select top 1000000 Num = row_number() over ( order by (select null))
    from sys.all_columns a, sys.all_columns b
), a as
(
    select
        Num,
        _Char = char(num),
        _NChar = nchar(num),
        _Date = cast(try_cast(num as datetime) as date)
    from nums
), b as
(
    select
        Num,
        _Char,
        _CharIsDigit =   convert(bit, iif(_Char like '[0-9]', 1, 0)),
        _CharIsLetter =  convert(bit, iif(_Char like '[a-zA-Z]', 1, 0)),
        _CharIsLetter_EN  = convert(bit, iif(num between 65 and 90 or num between 97 and 122, 1, 0)),
        _NChar,
        _NCharIsDigit =  convert(bit, iif(_NChar like N'[0-9]', 1, 0)),
        _NCharIsLetter = convert(bit, iif(_NChar like N'[a-zA-Z]', 1, 0)),
        _Date
    from a
), c as
(
    select
        Num,
        _Char,
        _CharIsDigit,
        _CharIsLetter,
        _CharIsLetter_EN,
        _CharIsAlphaNum = _CharIsDigit | _CharIsLetter,
        _CharIsUpper = iif
            (
                _CharIsLetter = 1 
                    and convert(binary(1), upper(_Char)) = convert(binary(1), _Char),
                1,
                0
            ),
        _NChar,
        _NCharIsDigit,
        _NCharIsLetter,
        _NCharIsLetter_EN = _CharIsLetter_EN,
        _NCharIsAlphaNum = _NCharIsDigit | _NCharIsLetter,
        _NCharIsUpper = iif
            (
                _NCharIsLetter = 1 
                    and convert(binary(2), upper(_NChar)) = convert(binary(2), _NChar),
                1,
                0
            ),
        _Date
    from b
)
insert into dbo.numbers
(
    Num,
    _Char,
    _CharIsDigit,
    _CharIsLetter,
    _CharIsLetter_EN,
    _CharIsAlphaNum,
    _CharIsUpper,
    _CharIsLower,
    _NChar,
    _NCharIsDigit,
    _NCharIsLetter,
    _NCharIsLetter_EN,
    _NCharIsAlphaNum,
    _NCharIsUpper,
    _NCharIsLower,
    _Date
)
select
    Num,
    _Char,
    _CharIsDigit,
    _CharIsLetter,
    _CharIsLetter_EN,
    _CharIsAlphaNum,
    _CharIsUpper,
    _CharIsLower = _CharIsLetter & ~_CharIsUpper,
    _NChar,
    _NCharIsDigit,
    _NCharIsLetter,
    _NCharIsLetter_EN,
    _NCharIsAlphaNum,
    _NCharIsUpper,
    _NCharIsLower = _NCharIsLetter & ~_NCharIsUpper,
    _Date
from c

go
