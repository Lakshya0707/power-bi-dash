# Retail Sales Analysis | SQL + Power BI

An end-to-end analytics project that models a retail business in MySQL, answers business questions with SQL, and presents the results in an interactive Power BI dashboard.

**Author:** Lakshya

## Objective
Understand where revenue and profit come from, how discounts affect margins, which regions, categories and products perform best, and where the business is losing money through returns and cancellations.

## Dataset
Four related tables, generated synthetically for this project to simulate a retail business (January 2023 to December 2025):

| Table | Rows | Description |
|---|---|---|
| customers | 500 | Customer, segment, city, region, signup date |
| products | 30 | Product, category, cost price, unit price |
| orders | 5,000 | Order date, status (Delivered / Returned / Cancelled), payment mode |
| order_items | 8,707 | Quantity and discount per product in each order |

Revenue is calculated as `quantity x unit_price x (1 - discount)`, and profit as revenue minus cost. Only delivered orders are counted in sales metrics.

## Tools
MySQL 8 (Workbench), Power BI Desktop, DAX.

## Repository Structure
```
retail_sales_analysis.sql   Schema, data quality checks, master view, 13 analysis queries
powerbi/measures.dax        Date table and DAX measures used in the dashboard
customers.csv, products.csv, orders.csv, order_items.csv
```

## SQL Techniques Used
Multi-table joins, CTEs, window functions (`LAG`, `RANK`, `NTILE`, running totals), conditional aggregation, views, data quality checks (orphan records, duplicates), and RFM customer segmentation.

## Power BI Dashboard
Connected to the `vw_sales` view in MySQL, with a dedicated date table and DAX measures for revenue, profit, margin, average order value, YoY growth and YTD revenue.

- **Executive Overview:** KPI cards, monthly revenue vs last year, revenue by category and city, filters for year, region and segment.
- **Product and Customer Analysis:** top products, category-to-product treemap, segment split, top customers, margin by discount level.
- **Operations:** payment mode share, return and cancellation rates by category, region by category matrix.

## Key Results

| Metric | Value |
|---|---|
| Delivered orders | 4,398 |
| Revenue | ₹80.9 million |
| Profit | ₹17.2 million |
| Profit margin | 21.3% |
| Average order value | ₹18,395 |

## Insights

1. **Electronics leads revenue, Home & Kitchen leads profitability.** Electronics contributes 27% of revenue (₹21.8M) but has the lowest margin at 19.4%. Home & Kitchen earns 25.3% margin, the highest of all categories, and generates almost the same profit as Electronics on much lower revenue.
2. **Discounts erode profit sharply.** Margin falls from 26.9% on undiscounted items to 23.0% at 5%, 18.5% at 10%, 14.3% at 15% and just 8.4% at 20% discount. Heavy discounting should be limited or tied to volume targets.
3. **South and West drive the business.** South contributes 33.3% of revenue and West 29.3%, followed by North at 27.7%. East contributes only 9.7%, the biggest expansion opportunity. Bengaluru, Mumbai, Hyderabad and Chennai are the top four cities.
4. **Top products are concentrated.** Bluetooth Speaker (₹5.55M), Dinner Set (₹5.18M), Study Table (₹4.88M), Yoga Mat (₹4.44M) and Headphones (₹3.88M) are the five biggest revenue products.
5. **Customer segments are balanced.** Corporate (35.2%), Home Office (33.1%) and Consumer (31.8%) contribute almost equally, so growth does not depend on a single segment.
6. **Revenue declined in 2025.** Revenue grew from ₹11.3M in 2023 to ₹38.3M in 2024, but dropped 18.2% to ₹31.3M in 2025. The 2023 figure reflects a ramp-up period, so the 2025 decline is the more important signal to investigate.
7. **Returns and cancellations need attention.** About 7.0% of items are returned and 5.2% of items are cancelled. Return rates are highest in Clothing (7.6%) and Electronics (7.5%), and cancellations are highest in Sports (6.2%).
8. **Payment mix is even.** All five payment modes hold between 18.5% and 21.2% of orders, with Cash on Delivery at 19.8%, so there is no dependence on one payment channel.

## Recommendations
- Cap discounts at 10% unless a promotion clearly drives volume, since margin drops below 15% beyond that.
- Push Home & Kitchen and Clothing, the higher-margin categories, through bundling and promotions.
- Invest in East region marketing and logistics to close the gap with other regions.
- Investigate the 2025 revenue decline by category and region, and reduce return rates in Clothing and Electronics through better product descriptions and quality checks.

## How to Run
1. Run the schema section of `retail_sales_analysis.sql` in MySQL to create `retail_db` and its tables.
2. Import the four CSV files in this order: customers, products, orders, order_items.
3. Run the remaining sections to create the `vw_sales` view and execute the analysis queries.
4. In Power BI Desktop, connect to `retail_db`, load `vw_sales`, and add the measures from `powerbi/measures.dax`.
