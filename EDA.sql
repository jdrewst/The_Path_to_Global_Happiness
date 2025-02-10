-- EDA --

-- 1. What commonalities exists among the top 10 happiest countries from 2015 to 2017? 
CREATE VIEW top_country_view AS
	SELECT * 
	FROM (
		SELECT 
			happiness_rank,
			country,
			region,
			happiness_score,
            ROUND(economy,2) AS economy,
            ROUND(family,2) AS family,
            ROUND(health,2) AS health,
            ROUND(freedom,2) AS freedom,
            ROUND(trust,2) AS trust,
            ROUND(generosity,2) AS generosity,
            `year`
		FROM year2015
		ORDER BY happiness_score DESC
		LIMIT 10
    ) AS top10_countries_2015
	UNION ALL
	SELECT *
	FROM (
		SELECT 
			happiness_rank,
			country,
			region,
			happiness_score,
            ROUND(economy,2) AS economy,
            ROUND(family,2) AS family,
            ROUND(health,2) AS health,
            ROUND(freedom,2) AS freedom,
            ROUND(trust,2) AS trust,
            ROUND(generosity,2) AS generosity,
            `year`
		FROM year2016
		ORDER BY happiness_score DESC
		LIMIT 10
    ) AS top10_countries_2016
	UNION ALL
	SELECT *
	FROM (
		SELECT 
			happiness_rank,
			country,
			region,
			ROUND(happiness_score,3) AS happiness_score,
            ROUND(economy,2) AS economy,
            ROUND(family,2) AS family,
            ROUND(health,2) AS health,
            ROUND(freedom,2) AS freedom,
            ROUND(trust,2) AS trust,
            ROUND(generosity,2) AS generosity,
            `year`
		FROM year2017
		ORDER BY happiness_score DESC
		LIMIT 10
    )AS top10_countries_2017;

SELECT *
FROM top_country_view; -- check the data in view
-- COMMON: The countries belong in top 10 are most from west side of the world.

-- 2. What is the mean happiness score per region?
CREATE VIEW region_mean_score_view AS
SELECT 
	DENSE_RANK() OVER(PARTITION BY year ORDER BY mean_happiness_score DESC) AS region_rank,
    region,
    mean_happiness_score,
    `year`
FROM(
		SELECT
			DISTINCT(region) AS region,
			ROUND(AVG(happiness_score),3) AS mean_happiness_score,
			`year`
		FROM year2015
		GROUP BY region, `year`
		UNION ALL
		SELECT 
			DISTINCT(region) AS region,
			ROUND(AVG(happiness_score),3) AS mean_happiness_score,
			`year`
		FROM year2016
		GROUP BY region, `year`
		UNION ALL
		SELECT
			DISTINCT(region) AS region,
			ROUND(AVG(happiness_score),3) AS mean_happiness_score,
			`year`
		FROM year2017
		GROUP BY region, `year`
		ORDER BY year, mean_happiness_score DESC
) AS region_mean;
    
SELECT *
FROM region_mean_score_view;

-- 3. Does GDP per capita affects the happiness score of a country?

-- since MySQL has no built-in correlation function. we need to create one procedure
DELIMITER $$

CREATE PROCEDURE pearson(IN tbl VARCHAR(64), IN colX VARCHAR(64), IN colY VARCHAR(64))
BEGIN
    DECLARE meanX DOUBLE;
    DECLARE meanY DOUBLE;
    DECLARE numerator DOUBLE;
    DECLARE denominator DOUBLE;
    DECLARE correlation DOUBLE;

    SET @sql1 = CONCAT('SELECT AVG(', colX, ') INTO @meanX FROM ', tbl);
    SET @sql2 = CONCAT('SELECT AVG(', colY, ') INTO @meanY FROM ', tbl);
    SET @sql3 = CONCAT(
        'SELECT SUM((', colX, ' - @meanX) * (', colY, ' - @meanY)) INTO @numerator FROM ', tbl
    );
    SET @sql4 = CONCAT(
        'SELECT SQRT(SUM(POW(', colX, ' - @meanX, 2)) * SUM(POW(', colY, ' - @meanY, 2))) INTO @denominator FROM ', tbl
    );

    PREPARE stmt1 FROM @sql1;
    EXECUTE stmt1;
    DEALLOCATE PREPARE stmt1;

    PREPARE stmt2 FROM @sql2;
    EXECUTE stmt2;
    DEALLOCATE PREPARE stmt2;

    PREPARE stmt3 FROM @sql3;
    EXECUTE stmt3;
    DEALLOCATE PREPARE stmt3;

    PREPARE stmt4 FROM @sql4;
    EXECUTE stmt4;
    DEALLOCATE PREPARE stmt4;

    IF @denominator = 0 THEN
        SET correlation = NULL;
    ELSE
        SET correlation = ROUND(@numerator / @denominator,2);
    END IF;

    SELECT correlation AS Pearson_Correlation;
END $$

DELIMITER ;
-- find the correlation of economy and happiness score
CALL pearson('year2015', 'happiness_score', 'economy'); -- 0.78 correlation
CALL pearson('year2016', 'happiness_score', 'economy'); -- 0.79 correlation
CALL pearson('year2017', 'happiness_score', 'economy'); -- 0.81 correlation

-- find the correlation of social support and happiness score
CALL pearson('year2015', 'happiness_score', 'family'); -- 0.74 correlation
CALL pearson('year2016', 'happiness_score', 'family'); -- 0.74 correlation
CALL pearson('year2017', 'happiness_score', 'family'); -- 0.75 correlation

-- find the correlation of life expectancy and happiness score
CALL pearson('year2015', 'happiness_score', 'health'); -- 0.72 correlation
CALL pearson('year2016', 'happiness_score', 'health'); -- 0.77 correlation
CALL pearson('year2017', 'happiness_score', 'health'); -- 0.78 correlation

-- find the correlation of freedom and happiness score
CALL pearson('year2015', 'happiness_score', 'freedom'); -- 0.57 correlation
CALL pearson('year2016', 'happiness_score', 'freedom'); -- 0.57 correlation
CALL pearson('year2017', 'happiness_score', 'freedom'); -- 0.57 correlation

-- find the correlation of absence of corruption and happiness score
CALL pearson('year2015', 'happiness_score', 'trust'); -- 0.40 correlation
CALL pearson('year2016', 'happiness_score', 'trust'); -- 0.40 correlation
CALL pearson('year2017', 'happiness_score', 'trust'); -- 0.43 correlation

-- find the correlation of generosity and happiness score
CALL pearson('year2015', 'happiness_score', 'generosity'); -- 0.18 correlation
CALL pearson('year2016', 'happiness_score', 'generosity'); -- 0.16 correlation
CALL pearson('year2017', 'happiness_score', 'generosity'); -- 0.16 correlation

-- now, we answered all the research questions --