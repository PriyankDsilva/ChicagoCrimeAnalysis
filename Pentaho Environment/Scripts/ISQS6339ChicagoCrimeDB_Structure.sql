----------------------------------------------DATABASE CREATION----------------------------------------------
DECLARE @DBName nvarchar(128)
SET @DBName = N'ISQS6339ChicagoCrimeDB'


IF (EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE ('[' + name + ']' = @DBName OR name = @DBName)))
BEGIN
	PRINT 'Data Base Exists!!!'
	PRINT 'Proceed Forward with Query Execution.'
END
ELSE
BEGIN 
	PRINT 'Data Base Does not Exists !!!'
	PRINT 'Creating DB . . .'
	CREATE DATABASE ISQS6339ChicagoCrimeDB
	PRINT 'Data Base Created.'
END
GO

USE ISQS6339ChicagoCrimeDB
GO

----------------------------------------------STAGING----------------------------------------------

--ChicagoCrimeStaging
CREATE TABLE ChicagoCrimeStaging
(
  ID FLOAT(53)
, "Case Number" VARCHAR(100)
, "DATE" DATETIME
, Block VARCHAR(100)
, IUCR VARCHAR(100)
, "Primary Type" VARCHAR(100)
, Description VARCHAR(100)
, "Location Description" VARCHAR(100)
, Arrest VARCHAR(100)
, Domestic VARCHAR(100)
, Beat VARCHAR(100)
, District VARCHAR(100)
, Ward FLOAT(53)
, "Community Area" VARCHAR(100)
, "FBI Code" VARCHAR(100)
, "X Coordinate" FLOAT(53)
, "Y Coordinate" FLOAT(53)
, "YEAR" FLOAT(53)
, "Updated On" DATETIME
, Latitude FLOAT(53)
, Longitude FLOAT(53)
, Location VARCHAR(100)
)
;

GO
--PoliceStationStaging
CREATE TABLE PoliceStationStaging
(
  DISTRICT VARCHAR(100)
, ADDRESS VARCHAR(100)
, CITY VARCHAR(100)
, "STATE" VARCHAR(100)
, ZIP VARCHAR(100)
, WEBSITE VARCHAR(100)
, PHONE VARCHAR(100)
, FAX VARCHAR(100)
, TTY VARCHAR(100)
, LOCATION VARCHAR(100)
)
;
GO
--SeniorCenterStaging
CREATE TABLE SeniorCenterStaging
(
  PROGRAM VARCHAR(100)
, "SITE NAME" VARCHAR(100)
, "HOURS OF OPERATION" VARCHAR(100)
, ADDRESS VARCHAR(100)
, CITY VARCHAR(100)
, "STATE" VARCHAR(100)
, ZIP VARCHAR(100)
, PHONE VARCHAR(100)
, LOCATION VARCHAR(100)
)
;
GO
--IUCRStaging
CREATE TABLE IUCRStaging
(
  IUCR VARCHAR(100)
, "PRIMARY DESCRIPTION" VARCHAR(100)
, "SECONDARY DESCRIPTION" VARCHAR(100)
, "INDEX CODE" VARCHAR(100)
)
;

----------------------------------------------VIEW----------------------------------------------
GO
--GeoLocation_Staging
CREATE VIEW GeoLocation_Staging
AS
SELECT CAST(Latitude as DECIMAL(18,5)) as Latitude,CAST(Longitude as DECIMAL(18,5)) as Longitude  FROM ChicagoCrimeStaging 
GROUP BY CAST(Latitude as DECIMAL(18,5)) ,CAST(Longitude as DECIMAL(18,5)) 
UNION
SELECT 
CAST(SUBSTRING(A.LOCATION,LAT_START,(LAT_END-LAT_START+1))  as DECIMAL(18,5)) AS Latitude,
CAST(SUBSTRING(A.LOCATION,LONG_START,(LONG_END-LONG_START+1))   as DECIMAL(18,5)) AS Longitude
FROM 
(
SELECT 
REPLACE(REPLACE(REPLACE(ISNULL( LOCATION, ''), CHAR(13), ''), CHAR(10), ' '),' ','') AS "LOCATION",
LEN(REPLACE(REPLACE(REPLACE(ISNULL( LOCATION, ''), CHAR(13), ''), CHAR(10), ' '),' ','')) AS "LOC_LENGTH",
LEN(REPLACE(REPLACE(REPLACE(ISNULL( LOCATION, ''), CHAR(13), ''), CHAR(10), ' '),' ','')) - CHARINDEX('(',REVERSE(REPLACE(REPLACE(REPLACE(ISNULL( LOCATION, ''), CHAR(13), ''), CHAR(10), ' '),' ',''))) + 2 AS "LAT_START",
LEN(REPLACE(REPLACE(REPLACE(ISNULL( LOCATION, ''), CHAR(13), ''), CHAR(10), ' '),' ','')) - CHARINDEX(',',REVERSE(REPLACE(REPLACE(REPLACE(ISNULL( LOCATION, ''), CHAR(13), ''), CHAR(10), ' '),' ',''))) AS "LAT_END",
LEN(REPLACE(REPLACE(REPLACE(ISNULL( LOCATION, ''), CHAR(13), ''), CHAR(10), ' '),' ','')) - CHARINDEX(',',REVERSE(REPLACE(REPLACE(REPLACE(ISNULL( LOCATION, ''), CHAR(13), ''), CHAR(10), ' '),' ',''))) +2 AS "LONG_START",
LEN(REPLACE(REPLACE(REPLACE(ISNULL( LOCATION, ''), CHAR(13), ''), CHAR(10), ' '),' ','')) - CHARINDEX(')',REVERSE(REPLACE(REPLACE(REPLACE(ISNULL( LOCATION, ''), CHAR(13), ''), CHAR(10), ' '),' ',''))) AS "LONG_END"
FROM PoliceStationStaging
) A
GROUP BY CAST(SUBSTRING(A.LOCATION,LAT_START,(LAT_END-LAT_START+1))  as DECIMAL(18,5)),
CAST(SUBSTRING(A.LOCATION,LONG_START,(LONG_END-LONG_START+1))   as DECIMAL(18,5))
UNION
SELECT
CAST( SUBSTRING(A.LOCATION,LAT_START,(LAT_END-LAT_START+1)) as DECIMAL(18,5))  AS Latitude,
CAST( SUBSTRING(A.LOCATION,LONG_START,(LONG_END-LONG_START+1))  as DECIMAL(18,5))  AS Longitude
FROM 
(
SELECT 
REPLACE(REPLACE(REPLACE(ISNULL( LOCATION, ''), CHAR(13), ''), CHAR(10), ' '),' ','') AS "LOCATION",
LEN(REPLACE(REPLACE(REPLACE(ISNULL( LOCATION, ''), CHAR(13), ''), CHAR(10), ' '),' ','')) AS "LOC_LENGTH",
LEN(REPLACE(REPLACE(REPLACE(ISNULL( LOCATION, ''), CHAR(13), ''), CHAR(10), ' '),' ','')) - CHARINDEX('(',REVERSE(REPLACE(REPLACE(REPLACE(ISNULL( LOCATION, ''), CHAR(13), ''), CHAR(10), ' '),' ',''))) + 2 AS "LAT_START",
LEN(REPLACE(REPLACE(REPLACE(ISNULL( LOCATION, ''), CHAR(13), ''), CHAR(10), ' '),' ','')) - CHARINDEX(',',REVERSE(REPLACE(REPLACE(REPLACE(ISNULL( LOCATION, ''), CHAR(13), ''), CHAR(10), ' '),' ',''))) AS "LAT_END",
LEN(REPLACE(REPLACE(REPLACE(ISNULL( LOCATION, ''), CHAR(13), ''), CHAR(10), ' '),' ','')) - CHARINDEX(',',REVERSE(REPLACE(REPLACE(REPLACE(ISNULL( LOCATION, ''), CHAR(13), ''), CHAR(10), ' '),' ',''))) +2 AS "LONG_START",
LEN(REPLACE(REPLACE(REPLACE(ISNULL( LOCATION, ''), CHAR(13), ''), CHAR(10), ' '),' ','')) - CHARINDEX(')',REVERSE(REPLACE(REPLACE(REPLACE(ISNULL( LOCATION, ''), CHAR(13), ''), CHAR(10), ' '),' ',''))) AS "LONG_END"
FROM SeniorCenterStaging
) A
GROUP BY CAST( SUBSTRING(A.LOCATION,LAT_START,(LAT_END-LAT_START+1)) as DECIMAL(18,5)),
CAST( SUBSTRING(A.LOCATION,LONG_START,(LONG_END-LONG_START+1))  as DECIMAL(18,5));


--senior center source
GO
CREATE VIEW SeniorCenterSourceView 
AS 
(
SELECT PROGRAM,SiteName,
CAST(SUBSTRING(A.LOCATION,LAT_START,(LAT_END-LAT_START+1)) as DECIMAL(18,5)) AS Latitude,
CAST(CAST(SUBSTRING(A.LOCATION,LAT_START,(LAT_END-LAT_START+1)) as FLOAT)as DECIMAL(18,5)) - 0.005 AS LatitudeMin,
CAST(CAST(SUBSTRING(A.LOCATION,LAT_START,(LAT_END-LAT_START+1)) as FLOAT)as DECIMAL(18,5)) + 0.005 AS LatitudeMax,
CAST(SUBSTRING(A.LOCATION,LONG_START,(LONG_END-LONG_START+1)) as DECIMAL(18,5)) AS Longitude,
CAST(CAST(SUBSTRING(A.LOCATION,LONG_START,(LONG_END-LONG_START+1)) as FLOAT) as DECIMAL(18,5))  - 0.005 AS LongitudeMin,
CAST(CAST(SUBSTRING(A.LOCATION,LONG_START,(LONG_END-LONG_START+1)) as FLOAT) as DECIMAL(18,5))  + 0.005 AS LongitudeMax
FROM 
(
SELECT PROGRAM,"SITE NAME" as SiteName,
REPLACE(REPLACE(REPLACE(ISNULL( LOCATION, ''), CHAR(13), ''), CHAR(10), ' '),' ','') AS "LOCATION",
LEN(REPLACE(REPLACE(REPLACE(ISNULL( LOCATION, ''), CHAR(13), ''), CHAR(10), ' '),' ','')) AS "LOC_LENGTH",
LEN(REPLACE(REPLACE(REPLACE(ISNULL( LOCATION, ''), CHAR(13), ''), CHAR(10), ' '),' ','')) - CHARINDEX('(',REVERSE(REPLACE(REPLACE(REPLACE(ISNULL( LOCATION, ''), CHAR(13), ''), CHAR(10), ' '),' ',''))) + 2 AS "LAT_START",
LEN(REPLACE(REPLACE(REPLACE(ISNULL( LOCATION, ''), CHAR(13), ''), CHAR(10), ' '),' ','')) - CHARINDEX(',',REVERSE(REPLACE(REPLACE(REPLACE(ISNULL( LOCATION, ''), CHAR(13), ''), CHAR(10), ' '),' ',''))) AS "LAT_END",
LEN(REPLACE(REPLACE(REPLACE(ISNULL( LOCATION, ''), CHAR(13), ''), CHAR(10), ' '),' ','')) - CHARINDEX(',',REVERSE(REPLACE(REPLACE(REPLACE(ISNULL( LOCATION, ''), CHAR(13), ''), CHAR(10), ' '),' ',''))) +2 AS "LONG_START",
LEN(REPLACE(REPLACE(REPLACE(ISNULL( LOCATION, ''), CHAR(13), ''), CHAR(10), ' '),' ','')) - CHARINDEX(')',REVERSE(REPLACE(REPLACE(REPLACE(ISNULL( LOCATION, ''), CHAR(13), ''), CHAR(10), ' '),' ',''))) AS "LONG_END"
FROM SeniorCenterStaging
) A
GROUP BY PROGRAM,SiteName,SUBSTRING(A.LOCATION,LAT_START,(LAT_END-LAT_START+1)) ,SUBSTRING(A.LOCATION,LONG_START,(LONG_END-LONG_START+1))
);



-- chicago crime source
GO
CREATE VIEW ChicagoCrimeSourceView
AS 
(
SELECT "Case Number" as CaseNumber,"DATE" as CaseDate,
IUCR as IUCRNumber,
"Primary Type" AS IUCRPrimaryDesc,
"Description" AS IUCRSecondaryDesc,
CAST(Latitude as DECIMAL(18,5)) AS Latitude, 
CAST(Longitude as DECIMAL(18,5)) AS Longitude
FROM ChicagoCrimeStaging
GROUP BY "Case Number","DATE",IUCR,
"Primary Type","Description",
Latitude,Longitude
);




GO

--Fact source view senior center nearby
CREATE VIEW SeniorCenterNearbyCrimeFactSource 
AS
(
select 
Program,SiteName,SCSV.Latitude,SCSV.Longitude,
CaseNumber,IUCRNumber,IUCRPrimaryDesc,IUCRSecondaryDesc,convert(date,casedate) as CaseDate,
convert(time(0),casedate) as CaseTime
 from SeniorCenterSourceView SCSV , ChicagoCrimeSourceView CCSV
where CCSV.Latitude >SCSV.LatitudeMin and CCSV.Latitude < SCSV.LatitudeMax
and CCSV.Longitude >SCSV.LongitudeMin and CCSV.Longitude < SCSV.LongitudeMax
);







--Police Station SOurce View 
GO
CREATE VIEW PoliceStationSourceView 
AS 
(
SELECT 
District,
CAST(SUBSTRING(A.LOCATION,LAT_START,(LAT_END-LAT_START+1)) as DECIMAL(18,5))  AS Latitude,
CAST(CAST(SUBSTRING(A.LOCATION,LAT_START,(LAT_END-LAT_START+1)) as FLOAT) as DECIMAL(18,5))  - 0.005 AS LatitudeMin,
CAST(CAST(SUBSTRING(A.LOCATION,LAT_START,(LAT_END-LAT_START+1)) as FLOAT) as DECIMAL(18,5))  + 0.005 AS LatitudeMax,
CAST(SUBSTRING(A.LOCATION,LONG_START,(LONG_END-LONG_START+1)) as DECIMAL(18,5))  AS Longitude,
CAST(CAST(SUBSTRING(A.LOCATION,LONG_START,(LONG_END-LONG_START+1)) as FLOAT) as DECIMAL(18,5))  - 0.005 AS LongitudeMin,
CAST(CAST(SUBSTRING(A.LOCATION,LONG_START,(LONG_END-LONG_START+1)) as FLOAT) as DECIMAL(18,5))  + 0.005 AS LongitudeMax
FROM 
(
SELECT District,
REPLACE(REPLACE(REPLACE(ISNULL( LOCATION, ''), CHAR(13), ''), CHAR(10), ' '),' ','') AS "LOCATION",
LEN(REPLACE(REPLACE(REPLACE(ISNULL( LOCATION, ''), CHAR(13), ''), CHAR(10), ' '),' ','')) AS "LOC_LENGTH",
LEN(REPLACE(REPLACE(REPLACE(ISNULL( LOCATION, ''), CHAR(13), ''), CHAR(10), ' '),' ','')) - CHARINDEX('(',REVERSE(REPLACE(REPLACE(REPLACE(ISNULL( LOCATION, ''), CHAR(13), ''), CHAR(10), ' '),' ',''))) + 2 AS "LAT_START",
LEN(REPLACE(REPLACE(REPLACE(ISNULL( LOCATION, ''), CHAR(13), ''), CHAR(10), ' '),' ','')) - CHARINDEX(',',REVERSE(REPLACE(REPLACE(REPLACE(ISNULL( LOCATION, ''), CHAR(13), ''), CHAR(10), ' '),' ',''))) AS "LAT_END",
LEN(REPLACE(REPLACE(REPLACE(ISNULL( LOCATION, ''), CHAR(13), ''), CHAR(10), ' '),' ','')) - CHARINDEX(',',REVERSE(REPLACE(REPLACE(REPLACE(ISNULL( LOCATION, ''), CHAR(13), ''), CHAR(10), ' '),' ',''))) +2 AS "LONG_START",
LEN(REPLACE(REPLACE(REPLACE(ISNULL( LOCATION, ''), CHAR(13), ''), CHAR(10), ' '),' ','')) - CHARINDEX(')',REVERSE(REPLACE(REPLACE(REPLACE(ISNULL( LOCATION, ''), CHAR(13), ''), CHAR(10), ' '),' ',''))) AS "LONG_END"
FROM PoliceStationStaging
) A
GROUP BY District,SUBSTRING(A.LOCATION,LAT_START,(LAT_END-LAT_START+1)) ,SUBSTRING(A.LOCATION,LONG_START,(LONG_END-LONG_START+1))
);



--Fact source view Police Station nearby
GO
CREATE VIEW PoliceStationNearbyCrimeFactSource 
AS
(
select 
District,PSSV.Latitude,PSSV.Longitude,
CaseNumber,IUCRNumber,IUCRPrimaryDesc,IUCRSecondaryDesc,convert(date,casedate) as CaseDate,
convert(time(0),casedate) as CaseTime
 from PoliceStationSourceView PSSV , ChicagoCrimeSourceView CCSV
where CCSV.Latitude >PSSV.LatitudeMin and CCSV.Latitude < PSSV.LatitudeMax
and CCSV.Longitude >PSSV.LongitudeMin and CCSV.Longitude < PSSV.LongitudeMax
);





--crimefact
GO
CREATE VIEW ChicagoCrimeFactSource 
AS
(
select  
CaseNumber,coalesce(Latitude,0) as Latitude,
coalesce(Longitude,0) as Longitude,
IUCRNumber,IUCRPrimaryDesc,IUCRSecondaryDesc,
convert(date,casedate) as CaseDate,
convert(time(0),casedate) as CaseTime
from ChicagoCrimeSourceView
);



GO
----------------------------------------------DIM TABLES----------------------------------------------
--GeoLocationDim
CREATE TABLE GeoLocationDim
(
  GeoLocationDimKey Integer IDENTITY 
, Latitude FLOAT(53) NOT NULL
, Longitude FLOAT(53) NOT NULL
, ADDRESS VARCHAR(100)
, CITY VARCHAR(100)
, ST VARCHAR(100)
, ZIP VARCHAR(100)
, COUNTRY VARCHAR(100)
PRIMARY KEY (GeoLocationDimKey)
)
;



/*
INSERT INTO geolocationdim 
            (latitude, 
             longitude) 
SELECT latitude, 
       longitude 
FROM   geolocation_staging GLS 
WHERE  NOT EXISTS(SELECT 1 
                  FROM   geolocationdim GLD 
                  WHERE  GLS.latitude = GLD.latitude 
                         AND GLS.longitude = GLD.longitude) 
       AND latitude IS NOT NULL 
       AND longitude IS NOT NULL
GROUP BY latitude,longitude;
*/
GO

--Case DIM
CREATE TABLE CaseDim
(
  CaseDimKey Integer IDENTITY 
, CaseNumber VARCHAR(30) NOT NULL
, Block VARCHAR(100)
, LocDesc VARCHAR(100)
, ArrestFlg Char(1) 
, ArrestDesc VARCHAR(10)
, CaseYear INTEGER
PRIMARY KEY (CaseDimKey)
)
;

/*
SELECT "Case Number" AS CaseNumber,
       coalesce(Block,'No Value') AS Block,
       coalesce("Location Description",'No Value') AS LocDesc,
       CASE
           WHEN Arrest = 'false' OR  Arrest = 'FALSE' OR Arrest = 0 THEN 0
           WHEN Arrest = 'true' OR  Arrest = 'TRUE' OR Arrest = 1  THEN 1
       END AS ArrestFlg,
       CASE
           WHEN Arrest = 'false' OR  Arrest = 'FALSE' OR Arrest = 0  THEN 'No Arrest'
           WHEN Arrest = 'true' OR  Arrest = 'TRUE'  OR Arrest = 1 THEN 'Arrested'
       END AS ArrestDesc,
       "YEAR" AS CaseYear
FROM ChicagoCrimeStaging
GROUP BY "Case Number",
         Block,
         "Location Description",
         CASE
             WHEN Arrest = 'false' OR  Arrest = 'FALSE' OR Arrest = 0  THEN 0
             WHEN Arrest = 'true' OR  Arrest = 'TRUE' OR Arrest = 1 THEN 1
         END,
         CASE
             WHEN Arrest = 'false' OR  Arrest = 'FALSE' OR Arrest = 0  THEN 'No Arrest'
             WHEN Arrest = 'true' OR  Arrest = 'TRUE' OR Arrest = 1  THEN 'Arrested'
         END,
         "YEAR";
*/


--Case DIM
GO

CREATE TABLE CrimeTypeDim
(
  CrimeTypeDimKey Integer IDENTITY 
, IUCRCode VARCHAR(100) NOT NULL
, IUCRPrimaryDesc VARCHAR(100) NOT NULL
, IUCRSecondaryDesc VARCHAR(100) NOT NULL
PRIMARY KEY (CrimeTypeDimKey)
)
;

/*
SELECT IUCR AS IUCRCode,
       "PRIMARY DESCRIPTION" AS IUCRPrimaryDesc,
       "SECONDARY DESCRIPTION" AS IUCRSecondaryDesc
FROM IUCRStaging
GROUP BY IUCR,
         "PRIMARY DESCRIPTION",
         "SECONDARY DESCRIPTION";
*/

GO
-- Senior Center DIM
CREATE TABLE SeniorCenterDim
(
  SeniorCenterDimKey Integer IDENTITY 
, PROGRAM VARCHAR(100) NOT NULL
, SiteName VARCHAR(100) NOT NULL
, WorkingHrDesc VARCHAR(100)
, PHONE VARCHAR(100)
PRIMARY KEY (SeniorCenterDimKey)
)
;

/*
SELECT PROGRAM,
       "SITE NAME" AS SiteName,
       "HOURS OF OPERATION" AS WorkingHrDesc,
       PHONE
FROM SeniorCenterStaging
GROUP BY PROGRAM,
         "SITE NAME",
         "HOURS OF OPERATION",
         PHONE;
*/
GO
--Police Station DIM

CREATE TABLE PoliceStationDim
(
  PoliceStationDimKey Integer IDENTITY
, DISTRICT VARCHAR(100) NOT NULL
, WEBSITE VARCHAR(100)
, Phone VARCHAR(100)
, Fax VARCHAR(100)
PRIMARY KEY (PoliceStationDimKey)
);



/*
SELECT DISTRICT,
       WEBSITE,
       coalesce(PHONE,'No Value') as Phone,
       coalesce(FAX,'No Value') as Fax
FROM PoliceStationStaging
GROUP BY DISTRICT,
         WEBSITE,
         coalesce(PHONE,'No Value'),
         coalesce(FAX,'No Value');
*/


--DAteDime
GO

CREATE TABLE #DateDimStaging
(
  [dates]       DATE PRIMARY KEY, 
  [days]        AS DATEPART(DAY,      [dates]),
  [months]      AS DATEPART(MONTH,    [dates]),
  FirstOfMonth AS CONVERT(DATE, DATEADD(MONTH, DATEDIFF(MONTH, 0, [dates]), 0)),
  [MonthName]  AS DATENAME(MONTH,    [dates]),
  [week]       AS DATEPART(WEEK,     [dates]),
  [ISOweek]    AS DATEPART(ISO_WEEK, [dates]),
  [DayOfWeek]  AS DATEPART(WEEKDAY,  [dates]),
  [quarter]    AS DATEPART(QUARTER,  [dates]),
  [years]       AS DATEPART(YEAR,     [dates]),
  FirstOfYear  AS CONVERT(DATE, DATEADD(YEAR,  DATEDIFF(YEAR,  0, [dates]), 0)),
  Style112     AS CONVERT(CHAR(8),   [dates], 112),
  Style101     AS CONVERT(CHAR(10),  [dates], 101)
);

DECLARE @StartDate DATE = '20000101', @NumberOfYears INT = 30;
DECLARE @CutoffDate DATE = DATEADD(YEAR, @NumberOfYears, @StartDate);

WITH GenerateNumberSeries AS (
    SELECT 1 AS Num
    UNION ALL
    SELECT Num+1 FROM GenerateNumberSeries WHERE Num+1<=DATEDIFF(DAY, @StartDate, @CutoffDate)
)
INSERT #DateDimStaging([dates])
SELECT Num 
FROM
(
SELECT Num = DATEADD(DAY, Num - 1, @StartDate) FROM 
(SELECT Num  FROM GenerateNumberSeries ) NumSeries
) InsDate
option (maxrecursion 32767)

GO


CREATE TABLE DateDim
(
  DateDimKey             INT         NOT NULL PRIMARY KEY,
  [Dates]              DATE        NOT NULL,
  [Days]               TINYINT     NOT NULL,
  [Weekday]           TINYINT     NOT NULL,
  WeekDayName         VARCHAR(10) NOT NULL,
  IsWeekend           BIT         NOT NULL,
  IsHoliday           BIT         NOT NULL,
  HolidayText         VARCHAR(64) NULL,
  DOWInMonth          TINYINT     NOT NULL,
  [DayOfYear]         SMALLINT    NOT NULL,
  WeekOfMonth         TINYINT     NOT NULL,
  [Months]             TINYINT     NOT NULL,
  [MonthName]         VARCHAR(10) NOT NULL,
  [Quarter]           TINYINT     NOT NULL,
  QuarterName         VARCHAR(6)  NOT NULL,
  [Years]              INT         NOT NULL,
  MMYYYY              CHAR(6)     NOT NULL,
  MonthYear           CHAR(7)     NOT NULL,
  FirstDayOfMonth     DATE        NOT NULL,
  FirstDayOfYear      DATE        NOT NULL
);
GO

INSERT DateDim 
SELECT
  DateDimKey       = CONVERT(INT, Style112),
  [Dates]        = [dates],
  [Days]         = CONVERT(TINYINT, [days]),
  [Weekday]     = CONVERT(TINYINT, [DayOfWeek]),
  [WeekDayName] = CONVERT(VARCHAR(10), DATENAME(WEEKDAY, [dates])),
  [IsWeekend]   = CONVERT(BIT, CASE WHEN [DayOfWeek] IN (1,7) THEN 1 ELSE 0 END),
  [IsHoliday]   = CONVERT(BIT, 0),
  HolidayText   = CONVERT(VARCHAR(64), NULL),
  [DOWInMonth]  = CONVERT(TINYINT, ROW_NUMBER() OVER 
                  (PARTITION BY FirstOfMonth, [DayOfWeek] ORDER BY [dates])),
  [DayOfYear]   = CONVERT(SMALLINT, DATEPART(DAYOFYEAR, [dates])),
  WeekOfMonth   = CONVERT(TINYINT, DENSE_RANK() OVER 
                  (PARTITION BY [years], [months] ORDER BY [week])),
  [Months]       = CONVERT(TINYINT, [months]),
  [MonthName]   = CONVERT(VARCHAR(10), [MonthName]),
  [Quarter]     = CONVERT(TINYINT, [quarter]),
  QuarterName   = CONVERT(VARCHAR(6), CASE [quarter] WHEN 1 THEN 'First' 
                  WHEN 2 THEN 'Second' WHEN 3 THEN 'Third' WHEN 4 THEN 'Fourth' END), 
  [Years]        = [years],
  MMYYYY        = CONVERT(CHAR(6), LEFT(Style101, 2)    + LEFT(Style112, 4)),
  MonthYear     = CONVERT(CHAR(7), LEFT([MonthName], 3) + LEFT(Style112, 4)),
  FirstDayOfMonth     = FirstOfMonth,
  FirstDayOfYear      = FirstOfYear
FROM #DateDimStaging;

GO


--Update Holidays
;WITH x AS 
(
  SELECT DateDimKey, [Dates], IsHoliday, HolidayText, FirstDayOfYear,
    DOWInMonth, [MonthName], [WeekDayName], [Days],
    LastDOWInMonth = ROW_NUMBER() OVER 
    (
      PARTITION BY FirstDayOfMonth, [Weekday] 
      ORDER BY [Dates] DESC
    )
  FROM dbo.DateDim
)
UPDATE x SET IsHoliday = 1, HolidayText = CASE
  WHEN ([Dates] = FirstDayOfYear) 
    THEN 'New Year''s Day'
  WHEN ([DOWInMonth] = 3 AND [MonthName] = 'January' AND [WeekDayName] = 'Monday')
    THEN 'Martin Luther King Day'    -- (3rd Monday in January)
  WHEN ([DOWInMonth] = 3 AND [MonthName] = 'February' AND [WeekDayName] = 'Monday')
    THEN 'President''s Day'          -- (3rd Monday in February)
  WHEN ([LastDOWInMonth] = 1 AND [MonthName] = 'May' AND [WeekDayName] = 'Monday')
    THEN 'Memorial Day'              -- (last Monday in May)
  WHEN ([MonthName] = 'July' AND [Days] = 4)
    THEN 'Independence Day'          -- (July 4th)
  WHEN ([DOWInMonth] = 1 AND [MonthName] = 'September' AND [WeekDayName] = 'Monday')
    THEN 'Labour Day'                -- (first Monday in September)
  WHEN ([DOWInMonth] = 2 AND [MonthName] = 'October' AND [WeekDayName] = 'Monday')
    THEN 'Columbus Day'              -- Columbus Day (second Monday in October)
  WHEN ([MonthName] = 'November' AND [Days] = 11)
    THEN 'Veterans'' Day'            -- Veterans' Day (November 11th)
  WHEN ([DOWInMonth] = 4 AND [MonthName] = 'November' AND [WeekDayName] = 'Thursday')
    THEN 'Thanksgiving Day'          -- Thanksgiving Day (fourth Thursday in November)
  WHEN ([MonthName] = 'December' AND [Days] = 25)
    THEN 'Christmas Day'
  END
WHERE 
  ([Dates] = FirstDayOfYear)
  OR ([DOWInMonth] = 3     AND [MonthName] = 'January'   AND [WeekDayName] = 'Monday')
  OR ([DOWInMonth] = 3     AND [MonthName] = 'February'  AND [WeekDayName] = 'Monday')
  OR ([LastDOWInMonth] = 1 AND [MonthName] = 'May'       AND [WeekDayName] = 'Monday')
  OR ([MonthName] = 'July' AND [Days] = 4)
  OR ([DOWInMonth] = 1     AND [MonthName] = 'September' AND [WeekDayName] = 'Monday')
  OR ([DOWInMonth] = 2     AND [MonthName] = 'October'   AND [WeekDayName] = 'Monday')
  OR ([MonthName] = 'November' AND [Days] = 11)
  OR ([DOWInMonth] = 4     AND [MonthName] = 'November' AND [WeekDayName] = 'Thursday')
  OR ([MonthName] = 'December' AND [Days] = 25);

  
 GO
 
 
UPDATE d SET IsHoliday = 1, HolidayText = 'Black Friday'
FROM dbo.DateDim AS d
INNER JOIN
(
  SELECT DateDimKey, [Years], [DayOfYear]
  FROM dbo.DateDim 
  WHERE HolidayText = 'Thanksgiving Day'
) AS src 
ON d.[Years] = src.[Years] 
AND d.[DayOfYear] = src.[DayOfYear] + 1;

GO


CREATE FUNCTION dbo.GetEasterHolidays(@year INT) 
RETURNS TABLE
WITH SCHEMABINDING
AS 
RETURN 
(
  WITH x AS 
  (
    SELECT [Dates] = CONVERT(DATE, RTRIM(@year) + '0' + RTRIM([Months]) 
        + RIGHT('0' + RTRIM([Days]),2))
      FROM (SELECT [Months], [Days] = DaysToSunday + 28 - (31 * ([Months] / 4))
      FROM (SELECT [Months] = 3 + (DaysToSunday + 40) / 44, DaysToSunday
      FROM (SELECT DaysToSunday = paschal - ((@year + @year / 4 + paschal - 13) % 7)
      FROM (SELECT paschal = epact - (epact / 28)
      FROM (SELECT epact = (24 + 19 * (@year % 19)) % 30) 
        AS epact) AS paschal) AS dts) AS m) AS d
  )
  SELECT [Dates], HolidayName = 'Easter Sunday' FROM x
    UNION ALL SELECT DATEADD(DAY,-2,[Dates]), 'Good Friday'   FROM x
    UNION ALL SELECT DATEADD(DAY, 1,[Dates]), 'Easter Monday' FROM x
);

GO


;WITH x AS 
(
  SELECT d.[Dates], d.IsHoliday, d.HolidayText, h.HolidayName
    FROM dbo.DateDim AS d
    CROSS APPLY dbo.GetEasterHolidays(d.[Years]) AS h
    WHERE d.[Dates] = h.[Dates]
)
UPDATE x SET IsHoliday = 1, HolidayText = HolidayName;


GO

Update dbo.DateDim 
SET HolidayText='-'
WHERE HolidayText IS NULL;

ALTER TABLE dbo.DateDim DROP COLUMN DOWInMonth;
ALTER TABLE dbo.DateDim DROP COLUMN FirstDayOfMonth;
ALTER TABLE dbo.DateDim DROP COLUMN FirstDayOfYear;



GO
--Time DIM
CREATE TABLE TimeDim
(
 TimeDimKey Integer IDENTITY(1,1) NOT NULL,
 Times CHAR(8) NOT NULL,
 Hours CHAR(2) NOT NULL,
 MilitaryHour CHAR(2) NOT NULL,
 Minutes CHAR(2) NOT NULL,
 Seconds CHAR(2) NOT NULL,
 AmPm CHAR(2) NOT NULL,
 StandardTime CHAR(11) NULL
);

GO

DECLARE @Time DATETIME

SET @TIME = CONVERT(VARCHAR,'12:00:00 AM',108)

WHILE @TIME <= '11:59:59 PM'
 BEGIN
 INSERT INTO dbo.TimeDim(Times, Hours, MilitaryHour, Minutes, Seconds, AmPm)
 SELECT CONVERT(VARCHAR,@TIME,108) Times
 , CASE 
 WHEN DATEPART(HOUR,@Time) > 12 THEN DATEPART(HOUR,@Time) - 12
 ELSE DATEPART(HOUR,@Time) 
 END AS Hours
 , CAST(SUBSTRING(CONVERT(VARCHAR,@TIME,108),1,2) AS INT) MilitaryHour
 , DATEPART(MINUTE,@Time) Minutes
 , DATEPART(SECOND,@Time) Seconds
 , CASE 
 WHEN DATEPART(HOUR,@Time) >= 12 THEN 'PM'
 ELSE 'AM'
 END AS AmPm

 SELECT @TIME = DATEADD(second,1,@Time)
 END;

UPDATE TimeDim
SET Hours = '0' + Hours
WHERE LEN(Hours) = 1;

UPDATE TimeDim
SET Minutes = '0' + Minutes
WHERE LEN(Minutes) = 1;

UPDATE TimeDim
SET Seconds = '0' + Seconds
WHERE LEN(Seconds) = 1;

UPDATE TimeDim
SET MilitaryHour = '0' + MilitaryHour
WHERE LEN(MilitaryHour) = 1;

UPDATE TimeDim
SET StandardTime = Hours + ':' + Minutes + ':' + Seconds + ' ' + AmPm
WHERE StandardTime is null
AND Hours <> '00';

UPDATE TimeDim
SET StandardTime = '12' + ':' + Minutes + ':' + Seconds + ' ' + AmPm
WHERE Hours = '00';


GO

ALTER TABLE TimeDim ADD PRIMARY KEY (TimeDimKey);

--TimeLookup
GO
CREATE VIEW TimeDimLookup 
AS
(
select TimeDimKey, convert(DATETIME,Times) as Times from TimeDim
);

GO


-----------------------------------------------------------------------------------------------------------------------------------------

-------------------Foreign Key Constrains---------------------
--FK_SeniorCenterID--
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FK_SeniorCenterID]') and OBJECTPROPERTY(id, N'IsForeignKey') = 1)
BEGIN
	ALTER TABLE [dbo].SeniorCenterNearbyCrimeFact DROP CONSTRAINT FK_SeniorCenterID
END
GO

--FK_SeniorCenterGeoLocID--
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FK_SeniorCenterGeoLocID]') and OBJECTPROPERTY(id, N'IsForeignKey') = 1)
BEGIN
	ALTER TABLE [dbo].SeniorCenterNearbyCrimeFact DROP CONSTRAINT FK_SeniorCenterGeoLocID
END
GO

--FK_SC_CaseNumber--
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FK_SC_CaseNumber]') and OBJECTPROPERTY(id, N'IsForeignKey') = 1)
BEGIN
	ALTER TABLE [dbo].SeniorCenterNearbyCrimeFact DROP CONSTRAINT FK_SC_CaseNumber
END
GO

--FK_SC_IUCR--
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FK_SC_IUCR]') and OBJECTPROPERTY(id, N'IsForeignKey') = 1)
BEGIN
	ALTER TABLE [dbo].SeniorCenterNearbyCrimeFact DROP CONSTRAINT FK_SC_IUCR
END
GO

--FK_SC_CaseRecordDate--
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FK_SC_CaseRecordDate]') and OBJECTPROPERTY(id, N'IsForeignKey') = 1)
BEGIN
	ALTER TABLE [dbo].SeniorCenterNearbyCrimeFact DROP CONSTRAINT FK_SC_CaseRecordDate
END
GO

--FK_SC_CaseRecordTime--
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FK_SC_CaseRecordTime]') and OBJECTPROPERTY(id, N'IsForeignKey') = 1)
BEGIN
	ALTER TABLE [dbo].SeniorCenterNearbyCrimeFact DROP CONSTRAINT FK_SC_CaseRecordTime
END
GO







---------------------------------------FACT TABLES-------------------------------------------
CREATE TABLE [dbo].[SeniorCenterNearbyCrimeFact](
	[SeniorCenterID] [int] NULL,
	[SeniorCenterGeoLocID] [int] NULL,
	[CaseNumber] [int] NULL,
	[IUCR] [int] NULL,
	[CaseRecordDate] [int] NULL,
	[CaseRecordTime] [int] NULL,
	[rc] [int] NULL,
	Constraint FK_SeniorCenterID Foreign key (SeniorCenterID) references SeniorCenterDim(SeniorCenterDimKey),
	Constraint FK_SeniorCenterGeoLocID Foreign key (SeniorCenterGeoLocID) references GeoLocationDim(GeoLocationDimKey),
	Constraint FK_SC_CaseNumber Foreign key (CaseNumber) references CaseDim(CaseDimKey),
	Constraint FK_SC_IUCR Foreign key (IUCR) references CrimeTypeDim(CrimeTypeDimKey),
	Constraint FK_SC_CaseRecordDate Foreign key (CaseRecordDate) references DateDim(DateDimKey),
	Constraint FK_SC_CaseRecordTime Foreign key (CaseRecordTime) references TimeDim(TimeDimKey)
) ON [PRIMARY];




-------------------Foreign Key Constrains---------------------
--FK_PoliceStationID--
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FK_PoliceStationID]') and OBJECTPROPERTY(id, N'IsForeignKey') = 1)
BEGIN
	ALTER TABLE [dbo].PoliceStationNearbyCrimeFact DROP CONSTRAINT FK_PoliceStationID
END
GO

--FK_PoliceStationGeoLocID--
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FK_PoliceStationGeoLocID]') and OBJECTPROPERTY(id, N'IsForeignKey') = 1)
BEGIN
	ALTER TABLE [dbo].PoliceStationNearbyCrimeFact DROP CONSTRAINT FK_PoliceStationGeoLocID
END
GO

--FK_PS_CaseNumber--
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FK_PS_CaseNumber]') and OBJECTPROPERTY(id, N'IsForeignKey') = 1)
BEGIN
	ALTER TABLE [dbo].PoliceStationNearbyCrimeFact DROP CONSTRAINT FK_PS_CaseNumber
END
GO

--FK_PS_IUCR--
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FK_PS_IUCR]') and OBJECTPROPERTY(id, N'IsForeignKey') = 1)
BEGIN
	ALTER TABLE [dbo].PoliceStationNearbyCrimeFact DROP CONSTRAINT FK_PS_IUCR
END
GO

--FK_PS_CaseRecordDate--
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FK_PS_CaseRecordDate]') and OBJECTPROPERTY(id, N'IsForeignKey') = 1)
BEGIN
	ALTER TABLE [dbo].PoliceStationNearbyCrimeFact DROP CONSTRAINT FK_PS_CaseRecordDate
END
GO

--FK_PS_CaseRecordTime--
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FK_PS_CaseRecordTime]') and OBJECTPROPERTY(id, N'IsForeignKey') = 1)
BEGIN
	ALTER TABLE [dbo].PoliceStationNearbyCrimeFact DROP CONSTRAINT FK_PS_CaseRecordTime
END
GO



CREATE TABLE [dbo].[PoliceStationNearbyCrimeFact](
	[PoliceStationID] [int] NULL,
	[PoliceStationGeoLocID] [int] NULL,
	[CaseNumber] [int] NULL,
	[IUCR] [int] NULL,
	[CaseRecordDate] [int] NULL,
	[CaseRecordTime] [int] NULL,
	[rc] [int] NULL,
	Constraint FK_PoliceStationID Foreign key (PoliceStationID) references PoliceStationDim(PoliceStationDimKey),
	Constraint FK_PoliceStationGeoLocID Foreign key (PoliceStationGeoLocID) references GeoLocationDim(GeoLocationDimKey),
	Constraint FK_PS_CaseNumber Foreign key (CaseNumber) references CaseDim(CaseDimKey),
	Constraint FK_PS_IUCR Foreign key (IUCR) references CrimeTypeDim(CrimeTypeDimKey),
	Constraint FK_PS_CaseRecordDate Foreign key (CaseRecordDate) references DateDim(DateDimKey),
	Constraint FK_PS_CaseRecordTime Foreign key (CaseRecordTime) references TimeDim(TimeDimKey)
) ON [PRIMARY];






-------------------Foreign Key Constrains---------------------

--FK_CaseNumber--
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FK_CaseNumber]') and OBJECTPROPERTY(id, N'IsForeignKey') = 1)
BEGIN
	ALTER TABLE [dbo].ChicagoCrimeFact DROP CONSTRAINT FK_CaseNumber
END
GO


--FK_CrimeGeoLocID--
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FK_CrimeGeoLocID]') and OBJECTPROPERTY(id, N'IsForeignKey') = 1)
BEGIN
	ALTER TABLE [dbo].ChicagoCrimeFact DROP CONSTRAINT FK_CrimeGeoLocID
END
GO


--FK_IUCR--
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FK_IUCR]') and OBJECTPROPERTY(id, N'IsForeignKey') = 1)
BEGIN
	ALTER TABLE [dbo].ChicagoCrimeFact DROP CONSTRAINT FK_IUCR
END
GO

--FK_CaseRecordDate--
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FK_CaseRecordDate]') and OBJECTPROPERTY(id, N'IsForeignKey') = 1)
BEGIN
	ALTER TABLE [dbo].ChicagoCrimeFact DROP CONSTRAINT FK_CaseRecordDate
END
GO

--FK_CaseRecordTime--
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FK_CaseRecordTime]') and OBJECTPROPERTY(id, N'IsForeignKey') = 1)
BEGIN
	ALTER TABLE [dbo].ChicagoCrimeFact DROP CONSTRAINT FK_CaseRecordTime
END
GO

CREATE TABLE [dbo].[ChicagoCrimeFact](
	[CaseNumber] [int] NULL,
	[CrimeGeoLocID] [int] NULL,
	[IUCR] [int] NULL,
	[CaseRecordDate] [int] NULL,
	[CaseRecordTime] [int] NULL,
	[rc] [int] NULL,
	Constraint FK_CaseNumber Foreign key (CaseNumber) references CaseDim(CaseDimKey),
	Constraint FK_CrimeGeoLocID Foreign key (CrimeGeoLocID) references GeoLocationDim(GeoLocationDimKey),
	Constraint FK_IUCR Foreign key (IUCR) references CrimeTypeDim(CrimeTypeDimKey),
	Constraint FK_CaseRecordDate Foreign key (CaseRecordDate) references DateDim(DateDimKey),
	Constraint FK_CaseRecordTime Foreign key (CaseRecordTime) references TimeDim(TimeDimKey)
) ON [PRIMARY];


