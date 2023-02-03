# Proc Logging
There are three procs I created to aid in logging of stored procedures:
* RecordContextEvent
* SetLoggingContext
* sp_log_proc_start

These procedures assume you have a logging database called `Admin` and an existing stored procedure called `RecordEvent` which writes to `Admin.log.Event`. This table also is assumed to have categorization fields `Category` and `SubCategory` with `Category` deemed to be the "higher level categorizer".

I plan to change that at some point to be more generic, but for the time being, that's how the `USE` statements are set up.

# Usage
## Log Proc Start
The idea is you start a proc off with a call like this:

```sql
declare
    @RunGuid uniqueidentifier = newid(),
    @Msg nvarchar(max)

exec StageAP.dbo.sp_log_proc_start
    @ProcID = @@procid,
    @DefaultCategory = 'MainCategory',
    @DefaultSubCategory = 'SubCategory',
    @DefaultSeverity = 'INFO', -- { DEBUG | INFO | WARN | ERROR }
    @RunGuid = @RunGuid,
    @Print = @Print
```

The `@RunGuid` is expected to be declared and assigned in the top of the proc body. This ends up getting prepended to all the log messages for a given execution so you can more easily tie log messages from a specific execution to each other.

This proc sets the SESSION_CONTEXT with keys:
* `:DefaultCategory`
  * The system name to use in the absence of a `@CategoryOverride`
* `:DefaultSubCategory`
  * The system Tag to use in the absence of a `@SubCategoryOverride`
* `:DefaultSeverity`
  * The default log level to use in the absence of a `SeverityOverride`
  * Will default to `INFO`
* `:DefaultUserName`
  * The default log level to use in the absence of a `UserNameOverride`
* `:RunGuid`
  * The RunGuid to be used for all logged messages during the session.
  * Note, if you have nested stored procedures, I don't have a great way to delineate which guid applies to which proc, since a nested proc would overwrite the parent RunGuid.
  * So far, if I have nested procs, I just re-set the `:RunGuid` in the parent proc after the child proc completes so that subsequent log messages reflect the parent procedures `@RunGuid`
  
the `@Print` parameter exists on this, and `Admin.log.RecordContextEvent` and if provided, will print the messages to output using `raiserror(@Msg, 0, 1) with nowait`

## Set Session Context
`sp_log_proc_start` uses `Admin.log.SetSessionContext` under the covers to set everything mentioned above. It's in a separate proc in case you want to use the default session context stuff in the absence of `sp_log_proc_start`. But ordinarily, you shouldn't need to call this.

## Record Context Event
Looks just like `Admin.log.RecordEvent` except many of the parameters are now optional, and will use session context values if overrides are not provided.