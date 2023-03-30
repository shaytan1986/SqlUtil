use Admin
go
set nocount on
go

/*****************************
This builds a reusable procedure list execution utility which can be built on the Admin database on any server.

It creates a new schema ([px]) to contain all the relevant items.

To use, you first create a Proced
*****************************/

:setvar dir "C:\Users\GTower\OneDrive - Trio Health Advisory Group, Inc\Documents\SQL Server Management Studio\Util\ProcExecution\"
print 'Work Dir: $(dir)'

-- Schema
:r $(dir)"\schema_px.sql"

-- Tables
:r $(dir)"Tables\ProcedureList.sql"
:r $(dir)"Tables\ProcedureListItem.sql"
:r $(dir)"Tables\ProcedureListExecution.sql"
:r $(dir)"Tables\ProcedureListExecutionItem.sql"
:r $(dir)"Tables\ProcedureListExecutionArg.sql"
:r $(dir)"Tables\ProcedureListExecutionItemArg.sql"

-- Views
:r $(dir)"Views\vProcedureListItem.sql"
:r $(dir)"Views\vProcedureListExecutionItem.sql"

-- Functions
:r $(dir)"Functions\GetProcedureListSK.sql"
:r $(dir)"Functions\GetProcedureListItems.sql"

-- Types
:r $(dir)"Types\tExecutionArgs.sql"
:r $(dir)"Types\tNameNVarchar.sql"
:r $(dir)"Types\tNameSqlVariant.sql"

-- Procedures
:r $(dir)"Procedures\ExecuteProcedureList.sql"