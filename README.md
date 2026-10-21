# Jewellery Order & Production Analytics System

## Project Overview
A SQL-based analytics project designed to track client orders, jewellery production workflows, quality-control checks, delivery performance, invoices, and outstanding payments in a lab-grown diamond jewellery business.

The project demonstrates how relational databases and SQL queries can support operational reporting and business decision-making.

## Business Objectives
- Monitor client-wise order volumes and order value.
- Analyse product demand and sales value.
- Track order status and on-time delivery performance.
- Evaluate production turnaround time (TAT).
- Measure quality-control pass rates and identify failures.
- Monitor invoice payments and outstanding balances.
- Perform data-quality and consistency checks.
- Consolidate key business performance indicators (KPIs).

## Tools & Technologies
- MySQL
- MySQL Workbench
- SQL: JOINs, aggregate functions, GROUP BY, CASE statements, subqueries, date functions, and conditional calculations.

## Database Design
The database contains 10 related tables:

1. `clients`
2. `client_contacts`
3. `skus`
4. `orders`
5. `order_items`
6. `production_stages`
7. `production_stage_log`
8. `tolerance_checks`
9. `invoices`
10. `invoice_payments`

Primary keys, foreign keys, constraints, and appropriate data types are used to structure the database and maintain data integrity.

## Key Analysis Areas
- Client performance and order value analysis
- Product-wise demand analysis
- On-time delivery and delay analysis
- Production-stage turnaround time analysis
- Quality-control performance
- Invoice-wise payment and outstanding balance analysis
- Data validation and business KPI reporting

## How to Run
1. Install MySQL Server and MySQL Workbench.
2. Open `LGD_Order_Analytics.sql` in MySQL Workbench.
3. Execute the database setup, table creation, and sample-data sections in order.
4. Run the analysis queries to explore the results.

**Note:** The project uses illustrative sample data for demonstration purposes. The records do not represent actual company or client data.

## Project Outcome
This project demonstrates practical SQL skills for relational database design, data validation, operational analytics, and business reporting in a jewellery order and production environment.
