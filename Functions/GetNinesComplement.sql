CREATE FUNCTION dbo.GetNinesComplement
(
	@Source varchar(20)
)
RETURNS VARCHAR(20)
AS
/*

Gets the 9's completement of a string.

*/
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

