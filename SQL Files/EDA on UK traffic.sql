/****** Script for SelectTopNRows command from SSMS  ******/
SELECT count(*)
FROM [stg].[TrafficCountDirection]

SELECT  Count(*)
FROM stg.TrafficCount

/*********************************/
SELECT sum(Link_length_miles) as 'Miles'
	 ,sum(Cars_and_taxis) as 'Cars'
FROM stg.Traffic
WHERE [Year] = 2021 and Region_id  = 6;

/*********************************/
SELECT [Year]
	 ,Region_id
	 ,Region_name
	 ,sum(Link_length_km) as 'Miles'
	 ,sum(Cars_and_taxis) as 'Cars&Taxis'
FROM stg.TrafficCount
WHERE [Year] =  2021
Group BY [Year], Region_id, Region_name

SELECT distinct count_date
	 ,DATEPART(DW, Count_date) as 'DayofWeek'
	 ,FORMAT(Count_date, 'ddddd') as 'DayName'
FROM stg.Traffic
WHERE [Year] = 2021
ORDER BY 1


-------------------------------------------
select count(*)
,511385 / 429
FRom stg.TrafficCount
