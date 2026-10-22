# Retail Sales Analysis | SQL + Power BI

## Part A: Power BI banane ke steps (30-40 min)

1. **Get Data > MySQL database** > server `localhost`, database `retail_db`
   Load: `vw_sales`, `customers`, `products` (ya sirf `vw_sales` + ek Date table)
2. **Date table banao** (Modeling > New Table):
```DAX
DateTable =
ADDCOLUMNS(
    CALENDAR(DATE(2023,1,1), DATE(2025,12,31)),
    "Year", YEAR([Date]),
    "Month No", MONTH([Date]),
    "Month", FORMAT([Date], "MMM"),
    "Quarter", "Q" & QUARTER([Date])
)
```
   Relationship: `DateTable[Date]` -> `vw_sales[order_date]` (one-to-many)
   Month column ko "Sort by column" > Month No karna mat bhoolna.

3. **Measures** (New Measure):
```DAX
Total Revenue = SUM(vw_sales[revenue])
Total Profit = SUM(vw_sales[profit])
Profit Margin % = DIVIDE([Total Profit], [Total Revenue])
Total Orders = DISTINCTCOUNT(vw_sales[order_id])
Total Customers = DISTINCTCOUNT(vw_sales[customer_id])
Avg Order Value = DIVIDE([Total Revenue], [Total Orders])
Revenue LY = CALCULATE([Total Revenue], SAMEPERIODLASTYEAR(DateTable[Date]))
YoY Growth % = DIVIDE([Total Revenue] - [Revenue LY], [Revenue LY])
Revenue YTD = TOTALYTD([Total Revenue], DateTable[Date])
```

## Part B: Dashboard layout

**Page 1: Executive Overview**
- Top row: 5 KPI cards (Revenue, Profit, Margin %, Orders, AOV)
- Line chart: Revenue by Month (Revenue + Revenue LY)
- Clustered bar: Revenue by Category
- Map / filled map: Revenue by City
- Slicers: Year, Region, Segment

**Page 2: Product & Customer**
- Top 10 products (bar, Top N filter)
- Treemap: Category > Product
- Donut: Segment-wise revenue
- Table: Top 10 customers
- Column chart: Margin % by Discount %

**Page 3: Operations**
- Donut: Payment mode share
- Bar: Return / cancel rate by category (SQL Q9 se data)
- Matrix: Region x Category revenue with conditional formatting

Theme: ek hi color palette rakh (e.g. dark blue + teal), title mein project name, har chart ka title clear.

## Part C: Insights likhna (submission me zaroor daalna)
Dashboard dekh ke 4-5 lines apne words me likh, jaise:
- Kaunsi category sabse zyada revenue/profit deti hai
- Kis region/city me growth hai ya girawat
- Discount badhne par margin kitna girta hai
- Repeat customers ka share kitna hai
- Recommendation: kahan focus karein

(Numbers apne dashboard se uthana, kyunki dataset synthetic hai toh actual values tere run pe dikhengi.)

## Part D: Submission ke liye README (copy kar le)

**Project:** Retail Sales Analysis using MySQL and Power BI
**Objective:** Sales, profit, customer aur product performance analyze karke business insights nikalna.
**Data:** 4 related tables (customers, products, orders, order_items), 5,000 orders, 2023-2025.
**SQL:** Joins, CTEs, window functions (LAG, RANK, NTILE, running total), views, RFM segmentation.
**Power BI:** Star-style model, date table, DAX measures (YoY, YTD, margin), 3-page interactive dashboard.
**Tools:** MySQL Workbench, Power BI Desktop.

## Submit kya karna hai
1. `retail_sales_analysis.sql`
2. 4 CSV files
3. `.pbix` file + dashboard ke screenshots/PDF
4. Ye README + insights
5. GitHub pe upload kar de, link bhej dena
