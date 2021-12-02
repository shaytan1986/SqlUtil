use tokens
go
set nocount, xact_abort on
go

/**********************************************************
* dbo.Noise
* Creator:		TRIO\GTower
* Created:		12/1/2021 4:36 PM
* Description:  A noisy table
* Sample Usage:

select top 100 *
from [dbo].[Noise]

* Modifications:
User			Date		Comment
----------------------------------------------------------

**********************************************************/
drop table if exists [dbo].[Noise]
go
create table [dbo].[Noise]
(
    NoiseSK bigint identity(1,1) not null, 
	MessageId bigint null,
    SourceChannel nvarchar(40) null,
    Message nvarchar(4000) null,
    IsMessageJson as isjson(Message),
    InsertDateUtc datetime2(7) not null constraint DF__dbo_Noise__InsertDate default sysutcdatetime()
    constraint PKC__dbo_Noise__NoiseSK primary key clustered (NoiseSK) 
        with (data_compression = page)
)

go

/**********************************************************
* dbo.MakeNoise
* Creator:      TRIO\GTower
* Created:      4:37 PM
* Description:	Make some noise
* Sample Usage

		exec dbo.MakeNoise

* Modifications
User            Date        Comment
-----------------------------------------------------------

**********************************************************/
drop proc if exists dbo.MakeNoise
go
create procedure dbo.MakeNoise
	@MessageId bigint = null,
    @SourceChannel nvarchar(40) = null,
    @Message nvarchar(4000) = null,
    @ReturnResult bit = 0,
    @NoiseSK bigint = null output    
as
begin

    insert into dbo.Noise
    (
        MessageId,
        SourceChannel,
        Message
    )
    select
        @MessageId,
        @SourceChannel,
        @Message	

    select @NoiseSK = scope_identity()

    if @ReturnResult = 1
    begin
        select NoiseSK = @NoiseSK
    end

end
return
go

grant execute on dbo.MakeNoise to squiggy