# 🛒 Blinkit Grocery Sales Analysis
### SQL + Power BI | Data Analysis Portfolio Project
**Author:** Júlia Lobo

---

## 📌 Project Overview

This project analyzes sales data from **Blinkit**, an Indian quick-commerce grocery delivery platform. The goal was to explore sales performance across different product categories, outlet types, locations, and sizes — identifying patterns and business insights from raw data.

The project covers the full data workflow: from raw CSV import, data cleaning, database normalization, SQL analysis, to a Power BI dashboard.

---

## 🛠️ Tools & Technologies

- **MySQL** — data storage, cleaning, normalization and analysis
- **MySQL Workbench** — database management and ERD design
- **Power BI** — interactive dashboard and data visualization
- **GitHub** — version control and portfolio documentation

---

## 📂 Dataset

- **Source:** Blinkit Grocery Dataset (Kaggle)
- **Size:** 8,523 rows
- **Original format:** Single flat CSV file

### Columns:
| Column | Description |
|--------|-------------|
| Item Identifier | Unique product code |
| Item Type | Product category |
| Item Fat Content | Low Fat or Regular |
| Item Visibility | Shelf visibility score |
| Outlet Identifier | Unique store code |
| Outlet Type | Store format (Supermarket/Grocery) |
| Outlet Size | Small, Medium or High |
| Outlet Location Type | Tier 1, 2 or 3 city |
| Outlet Establishment Year | Year store was opened |
| Sales | Total sales value |
| Rating | Customer rating |

---

## 🗄️ Database Design & Normalization

The raw flat CSV was normalized into **3NF (Third Normal Form)** — splitting the data into 3 related tables to eliminate redundancy and ensure data integrity.

### Entity Relationship Diagram (ERD):

![ERD Diagram](erd_diagram.png)

### Tables:

**Items** — unique product properties
- `Item_Id` (PK), `Item_Fat_Content`, `Item_Type`
- 1,559 unique items

**Outlet** — unique store properties
- `outlet_id` (PK), `establishment_year`, `location_type`, `size`, `outlet_type`
- 10 unique outlets

**Sales** — transaction bridge table (resolves Many-to-Many)
- `sale_id` (PK), `Item_Id` (FK), `outlet_id` (FK), `item_visibility`, `sales`, `rating`
- 8,523 transactions

---

## 🧹 Data Cleaning

Before analysis, the following issues were identified and fixed:

- **Inconsistent categorical values** → `Item_Fat_Content` had 4 variations ("Low Fat", "low fat", "LF", "reg") standardized to 2 clean values
- **Dirty data in Outlet Size** → 3 outlets had conflicting size values — fixed using the most frequent value per outlet (majority rule)
- **Missing values** → `Item_Weight` column had 17% missing values — column excluded from analysis
- **Data type corrections** → All columns imported as TEXT and converted to correct types (INT, DOUBLE, VARCHAR) after cleaning

---

## 📊 Analysis & Key Findings

### 1 — Sales by Item Type
- **Snack Foods and Frozen Foods** are the top selling categories by total revenue
- **Seafood** generates the highest average revenue per individual item — suggesting premium pricing
- **Low Fat Snack Foods sell 16% more than Regular Snacks** — indicating a growing consumer preference for healthier options

### 2 — Outlet Type Performance
- **Supermarket Type1** dominates total sales (≈65% of revenue) — explained by volume (6 out of 10 stores)
- When comparing **average revenue per store**, all Supermarket types perform similarly 
- **Grocery Stores generate significantly less revenue per store ** 

### 3 — Does Size Explain Grocery Store Underperformance?
- Grocery Stores exist in both **Medium and Small** sizes
- Medium Supermarkets **outperform** Medium Grocery Stores
- ⚠️ **Conclusion:** Size does not explain the underperformance — the **business model itself** (limited product range, fewer departments, lower customer traffic) is the likely cause

### 4 — Sales by Location Tier
> *Tier classification follows the standard Indian market definition: Tier 1 = major cities, Tier 2 = medium cities, Tier 3 = smaller/rural areas*

- Tier 2 locations outperform Tier 1
- **Possible explanation:** Tier 1 cities have higher market saturation and competition. Tier 2 cities offer growing purchasing power with less competitive pressure — a potential sweet spot for retail expansion
- ⚠️ Differences between tiers are not statistically outstanding given the small sample size

### 5 — Item Visibility vs Sales
- **No significant correlation** found between item visibility and sales
- Contrary to retail intuition, shelf placement does not appear to drive purchase decisions in this dataset
- Other factors (product category, brand recognition, price) likely have greater influence

### 6 — Rating Analysis
- Average rating across all products: **4.69 / 5**
- Ratings are very uniform — limited variation between categories
- No significant correlation between rating and sales performance

---

## ⚠️ Dataset Limitations

- **Small sample size** — only 10 unique stores. Statistical conclusions about size and location impact should be interpreted with caution
- **No transaction date column** — a true time series sales trend analysis is not possible. Only store establishment year is available, which represents when the store opened, not when sales occurred
- **Single snapshot** — the dataset represents accumulated sales without temporal granularity

---

## 📈 Dashboard

![Dashboard](dashboard_screenshot.png)

### Dashboard includes:
- KPI Cards: Total Sales, Total Outlets, Average Rating
- Total Sales by Item Type
- Average Revenue per Outlet Type
- Sales by Outlet Location
- Correlation: Sales vs Item Visibility
- Interactive filter by Outlet type

---

## 💡 Business Recommendations

1. **Expand Supermarket format** over Grocery Stores — significantly higher revenue per store regardless of location or size
2. **Prioritize Tier 2 city expansion** — less competition with growing purchasing power
3. **Invest in healthier product lines** — Low Fat Snack Foods outperforming Regular suggests a market trend worth capitalizing on
4. **Re-evaluate shelf space strategy** — visibility alone does not drive sales; focus on product mix and category placement instead
5. **Collect transaction-level date data** — essential for proper time series analysis and seasonal trend identification

---


*This project was developed as part of a Data Science portfolio to demonstrate SQL data cleaning, normalization, and analytical skills combined with Power BI visualization.*
