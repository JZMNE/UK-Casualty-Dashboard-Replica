SELECT COUNT(*) as 'StagingTable'
FROM stg.Traffic
GO;

SELECT COUNT(*) as 'FactTable'
FROM f.TrafficFact
GO;

SELECT COUNT(*) as 'DimDirection'
FROM dim.Direction
GO;

SELECT COUNT(*) as 'ErrDirection'
FROM err.eDirection
GO;

SELECT COUNT(*) as 'DimHourofDay'
FROM dim.HourofDay
GO;

SELECT COUNT(*) as 'ErrHourofDay'
FROM err.eHourofDay
GO;

SELECT COUNT(*) as 'DimLocalAuth'
FROM dim.LocalAuthority
GO;

SELECT COUNT(*) as 'ErrLocalAuth'
FROM err.eLocalAuthority
GO;

SELECT COUNT(*) as 'DimRoadCategory'
FROM dim.RoadCategory
GO;

SELECT COUNT(*) as 'ErrRoadCategory'
FROM err.eRoadCategory
GO;


----VIEWING FACT TABLE
SELECT TOP 100 *
FROM f.TrafficFact

-- CHECKING NULLS
SELECT [CountPointId]
      ,[kDate]
      ,[kDirection]
      ,[kHourofDay]
      ,[kLocalAuthorityId]
      ,[kRoadCategory]
      ,[Latitude]
      ,[Longitude]
      ,[PedalCycles]
      ,[TwoWheeledMotorVehicle]
      ,[CarsandTaxis]
      ,[BusesandCoaches]
      ,[LGVs]
      ,[HGVs_2_rigid_Axle]
      ,[HGVs_3_or_4_articulated_Axle]
      ,[HGVs_3_rigid_Axle]
      ,[HGVs_4_or_more_rigid_Axle]
      ,[HGVs_5_articulated_Axle]
      ,[HGVs_6_articulated_axle]
  FROM [UK_Traffic].[f].[TrafficFact]
  WHERE [CarsandTaxis] IS NULL OR
      [BusesandCoaches] IS NULL OR
      [LGVs] IS NULL OR
      [HGVs_2_rigid_Axle] IS NULL OR
      [HGVs_3_or_4_articulated_Axle] IS NULL OR
      [HGVs_3_rigid_Axle] IS NULL OR
      [HGVs_4_or_more_rigid_Axle] IS NULL OR
      [HGVs_5_articulated_Axle] IS NULL OR
      [HGVs_6_articulated_axle] IS NULL 