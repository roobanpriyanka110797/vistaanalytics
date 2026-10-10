AIRLINE BOOKING ANALYSIS — SQL FILES (MySQL 8.0+)

Run in this order:
1. 01_create_database.sql
2. 02_create_raw_table.sql
   Import your CSV into airline_bookings_raw. The CSV headers/column order must be mapped
   to the table fields in the import wizard.
3. 03_data_quality_checks.sql
4. 04_clean_and_build_analysis_view.sql
5. 05_kpi_summary.sql
6. 06_revenue_route_flight_fareclass.sql
7. 07_booking_trends_and_lead_time.sql
8. 08_cancellation_and_status_analysis.sql
9. 09_customer_analysis.sql
10. 10_advanced_analysis.sql

IMPORTANT:
- These scripts assume MySQL 8.0+ and the field names listed in 02_create_raw_table.sql.
- Dates are expected as YYYY-MM-DD. If your source uses another format, change STR_TO_DATE
  format strings in scripts 03 and 04 before running.
- The raw table stores dates/fare as text to let you inspect malformed values before conversion.
- Review duplicates before removing them. CREATE TABLE ... SELECT DISTINCT removes only rows
  identical across all selected columns; it does not guarantee one row per booking ID if the
  same ID has conflicting details.
- Confirmed revenue is defined as the sum of fare_amount for records with booking_status='Confirmed'.
  This is a proxy based on the available fields, not necessarily recognized accounting revenue.
- No-show/cancellation rates use all rows as the denominator.
- The schema does not include seat capacity or aircraft capacity, so load factor cannot be calculated
  from these fields alone.
- If your actual CSV has different column names or multiple rows per booking, adapt the schema and
  business definitions before interpreting the outputs.
