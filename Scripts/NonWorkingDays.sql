DROP TABLE NonWorkingDays
GO
/*
Creates a table of non-working days. This can then be subtracted from the number of days
in a date range to determine the number of working days in the range.
*/
CREATE TABLE NonWorkingDays (
    NonWorkingDay DATE NOT NULL PRIMARY KEY,
    IsHoliday BIT NOT NULL,
    IsWeekend BIT NOT NULL,
    DayOfWeek CHAR(9) NOT NULL, 
    Reason VARCHAR(50) NOT NULL
    )

-- Set the range of years and if the Friday after Thansgiving should be included 
DECLARE @StartingDate DATE = '01/01/2010'
    , @CutoffDate DATE = '12/31/2030'
    , @IncludeFridayAfterThanksgiving BIT = 1
    , @IncludeIllinoisElectionDay BIT = 1
    , @IncludeLincolnsBirthday BIT = 1
    , @Year INT
	, @CutoffYear INT
    , @Dt DATE
    , @Cnt INT

SET @Year = DATEPART(YEAR, @StartingDate)
SET @CutoffYear = DATEPART(YEAR, @CutoffDate)

-- Work thru the years
WHILE @Year < @CutoffYear
    BEGIN
        SET @Dt = CAST('1/1/' + CAST(@Year as varchar) as date)
        INSERT INTO NonWorkingDays (IsHoliday, IsWeekend, NonWorkingDay, DayOfWeek, Reason) SELECT 1, 0, @Dt, DATENAME(WEEKDAY, @Dt), 'New Years Day'

		IF @IncludeLincolnsBirthday = 1
			BEGIN
				SET @Dt = CAST('2/12/' + CAST(@Year as varchar) as date)
				INSERT INTO NonWorkingDays (IsHoliday, IsWeekend, NonWorkingDay, DayOfWeek, Reason) SELECT 1, 0, @Dt, DATENAME(WEEKDAY, @Dt), 'Lincoln''s Birthday'
			END

        SET @Dt = CAST('7/4/' + CAST(@Year as varchar) as date)
        INSERT INTO NonWorkingDays (IsHoliday, IsWeekend, NonWorkingDay, DayOfWeek, Reason) SELECT 1, 0, @Dt, DATENAME(WEEKDAY, @Dt), 'Independence Day'
        
		SET @Dt = CAST('11/11/' + CAST(@Year as varchar) as date)
        INSERT INTO NonWorkingDays (IsHoliday, IsWeekend, NonWorkingDay, DayOfWeek, Reason) SELECT 1, 0, @Dt, DATENAME(WEEKDAY, @Dt), 'Veteran''s Day'
        
		SET @Dt = CAST('12/25/' + CAST(@Year as varchar) as date)
        INSERT INTO NonWorkingDays (IsHoliday, IsWeekend, NonWorkingDay, DayOfWeek, Reason) SELECT 1, 0, @Dt, DATENAME(WEEKDAY, @Dt), 'Christmas Day'

        IF @IncludeIllinoisElectionDay = 1 And @Year % 2 = 0
            BEGIN
                SET @Dt = CAST('11/2/' + CAST(@Year as varchar) as date)
                SET @Dt = dbo.GetNextDayOfWeek('11/02/' + CAST(@Year as varchar), 'THURSDAY')
            
                INSERT INTO NonWorkingDays (IsHoliday, IsWeekend, NonWorkingDay, DayOfWeek, Reason) SELECT 1, 0, @Dt, DATENAME(WEEKDAY, @Dt), 'General Election Day'
            END
            
        BEGIN -- All of the holidays that fall on a specific day of the week
            -- Martin Luther King
            SET @Dt = dbo.GetNextDayOfWeek('01/15/' + CAST(@Year as varchar), 'MONDAY')
            INSERT INTO NonWorkingDays (IsHoliday, IsWeekend, NonWorkingDay, DayOfWeek, Reason) SELECT 1, 0, @Dt, DATENAME(WEEKDAY, @Dt), 'Martin Luther King Day'

            -- President's day
            SET @Dt = dbo.GetNextDayOfWeek('02/15/' + CAST(@Year as varchar), 'MONDAY')
            INSERT INTO NonWorkingDays (IsHoliday, IsWeekend, NonWorkingDay, DayOfWeek, Reason) SELECT 1, 0, @Dt, DATENAME(WEEKDAY, @Dt), 'President''s Day'

            -- Memorial day
            SET @Dt = dbo.GetPreviousDayOfWeek('05/31/' + CAST(@Year as varchar), 'MONDAY')
            INSERT INTO NonWorkingDays (IsHoliday, IsWeekend, NonWorkingDay, DayOfWeek, Reason) SELECT 1, 0, @Dt, DATENAME(WEEKDAY, @Dt), 'Memorial Day'

            -- Labor day
            SET @Dt = dbo.GetNextDayOfWeek('09/01/' + CAST(@Year as varchar), 'MONDAY')
            INSERT INTO NonWorkingDays (IsHoliday, IsWeekend, NonWorkingDay, DayOfWeek, Reason) SELECT 1, 0, @Dt, DATENAME(WEEKDAY, @Dt), 'Labor Day'

            -- Columbus day
            SET @Dt = dbo.GetNextDayOfWeek('10/08/' + CAST(@Year as varchar), 'MONDAY')
            INSERT INTO NonWorkingDays (IsHoliday, IsWeekend, NonWorkingDay, DayOfWeek, Reason) SELECT 1, 0, @Dt, DATENAME(WEEKDAY, @Dt), 'Columbus Day'

            BEGIN -- Thanksgiving day
                SET @Dt = dbo.GetNextDayOfWeek('11/22/' + CAST(@Year as varchar), 'THURSDAY')
                INSERT INTO NonWorkingDays (IsHoliday, IsWeekend, NonWorkingDay, DayOfWeek, Reason) SELECT 1, 0, @Dt, DATENAME(WEEKDAY, @Dt), 'Thanksgiving Day'

                IF @IncludeFridayAfterThanksgiving = 1
                    BEGIN
                        SET @Dt = DATEADD(Day, 1, @Dt)
                        INSERT INTO NonWorkingDays (IsHoliday, IsWeekend, NonWorkingDay, DayOfWeek, Reason) SELECT 1, 0, @Dt, DATENAME(WEEKDAY, @Dt), 'Thanksgiving Day (Friday)'
                    END
            END
        END

        SET @Year = @Year + 1
    END

-- Before we add the weekends, we need to check if any of our holidays fall on the weekend
INSERT INTO NonWorkingDays (IsHoliday, IsWeekend, NonWorkingDay, DayOfWeek, Reason)
    SELECT 1 IsHoliday,
        0 IsWeekend,
        DATEADD(DAY, -1, NonWorkingDay) NonWorkingDay,
        DayOfWeek = 'Friday',
        Reason + ' Observed'
    FROM NonWorkingDays
    WHERE DayOfWeek = 'Saturday'

INSERT INTO NonWorkingDays (IsHoliday, IsWeekend, NonWorkingDay, DayOfWeek, Reason)
    SELECT 1 IsHoliday,
        0 IsWeekend,
        DATEADD(DAY, 1, NonWorkingDay) NonWorkingDay,
        DayOfWeek = 'Monday',
        Reason + ' Observed'
    FROM NonWorkingDays
    WHERE DayOfWeek = 'Sunday'

/* Weekends are done last so that a holiday is always recorded. They will still show as weekend day */
BEGIN -- Weekends
    /* Find the first Saturday in the first year */

	DECLARE @Nums TABLE (Num INT)
	DECLARE @Saturdays TABLE (ActualDate DATE)

    SET @Dt = dbo.GetNextDayOfWeek(@StartingDate, 'Saturday')

	;WITH v AS (SELECT * FROM (VALUES(0),(0),(0),(0),(0),(0),(0),(0),(0),(0)) v(z))
	INSERT INTO @Nums
		SELECT TOP 2000 N FROM (SELECT ROW_NUMBER() OVER (ORDER BY v1.z)-1 N FROM v v1 
			CROSS JOIN v v2 CROSS JOIN v v3 CROSS JOIN v v4 CROSS JOIN v v5 CROSS JOIN v v6) Nums

	INSERT INTO @Saturdays
		SELECT DATEADD(DAY, (7 * Num), @Dt) FROM @Nums

	INSERT INTO NonWorkingDays (IsHoliday, IsWeekend, NonWorkingDay, DayOfWeek, Reason)
		SELECT 0, 1, ActualDate, 'Saturday', 'Weekend'
		FROM @Saturdays
		WHERE ActualDate NOT IN (SELECT NonWorkingDay FROM NonWorkingDays) 

	INSERT INTO NonWorkingDays (IsHoliday, IsWeekend, NonWorkingDay, DayOfWeek, Reason)
		SELECT 0, 1, DATEADD(DAY, 1, ActualDate), 'Sunday', 'Weekend'
		FROM @Saturdays
		WHERE ActualDate NOT IN (SELECT NonWorkingDay FROM NonWorkingDays)     
    
    UPDATE NonWorkingDays SET IsWeekend = 1 WHERE DayOfWeek IN ('Saturday', 'Sunday')
END

DELETE FROM NonWorkingDays WHERE NonWorkingDay < @StartingDate Or NonWorkingDay > @CutoffDate

SELECT NonWorkingDay, DayOfWeek, Reason, IsHoliday, IsWeekend FROM NonWorkingDays ORDER BY NonWorkingDay