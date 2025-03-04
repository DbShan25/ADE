# ADE
Agri Data Explorer
Using Python from Jupyter Notebook:
Read data from source file
standardizing units
ensuring consistency across various fields (e.g., converting hectares, tons, and kilograms)
-	Updated column header to lower case
-	Replaced “ ” with “_”
-	Trimmed values using strip
-	Converted 1000 ha to ha, 1000 tons to tons
-	Renamed columns removing 1000
Data Analysis: 
Perform exploratory data analysis (EDA) to understand trends, patterns, and correlations.
Use statistical methods to identify insights such as high and low production areas, top-performing crops, and yield optimization strategies.
Loaded data into sql:
Database: project2_ade
Table: df_agri_data
Exploratory Data Analysis (EDA):
•	Top 7 RICE PRODUCTION State Data(Bar_plot)
•	Top 5 Wheat Producing States Data(Bar_chart)and its percentage(%)(Pie_chart)
•	Oil seed production by top 5 states
•	Top 7 SUNFLOWER PRODUCTION  State
•	India's SUGARCANE PRODUCTION From Last 50 Years(Line_plot)
•	Rice Production Vs Wheat Production (Last 50y)
•	Rice Production By West Bengal Districts
•	Top 10 Wheat Production Years From UP
•	Millet Production (Last 50y)
•	Sorghum Production (Kharif and Rabi) by Region
•	Top 7 States for Groundnut Production
•	Soybean Production by Top 5 States and Yield Efficiency
•	Oilseed Production in Major States
•	Impact of Area Cultivated on Production (Rice, Wheat, Maize)
•	Rice vs. Wheat Yield Across States
Questions to be answered:(SQL):
Answer the below questions through your analysis and visualizations:
1.Year-wise Trend of Rice Production Across States (Top 3)
2.Top 5 Districts by Wheat Yield Increase Over the Last 5 Years
3.States with the Highest Growth in Oilseed Production (5-Year Growth Rate)
4.District-wise Correlation Between Area and Production for Major Crops (Rice, Wheat, and Maize)
5.Yearly Production Growth of Cotton in Top 5 Cotton Producing States
6.Districts with the Highest Groundnut Production in 2020
7.Annual Average Maize Yield Across All States
8.Total Area Cultivated for Oilseeds in Each State
9.Districts with the Highest Rice Yield
10.Compare the Production of Wheat and Rice for the Top 5 States Over 10 Years
SQL queries for EDA questions
Import all SQL queries to PBi and visualize
Import all EDA queries to PBi and visualize
