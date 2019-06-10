CREATE FUNCTION dbo.GetPreviousDayOfWeek
(
	 @FirstDate DATE
	, @DesiredDayOfWeek VARCHAR(9)
)
RETURNS Date
AS
/*
Returns the previous day of the week for a given date. 

For example, Memorial day is the last Monday in May. This commands returns Memorial Day for 2019

SELECT dbo.GetPreviousDayOfWeek('05/31/2019', 'MONDAY') => 2019-05-27

*/
BEGIN
	DECLARE @Result DATE
		, @Plus1 DATE = DATEADD(DAY, -1, @FirstDate)
		, @Plus2 DATE = DATEADD(DAY, -2, @FirstDate)
		, @Plus3 DATE = DATEADD(DAY, -3, @FirstDate)
		, @Plus4 DATE = DATEADD(DAY, -4, @FirstDate)
		, @Plus5 DATE = DATEADD(DAY, -5, @FirstDate)
		, @Plus6 DATE = DATEADD(DAY, -6, @FirstDate)

	SELECT @Result = CASE
		WHEN DATENAME(WEEKDAY, @Plus1) = @DesiredDayOfWeek THEN @Plus1
		WHEN DATENAME(WEEKDAY, @Plus2) = @DesiredDayOfWeek THEN @Plus2
		WHEN DATENAME(WEEKDAY, @Plus3) = @DesiredDayOfWeek THEN @Plus3
		WHEN DATENAME(WEEKDAY, @Plus4) = @DesiredDayOfWeek THEN @Plus4
		WHEN DATENAME(WEEKDAY, @Plus5) = @DesiredDayOfWeek THEN @Plus5
		WHEN DATENAME(WEEKDAY, @Plus6) = @DesiredDayOfWeek THEN @Plus6
		ELSE @FirstDate END

	RETURN @Result
END
