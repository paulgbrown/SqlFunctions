DROP TABLE NonWorkingDays
GO
/*
Creates a table of non-working days. This can then be subtracted from the number of days
in a date range to determine the number of working days in the range.
*/
CREATE TABLE NonWorkingDays (
    NonWorkingDay date NOT NULL PRIMARY KEY,
    IsHoliday bit NOT NULL,
    IsWeekend bit NOT NULL,
    DayOfWeek char(9) NOT NULL, 
    Reason varchar(50) NOT NULL
    )

-- Set the range of years and if the Friday after Thansgiving should be included 
DECLARE @StartingYear int = 2010
    , @CutoffYear int = 2030
    , @IncludeFridayAfterThanksgiving bit = 1
    , @IncludeIllinoisElectionDay bit = 1
    , @IncludeLincolnsBirthday bit = 1
    , @Year int
    , @Dt Date
    , @Cnt int

SET @Year = @StartingYear

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
                WHILE DATENAME(WEEKDAY, @Dt) <> 'TUESDAY'
                    BEGIN
                        SET @Dt = DATEADD(Day, 1, @Dt)
                    END
                INSERT INTO NonWorkingDays (IsHoliday, IsWeekend, NonWorkingDay, DayOfWeek, Reason) SELECT 1, 0, @Dt, DATENAME(WEEKDAY, @Dt), 'General Election Day'
            END
            
        BEGIN -- All of the holidays that fall on a specific day of the week
            -- Martin Luther King
            SET @Dt = CAST('1/15/' + CAST(@Year as varchar) as date)
            WHILE DATENAME(WEEKDAY, @Dt) <> 'MONDAY'
                BEGIN
                    SET @Dt = DATEADD(Day, 1, @Dt)
                END
            INSERT INTO NonWorkingDays (IsHoliday, IsWeekend, NonWorkingDay, DayOfWeek, Reason) SELECT 1, 0, @Dt, DATENAME(WEEKDAY, @Dt), 'Martin Luther King Day'

            -- President's day
            SET @Dt = CAST('2/15/' + CAST(@Year as varchar) as date)
            WHILE DATENAME(WEEKDAY, @Dt) <> 'MONDAY'
                BEGIN
                    SET @Dt = DATEADD(Day, 1, @Dt)
                END
            INSERT INTO NonWorkingDays (IsHoliday, IsWeekend, NonWorkingDay, DayOfWeek, Reason) SELECT 1, 0, @Dt, DATENAME(WEEKDAY, @Dt), 'President''s Day'

            -- Memorial day
            SET @Dt = CAST('5/31/' + CAST(@Year as varchar) as date)
            WHILE DATENAME(WEEKDAY, @Dt) <> 'MONDAY'
                BEGIN
                    SET @Dt = DATEADD(Day, -1, @Dt)
                END
            INSERT INTO NonWorkingDays (IsHoliday, IsWeekend, NonWorkingDay, DayOfWeek, Reason) SELECT 1, 0, @Dt, DATENAME(WEEKDAY, @Dt), 'Memorial Day'

            -- Labor day
            SET @Dt = CAST('9/1/' + CAST(@Year as varchar) as date)
            WHILE DATENAME(WEEKDAY, @Dt) <> 'MONDAY'
                BEGIN
                    SET @Dt = DATEADD(Day, 1, @Dt)
                END
            INSERT INTO NonWorkingDays (IsHoliday, IsWeekend, NonWorkingDay, DayOfWeek, Reason) SELECT 1, 0, @Dt, DATENAME(WEEKDAY, @Dt), 'Labor Day'

            -- Columbus day
            SET @Dt = CAST('10/8/' + CAST(@Year as varchar) as date)
            WHILE DATENAME(WEEKDAY, @Dt) <> 'MONDAY'
                BEGIN
                    SET @Dt = DATEADD(Day, 1, @Dt)
                END
            INSERT INTO NonWorkingDays (IsHoliday, IsWeekend, NonWorkingDay, DayOfWeek, Reason) SELECT 1, 0, @Dt, DATENAME(WEEKDAY, @Dt), 'Columbus Day'

            BEGIN -- Thanksgiving day
                SET @Dt = CAST('11/22/' + CAST(@Year as varchar) as date)
                WHILE DATENAME(WEEKDAY, @Dt) <> 'THURSDAY'
                    BEGIN
                        SET @Dt = DATEADD(Day, 1, @Dt)
                    END
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
    SET @Dt = CAST('1/1/' + CAST(@StartingYear as varchar) as date)
    WHILE DATENAME(WEEKDAY, @Dt) <> 'SATURDAY'
        BEGIN
            SELECT @Cnt = COUNT(*) FROM NonWorkingDays WHERE NonWorkingDay = @Dt
            IF DATENAME(WEEKDAY, @Dt) = 'SUNDAY' And @Cnt = 0
                INSERT INTO NonWorkingDays (IsHoliday, IsWeekend, NonWorkingDay, DayOfWeek, Reason) SELECT 0, 1, @Dt, DATENAME(WEEKDAY, @Dt), 'Weekend'

            SET @Dt = DATEADD(Day, 1, @Dt)
        END

    /* Now loop thru each weekend until we get to the cutoff year */
    WHILE YEAR(@Dt) < @CutoffYear
        BEGIN
            SELECT @Cnt = COUNT(*) FROM NonWorkingDays WHERE NonWorkingDay = @Dt
            IF @Cnt = 0
                INSERT INTO NonWorkingDays (IsHoliday, IsWeekend, NonWorkingDay, DayOfWeek, Reason) SELECT 0, 1, @Dt, DATENAME(WEEKDAY, @Dt), 'Weekend'
            SET @Dt = DATEADD(Day, 1, @Dt)
            SELECT @Cnt = COUNT(*) FROM NonWorkingDays WHERE NonWorkingDay = @Dt
            IF @Cnt = 0
                INSERT INTO NonWorkingDays (IsHoliday, IsWeekend, NonWorkingDay, DayOfWeek, Reason) SELECT 0, 1, @Dt, DATENAME(WEEKDAY, @Dt), 'Weekend'
            SET @Dt = DATEADD(Day, 6, @Dt)
        END

    UPDATE NonWorkingDays SET IsWeekend = 1 WHERE DayOfWeek IN ('Saturday', 'Sunday')
END
SELECT NonWorkingDay, DayOfWeek, Reason, IsHoliday, IsWeekend FROM NonWorkingDays ORDER BY NonWorkingDay

