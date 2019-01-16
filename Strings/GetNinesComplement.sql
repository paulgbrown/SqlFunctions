-- =============================================
-- Author:		Paul G Brown
-- Copyright:   @ 2019 Paul G Brown
-- License:     See Github repo license
-- Create date: 2019-01-16
-- Description:	Gets the 9's completement of a
--              string.
-- =============================================
CREATE FUNCTION GetNinesComplement
(
	@Source varchar(20)
)
RETURNS VARCHAR(20)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Position int = 1
		, @Len int
		, @TrimmedSource varchar(20)
		, @IntValue int
		, @FinalResult varchar(20) = ''

	SET @TrimmedSource = RTRIM(LTRIM(@Source))
	SET @Len = LEN(@TrimmedSource)

	WHILE @Position <= @Len
		BEGIN
			SET @IntValue = CAST(SUBSTRING(@TrimmedSource, @Position, 1) as int)
			SET @FinalResult = @FinalResult + CAST(9 - @IntValue as char(1))

			SET @Position = @Position + 1
		END

	RETURN @FinalResult

END
GO

