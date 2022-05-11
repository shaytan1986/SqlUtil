# SqlUtil
Misc utility functions and procs.

Anything at the base level of the project are standalone objects that have some purpose by themselves. For systems of objects which work in conjunction with eachother, see the `Systems` folder.

# Project Sections
## Functions
### StringSplit
A tally-table string splitter with an identity column on it (something which, at time of writing, the inbuilt `split_string` function sql provides, does not.)

## Procedures
### LoadJsonFile
A procedure which loads a JSON file from a path into an output variable. You can specify the path style (i.e. Windows or POSIX).

If you want to set a default directory, to be used for relative paths, you can add an extended propert `:defaultDirectory` to the procedure, which it will use for any relative paths. If the default directory is not set, you can't use relative paths.

## Tables
### Numbers
An improved tally table which takes advantage of the number to produce characters (via ASCII and UNICODE functions) and dates (via OADate conversion)

## Master
Custom stored procedures built in the `master` database, and marked as special procedures using `sp_ms_MarkSystemObject`.

## Systems
Systems of more than one object which work together to provide a specific unit of functionality.