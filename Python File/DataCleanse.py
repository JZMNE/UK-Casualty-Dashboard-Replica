import numpy as np
import pandas as pd

pd.set_option('display.max_columns', None)

df = pd.read_csv('./dft-road-casualty-statistics-accident-2021.csv', low_memory=False)
df.head()

df['date'] = pd.to_datetime(df['date'],dayfirst=True)

df.columns;

df.drop(['location_easting_osgr', 'location_northing_osgr', 'lsoa_of_accident_location',
        'trunk_road_flag', 'first_road_class', 'first_road_number', 'junction_detail',
         'junction_control', 'second_road_class', 'second_road_number', 'accident_index'],
          axis = 1, inplace=True)

df.shape
df.to_csv('./accidents222.csv', index=False)

