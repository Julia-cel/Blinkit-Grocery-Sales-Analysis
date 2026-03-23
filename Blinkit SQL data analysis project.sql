CREATE DATABASE blikit_grocery;
USE blikit_grocery;
-- DATA VALIDATION AND DATA CLEANING
-- Checking data for inconsistencies and performing data cleaning
SELECT DISTINCT `Item Fat Content` FROM `blinkit-data`;
-- cleaning using update
UPDATE `blinkit-data` SET `Item Fat Content`= "low fat" WHERE `Item Fat Content` IN ('Low Fat', 'LF');
UPDATE `blinkit-data` SET `Item Fat Content`= "regular" WHERE `Item Fat Content` IN ("Regular", "reg");
select distinct `Item Type` from `blinkit-data`;
select distinct `Outlet Establishment Year` from `blinkit-data` order by `Outlet Establishment Year` ;
-- data go from 2011 to 2022. -> changing it to the proper data type
alter table `blinkit-data` modify `Outlet Establishment Year` INT;
select distinct `Outlet Location Type` from`blinkit-data`;
select distinct `Outlet Size` from`blinkit-data`; -- trhee sizes medium, small and high
select distinct `Outlet Type` from`blinkit-data`; 
select `Outlet Size`,`Outlet Type`,COUNT(`Outlet Type`) from `blinkit-data` where `Outlet Size`= "High" GROUP BY `Outlet Type`;
-- The supermarket type 1 and the grocery store are the only in high size
select `Outlet Size`,`Outlet Type`,COUNT(`Outlet Type`) from `blinkit-data` where `Outlet Size`= "Medium" GROUP BY `Outlet Type`;
-- all outlets have stores in medium size
select `Outlet Size`,`Outlet Type`,COUNT(`Outlet Type`) from `blinkit-data` where `Outlet Size`= "Small" GROUP BY `Outlet Type`;
-- The supermarket type 1 and the grocery store are the only in small size
-- Modifying the other columns with the correct data type
ALTER TABLE `blinkit-data`
MODIFY COLUMN `Item Visibility` DOUBLE,
MODIFY COLUMN `Sales` DOUBLE,
MODIFY COLUMN `Rating` DOUBLE;
-------------------------------------------------------------------------------------------------------------------------------------------------------

-- NORMALIZATION AND CREATING PROPER TABLES

-- Normalizing dataset by creating three tables from the raw data
SELECT MAX(LENGTH(`Outlet Identifier`)) FROM `blinkit-data`; -- 21
SELECT MAX(LENGTH(`Item Fat Content`)) FROM `blinkit-data`; -- 7
CREATE TABLE items (
    Item_Id VARCHAR(5) PRIMARY KEY,
    Item_Fat_Content VARCHAR(10),
    Item_Type VARCHAR(30)
);
INSERT INTO Items 
SELECT DISTINCT `Item Identifier`, `Item Fat Content`, `Item Type`
FROM `blinkit-data`;
SELECT COUNT(*) FROM items;
SELECT * FROM items LIMIT 10;

CREATE TABLE outlet(
outlet_id varchar (5) PRIMARY KEY,
establishment_year INT, 
location_type varchar (7),
size varchar (10),
outlet_type varchar (20)) ;
ALTER TABLE outlet modify column outlet_id varchar (6);
INSERT INTO outlet 
SELECT DISTINCT  `Outlet Identifier`, `Outlet Establishment Year`, `Outlet Location Type`, `Outlet Size`, `Outlet Type`
FROM `blinkit-data`;
-- Error in insert: duplicate pk values -> discovering the issue: 
SELECT `Outlet Identifier`, COUNT(*)
FROM `blinkit-data`
GROUP BY `Outlet Identifier`
HAVING COUNT(*) > 1;
SELECT DISTINCT 
    `Outlet Identifier`,
    `Outlet Establishment Year`,
    `Outlet Location Type`,
    `Outlet Size`,
    `Outlet Type`
FROM `blinkit-data`
WHERE `Outlet Identifier` = 'OUT017';
-- The problem is that the dataset registered more than one outlet size for the same outlet
-- Fix: Replace the multiple outlets size with the size more frequent
SELECT `Outlet Identifier`, `Outlet Size`, COUNT(*) as frequency
FROM `blinkit-data`
GROUP BY `Outlet Identifier`, `Outlet Size`
ORDER BY `Outlet Identifier`; -- Outlets 10, 17 and 45 presents this issue, so it can be fix manually
SELECT `Outlet Identifier`, `Outlet Size`, COUNT(*)
FROM `blinkit-data`
WHERE `Outlet Identifier` = 'OUT017'
GROUP BY  `Outlet Size`; -- discovering the more frequent size
UPDATE `blinkit-data`
SET `Outlet Size` = 'Small'
WHERE `Outlet Identifier` = 'OUT017' 
AND `Outlet Size` != 'Small'; -- replacing values withe the more frequent size
-- Repeating the process to the other two outlets
SELECT `Outlet Identifier`, `Outlet Size`, count(*) as frequency
FROM `blinkit-data`
WHERE `Outlet Identifier`= 'OUT045'
GROUP BY   `Outlet Size`;
UPDATE `blinkit-data` 
SET `Outlet Size`= 'Medium'
WHERE `Outlet Identifier`= 'OUT045' and `Outlet Size` != 'Medium';
SELECT `Outlet Identifier`, `Outlet Size`, COUNT(*)
FROM `blinkit-data`
WHERE `Outlet Identifier` = 'OUT010'
GROUP BY `Outlet Size`;
UPDATE `blinkit-data`
SET `Outlet Size`= 'Medium'
WHERE `Outlet Identifier`= 'OUT010' AND `Outlet Size` != 'Medium';
select * from outlet; -- There are only 10 physical stores in the dataset
-- Creating the bridge table between outlet and items
CREATE TABLE sales (
sale_id INT auto_increment PRIMARY KEY,
sales DOUBLE, 
Item_Id varchar (5), 
outlet_id varchar (6),
item_visibility DOUBLE, 
Rating DOUBLE,
FOREIGN KEY (Item_Id) references items(Item_Id),
FOREIGN KEY (outlet_id) references outlet(outlet_id));
INSERT INTO sales (Item_Id, outlet_id, item_visibility, sales, Rating)
SELECT 
    `Item Identifier`,
    `Outlet Identifier`,
    `Item Visibility`,
    `Sales`,
    `Rating`
FROM `blinkit-data`;
-------------------------------------------------------------------------------------------------------------------------------------------------------

-- ANALYZING DATA

-- Total Sales by item type:
SELECT ROUND(sum(sales.sales),2) as Total_Sales, items.Item_Type
FROM sales
JOIN items on sales.Item_Id= items.Item_Id
GROUP BY Item_Type
ORDER BY Total_Sales DESC;
-- Average Sales by Item type:
SELECT items.Item_Type, 
    ROUND(SUM(sales.sales) / COUNT(DISTINCT items.Item_Id), 2) as Avg_sales_per_item
FROM sales
JOIN items ON sales.Item_Id = items.Item_Id
GROUP BY Item_Type
ORDER BY Avg_sales_per_item DESC;
-- While Fruits & Vegetables leads in total sales volume, Seafood generates the highest average revenue per individual item — suggesting premium pricing or higher demand concentration in fewer products.
-- Let's investigate if it is related to visibility and rating
-- Items sold by average rating:
SELECT items.Item_Type, ROUND(AVG(sales.Rating),2) as Avg_Rating
FROM sales
JOIN items on sales.Item_Id = items.Item_Id
GROUP BY Item_Type
ORDER BY Avg_Rating DESC;
-- Not necessarily the products with higher rating have more sales.

-- Items sold by average visibility
SELECT items.Item_Type, ROUND(AVG(sales.item_visibility),2) as Avg_Visibility
FROM sales
JOIN items on sales.Item_Id = items.Item_Id
GROUP BY Item_Type
ORDER BY Avg_Visibility DESC;
-- The same happens with relation between visibility and type of items sold
SELECT items.Item_Type, items.Item_Fat_Content, -- Analysing differences in sales between low fat and regular products
    ROUND(SUM(sales.sales),2) as total_sales,
    ROUND(AVG(sales.sales),2) as avg_sales_per_item
FROM sales
JOIN items ON sales.item_id = items.Item_Id
WHERE Item_Type in ('Snack Foods')
GROUP BY items.Item_Type, items.Item_Fat_Content
ORDER BY avg_sales_per_item DESC;
-- Low fat Snack food selling 16% more than regular snacks. It can indicate a preference for fitness snacks.
-------------------------------------------------------------------------------------------------------------------------------------------------------

-- Sales by outlet type
SELECT ROUND(sum(sales.sales),2) as Total_Sales, outlet.outlet_type -- Calculating total sales
FROM sales
JOIN outlet on sales.outlet_id = outlet.outlet_id
GROUP BY outlet_type
ORDER BY Total_Sales DESC;
SELECT outlet_type, -- Percentage of sales by outlet type
    ROUND(SUM(sales), 2) as total_sales,
    ROUND(SUM(sales) / (SELECT SUM(sales) FROM sales) * 100, 2) as percentage
FROM sales
JOIN outlet ON sales.outlet_id = outlet.outlet_id
GROUP BY outlet_type
ORDER BY total_sales DESC;
-- Supermarket type 1 concentrate 65% of sales, lets investigate it further 
SELECT count(*), outlet_type
FROM outlet
GROUP BY outlet_type 
ORDER BY count(*) DESC;
-- Supermarket 1 have more stores so it explain the higher sales
-- To make a normalized comparison of sales by outlet type we must calculate Average sales per outlet
-- Average sales per Outlet type:
SELECT outlet_type,
    COUNT(DISTINCT outlet.outlet_id) as number_of_stores,
    ROUND(SUM(sales.sales), 2) as total_sales,
    ROUND(SUM(sales.sales) / COUNT(DISTINCT outlet.outlet_id), 2) as avg_revenue_per_store
FROM sales
JOIN outlet ON sales.outlet_id = outlet.outlet_id
GROUP BY outlet_type
ORDER BY avg_revenue_per_store DESC;
-- Insights: Grocery Store generates HALF the revenue per store compared to Supermarkets
-- What if size of outlet is impacting in this tend?
SELECT outlet.size, outlet.outlet_type,
    COUNT(DISTINCT outlet.outlet_id) as number_of_stores,
    ROUND(SUM(sales.sales)/COUNT(DISTINCT outlet.outlet_id), 2) as avg_revenue_per_store
FROM sales
JOIN outlet ON sales.outlet_id = outlet.outlet_id
GROUP BY outlet.size, outlet.outlet_type
ORDER BY outlet.size, avg_revenue_per_store DESC;
-- Insights:
-- Grocery Stores exist in both Medium and Small sizes
-- Medium Supermarkets outperform Medium Grocery Stores
-- Therefore size does not explain the underperformance — the business model itself is the likely cause
-------------------------------------------------------------------------------------------------------------------------------------------------------

-- Analysing impact of size in sales individually 
-- Average sales per outlet size
SELECT outlet.size, COUNT(DISTINCT outlet.outlet_id) as number_of_stores,
ROUND(SUM(sales.sales),2) as total_sales,
ROUND(SUM(sales.sales)/COUNT(DISTINCT outlet.outlet_id),2) as avg_sales_per_size
FROM sales
JOIN outlet on sales.outlet_id = outlet.outlet_id
GROUP BY size;
-- High outlets indicates have better sales performance, but it can not be asserted
-- Because the dataset is too small (only 10 stores and 1 High store) to make statistically reliable conclusions about size vs performance.
-------------------------------------------------------------------------------------------------------------------------------------------------------

-- Analyzing relation between outlet location and sales
-- Average reveneue by outlet location:
SELECT outlet.location_type, count(DISTINCT outlet.outlet_id) as number_of_stores,
ROUND(SUM(sales.sales),2) as total_sales, ROUND(SUM(sales.sales)/count(DISTINCT outlet.outlet_id),2) as avg_sales_per_location
FROM sales
JOIN outlet on sales.outlet_id= outlet.outlet_id
GROUP BY location_type
ORDER BY avg_sales_per_location;
-- In retail/business context:
-- Tier 1 → Major cities 
-- Tier 2 → Medium sized cities 
-- Tier 3 → Smaller cities or rural areas 
-- Tier 2 presents better performance, a possible explanation is that Tier 1 cities have higher competition — more supermarket chains fighting for the same customers. Tier 2 cities may have less competition but growing purchasing power —  potential spot for retail. Tier 3, as remote areas cities have lower purchasing power. 
SELECT outlet.location_type, outlet.outlet_type, count(DISTINCT outlet.outlet_id) as number_of_stores,
ROUND(SUM(sales.sales),2) as total_sales, ROUND(SUM(sales.sales)/count(DISTINCT outlet.outlet_id),2) as avg_sales_per_location
FROM sales
JOIN outlet on sales.outlet_id= outlet.outlet_id
GROUP BY location_type, outlet_type
ORDER BY avg_sales_per_location;
-- However when comparing outlet type and localiton the difference between tiers is not outstanding and this analysis have limitations due to dataset size
-- Outlet with biggest sales
SELECT outlet.outlet_id, ROUND(SUM(sales.sales),2) as Total_sales, outlet.outlet_type, outlet.location_type
FROM sales
JOIN outlet on sales.outlet_id= outlet.outlet_id
GROUP BY outlet_id
ORDER BY Total_sales DESC;
-- The results confirm the biggest find of the analysis: Independent of location and size, grocery store generates significantly lower profits 
------------------------------------------------------------------------------------------------------------------------------------------------------

-- Analyzing Trends over time
SELECT  outlet.establishment_year, ROUND(SUM(sales.sales),2) as Total_sales, count(distinct outlet.outlet_id)
FROM sales
JOIN outlet on sales.outlet_id = outlet.outlet_id
GROUP BY establishment_year
ORDER BY establishment_year ;
-- The store established in 2018 shows significantly higher total sales (204,522) compared to the average (≈130,000) because in that year two outlets were launched. 
-- However, a true sales trend analysis over time is not possible with this dataset because there is no sales date column — only the store establishment year is available. To perform time series analysis, transaction-level date data would be required.


