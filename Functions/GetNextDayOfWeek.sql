CREATE FUNCTION dbo.GetNextDayOfWeek
(
	 @StartDate DATE
	, @DesiredDayOfWeek VARCHAR(9)
)
RETURNS Date
AS
/*
Returns the next day of the week for a given date. 

For example, PResidents Day in the US is the third Monday in February. This commands returns PResidents Day for 2019

SELECT dbo.GetNextDayOfWeek('02/15/2019', 'MONDAY') => 2019-02-18

*/
BEGIN
	DECLARE @Result DATE
		, @Plus1 DATE = DATEADD(DAY, 1, @StartDate)
		, @Plus2 DATE = DATEADD(DAY, 2, @StartDate)
		, @Plus3 DATE = DATEADD(DAY, 3, @StartDate)
		, @Plus4 DATE = DATEADD(DAY, 4, @StartDate)
		, @Plus5 DATE = DATEADD(DAY, 5, @StartDate)
		, @Plus6 DATE = DATEADD(DAY, 6, @StartDate)

	SELECT @Result = CASE
		WHEN DATENAME(WEEKDAY, @Plus1) = @DesiredDayOfWeek THEN @Plus1
		WHEN DATENAME(WEEKDAY, @Plus2) = @DesiredDayOfWeek THEN @Plus2
		WHEN DATENAME(WEEKDAY, @Plus3) = @DesiredDayOfWeek THEN @Plus3
		WHEN DATENAME(WEEKDAY, @Plus4) = @DesiredDayOfWeek THEN @Plus4
		WHEN DATENAME(WEEKDAY, @Plus5) = @DesiredDayOfWeek THEN @Plus5
		WHEN DATENAME(WEEKDAY, @Plus6) = @DesiredDayOfWeek THEN @Plus6
		ELSE @StartDate END

	RETURN @Result
END
