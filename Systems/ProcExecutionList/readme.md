# Proc Execution Utility
This builds a reusable procedure list execution utility which can be built on the Admin database on any server.

It creates a new schema ``px` to contain all the relevant items.

[Confluence Page: Procedure List Execution](https://triohealth.atlassian.net/wiki/spaces/Engineerin/pages/16842753/Procedure+List+Execution)
# Building the Solution
In the script `.\BUILD_CMD.sql`, replace the path assigned to the `:setvar dir` statement to match wherever you have the solution on your hard drive. Set your query windows into SQLCMD mode, and let er rip.

# Executing a ProcedureList
You execute a list by calling `px.ExecuteProcedureList`.

## Parameters
At a minimum, the proc requires you to identify a procedure list by passing:
* `@HomeDatabase`
* `@ProcedureListName`

Optional arguments are:
* `@ThrowExceptions`
  * If 1 (default), will re-throw any exceptions.
  * If 0, will log the exceptions, but won't throw them
* `@Log`
  * If 1 (default), will log the start and stop of the list and each item.
  * If 0, no logging will occur. This includes if exceptions are thrown.
* `@ProcedureListExecutionSK`
  * Output parameter
  * Allows you to get the execution sk for the current run.

## Arguments
While many lists will just have parameterless workoffs, some procedures may benefit from having arguments provided to them.

If you want to pass arguments, there is a user defined table type on the `Admin` database called `px.tExecutionArgs`

Each row requires a `ParamName` which must match the name of the parameter in `sys.parameters`. The value may be null, in which case, an explicit null will be passed to the parameter.

Parameters can be applied at three different levels:
* To all procedures in the list (Global)
  * This has the lowest priority and will be overridden by Procedure and Item parameters
* To all instances of a specific procedure in the list (Procedure)
  * This has priority above Global parameters, but lower than Item parameters
* To a specific ExecutionOrder item in the list (Item)
  * This has the highest priority and will override Procedure and Global parameters

### Global Parameters
Global parameters can be though of as default values which will be set on _any_ procedure bearing the `ParamName` value.

**Be careful using these, especially if similarly named parameters across multiple procedures have different semantics**

To set a global parameter, provide a row which only provides a `ParamName` and `ParamValue` (remember, `ParamValue` may be null if you want it explicitly passed)

### Procedure Parameters
Since a ProcedureList can call the same proc more than once, setting procedure parameters will pass the same values to _all_ instances of that procedure in the list.

To set a Procedure Parameter, provide a row which, in addition to `ParamName` and `ParamValue` (remember, `ParamValue` may be null if you want it explicitly passed), supplies:
* `DatabaseName`
* `SchemaName`
* `ProcedureName`

### Item Parameters
Since a ProcedureList can call the same proc more than once, you may want to provide _different_ parameters to different executions of the same procedure. 

To set an Item Parameter, provide a row which, in addition to `ParamName` and `ParamValue` (remember, `ParamValue` may be null if you want it explicitly passed), supplies:
* `ExecutionOrder`


## Example Call
```SQL
declare
  @HomeDatabase nvarchar(128) = 'Admin'
  @ProcedureListName nvarchar(128) = 'TestList',
  @ProcedureListExecutionSK bigint,
  @Args px.tExecutionArgs 

insert into @args
(
    DatabaseName,
    SchemaName,
    ProcedureName,
    ExecutionOrder,
    ParamName,
    ParamValue
)
values
    (null, null, null, null, '@SystemName', 'DefaultSystemName'),
    (null, null, null, null, '@SystemTag', 'DefaultSystemTag'),
    ('Admin', 'px', 'TestProc1', null, '@SystemName', 'TestProc1SystemName'),
    ('Admin', 'px', 'TestProc1', null, '@SystemTag', 'TestProc1SystemTag'),
    -- The ExecutionOrder uniquely identifies a proc, so you don't have to provide the proc naming info. 
    -- You MAY, but it will just be ignored.
    (null, null, null, 3, '@SystemName', 'ExecOrder3SystemName'),
    (null, null, null, 3, '@SystemTag', 'ExecOrder3SystemTag')

-- Execute the list
exec px.ExecuteProcedureList
    @HomeDatabase = @HomeDatabase,
    @ProcedureListName = @ProcedureListName,
    @Args = @Args,
    @ProcedureListExecutionSK = @ProcedureListExecutionSK output

-- Review results
exec px.AnalyzeProcedureListExecution
  @ProcedureListExecutionSK = @ProcedureListExecutionSK
```

# How to Create a ProcedureList
1. Insert a record in `px.ProcedureList`
   1. Note: Procedure Lists are uniquely identified by combination of `HomeDatabase` and `Name`
2. Insert records into `px.ProcedureListItem` for the individual procedures you want to execute

## Details

### 1. Create ProcedureList Record
First, create a new `ProcedureList`. This is basically a named handle for the list you want to execute.
It is uniquely identified by a combination of `HomeDatabase` and `Name`. 

#### HomeDatabase
**The HomeDatabase doesn't currently do anything besides providing a namespace of sorts**. 
However if this is going to be cross database, it seems likely there might be lists with names generic enough that we'd want to reuse the name in multiple lists,
rather than force one of the lists to use an awkward name. This is ok though since previously, we pretty much had a Proc Execution utility per database anyway.

 So just think of `HomeDatabase` as being "where you would have build a Proc Execution utility before, and now don't have to because of this.

#### Name
Name can't have spaces.

#### System Information
There are fields on the procedure list for defining a `SystemName` and `SystemTag`. Currently, they're not used anywhere, but it seems like categorizing these lists by 
the same fields we use to log messages would be useful. At the very least, it gets us thinking about consistent usage of these fields, and at best, we could integrat automated logging 
to use those values.

### 2. Create ProcedureListItem Records
Define a list of procedures to be executed. Each ProcedureListItem must have a unique ExecutionOrder, however you CAN have the same procedure in the same list more than once.

