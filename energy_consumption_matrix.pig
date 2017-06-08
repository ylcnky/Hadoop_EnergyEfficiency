
-- Loading the required jar files
REGISTER /usr/local/Cellar/hadoop/pig-0.16.0/lib/piggybank.jar;
-- REGISTER /usr/local/Cellar/hadoop/pig-0.16.0/lib/joda-time-2.9.3.jar;
-- DEFINE CustomFormatToISO org.apache.pig.piggybank.evaluation.datetime.convert.CustomFormatToISO();
-- DEFINE ISOToUnix org.apache.pig.piggybank.evaluation.datetime.convert.ISOToUnix();

-- Removing the output directory if it already exists
rmf energy_consumption_matrix;

-- Loading the energy consumption data
energy = LOAD 'energy_data.data' USING org.apache.pig.piggybank.storage.CSVExcelStorage(',') AS (dev:int, building:chararray, meternumb:int ,type:chararray, date:chararray,hr:int,consumption:int);

-- Removing any rows with blank building names
NARM = FILTER energy BY (building matches 'Building.*');

-- Segregating electricity & electricity used for heating
elect = FILTER NARM BY type == 'elect';
heat = FILTER NARM BY type == 'Dist_Heating';

-- Aggregating the data to get average hourly electricity consumption per day per building.
elec_group  = GROUP elect BY (building,date);
avg_daily_elec = FOREACH elec_group GENERATE group, AVG(elect.consumption) AS avg_hourly_consumption;
avg_daily_elec_months = FOREACH avg_daily_elec GENERATE group.building,avg_hourly_consumption, GetMonth(ToDate(group.date,'yyyyMMdd')) AS month;

-- Aggregating the data to get average hourly electricity consumption per month per building
avg_monthly_elec_group = GROUP avg_daily_elec_months BY (building,month);
avg_monthly_elec = FOREACH avg_monthly_elec_group  GENERATE group.building,group.month, AVG(avg_daily_elec_months.avg_hourly_consumption) AS avg_monthly_consumption;

-- Removing the electricity consumption values for December as only a few day data was available
monthly_elec = FILTER avg_monthly_elec BY month!=12;

-- Aggregating the data to get average hourly electricity for heating consumption per day per building.
heat_group  = GROUP heat BY (building,date);
avg_daily_heat = FOREACH heat_group GENERATE group, AVG(heat.consumption) AS avg_hourly_consumption;
avg_daily_heat_months = FOREACH avg_daily_heat GENERATE group.building,avg_hourly_consumption, GetMonth(ToDate(group.date,'yyyyMMdd')) AS month;

-- Aggregating the data to get average hourly electricity for heating consumption per month per building
avg_monthly_heat_group = GROUP avg_daily_heat_months BY (building,month);
avg_monthly_heat = FOREACH avg_monthly_heat_group  GENERATE group.building,group.month, AVG(avg_daily_heat_months.avg_hourly_consumption) AS avg_monthly_consumption;

-- Removing the electricity consumption values for December as only a few day data was available
monthly_heat = FILTER avg_monthly_heat BY month!=12;

-- Joining the electricity and electricity consumed for heating tables to form the energy consumption matrix
main_matrix = JOIN monthly_elec BY (building,month), monthly_heat BY (building,month);
energy_comsumption_matrix = FOREACH main_matrix GENERATE $0 as building, $1 as month, $2 as elect_consumption, $5 as heat_consumption;

-- Storing the data
STORE energy_comsumption_matrix INTO 'energy_consumption_matrix' USING PigStorage(',');
