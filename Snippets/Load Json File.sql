declare 
	@JsonText nvarchar(max),
	@FilePath nvarchar(4000) = '$file_path$.json'

exec dbo.LoadJsonFile
    @FilePath = @FilePath,
    @JsonText = @JsonText output,
	@Debug = 1

select *
from openjson(@JsonText)