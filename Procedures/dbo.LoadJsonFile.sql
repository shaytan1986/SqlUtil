use fhir
go
set nocount on
go

/*****************************
DSQL wrapper for grabbing the content of a JSON file from disk
NOTE: This could be expanded to be sp_LoadJsonFile, but that would either mean the removal of the xp/default directory logic, or it's expansion.

declare 
	@JsonText nvarchar(max),
	@FilePath nvarchar(4000) = 'G:\data\fhir\definitions\conceptmaps.json',
	@RelativePath nvarchar(4000) = '.\conceptmaps.json'

exec dbo.LoadJsonFile
    @FilePath = @RelativePath,
    @JsonText = @JsonText output,
	@Debug = 1

select *
from openjson(@JsonText)

*****************************/
create or alter proc dbo.LoadJsonFile
	@FilePath nvarchar(4000),
	@JsonText nvarchar(max) output,
	@PathStyle varchar(10) = 'windows', -- { windows | posix } Has no effect unless you're using relative paths.
	@Debug bit = 0 --Print DSQL statement before running
as
begin

	declare 
		@NewFilePath nvarchar(4000) = @FilePath,
		@DefaultDirectory nvarchar(4000),
		@Slash nchar(1),
		@DotSlash nchar(2),
		@sql nvarchar(max),
		@msg nvarchar(max)

	begin try

		-- If @FilePath is a relative path (i.e. starts with a period)
		if left(@FilePath, 1) = '.'
		begin

			select
				@Slash = iif(@PathStyle = 'posix', N'/', N'\'),
				@DotSlash = N'.' + @Slash

			-- Look up the value set for the default directory
			select @DefaultDirectory = try_convert(nvarchar(4000), value)
			from sys.extended_properties
			where major_id = @@procid
				and name = N':defaultDirectory'

			if @Debug = 1 raiserror('Default Directory: %s', 0, 1) with nowait

			-- If default directory value exists, expand to the full path
			if @DefaultDirectory is not null
				begin
					select @NewFilePath = concat
					(
						@DefaultDirectory,
						iif(right(@DefaultDirectory, 1) != @Slash, @Slash, ''), -- append path separator if none exists
						right(@NewFilePath, len(@NewFilePath) - len(@DotSlash)), -- Lop off the dotslash. Using length in case someone wants to simulate this elsewhere with longer sequences
						iif(@NewFilePath not like N'%.json', N'.json', '') -- add file extension if missing
					)

				end
			-- Otherwise throw an error
			else
				begin
					raiserror('Cannot pass a relative path without ":defaultDirectory" extended property set.', 16, 1)
				end
		end

		-- Dynamically populate @JsonText variable.
		-- Have to use DSQL because OPENROWSET won't let you parameterize it
		select @sql = concat
		(
			'select @JsonText = BulkColumn ', char(13), char(9),
			'from openrowset(bulk ', quotename(@NewFilePath, ''''), ', single_clob) a'
		)

		-- debug logging
		if @Debug = 1
		begin
			select @msg = concat
			(
				'Input FilePath:', char(13), char(9),
					@FilePath, char(13), char(13),
				'New FilePath:', char(13), char(9),
					@NewFilePath, char(13), char(13),
				'Stmt: ' , char(13), char(9),
					@Sql, char(13), char(13),
				'DefaultDirectory: ' , char(13), char(9),
					@DefaultDirectory, char(13), char(13),
				'PathStyle: ' , char(13), char(9),
					@PathStyle, char(13)
			)

			raiserror(@sql, 0, 1) with nowait
		end

		-- Do the deetness
		exec sp_executesql
			@sql,
			N'@JsonText nvarchar(max) output',
			@JsonText output
	
	end try
	begin catch
	
	    if @@trancount > 0
	        rollback tran

			select @msg = concat
			(
				'Input FilePath:', char(13), char(9),
					@FilePath, char(13), char(13),
				'New FilePath:', char(13), char(9),
					@NewFilePath, char(13), char(13),
				'Stmt: ' , char(13), char(9),
					@Sql, char(13), char(13),
				'DefaultDirectory: ' , char(13), char(9),
					@DefaultDirectory, char(13), char(13),
				'PathStyle: ' , char(13), char(9),
					@PathStyle, char(13)
			)
		print @msg

	    ;throw
	
	end catch

end
return
go

/*****************************
Extended Properties

Note: if you have SqlXP installed, you can use sp_setextendedproperty instead

exec sys.sp_addextendedproperty
    @name = N':defaultDirectory',
    @value = N'G:\data\fhir\definitions',
    @level0type = 'SCHEMA',
    @level0name = N'dbo',
    @level1type = 'PROCEDURE',
    @level1name = N'LoadJsonFile'

exec sys.sp_updateextendedproperty
    @name = N':defaultDirectory',
    @value = N'G:\data\fhir\definitions\all-types',
    @level0type = 'SCHEMA',
    @level0name = N'dbo',
    @level1type = 'PROCEDURE',
    @level1name = N'LoadJsonFile'
*****************************/



declare 
	@JsonText nvarchar(max),
	@FilePath nvarchar(4000) = 'G:\data\fhir\definitions\conceptmaps.json',
	@RelativePath nvarchar(4000) = '.\conceptmaps.json'

exec dbo.LoadJsonFile
    @FilePath = @RelativePath,
    @JsonText = @JsonText output

select @JsonText