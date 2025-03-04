#Questions to be answered:(SQL)
#Answer the below questions through your analysis and visualizations:
#127.0.0.1
use project2_ade;
#1.Year-wise Trend of Rice Production Across States (Top 3)
WITH RankedStates AS (
    SELECT year, state_name, 
        SUM(rice_production_tons) AS total_production_tons,
        RANK() OVER (PARTITION BY year ORDER BY SUM(rice_production_tons) DESC) AS rnk
    FROM df_agri_data
    GROUP BY year, state_name
)
SELECT year, state_name, total_production_tons
FROM RankedStates
WHERE rnk <= 3
ORDER BY year, rnk;

#2.Top 5 Districts by Wheat Yield Increase Over the Last 5 Years
WITH WheatYield AS (
    SELECT dist_name, year, AVG(wheat_yield_kg_per_ha) AS avg_yield
    FROM df_agri_data
    WHERE wheat_yield_kg_per_ha IS NOT NULL
    GROUP BY dist_name, year
),
YieldGrowth AS (
    SELECT dist_name, 
        MAX(CASE WHEN year = (SELECT MAX(year) FROM df_agri_data) THEN avg_yield END) AS latest_yield,
        MAX(CASE WHEN year = (SELECT MAX(year) - 5 FROM df_agri_data) THEN avg_yield END) AS past_yield
    FROM WheatYield
    GROUP BY dist_name
)
SELECT dist_name, latest_yield, past_yield, round((latest_yield - past_yield),2) AS yield_increase
FROM YieldGrowth
WHERE past_yield IS NOT NULL AND latest_yield IS NOT NULL
ORDER BY yield_increase DESC
LIMIT 5;

#3.States with the Highest Growth in Oilseed Production (5-Year Growth Rate)
WITH growth AS (
    SELECT state_name,
           SUM(CASE WHEN year = (SELECT MAX(year) FROM df_agri_data) - 5 THEN oilseeds_production_tons ELSE 0 END) AS production_5yrs_ago,
           SUM(CASE WHEN year = (SELECT MAX(year) FROM df_agri_data) THEN oilseeds_production_tons ELSE 0 END) AS current_production
    FROM df_agri_data
    GROUP BY state_name
)
SELECT state_name, production_5yrs_ago,current_production,
       ((current_production - production_5yrs_ago) / production_5yrs_ago) * 100 AS growth_rate
FROM growth
where ((current_production - production_5yrs_ago) / production_5yrs_ago) * 100>0
ORDER BY growth_rate DESC;

#4.District-wise Correlation Between Area and Production for Major Crops (Rice, Wheat, and Maize)
WITH correlations AS (
    SELECT dist_name,
        ROUND(
            (SUM((rice_area_ha - avg_rice_area) * (rice_production_tons - avg_rice_production)) /
             NULLIF(SQRT(SUM(POW(rice_area_ha - avg_rice_area, 2)) * SUM(POW(rice_production_tons - avg_rice_production, 2))), 0)
            ), 4
        ) AS rice_corr,
        ROUND(
            (SUM((wheat_area_ha - avg_wheat_area) * (wheat_production_tons - avg_wheat_production)) /
             NULLIF(SQRT(SUM(POW(wheat_area_ha - avg_wheat_area, 2)) * SUM(POW(wheat_production_tons - avg_wheat_production, 2))), 0)
            ), 4
        ) AS wheat_corr,
        ROUND(
            (SUM((maize_area_ha - avg_maize_area) * (maize_production_tons - avg_maize_production)) /
             NULLIF(SQRT(SUM(POW(maize_area_ha - avg_maize_area, 2)) * SUM(POW(maize_production_tons - avg_maize_production, 2))), 0)
            ), 4
        ) AS maize_corr
    FROM (
        SELECT dist_name, 
               rice_area_ha, rice_production_tons, 
               wheat_area_ha, wheat_production_tons, 
               maize_area_ha, maize_production_tons,
               AVG(rice_area_ha) OVER(PARTITION BY dist_name) AS avg_rice_area,
               AVG(rice_production_tons) OVER(PARTITION BY dist_name) AS avg_rice_production,
               AVG(wheat_area_ha) OVER(PARTITION BY dist_name) AS avg_wheat_area,
               AVG(wheat_production_tons) OVER(PARTITION BY dist_name) AS avg_wheat_production,
               AVG(maize_area_ha) OVER(PARTITION BY dist_name) AS avg_maize_area,
               AVG(maize_production_tons) OVER(PARTITION BY dist_name) AS avg_maize_production
        FROM df_agri_data
    ) AS subquery
    GROUP BY dist_name
)
SELECT dist_name, rice_corr, wheat_corr, maize_corr
FROM correlations
ORDER BY dist_name;

#5.Yearly Production Growth of Cotton in Top 5 Cotton Producing States
WITH top_states AS (
    SELECT state_name
    FROM df_agri_data
    GROUP BY state_name
    ORDER BY SUM(cotton_production_tons) DESC
    LIMIT 5
)
SELECT year, state_name, SUM(cotton_production_tons) AS total_production
FROM df_agri_data
WHERE state_name IN (SELECT state_name FROM top_states)
GROUP BY year, state_name
ORDER BY year, total_production DESC;

#6.Districts with the Highest Groundnut Production in 2020 --No data for 2020
SELECT dist_name, SUM(groundnut_production_tons) AS total_production
FROM df_agri_data
WHERE year = 2017
GROUP BY dist_name
ORDER BY total_production DESC
LIMIT 5;


#7.Annual Average Maize Yield Across All States
SELECT year, AVG(maize_yield_kg_per_ha) AS avg_yield
FROM df_agri_data
GROUP BY year
ORDER BY year;

#8.Total Area Cultivated for Oilseeds in Each State
SELECT state_name, SUM(oilseeds_area_ha) AS total_area
FROM df_agri_data
GROUP BY state_name
ORDER BY total_area DESC;

#9.Districts with the Highest Rice Yield
SELECT dist_name, MAX(rice_yield_kg_per_ha) AS max_yield
FROM df_agri_data
GROUP BY dist_name
ORDER BY max_yield DESC
LIMIT 5;

#10.Compare the Production of Wheat and Rice for the Top 5 States Over 10 Years
WITH ProductionData AS (  
    SELECT 
        state_name, 
        year, 
        SUM(wheat_production_tons) AS total_wheat_production,
        SUM(rice_production_tons) AS total_rice_production
    FROM df_agri_data
    WHERE year >= (SELECT MAX(year) FROM df_agri_data) - 9
    GROUP BY state_name, year
),
TopStates AS (
    SELECT state_name
    FROM ProductionData
    WHERE year = (SELECT MAX(year) FROM df_agri_data)
    ORDER BY total_wheat_production + total_rice_production DESC
    LIMIT 5
)
SELECT 
    p.year,
    p.state_name,
    p.total_wheat_production,
    p.total_rice_production
FROM ProductionData p
JOIN TopStates t ON p.state_name = t.state_name
ORDER BY p.year ASC, p.state_name;

#EDA Queries:
#1.Top 7 RICE PRODUCTION State Data(Bar_plot)
SELECT state_name, SUM(rice_production_tons) AS total_rice_production
FROM df_agri_data
GROUP BY state_name
ORDER BY total_rice_production DESC
LIMIT 7;

#2.Top 5 Wheat Producing States Data(Bar_chart)and its percentage(%)(Pie_chart)
WITH wheat_production AS (
    SELECT state_name, SUM(wheat_production_tons) AS total_wheat_production
    FROM df_agri_data
    GROUP BY state_name
)
SELECT state_name, total_wheat_production, 
       ROUND((total_wheat_production / (SELECT SUM(total_wheat_production) FROM wheat_production)) * 100, 2) AS percentage
FROM wheat_production
ORDER BY total_wheat_production DESC
LIMIT 5;

#3.Oil seed production by top 5 states
SELECT state_name, SUM(oilseeds_production_tons) AS oilseed_production
FROM df_agri_data
GROUP BY state_name
ORDER BY oilseed_production DESC
LIMIT 5;

#4.Top 7 SUNFLOWER PRODUCTION  State
SELECT state_name, SUM(sunflower_production_tons) AS sunflower_production
FROM df_agri_data
GROUP BY state_name
ORDER BY sunflower_production DESC
LIMIT 7;

#5. India's SUGARCANE PRODUCTION From Last 50 Years(Line_plot)
SELECT year, SUM(sugarcane_production_tons) AS total_sugarcane_production
FROM df_agri_data
WHERE year >= YEAR(CURDATE()) - 50
GROUP BY year
ORDER BY year ASC;

#6. Rice Production Vs Wheat Production (Last 50y)
SELECT year, 
       SUM(rice_production_tons) AS total_rice_production, 
       SUM(wheat_production_tons) AS total_wheat_production
FROM df_agri_data
WHERE year >= YEAR(CURDATE()) - 50
GROUP BY year
ORDER BY year ASC;

#7. Rice Production By West Bengal Districts
SELECT dist_name, SUM(rice_production_tons) AS total_rice_production
FROM df_agri_data
WHERE state_name = 'West Bengal'
GROUP BY dist_name
ORDER BY total_rice_production DESC;

#8. Top 10 Wheat Production Years From UP
SELECT year, SUM(wheat_production_tons) AS total_wheat_production
FROM df_agri_data
WHERE state_name = 'Uttar Pradesh'
GROUP BY year
ORDER BY total_wheat_production DESC
LIMIT 10;

#9. Millet Production (Last 50y)
SELECT year, 
       SUM(pearl_millet_production_tons) AS pearl_millet_production,
       SUM(finger_millet_production_tons) AS finger_millet_production
FROM df_agri_data
WHERE year >= YEAR(CURDATE()) - 50
GROUP BY year
ORDER BY year ASC;

#10. Sorghum Production (Kharif and Rabi) by Region
SELECT state_name, 
       SUM(kharif_sorghum_production_tons) AS kharif_sorghum_production,
       SUM(rabi_sorghum_production_tons) AS rabi_sorghum_production,
       SUM(sorghum_production_tons) AS total_sorghum_production
FROM df_agri_data
GROUP BY state_name
ORDER BY total_sorghum_production DESC;

#11. Top 7 States for Groundnut Production
SELECT state_name, SUM(groundnut_production_tons) AS total_groundnut_production
FROM df_agri_data
GROUP BY state_name
ORDER BY total_groundnut_production DESC
LIMIT 7;

#12. Soybean Production by Top 5 States and Yield Efficiency
SELECT state_name, 
       SUM(soyabean_production_tons) AS total_soyabean_production,
       ROUND(SUM(soyabean_production_tons) / NULLIF(SUM(soyabean_area_ha), 0), 4) AS yield_efficiency
FROM df_agri_data
GROUP BY state_name
ORDER BY total_soyabean_production DESC
LIMIT 5;

#13. Oilseed Production in Major States
SELECT state_name, SUM(oilseeds_production_tons) AS total_oilseed_production
FROM df_agri_data
GROUP BY state_name
ORDER BY total_oilseed_production DESC;

#14. Impact of Area Cultivated on Production (Rice, Wheat, Maize)
WITH avg_values AS (
    SELECT dist_name,
           AVG(rice_area_ha) AS avg_rice_area, AVG(rice_production_tons) AS avg_rice_production,
           AVG(wheat_area_ha) AS avg_wheat_area, AVG(wheat_production_tons) AS avg_wheat_production,
           AVG(maize_area_ha) AS avg_maize_area, AVG(maize_production_tons) AS avg_maize_production
    FROM df_agri_data
    GROUP BY dist_name
),
covariance_values AS (
    SELECT d.dist_name,
           SUM((d.rice_area_ha - a.avg_rice_area) * (d.rice_production_tons - a.avg_rice_production)) AS cov_rice,
           SUM((d.wheat_area_ha - a.avg_wheat_area) * (d.wheat_production_tons - a.avg_wheat_production)) AS cov_wheat,
           SUM((d.maize_area_ha - a.avg_maize_area) * (d.maize_production_tons - a.avg_maize_production)) AS cov_maize,
           SQRT(SUM(POW(d.rice_area_ha - a.avg_rice_area, 2)) * SUM(POW(d.rice_production_tons - a.avg_rice_production, 2))) AS std_rice,
           SQRT(SUM(POW(d.wheat_area_ha - a.avg_wheat_area, 2)) * SUM(POW(d.wheat_production_tons - a.avg_wheat_production, 2))) AS std_wheat,
           SQRT(SUM(POW(d.maize_area_ha - a.avg_maize_area, 2)) * SUM(POW(d.maize_production_tons - a.avg_maize_production, 2))) AS std_maize
    FROM df_agri_data d
    JOIN avg_values a ON d.dist_name = a.dist_name
    GROUP BY d.dist_name
)
SELECT dist_name,
       ROUND(cov_rice / NULLIF(std_rice, 0), 4) AS rice_corr,
       ROUND(cov_wheat / NULLIF(std_wheat, 0), 4) AS wheat_corr,
       ROUND(cov_maize / NULLIF(std_maize, 0), 4) AS maize_corr
FROM covariance_values
ORDER BY dist_name;

#15. Rice vs. Wheat Yield Across States
SELECT state_name, 
       ROUND(SUM(rice_production_tons) / NULLIF(SUM(rice_area_ha), 0), 4) AS rice_yield,
       ROUND(SUM(wheat_production_tons) / NULLIF(SUM(wheat_area_ha), 0), 4) AS wheat_yield
FROM df_agri_data
GROUP BY state_name
ORDER BY rice_yield DESC, wheat_yield DESC;

