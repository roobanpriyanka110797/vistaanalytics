USE airline_booking_analysis;

-- Rank routes by confirmed revenue
WITH route_revenue AS (
  SELECT route,
    SUM(CASE WHEN booking_status = 'Confirmed' THEN COALESCE(fare_amount, 0) ELSE 0 END) AS revenue
  FROM airline_analysis
  GROUP BY route
)
SELECT route, revenue, RANK() OVER (ORDER BY revenue DESC) AS revenue_rank
FROM route_revenue
ORDER BY revenue_rank, route;

-- Fare class share of confirmed revenue
WITH fare_revenue AS (
  SELECT fare_class,
    SUM(CASE WHEN booking_status = 'Confirmed' THEN COALESCE(fare_amount, 0) ELSE 0 END) AS revenue
  FROM airline_analysis
  GROUP BY fare_class
)
SELECT fare_class, revenue,
  ROUND(100.0 * revenue / NULLIF(SUM(revenue) OVER (), 0), 2) AS revenue_share_pct
FROM fare_revenue
ORDER BY revenue DESC;

-- Month-over-month revenue change by travel month
WITH monthly_revenue AS (
  SELECT
    DATE_FORMAT(travel_date, '%Y-%m') AS travel_month,
    SUM(CASE WHEN booking_status = 'Confirmed' THEN COALESCE(fare_amount, 0) ELSE 0 END) AS revenue
  FROM airline_analysis
  WHERE travel_date IS NOT NULL
  GROUP BY DATE_FORMAT(travel_date, '%Y-%m')
),
monthly_lag AS (
  SELECT travel_month, revenue,
    LAG(revenue) OVER (ORDER BY travel_month) AS previous_month_revenue
  FROM monthly_revenue
)
SELECT travel_month, revenue, previous_month_revenue,
  revenue - previous_month_revenue AS revenue_change,
  ROUND(100.0 * (revenue - previous_month_revenue) / NULLIF(previous_month_revenue, 0), 2) AS revenue_change_pct
FROM monthly_lag
ORDER BY travel_month;

-- Data validation summary after cleaning
SELECT
  COUNT(*) AS clean_rows,
  SUM(booking_id IS NULL) AS missing_booking_id,
  SUM(booking_date IS NULL) AS missing_or_unparsed_booking_date,
  SUM(travel_date IS NULL) AS missing_or_unparsed_travel_date,
  SUM(fare_amount IS NULL) AS missing_or_unparsed_fare,
  SUM(fare_amount < 0) AS negative_fares,
  SUM(booking_date > travel_date) AS booking_after_travel
FROM airline_bookings_clean;
