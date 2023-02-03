/**********************************************************
* SCALAR FUNCTION: px.GetListSK
* Creator:      TRIO\GTower
* Created:      11/16/2022 9:12 AM
* Notes:
    get list sk
* Sample Usage

 select px.GetListSK()

* Modifications
User            Date        Comment
-----------------------------------------------------------

**********************************************************/
create or alter function px.GetListSK
(
    @Name nvarchar(128)
)
returns int
as
begin

return
(
    select top 1 ListSK
    from px.List
    where Name = @Name
)
end