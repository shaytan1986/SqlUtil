# Proc Execution Utility
This builds a reusable procedure list execution utility which can be built on the Admin database on any server.

It creates a new schema ``px` to contain all the relevant items.

# Building the Solution
In the script `.\BUILD_CMD.sql`, replace the path assigned to the `:setvar dir` statement to match wherever you have the solution on your hard drive. Set your query windows into SQLCMD mode, and let er rip.

# Usage
1. Insert a record in `px.ProcedureList`
   1. Note: Procedure Lists are uniquely identified by combination of `HomeDatabase` and `Name`
2. Insert records into `px.ProcedureListItem` for the individual procedures you want to execute
3. Execute the procedure list by calling `px.ExecuteProcedureList`

# Usage Details

## 1. Create ProcedureList Record
First, create a new `ProcedureList`. This is basically a named handle for the list you want to execute.
It is uniquely identified by a combination of `HomeDatabase` and `Name`. 

### HomeDatabase
**The HomeDatabase doesn't currently do anything besides providing a namespace of sorts**. 
However if this is going to be cross database, it seems likely there might be lists with names generic enough that we'd want to reuse the name in multiple lists,
rather than force one of the lists to use an awkward name. This is ok though since previously, we pretty much had a Proc Execution utility per database anyway.

 So just think of `HomeDatabase` as being "where you would have build a Proc Execution utility before, and now don't have to because of this.

### Name
Name can't have spaces.

### System Information
There are fields on the procedure list for defining a `SystemName` and `SystemTag`. Currently, they're not used anywhere, but it seems like categorizing these lists by 
the same fields we use to log messages would be useful. At the very least, it gets us thinking about consistent usage of these fields, and at best, we could integrat automated logging 
to use those values.

## 2. Create ProcedureListItem Records
Define a list of procedures to be executed. Each ProcedureListItem must have a unique ExecutionOrder, however you CAN have the same procedure in the same list more than once.

## 3. Execute Procedure List
Proc requires
* `@HomeDatabase`
* `@ProcedureListName`

to uniquely identify a procedure list.

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

### Example Call
```SQL
declare @ProcedureListExecutionSK bigint

exec px.ExecuteProcedureList
    @HomeDatabase = 'Admin',
    @ProcedureListName = 'TestList',
    @ThrowExceptions = 1,
    @Log = 1,
    @ProcedureListExecutionSK = @ProcedureListExecutionSK output

select *
from px.vProcedureListExecutionItem
where ProcedureListExecutionSK = @ProcedureListExecutionSK
```