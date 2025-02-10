-- checking the content of the table
SELECT *
FROM `2015`; 

SELECT *
FROM `2016`; 

SELECT *
FROM `2017`;

-- DATA PREPARATION
-- create staging for 2015
CREATE TABLE year2015 
LIKE `2015`;

INSERT year2015
	SELECT *
	FROM `2015`;
    
-- table checking
SELECT *
FROM year2015;

-- remove unnecessary columns and standardizing other columns 
ALTER TABLE year2015
RENAME COLUMN `Country` TO country,
RENAME COLUMN `Region` TO region,
RENAME COLUMN `Happiness Rank` TO happiness_rank,
RENAME COLUMN `Happiness Score` TO happiness_score,
DROP COLUMN `Standard Error`,
RENAME COLUMN `Economy (GDP per Capita)` TO economy, 
RENAME COLUMN `Family` TO family,
RENAME COLUMN `Health (Life Expectancy)` TO health,
RENAME COLUMN `Freedom` TO freedom,
RENAME COLUMN `Trust (Government Corruption)` TO trust,
RENAME COLUMN `Generosity` TO generosity,
DROP COLUMN `Dystopia Residual`;

-- create staging for 2016
CREATE TABLE year2016 
LIKE `2016`;

INSERT year2016
	SELECT *
	FROM `2016`;
    
-- table checking
SELECT *
FROM year2016;

-- remove unnecessary columns and standardizing other columns' name
ALTER TABLE year2016
RENAME COLUMN `Country` TO country,
RENAME COLUMN `Region` TO region,
RENAME COLUMN `Happiness Rank` TO happiness_rank,
RENAME COLUMN `Happiness Score` TO happiness_score,
DROP COLUMN `Lower Confidence Interval`,
DROP COLUMN `Upper Confidence Interval`,
RENAME COLUMN `Economy (GDP per Capita)` TO economy, 
RENAME COLUMN `Family` TO family,
RENAME COLUMN `Health (Life Expectancy)` TO health,
RENAME COLUMN `Freedom` TO freedom,
RENAME COLUMN `Trust (Government Corruption)` TO trust,
RENAME COLUMN `Generosity` TO generosity,
DROP COLUMN `Dystopia Residual`;

-- create staging for 2017
CREATE TABLE year2017 
LIKE `2017`;

INSERT year2017
	SELECT *
	FROM `2017`;
    
-- table checking
SELECT *
FROM year2017;

ALTER TABLE year2017
RENAME COLUMN `Country` TO country,
RENAME COLUMN `Happiness.Rank` TO happiness_rank,
RENAME COLUMN `Happiness.Score` TO happiness_score,
DROP COLUMN `Whisker.high`,
DROP COLUMN `Whisker.low`,
RENAME COLUMN `Economy..GDP.per.Capita.` TO economy, 
RENAME COLUMN `Family` TO family,
RENAME COLUMN `Health..Life.Expectancy.` TO health,
RENAME COLUMN `Freedom` TO freedom,
RENAME COLUMN `Trust..Government.Corruption.` TO trust,
RENAME COLUMN `Generosity` TO generosity,
DROP COLUMN `Dystopia.Residual`;

-- add year column to each table for EDA later
ALTER TABLE year2015
ADD COLUMN year int;
UPDATE year2015
SET year = 2015;

ALTER TABLE year2016
ADD COLUMN year int;
UPDATE year2016
SET year = 2016;

ALTER TABLE year2017
ADD COLUMN year int;
UPDATE year2017
SET year = 2017;

-- we need to reorder the columns in year2017
SELECT *
FROM year2017;
CREATE TABLE new2017(
	country VARCHAR(255),
    region VARCHAR(255),
    happiness_rank INT,
    happiness_score FLOAT,
    economy FLOAT,
    family FLOAT,
    health FLOAT,
    freedom FLOAT,
    generosity FLOAT,
    trust FLOAT,
    year INT
);

INSERT INTO new2017 (country, region, happiness_rank, happiness_score, economy, family, health, freedom, generosity, trust, year)
SELECT 
	country,
    region,
    happiness_rank,
    happiness_score,
    economy,
    family,
    health,
    freedom,
    generosity,
    trust,
    `year`
FROM year2017;
 
 SELECT *
 FROM new2017;
 
 DROP TABLE year2017;
 ALTER TABLE new2017 RENAME TO year2017;
 
SELECT *
 FROM year2017;
-- DATA CLEANING
-- check duplicates in each table. this step is optional in this case since there's happiness_rank column so you can check duplicates through that column.
WITH duplicate AS(
	SELECT *,
		ROW_NUMBER() OVER(PARTITION BY country, happiness_rank, happiness_score, economy, family, health, freedom, generosity, trust) AS row_num
	FROM year2017
) -- assign row number. 

SELECT *
FROM duplicate
WHERE row_num > 1; -- check if may duplicate.
-- upon checking all three tables, there are no duplicates so proceed with data standardization.

-- DATA STANDARDIZATION
SELECT 
	country
FROM year2017; -- check if the text data is in standard form, if not then use appropriate function to fix it

-- the only error is that year2017 table has no column for region. 
ALTER TABLE year2017
ADD COLUMN region VARCHAR(255);


-- WORK WITH NULL VALUES/BLANK VALUES
UPDATE year2017
LEFT JOIN year2015 
	USING(country)
SET year2017.region = year2015.region
WHERE year2017.region IS NULL 
	AND year2015.region IS NOT NULL; -- populate null values 
    
SELECT 
	DISTINCT(region)
FROM year2017; -- check if there are null values. 

-- since there are null values, populate it again using 2016 table.
UPDATE year2017
LEFT JOIN year2016 
	USING(country)
SET year2017.region = year2016.region
WHERE year2017.region IS NULL 
	AND year2016.region IS NOT NULL;

SELECT 
	country,
	region
FROM year2017
WHERE region IS NULL; -- check what are the remaining null values

-- null values are Taiwan Province of China and Hong Kong
UPDATE year2017
SET region = "Eastern Asia"
WHERE region IS NULL; -- update the region (both of them are part of east asia)  


-- now the data in three tables are clean --