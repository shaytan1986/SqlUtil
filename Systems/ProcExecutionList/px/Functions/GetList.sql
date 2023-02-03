/*****************************  
INLINE TABLE-VALUED FUNCTION: px.GetList  

select *  
from px.GetList('LoadCDMData')  
*****************************/  
create or alter function px.GetList  
(  
    @Name nvarchar(128)  
)  
returns table  
as  
return  
(  
    select  
        ListSK,  
        Name,  
        Label,  
        Description,  
        SystemName,  
        SystemTag  
    from px.List  
    where Name = @Name  
)