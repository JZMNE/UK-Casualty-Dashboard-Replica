/*CREATING SCHEMAS*/

IF NOT EXISTS (SELECT SCHEMA_NAME
				FROM INFORMATION_SCHEMA.SCHEMATA
				WHERE CATALOG_NAME = 'UK_Traffic' AND SCHEMA_NAME='stg')
	execute('CREATE SCHEMA stg');
GO
--------------------------------------------------------
 IF NOT EXISTS (SELECT SCHEMA_NAME 
				FROM INFORMATION_SCHEMA.SCHEMATA
				WHERE CATALOG_NAME = 'UK_Traffic' AND SCHEMA_NAME='f')
	execute('CREATE SCHEMA f');
GO
----------------------------------------------------------
IF NOT EXISTS (SELECT SCHEMA_NAME
				FROM INFORMATION_SCHEMA.SCHEMATA
				WHERE CATALOG_NAME = 'UK_Traffic' AND  SCHEMA_NAME='dim')
	execute('CREATE SCHEMA dim');
GO

----------------------------------------------------------
IF NOT EXISTS (SELECT SCHEMA_NAME
				FROM INFORMATION_SCHEMA.SCHEMATA
				WHERE CATALOG_NAME = 'UK_Traffic' AND  SCHEMA_NAME='err')
	execute('CREATE SCHEMA err');
GO
--------------------------------------------------------
IF NOT EXISTS (SELECT SCHEMA_NAME 
				FROM INFORMATION_SCHEMA.SCHEMATA
				WHERE CATALOG_NAME = 'UK_Traffic' AND SCHEMA_NAME='rpt')
	execute('CREATE SCHEMA rpt');
GO


----------------DIM DIRECTION AND ITES ERROR TABLE----------------------------------------------
GO
IF NOT EXISTS (SELECT TABLE_NAME
			FROM UK_Traffic.INFORMATION_SCHEMA.TABLES	
			WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_NAME = 'Direction')
	execute('CREATE TABLE [dim].[Direction] (
		    [kDirection] int NOT NULL,
		    [DirectionCode] varchar(5) NULL,
		    [DirectionName] varchar(8) NULL,

		    CONSTRAINT pk_Direction PRIMARY KEY(kDirection)

)');
GO

IF NOT EXISTS (SELECT TABLE_NAME
			FROM UK_Traffic.INFORMATION_SCHEMA.TABLES	
			WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_NAME = 'eDirection')
	execute('CREATE TABLE [err].[eDirection] (
		    [kDirection] int  NULL,
		    [DirectionCode] varchar(5) NULL,
		    [DirectionName] varchar(8) NULL,
		    [LocalRuntime] datetime NULL,
		    [UTCRuntime] datetime NULL,
		    [ZoneOffset] int NULL,
		    [ErrorCode] int NULL,
		    [ErrorColumn] int NULL
)');
GO

TRUNCATE TABLE dim.Direction;
GO


----------------DIM LOCAL AUTHORITY AND ITS ERROR TABLE----------------------------------------------
GO
IF NOT EXISTS (SELECT TABLE_NAME
			FROM UK_Traffic.INFORMATION_SCHEMA.TABLES	
			WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_NAME = 'LocalAuthority')
	execute('CREATE TABLE [dim].[LocalAuthority] (
		    [kLocalAuthorityId] int NOT NULL,
		    [RegionId] int NULL,
		    [RegionName] varchar(255) NULL,
		    [RegionCode] varchar(255) NULL,
		    [LocalAuthorityId] int NULL,
		    [LocalAuthorityName] varchar(255) NULL,
		    [LocalAuthorityCode] varchar(50) NULL

		    CONSTRAINT pk_LocalAuthority PRIMARY KEY(kLocalAuthorityId)

)');
GO

IF NOT EXISTS (SELECT TABLE_NAME
			FROM UK_Traffic.INFORMATION_SCHEMA.TABLES	
			WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_NAME = 'eLocalAuthority')
	execute('CREATE TABLE [err].[eLocalAuthority] (
		    [kLocalAuthorityId] int NOT NULL,
		    [RegionId] int NULL,
		    [RegionName] varchar(255) NULL,
		    [RegionCode] varchar(255) NULL,
		    [LocalAuthorityId] int NULL,
		    [LocalAuthorityName] varchar(255) NULL,
		    [LocalAuthorityCode] varchar(50) NULL,
		    [LocalRuntime] datetime NULL,
		    [UTCRuntime] datetime NULL,
		    [ZoneOffset] int NULL,
		    [ErrorCode] int NULL,
		    [ErrorColumn] int NULL
)');
GO

TRUNCATE TABLE dim.LocalAuthority;
GO


----------------DIM ROAD CATEGORY AND ITS ERROR TABLE----------------------------------------------
GO
IF NOT EXISTS (SELECT TABLE_NAME
			FROM UK_Traffic.INFORMATION_SCHEMA.TABLES	
			WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_NAME = 'RoadCategory')
	execute('CREATE TABLE [dim].[RoadCategory] (
		    [kRoadCategory] int NOT NULL,
		    [RoadType] varchar(50) NULL,
		    [RoadCategory] varchar(10) NULL,
		    [CatDescription] varchar(50) NULL

		    CONSTRAINT pk_RoadCategory PRIMARY KEY(kRoadCategory)

)');
GO

IF NOT EXISTS (SELECT TABLE_NAME
			FROM UK_Traffic.INFORMATION_SCHEMA.TABLES	
			WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_NAME = 'eRoadCategory')
	execute('CREATE TABLE [err].[eRoadCategory] (
		    [kRoadCategory] int NOT NULL,
		    [RoadType] varchar(50) NULL,
		    [RoadCategory] varchar(10) NULL,
		    [CatDescription] varchar(50) NULL,
		    [LocalRuntime] datetime NULL,
		    [UTCRuntime] datetime NULL,
		    [ZoneOffset] int NULL,
		    [ErrorCode] int NULL,
		    [ErrorColumn] int NULL
)');
GO

TRUNCATE TABLE dim.RoadCategory;
GO


--------------------HOUR OF DAY AND ITS ERROR---------------------- 
GO
IF NOT EXISTS (SELECT TABLE_NAME
			FROM UK_Traffic.INFORMATION_SCHEMA.TABLES	
			WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_NAME = 'HourofDay')
	execute('CREATE TABLE [dim].[HourofDay] (
		    [kHourofDay] int NOT NULL,
		    [HourofDay] int NULL,
		    [HourDescription] varchar(50) NULL

		    CONSTRAINT pk_HourofDay PRIMARY KEY(kHourofDay)

)');
GO

IF NOT EXISTS (SELECT TABLE_NAME
			FROM UK_Traffic.INFORMATION_SCHEMA.TABLES	
			WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_NAME = 'eHourofDay')
	execute('CREATE TABLE [err].[eHourofDay] (
		    [kHourofDay] int NOT NULL,
		    [HourofDay] int NULL,
		    [HourDescription] varchar(50) NULL,
		    [LocalRuntime] datetime NULL,
		    [UTCRuntime] datetime NULL,
		    [ZoneOffset] int NULL,
		    [ErrorCode] int NULL,
		    [ErrorColumn] int NULL
)');
GO

TRUNCATE TABLE dim.HourofDay;
GO

-------------------------------------------------------
SELECT ROW_NUMBER() OVER (ORDER BY direction_of_travel)  as 'kDirection' 
	 ,Direction_of_travel as 'DirectionCode'
	 ,(CASE
		WHEN Direction_of_travel = 'N' THEN 'North'
		WHEN Direction_of_travel = 'S' THEN 'South'
		WHEN Direction_of_travel = 'E' THEN 'East'
		WHEN Direction_of_travel = 'W' THEN 'West'
		WHEN Direction_of_travel = 'C' THEN 'Combined'
		WHEN Direction_of_travel = 'J' THEN 'Unknown'
	  END) as 'DirectionName'
	  ,GETDATE() as 'LocalRuntime'
	  ,GETUTCDATE() as 'UTCRuntime'
	  ,DATEDIFF(hh, GETUTCDATE(), GETDATE()) as  'ZoneOffset'
FROM stg.Traffic
GROUP BY Direction_of_travel
ORDER BY 1

----------------------------CALENDAR DIMENSION----------------------------------------------------------
IF NOT EXISTS (SELECT TABLE_NAME 
      FROM UK_Traffic.INFORMATION_SCHEMA.TABLES 
            WHERE TABLE_TYPE = 'BASE TABLE' and TABLE_NAME = 'Calendar'
   )
   exec('CREATE TABLE [dim].[Calendar](
  [kDate] [int] NOT NULL,
  [Date] [date] NOT NULL,
  [Day] [int] NULL,
  [DayName] [nvarchar](30) NULL,
  [Week] [int] NULL,
  [ISOWeek] [int] NULL,
  [DayOfWeek] [int] NULL,
  [Month] [int] NULL,
  [MonthName] [nvarchar](30) NULL,
  [Quarter] [int] NULL,
  [Year] [int] NULL,
  [FirstOfMonth] [date] NULL,
  [LastOfYear] [date] NULL,
  [DayOfYear] [int] NULL
   )'
	 );
GO 

IF NOT EXISTS ( SELECT [name]
			 FROM UK_Traffic.sys.key_constraints
			 WHERE [name] = 'pk_Calendar'
			 )
	exec('ALTER TABLE dim.Calendar
		ADD CONSTRAINT pk_Calendar PRIMARY KEY(kDate)'
		)
;


TRUNCATE TABLE dim.Calendar;


DECLARE @StartDate  date = '20000101';

DECLARE @CutoffDate date = DATEADD(DAY, -1, DATEADD(YEAR, 23, @StartDate));

;WITH seq(n) AS 
(
  SELECT 0 UNION ALL SELECT n + 1 FROM seq
  WHERE n < DATEDIFF(DAY, @StartDate, @CutoffDate)
),
d(d) AS 
(
  SELECT DATEADD(DAY, n, @StartDate) FROM seq
),
src AS
(
  SELECT
    kDate		  = CAST(REPLACE(CAST ([d] as varchar(10)),'-','') as INT),			
    Date		  = CONVERT(date, d),
    Day          = DATEPART(DAY,       d),
    DayName      = DATENAME(WEEKDAY,   d),
    Week         = DATEPART(WEEK,      d),
    ISOWeek      = DATEPART(ISO_WEEK,  d),
    DayOfWeek    = DATEPART(WEEKDAY,   d),
    Month        = DATEPART(MONTH,     d),
    MonthName    = DATENAME(MONTH,     d),
    Quarter      = DATEPART(Quarter,   d),
    Year         = DATEPART(YEAR,      d),
    FirstOfMonth = DATEFROMPARTS(YEAR(d), MONTH(d), 1),
    LastOfYear   = DATEFROMPARTS(YEAR(d), 12, 31),
    DayOfYear    = DATEPART(DAYOFYEAR, d)
  FROM d
)
INSERT INTO dim.Calendar
SELECT * 
FROM src
ORDER BY Date
OPTION (MAXRECURSION 0);
GO

--------- Local Authority dim(datamart name) OR All_LocalAuthorities(Used in data modelling)------------------
SELECT distinct Local_authority_id as 'kLocalAuthorityId'
	 ,Region_id as 'RegionId'
	 ,Region_name as 'RegionName'
	 ,Region_ons_code as 'RegionCode'
	 ,Local_authority_id as 'LocalAuthorityId'
	 ,Local_authority_name as 'LocalAuthorityName'
	 ,Local_authority_code as 'LocalAuthorityCode'
	 ,GETDATE() as 'LocalRuntime'
	 ,GETUTCDATE() as 'UTCRuntime'
	 ,DATEDIFF(hh, GETUTCDATE(), GETDATE()) as  'ZoneOffset'
FROM stg.Traffic
ORDER BY 1



------------------------ ROAD DIMENSION ------------------------------------
SELECT ROW_NUMBER() OVER (ORDER BY Road_category) + 100 as 'kRoadCategory'
	, Road_type as 'RoadType'
	 ,Road_category as 'RoadCategory'
	 ,(CASE
		WHEN Road_category = 'PA' THEN 'Class A Principal road'
		WHEN Road_category = 'PM' THEN 'M or Class A Principal Motorway'
		WHEN Road_category = 'TA' THEN 'Class A Trunk road'
		WHEN Road_category = 'TM' THEN 'M or Class A Trunk Motorway'
		WHEN Road_category = 'MB' THEN 'Minor Class B road'
		WHEN Road_category = 'MCU' THEN 'Minor Class C road or Unclassified road'
	 END) as 'CatDescription'
	 ,GETDATE() as 'LocalRuntime'
	 ,GETUTCDATE() as 'UTCRuntime'
	 ,DATEDIFF(hh, GETUTCDATE(), GETDATE()) as  'ZoneOffset'
FROM stg.Traffic
GROUP BY Road_category, Road_type


--------------------HOUR OF DAY ---------------------- 
SELECT DISTINCT [hour] as kHourofDay
	, [hour] as 'HourofDay'
	,(CASE
		WHEN [hour] = 0 then '12am to 1am'
		WHEN [hour] = 1 then '1am to 2am'
		WHEN [hour] = 2 then '2am to 3am'
		WHEN [hour] = 3 then '3am to 4am'
		WHEN [hour] = 4 then '4am to 5am'
		WHEN [hour] = 5 then '5am to 6am'
		WHEN [hour] = 6 then '6am to 7am'
		WHEN [hour] = 7 then '7am to 8am'
		WHEN [hour] = 8 then '8am to 9am'
		WHEN [hour] = 9 then '9am to 10am'
		WHEN [hour] = 10 then '10am to 11am'
		WHEN [hour] = 11 then '11am to 12pm'
		WHEN [hour] = 12 then '12pm to 1pm'
		WHEN [hour] = 13 then '1pm to 2pm'
		WHEN [hour] = 14 then '2pm to 3pm'
		WHEN [hour] = 15 then '3pm to 4pm'
		WHEN [hour] = 16 then '4pm to 5pm'
		WHEN [hour] = 17 then '5pm to 6pm'
		WHEN [hour] = 18 then '6pm to 7pm'
	  END) as 'HourDescription'
	 ,GETDATE() as 'LocalRuntime'
	 ,GETUTCDATE() as 'UTCRuntime'
	 ,DATEDIFF(hh, GETUTCDATE(), GETDATE()) as  'ZoneOffset'
FROM stg.Traffic
ORDER BY 1



------------------- CREATE AND ADDING FOREIGN KEY CONSTRAINTS---------------------
GO
IF NOT EXISTS (SELECT TABLE_NAME
			FROM UK_Traffic.INFORMATION_SCHEMA.TABLES	
			WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_NAME = 'TrafficFact')
	execute('CREATE TABLE [f].[TrafficFact](
	[CountPointId] [bigint] NULL,
	[kDate] [int]  NULL,
	[kDirection] [int]  NULL,
	[kHourofDay] [int]  NULL,
	[kLocalAuthorityId] [int]  NULL,
	[kRoadCategory] [int] NULL,
	[Latitude] [varchar](75) NULL,
	[Longitude] [varchar](75) NULL,
	[PedalCycles] [bigint] NOT NULL,
	[TwoWheeledMotorVehicle] [bigint]  NULL,
	[CarsandTaxis] [bigint]  NULL,
	[BusesandCoaches] [bigint]  NULL,
	[LGVs] [bigint]  NULL,
	[HGVs_2_rigid_Axle] [bigint]  NULL,
	[HGVs_3_or_4_articulated_Axle] [bigint]  NULL,
	[HGVs_3_rigid_Axle] [bigint]  NULL,
	[HGVs_4_or_more_rigid_Axle] [bigint]  NULL,
	[HGVs_5_articulated_Axle] [bigint]  NULL,
	[HGVs_6_articulated_axle] [bigint]  NULL
		    
)');
GO

-------------------------------------------------------------
IF NOT EXISTS (SELECT [name] 
			FROM UK_Traffic.sys.foreign_keys
			WHERE [name] = 'fkCalendar')
	execute('ALTER TABLE f.TrafficFact
			ADD CONSTRAINT fkCalendar FOREIGN KEY (kDate)
			REFERENCES dim.Calendar(kDate);')
GO

IF NOT EXISTS (SELECT [name] 
			FROM UK_Traffic.sys.foreign_keys
			WHERE [name] = 'fkDirection')
	execute('ALTER TABLE f.TrafficFact
			ADD CONSTRAINT fkDirection FOREIGN KEY (kDirection)
			REFERENCES dim.Direction(kDirection);')
GO

IF NOT EXISTS (SELECT [name] 
			FROM UK_Traffic.sys.foreign_keys
			WHERE [name] = 'fkHourofDay')
	execute('ALTER TABLE f.TrafficFact
			ADD CONSTRAINT fkHourofDay FOREIGN KEY (kHourofDay)
			REFERENCES dim.HourofDay(kHourofDay);')
GO

IF NOT EXISTS (SELECT [name] 
			FROM UK_Traffic.sys.foreign_keys
			WHERE [name] = 'fkLocalAuthority')
	execute('ALTER TABLE f.TrafficFact
			ADD CONSTRAINT fkLocalAuthority FOREIGN KEY (kLocalAuthorityId)
			 REFERENCES dim.LocalAuthority(kLocalAuthorityId);')
GO

IF NOT EXISTS (SELECT [name] 
			FROM UK_Traffic.sys.foreign_keys
			WHERE [name] = 'fkRoadCategory')
	execute('ALTER TABLE f.TrafficFact
		ADD CONSTRAINT fkRoadCategory FOREIGN KEY (kRoadCategory)
		  REFERENCES dim.RoadCategory (kRoadCategory);')
GO

--------------------DROPPING FOREIGN KEYS-----------------------------------------------------
IF EXISTS (SELECT [name] 
			FROM UK_Traffic.sys.foreign_keys
			WHERE [name] = 'fkCalendar')
	execute('ALTER TABLE f.TrafficFact
			DROP CONSTRAINT fkCalendar;')
GO

IF EXISTS (SELECT [name] 
			FROM UK_Traffic.sys.foreign_keys
			WHERE [name] = 'fkDirection')
	execute('ALTER TABLE f.TrafficFact
			DROP CONSTRAINT fkDirection;')
GO

IF EXISTS (SELECT [name] 
			FROM UK_Traffic.sys.foreign_keys
			WHERE [name] = 'fkHourofDay')
	execute('ALTER TABLE f.TrafficFact
			DROP CONSTRAINT fkHourofDay;')
GO

IF EXISTS (SELECT [name] 
			FROM UK_Traffic.sys.foreign_keys
			WHERE [name] = 'fkLocalAuthority')
	execute('ALTER TABLE f.TrafficFact
			DROP CONSTRAINT fkLocalAuthority;')
GO

IF EXISTS (SELECT [name] 
			FROM UK_Traffic.sys.foreign_keys
			WHERE [name] = 'fkRoadCategory')
	execute('ALTER TABLE f.TrafficFact
		DROP CONSTRAINT fkRoadCategory;')
GO
---------------------------------------------------------------------------
TRUNCATE TABLE f.TrafficFact;
GO


-----------------------DROPPING PRIMARY KEY------------------------------------------------------
ALTER TABLE dim.Calendar
DROP CONSTRAINT pk_Calendar;
GO

ALTER TABLE dim.Direction
DROP CONSTRAINT pk_Direction;
GO

ALTER TABLE dim.HourofDay
DROP CONSTRAINT pk_HourofDay;
GO

ALTER TABLE dim.LocalAuthority
DROP CONSTRAINT pk_LocalAuthority;
GO

ALTER TABLE dim.RoadCategory
DROP CONSTRAINT pk_RoadCategory;
GO


---------------------TRUNCATE TABLE ------------------------------
TRUNCATE TABLE dim.Calendar;
GO
TRUNCATE TABLE dim.Direction;
GO
TRUNCATE TABLE dim.HourofDay;
GO
TRUNCATE TABLE dim.LocalAuthority;
GO
TRUNCATE TABLE dim.RoadCategory;
GO
TRUNCATE TABLE err.eDirection;
GO
TRUNCATE TABLE err.eHourofDay;
GO
TRUNCATE TABLE err.eLocalAuthority;
GO
TRUNCATE TABLE err.eRoadCategory;
GO
----------------------DELETE TABLE------------------------------------
DROP TABLE dim.Calendar;
GO
DROP TABLE dim.Direction;
GO
DROP TABLE dim.HourofDay;
GO
DROP TABLE dim.LocalAuthority;
GO
DROP TABLE dim.RoadCategory;
GO
------------------------------------------------------------------------
SELECT stg.Count_point_id as 'CountPointId'
	,cal.kDate
	,dir.kDirection
	,hod.kHourofDay
	,la.kLocalAuthorityId
	,rc.kRoadCategory
	,stg.Latitude
	,stg.Longitude
	,ISNULL(stg.Pedal_cycles, 0) as 'PedalCycles'
	,ISNULL(stg.Two_wheeled_motor_vehicles, 0) as 'TwoWheeledMotorVehicle'
	,ISNULL(stg.Cars_and_taxis, 0) as 'CarsandTaxis'
	,ISNULL(stg.Buses_and_coaches, 0) as 'BusesandCoaches'
	,ISNULL(stg.LGVs,0) as 'LGVs'
	,ISNULL(stg.HGVs_2_rigid_axle, 0) as 'HGVs_2_rigid_Axle'
	,ISNULL(stg.HGVs_3_or_4_articulated_axle, 0) as 'HGVs_3_or_4_articulated_Axle'
	,ISNULL(stg.HGVs_3_rigid_axle, 0) as 'HGVs_3_rigid_Axle'
	,ISNULL(stg.HGVs_4_or_more_rigid_axle, 0) as 'HGVs_4_or_more_rigid_Axle'
	,ISNUll(stg.HGVs_5_articulated_axle, 0) as 'HGVs_5_articulated_Axle'
	,ISNULL(stg.HGVs_6_articulated_axle, 0) as 'HGVs_6_articulated_axle'
FROM stg.Traffic stg
INNER JOIN dim.Calendar cal
	ON stg.Count_date = cal.Date
INNER JOIN dim.HourofDay hod
	ON stg.[hour] = hod.HourofDay
INNER JOIN dim.LocalAuthority la
	ON stg.Local_authority_id = la.LocalAuthorityId
INNER JOIN dim.RoadCategory rc
	ON stg.Road_category = rc.RoadCategory
INNER JOIN dim.Direction dir
	ON stg.Direction_of_travel = dir.DirectionCode
--4,657,464 rows

--------------------------------------
----------Use in Reporting for drilling
SELECT Region_id
	 ,count(DISTINCT Local_authority_id)
FROM stg.Traffic
GROUP BY Region_id
ORDER BY 1

SELECT count(Distinct Region_id )
FROM stg.Traffic

SELECT count(Distinct Local_authority_id )
FROM stg.Traffic
GO

SELECT count(*)
FROM stg.Traffic
WHERE Start_junction_road_name IS NULL

SELECT count(*)
FROM stg.Traffic
WHERE End_junction_road_name IS NULL

SELECT count(*)
FROM stg.Traffic
WHERE Link_length_km IS NULL


SELECT count(*)
FROM stg.Traffic
WHERE Link_length_miles IS NULL

SELECT count(*)
FROM stg.Traffic
WHERE Cars_and_taxis IS NULL
------------------------------------
