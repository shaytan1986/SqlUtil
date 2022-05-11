 
/**********************************************************  
* rt.vExpressionSetItem  
* Creator:      Shaytan1986
* Created:      4/11/2022 4:18 PM
* Description:  Denormalized collection of fields for processing expression set items  
* Sample Usage  
  
    select top 1000 *  
    from dbo.vExpressionSetItem  
  
* Modifications  
User            Date        Comment  
-----------------------------------------------------------  
  
**********************************************************/  
create or alter view dbo.vExpressionSetItem  
as  
select  
    ExpressionSetSK,  
    Context,  
    ExpressionSetOrdering,  
    OutputValue,  
    ExpressionSetDesc,  
    ExpressionSetIsActive,  
    ExpressionSetItemSK,      
    Field,  
    Operator,  
    Comparator,  
    ArgMayBeNull,  
    OperatorExpr,  
    Expr,  
    EvalExpr = concat('select @EvalFailed = iif(', Expr, ', 0, 1)')  
from  
(  
    select  
        ExpressionSetSK = xs.ExpressionSetSK,  
        Context = xs.Context,  
        ExpressionSetOrdering = xs.Ordering,  
        OutputValue = xs.OutputValue,  
        ExpressionSetDesc = xs.Description,  
        ExpressionSetIsActive = xs.IsActive,  
        ExpressionSetItemSK = i.ExpressionSetItemSK,  
        Field = i.Field,  
        Operator = i.OperatorCode,  
        Comparator = i.Comparator,  
        ArgMayBeNull = i.ArgMayBeNull,  
        OperatorExpr = o.Expr,  
        Expr = concat('(', iif(i.ArgMayBeNull = 1, 'nullif(@arg, '''') is null or ', ''), o.Expr, ')')  
    from dbo.ExpressionSet xs  
    inner join dbo.ExpressionSetItem i  
        on xs.ExpressionSetSK = i.ExpressionSetSK  
    inner join dbo.Operator o  
        on i.OperatorCode = o.Code  
) a  
  
  