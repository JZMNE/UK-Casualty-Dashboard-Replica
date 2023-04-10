GO
CREATE TABLE [stg].[casualties](
	[accident_index] [varchar](50) NULL,
	[accident_year] [bigint] NULL,
	[accident_reference] [varchar](50) NULL,
	[vehicle_reference] [bigint] NULL,
	[casualty_reference] [bigint] NULL,
	[casualty_class] [bigint] NULL,
	[sex_of_casualty] [bigint] NULL,
	[age_of_casualty] [bigint] NULL,
	[age_band_of_casualty] [bigint] NULL,
	[casualty_severity] [bigint] NULL,
	[pedestrian_location] [bigint] NULL,
	[pedestrian_movement] [bigint] NULL,
	[car_passenger] [bigint] NULL,
	[bus_or_coach_passenger] [bigint] NULL,
	[pedestrian_road_maintenance_worker] [bigint] NULL,
	[casualty_type] [bigint] NULL,
	[casualty_home_area_type] [bigint] NULL,
	[casualty_imd_decile] [bigint] NULL,
	[lsoa_of_casualty] [varchar](50) NULL
) 
GO


