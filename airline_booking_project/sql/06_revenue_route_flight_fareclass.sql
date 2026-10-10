USE airline_booking_analysis;

SELECT
  route,
  COUNT(*) AS total_records,
  SUM(booking_status = 'Confirmed') AS confirmed_bookings,
  SUM(CASE WHEN booking_status = 'Confirmed' THEN COALESCE(fare_amount, 0) ELSE 0 END) AS confirmed_revenue,
  ROUND(AVG(CASE WHEN booking_status = 'Confirmed' THEN fare_amount END), 2) AS average_confirmed_fare
FROM airline_analysis
GROUP BY route
ORDER BY confirmed_revenue DESC;

SELECT
  route,
  SUM(CASE WHEN booking_status = 'Confirmed' THEN COALESCE(fare_amount, 0) ELSE 0 END) AS confirmed_revenue
FROM airline_analysis
GROUP BY route
ORDER BY confirmed_revenue DESC
LIMIT 10;

SELECT
  flight_number,
  COUNT(*) AS total_records,
  SUM(booking_status = 'Confirmed') AS confirmed_bookings,
  SUM(CASE WHEN booking_status = 'Confirmed' THEN COALESCE(fare_amount, 0) ELSE 0 END) AS confirmed_revenue,
  ROUND(AVG(CASE WHEN booking_status = 'Confirmed' THEN fare_amount END), 2) AS average_confirmed_fare
FROM airline_analysis
GROUP BY flight_number
ORDER BY confirmed_revenue DESC;

SELECT
  fare_class,
  COUNT(*) AS total_records,
  SUM(booking_status = 'Confirmed') AS confirmed_bookings,
  SUM(CASE WHEN booking_status = 'Confirmed' THEN COALESCE(fare_amount, 0) ELSE 0 END) AS confirmed_revenue,
  ROUND(AVG(CASE WHEN booking_status = 'Confirmed' THEN fare_amount END), 2) AS average_confirmed_fare
FROM airline_analysis
GROUP BY fare_class
ORDER BY confirmed_revenue DESC;


WITH route_revenue AS (
  SELECT route,
    SUM(CASE WHEN booking_status = 'Confirmed' THEN COALESCE(fare_amount, 0) ELSE 0 END) AS revenue
  FROM airline_analysis
  GROUP BY route
)
SELECT route, revenue,
  ROUND(100.0 * revenue / NULLIF(SUM(revenue) OVER (), 0), 2) AS revenue_share_pct,
  RANK() OVER (ORDER BY revenue DESC) AS revenue_rank
FROM route_revenue
ORDER BY revenue DESC;
