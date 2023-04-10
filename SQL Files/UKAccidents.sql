/******************************TESTING DATA******************************************/
SELECT Count(*)
FROM [stg].[accidents]

SELECT Count(*)
FROM [stg].[casualites]

select count (distinct [accident_index])
FROM stg.accidents

select count (distinct [accident_index])
FROM stg.casualites

SELECT top 1000 *
FROM stg.accidents acc
LEFT JOIN stg.casualites cas
	ON acc.accident_index = cas.accident_index

SELECT top 10 *
FROM [stg].[accidents]

SELECT top 10 *
FROM [stg].[casualites]



SELECT DISTINCT pedestrian_crossing_physical_facilities
FROM stg.accidents
ORDER BY 1

/******************************CREATING SCHEMA**************************************************/
IF NOT EXISTS (SELECT SCHEMA_NAME
			FROM Uk_Staging.INFORMATION_SCHEMA.SCHEMATA
			WHERE SCHEMA_NAME = 'stg')
EXECUTE ('Create schema stg')
;

IF NOT EXISTS (SELECT SCHEMA_NAME
			FROM Uk_Staging.INFORMATION_SCHEMA.SCHEMATA
			WHERE SCHEMA_NAME = 'dim')
EXECUTE ('Create schema dim')
;

IF NOT EXISTS (SELECT SCHEMA_NAME
			FROM Uk_Staging.INFORMATION_SCHEMA.SCHEMATA
			WHERE SCHEMA_NAME = 'f')
EXECUTE ('Create schema f')
;
IF NOT EXISTS (SELECT SCHEMA_NAME
			FROM Uk_Staging.INFORMATION_SCHEMA.SCHEMATA
			WHERE SCHEMA_NAME = 'vw')
EXECUTE ('Create schema vw')

IF NOT EXISTS (SELECT SCHEMA_NAME
			FROM Uk_Staging.INFORMATION_SCHEMA.SCHEMATA
			WHERE SCHEMA_NAME = 'rpt')
EXECUTE ('Create schema rpt')

--------------------------------DIMENSIONS TO BUILD---------------
-- casualty age group --done
-- Casualty class
-- Casualty sex -- done
-- Road User Type -- done
-- Severity --done
-- Local Highway authority - done
-- Police force Area - done
-- Road type - motorway, rural , urban, unknown
-- speed limit --done
-- dim calendar -done
			
/******************************BUILDING OUT DIMENSIONS FOR ACCIDENTS******************************************/

-----------Police Force-------------------
DROP TABLE if exists stg.Police_Force;

SELECT DISTINCT (police_force) as 'Police_Force_Code'
	 ,(CASE
		WHEN police_force = 1 THEN 'Metropolitan Police'
		WHEN police_force = 3 THEN 'Cumbria'
		WHEN police_force = 4 THEN 'Lancashire'
		WHEN police_force = 5 THEN 'Merseyside'
		WHEN police_force = 6 THEN 'Greater Manchester'
		WHEN police_force = 7 THEN 'Cheshire'
		WHEN police_force = 10 THEN 'Northumbria'
		WHEN police_force = 11 THEN 'Durham'
		WHEN police_force = 12 THEN 'North Yorkshire'
		WHEN police_force = 13 THEN 'West Yorkshire'
		WHEN police_force = 14 THEN 'South Yorkshire'
		WHEN police_force = 16 THEN 'Humberside'
		WHEN police_force = 17 THEN 'Cleveland'
		WHEN police_force = 20 THEN 'West Midlands'
		WHEN police_force = 21 THEN 'Staffordshire'
		WHEN police_force = 22 THEN 'West Mercia'
		WHEN police_force = 23 THEN 'Warwickshire'
		WHEN police_force = 30 THEN 'Derbyshire'
		WHEN police_force = 31 THEN 'Nottinghamshire'
		WHEN police_force = 32 THEN 'Lincolnshire'
		WHEN police_force = 33 THEN 'Leicestershire'
		WHEN police_force = 34 THEN 'Northamptonshire'
		WHEN police_force = 35 THEN 'Cambridgeshire'
		WHEN police_force = 36 THEN 'Norfolk'
		WHEN police_force = 37 THEN 'Suffolk'
		WHEN police_force = 40 THEN 'Bedfordshire'
		WHEN police_force = 41 THEN 'Hertfordshire'
		WHEN police_force = 42 THEN 'Essex'
		WHEN police_force = 43 THEN 'Thames Valley'
		WHEN police_force = 44 THEN 'Hampshire'
		WHEN police_force = 45 THEN 'Surrey'
		WHEN police_force = 46 THEN 'Kent'
		WHEN police_force = 47 THEN 'Sussex'
		WHEN police_force = 48 THEN 'City of London'
		WHEN police_force = 50 THEN 'Devon and Cornwall'
		WHEN police_force = 52 THEN 'Avon and Somerset'
		WHEN police_force = 53 THEN 'Gloucestershire'
		WHEN police_force = 54 THEN 'Wiltshire'
		WHEN police_force = 55 THEN 'Dorset'
		WHEN police_force = 60 THEN 'North Wales'
		WHEN police_force = 61 THEN 'Gwent'
		WHEN police_force = 62 THEN 'South Wales'
		WHEN police_force = 63 THEN 'Dyfed-Powys'
		WHEN police_force = 91 THEN 'Northern'
		WHEN police_force = 92 THEN 'Grampian'
		WHEN police_force = 93 THEN 'Tayside'
		WHEN police_force = 94 THEN 'Fife'
		WHEN police_force = 95 THEN 'Lothian and Borders'
		WHEN police_force = 96 THEN 'Central'
		WHEN police_force = 97 THEN 'Strathclyde'
		WHEN police_force = 98 THEN 'Dumfries and Galloway'
		WHEN police_force = 99 THEN 'Unknown'
	 END) as 'Police_Force_Desc' 
INTO stg.Police_Force
From stg.accidents
ORDER by 1
GO

-----------------------------------
DROP TABLE if exists dim.Police_Force

SELECT DISTINCT Police_Force_Code
	,IIF(Police_Force_Desc IN ('Northern','Grmapian','Tayside','Fife', 'Lothian and Borders', 'Central', 'Strathclyde','Dumfries and Galloway', 'Unknown' ),'Police Scotland', Police_Force_Desc) as 'Police_Force_Desc'
INTO dim.Police_Force
FROM stg.Police_Force
GO
--------------Calendar-------------------------
DROP TABLE if exists dim.Calendar;

DECLARE @StartDate  date;
SET @StartDate = '20170101';

DECLARE @CutoffDate date
SET @CutoffDate = DATEADD(DAY, -1, DATEADD(YEAR, 5, @StartDate));

-- CHANGE NOTHING BELOW THIS LINE
;WITH seq(n) AS 
(
	SELECT 0 
	UNION ALL
	SELECT n + 1
	FROM seq
	WHERE n < DATEDIFF(DAY, @StartDate, @CutoffDate)
),
d(d) AS 
(
	SELECT DATEADD(DAY, n, @StartDate) 
	FROM seq
),
src AS
(
	SELECT
		Date			= CONVERT(date, d),
		DayOfMonth	= DATEPART(DAY,  d),
		DayName		= DATENAME(WEEKDAY, d),
		DayOfWeek		= DATEPART(WEEKDAY,   d),
		Month		= DATEPART(MONTH,     d),
		MonthName		= DATENAME(MONTH,     d),
		MonthAbbrev	= LEFT(DATENAME(MONTH, d),3),
		Quarter		= DATEPART(Quarter,   d),
		Qtr			= (CASE
					WHEN DATEPART(QUARTER, d) = 1 THEN 'Q1'
					WHEN DATEPART(QUARTER, d) = 2 THEN 'Q2'
					WHEN DATEPART(QUARTER, d) = 3 THEN 'Q3'
					WHEN DATEPART(QUARTER, d) = 4 THEN 'Q4'
				 ELSE  'Err'
				END),
		Year			= DATEPART(YEAR,      d),
		DayOfYear		= DATEPART(DAYOFYEAR, d)
		
	  FROM d
)
SELECT * 
INTO dim.Calendar
FROM src
ORDER BY Date
OPTION (MAXRECURSION 0);
GO;


---------------Severity--------------
DROP TABLE if exists dim.Severity;

Select distinct (accident_severity) as 'Severity_Code'
	 ,(CASE
		WHEN accident_severity = 1 THEN 'Fatal'
		WHEN accident_severity = 2 THEN 'Serious'
		WHEN accident_severity = 3 THEN 'Slight'
	 END) as 'Severity_Desc'
--INTO dim.Severity
FROM stg.accidents
ORDER BY 1
GO;

---------------CASULATY SEX--------------
DROP TABLE if exists dim.Casualty_Sex;

SELECT distinct (sex_of_casualty) as 'Cas_Sex_Code'
	 ,(CASE
		WHEN sex_of_casualty = 1 THEN 'Male'
		WHEN sex_of_casualty = 2 THEN 'Female'
		WHEN sex_of_casualty = -1 THEN 'Unknown'
		WHEN sex_of_casualty = 9 THEN 'Unknown'
	 END) as 'Casualty_Sex_Desc'
--INTO dim.Casualty_Sex
FROM stg.casualites
ORDER BY 1
GO;

------------------JUNCTION DETAILS----------------------
DROP TABLE if exists dim.JunctionDetail

SELECT DISTINCT junction_detail as JuncDet_Code
	 ,(CASE
		WHEN junction_detail = 0 THEN 'Not at Junction'
		WHEN junction_detail = 1 THEN 'Roundabout'
		WHEN junction_detail = 2 THEN 'Mini-roundabout'
		WHEN junction_detail = 3 THEN 'T or Staggered junction'
		WHEN junction_detail = 5 THEN 'Slip road'
		WHEN junction_detail = 6 THEN 'Crossroads'
		WHEN junction_detail = 7 THEN 'Not Roundabout'
		WHEN junction_detail = 8 THEN 'Private Driveway'
		WHEN junction_detail = 9 THEN 'Other Junction'
		ELSE 'Unknown'
	END) as 'JunctionDetail'
INTO dim.JunctionDetail
FROM stg.accidents
ORDER BY 1
GO

------------------JUNCTION CONTROL----------------------
DROP TABLE if exists dim.JuncCtrl

SELECT DISTINCT junction_control as JuncCtrl_Code
	 ,(CASE
		WHEN junction_control = 0 THEN 'None within 20m'
		WHEN junction_control = 1 THEN 'Authorised Person'
		WHEN junction_control = 2 THEN 'Auto Traffic Signal'
		WHEN junction_control = 3 THEN 'Stop Sign'
		WHEN junction_control = 4 THEN 'Give Way or Uncontrolled'
		ELSE 'Unknown'
	END) as 'JunctionControl'
INTO dim.JuncCtrl
FROM stg.accidents
ORDER BY 1
GO

------------------HAZARDS----------------------
DROP TABLE if exists dim.Hazard

SELECT DISTINCT carriageway_hazards as Hazard_Code
	 ,(CASE
		WHEN carriageway_hazards  = 0 THEN 'None'
		WHEN carriageway_hazards  = 1 THEN 'Vehicle Load'
		WHEN carriageway_hazards  = 2 THEN 'Other Object'
		WHEN carriageway_hazards  = 3 THEN 'Previous Accident'
		WHEN carriageway_hazards  = 4 THEN 'Dog on RD'
		WHEN carriageway_hazards  = 5 THEN 'Other Animal'
		WHEN carriageway_hazards  = 6 THEN 'Pedestrian in CW'
		WHEN carriageway_hazards  = 7 THEN 'Any Animal in CW'
		ELSE 'Unknown'
	END) as 'Hazard'
INTO dim.Hazard
FROM stg.accidents
ORDER BY 1
GO

------------------CROSSING CONTROL----------------------
DROP TABLE if exists dim.CrossingCtrl

SELECT DISTINCT pedestrian_crossing_human_control as CrsCtrl_Code
	 ,(CASE
		WHEN pedestrian_crossing_human_control = 0 THEN 'None with 50m'
		WHEN pedestrian_crossing_human_control  = 1 THEN 'By School Crossing Patrol'
		WHEN pedestrian_crossing_human_control  = 2 THEN 'By Authorized Person'
		ELSE 'Unknown'
	END) as 'Crossing_Control'
INTO dim.CrossingCtrl
FROM stg.accidents
ORDER BY 1
GO

------------------CROSSING FACILITIES----------------------
DROP TABLE if exists dim.CrossingFac

SELECT DISTINCT pedestrian_crossing_physical_facilities as CrsFac_Code
	 ,(CASE
		WHEN pedestrian_crossing_physical_facilities = 0 THEN 'None with 50m'
		WHEN pedestrian_crossing_physical_facilities  = 1 THEN 'Zebra Crossing'
		WHEN pedestrian_crossing_physical_facilities  = 4 THEN 'Light Crossing'
		WHEN pedestrian_crossing_physical_facilities  = 5 THEN 'Pedestrian Phase'
		WHEN pedestrian_crossing_physical_facilities  = 7 THEN 'FootBridge/Subway'
		WHEN pedestrian_crossing_physical_facilities  = 8 THEN 'Central Refuge'
		ELSE 'Unknown'
	END) as 'Crossing_Facilities'
INTO dim.CrossingFac
FROM stg.accidents
ORDER BY 1
GO
--------------- SPEED LIMIT DIMENSION --------------
DROP TABLE if exists dim.Speed_Limit

SELECT DISTINCT speed_limit
	 ,(CASE
		WHEN speed_limit = 20 THEN '20 Km/Hr'
		WHEN speed_limit = 30 THEN '30 Km/Hr'
		WHEN speed_limit = 40 THEN '40 Km/Hr'
		WHEN speed_limit = 50 THEN '50 Km/Hr'
		WHEN speed_limit = 60 THEN '60 Km/Hr'
		WHEN speed_limit = 70 THEN '70 Km/Hr'
		WHEN speed_limit = -1 THEN 'Unknown Km/Hr'
	END) as 'Speed_Limit_Desc'
--INTO dim.Speed_Limit
FROM stg.accidents
ORDER BY 1
GO
------------AGE GROUP DIMENSION--------------
DROP TABLE if exists dim.Age;

SELECT distinct (age_of_casualty) as Casualty_Age
	 ,(CASE
		WHEN age_of_casualty BETWEEN 0 AND 15 THEN '0 - 15'
		WHEN age_of_casualty BETWEEN 16 AND 24 THEN '16 - 24'
		WHEN age_of_casualty BETWEEN 25 AND 59 THEN '25 - 59'
		WHEN age_of_casualty >= 60 THEN '60+'
		ELSE 'Unknown'
	  END) as 'Age_Group'
INTO dim.Age
FROM stg.casualites
ORDER BY 1
GO

--------LOCAL HIGHWAY AUTHORITY----------------
SELECT distinct local_authority_highway
FROM stg.accidents
GO;

--------------ROAD USER TYPR-----------------
DROP TABLE if exists dim.Road_User_Type

SELECT distinct casualty_type as 'Road_User_Type'
	 ,(CASE
		WHEN casualty_type = 0 THEN 'Pedestrian'
		WHEN casualty_type = 1 THEN 'Pedal Cyclist'
		WHEN casualty_type IN (8, 9, 10) THEN 'Car Occupant'
		WHEN casualty_type = 11 THEN 'Bus Occupant'
		WHEN casualty_type = 19 THEN 'Van Occupant'
		WHEN casualty_type IN (2,3,4,5,23,97)  THEN 'Motor Cyclist'
		WHEN casualty_type IN (20, 21) THEN 'HGV Occupant'
		WHEN casualty_type IN (16,17,18,22,90,98,-1,99) THEN 'Other Veh Occupant'
		ELSE 'Unknown'
	 END) as 'Road_User'
--INTO dim.Road_User_Type
FROM stg.casualites
ORDER BY 1
GO

---------------CASUALTY CLASS ---------------------
DROP TABLE if exists dim.Casualty_Class;

SELECT distinct casualty_class as 'Cas_Class_Code'
	,(CASE
		WHEN casualty_class = 1 THEN 'Driver or Rider'
		WHEN casualty_class = 2 THEN 'Passenger'
		WHEN casualty_class = 3 THEN 'Pedestrian'
	 END) as 'Cas_Class_Desc'
INTO dim.Casualty_Class
FROM stg.casualites
GO;

-----------FACT ACCIDENTS----------------------
DROP TABLE IF EXISTS f.Accidents

SELECT [accident_index]
      ,[accident_reference]
	 ,longitude
	 ,latitude
	 ,[acc_date]
      ,[time]
      ,[police_force]
      ,[accident_severity]
      ,[number_of_vehicles]
      ,[number_of_casualties]
      ,[local_authority_highway]
      ,[first_road_class]
      ,[first_road_number]
      ,[road_type]
	 ,(CASE
		WHEN  first_road_class IN (1,2) THEN '111'
		WHEN urban_or_rural_area = 1 AND first_road_class NOT IN (1,2) THEN '212'
		WHEN urban_or_rural_area = 2 AND first_road_class NOT IN (1,2) THEN '313'
		ELSE '-99'
	END) as 'Calc_Road_Type'
      ,[speed_limit]
	 ,junction_control as 'Junction_Control'
	 ,junction_detail as 'Junction_Detail'
      ,[pedestrian_crossing_human_control] as 'Crossing_Control'
      ,[pedestrian_crossing_physical_facilities] as 'Crossing_Facilities'
      ,[carriageway_hazards] as 'Hazards'
      ,[urban_or_rural_area]
      ,[trunk_road_flag]
      ,[lsoa_of_accident_location]
INTO f.Accidents
FROM stg.[accidents]
GO;

----------------ROAD TYPE DIMENSION--------------------------------
DROP TABLE IF EXISTS dim.RoadType;
 
SELECT distinct Calc_Road_Type as 'Road_Type'
		,(CASE
			WHEN Calc_Road_Type = 111 THEN 'Motorway'
			WHEN Calc_Road_Type = 212 THEN 'Urban'
			WHEN Calc_Road_Type = 313 THEN 'Rural'
			ELSE 'Unknown'
		END) as  'RoadTypeDesc'
INTO dim.RoadType
FROM f.Accidents


-----------FACT CASUALTY----------------------
DROP TABLE IF EXISTS f.Casualty

SELECT[accident_index]
      ,[accident_year]
      ,[accident_reference]
      ,[vehicle_reference]
      ,[casualty_reference]
      ,[casualty_class]
      ,[sex_of_casualty]
      ,[age_of_casualty]
      ,[casualty_severity]
      ,[pedestrian_location]
      ,[pedestrian_movement]
      ,[casualty_type]
      ,[lsoa_of_casualty]
	 ,1 as 'Casualty_Count'
INTO f.Casualty
FROM [stg].[casualites]
GO;

-----------------JOINS------------------------------
SELECT count(*)
FROM stg.casualites cas
	INNER JOIN stg.accidents acc
		ON acc.accident_index = cas.accident_index
	INNER JOIN dim.Age age
		ON cas.age_of_casualty = age.Casualty_Age
	INNER JOIN dim.Calendar cal
		ON cal.[Date] = acc.acc_date
	INNER JOIN dim.Casualty_Class cla
		ON cla.Cas_Class_Code = cas.casualty_class
	INNER JOIN dim.Casualty_Sex sex
		ON sex.Cas_Sex_Code = cas.sex_of_casualty
	INNER JOIN dim.Local_Highway_Auth lha
		ON lha.LHA_Code = acc.local_authority_highway
	INNER JOIN dim.Police_Force pf
		ON pf.Police_Force_Code = acc.police_force
	INNER JOIN dim.Road_User_Type rut
		ON rut.Road_User_Type = cas.casualty_type
	INNER JOIN dim.Severity sev
		ON sev.Severity_Code = cas.casualty_severity
	INNER JOIN dim.Speed_Limit sl
		ON sl.speed_limit = acc.speed_limit
GO

---------------------------REPORTING VIEW--------------------------------
CREATE OR ALTER VIEW rpt.UK_Casualty
AS
SELECT cas.accident_index
	 ,cal.[Year]
	 ,Cal.[Month]
	 ,cal.Qtr
	 ,cal.[MonthName]
	 ,cal.[DayName]
	 ,age.Age_Group
	 ,sex.Casualty_Sex_Desc
	 ,rut.Road_User
	 ,lha.Local_Highway_Auth
	 ,lhaa.Local_Highway_Auth as 'MapLHA'
	 ,pf.Police_Force_Desc
	 ,(CASE 
		WHEN Police_Force_Desc IN ('Gwent', 'South Wales', 'North Wales', 'Dyfed-Powys') THEN 'Wales'
		WHEN Police_Force_Desc IN ('Grampian','Police Scotland') THEN 'Scotland'
		ELSE 'England'
			END) as 'Country'
	 ,ru.RoadTypeDesc
	 ,sl.Speed_Limit_Desc
	 ,sev.Severity_Desc
	 ,cla.Cas_Class_Desc
	 ,jc.JunctionControl
	 ,jd.JunctionDetail
	 ,hz.Hazard
	 ,cc.Crossing_Control
	 ,cf.Crossing_Facilities
	 ,cas.Casualty_Count
FROM f.Casualty cas
	INNER JOIN f.Accidents acc
		ON acc.accident_index = cas.accident_index
	INNER JOIN dim.Age age
		ON cas.age_of_casualty = age.Casualty_Age
	INNER JOIN dim.Calendar cal
		ON cal.[Date] = acc.acc_date
	INNER JOIN dim.Casualty_Class cla
		ON cla.Cas_Class_Code = cas.casualty_class
	INNER JOIN dim.Casualty_Sex sex
		ON sex.Cas_Sex_Code = cas.sex_of_casualty
	INNER JOIN dim.Local_Highway_Auth lha
		ON lha.LHA_Code = acc.local_authority_highway
	INNER JOIN dim.LoHiAu lhaa
		ON lhaa.LHA_Code = acc.local_authority_highway
	INNER JOIN dim.Police_Force pf
		ON pf.Police_Force_Code = acc.police_force
	INNER JOIN dim.Road_User_Type rut
		ON rut.Road_User_Type = cas.casualty_type
	INNER JOIN dim.RoadType ru
		ON ru.Road_Type = acc.Calc_Road_Type
	INNER JOIN dim.Severity sev
		ON sev.Severity_Code = cas.casualty_severity
	INNER JOIN dim.Speed_Limit sl
		ON sl.speed_limit = acc.speed_limit
	INNER JOIN dim.Hazard hz
		ON hz.Hazard_Code = acc.Hazards
	INNER JOIN dim.JuncCtrl jc
		ON jc.JuncCtrl_Code = acc.Junction_Control
	INNER JOIN dim.JunctionDetail jd
		ON jd.JuncDet_Code = acc.Junction_Detail
	INNER JOIN dim.CrossingCtrl cc
		ON cc.CrsCtrl_Code = acc.Crossing_Control
	INNER JOIN dim.CrossingFac cf
		ON cf.CrsFac_Code = acc.Crossing_Facilities
GO
--728541

--------------------MAP RPT VIEW------------------------------
CREATE OR ALTER VIEW rpt.PctChange AS
WITH CurrentYear (LHA, MapLHA, cyTotal)
AS
(
    SELECT Local_Highway_Auth
		,MapLHA
		,sum(Casualty_Count)
	FROM rpt.UK_Casualty
	WHERE Year = 2021
	GROUP BY MapLHA, Local_Highway_Auth 
),
LastYear (LHA, MapLHA, lyTotal)
AS
(
        SELECT Local_Highway_Auth
		,MapLHA
		,sum(Casualty_Count)
	FROM rpt.UK_Casualty
	WHERE Year = 2020
	GROUP BY MapLHA, Local_Highway_Auth 
) 

-- THIS is your POST Query
SELECT cy.LHA
	 ,cy.MapLHA
	 ,ly.lyTotal
	 ,cy.cyTotal
	 ,ROUND (((cast ((cy.cyTotal - ly.lyTotal) as float))/ ly.lyTotal), 4) as 'Percent Change'
FROM CurrentYear cy
    INNER JOIN LastYear ly
      ON cy.LHA = ly.LHA
--ORDER BY 1
GO
---------------------------------------------------------------------------------------------------------

--CREATE or ALTER VIEW rpt.YearlyChange AS
SELECT [Year]
	,Qtr
--	,[Month]
--	,[MonthName]
	,MapLHA
	,Country
	,sum(Casualty_Count) AS 'Total'
	FROM rpt.UK_Casualty
	GROUP BY  [Year],Qtr, MapLHA,Country 
	order by 1,3, 2