USE airline_booking_analysis;

WITH customer_summary AS (
  SELECT
    passenger_id,
    MAX(passenger_name) AS passenger_name,
    COUNT(*) AS total_records,
    SUM(booking_status = 'Confirmed') AS confirmed_bookings,
    SUM(CASE WHEN booking_status = 'Confirmed' THEN COALESCE(fare_amount, 0) ELSE 0 END) AS confirmed_revenue
  FROM airline_analysis
  WHERE passenger_id IS NOT NULL
  GROUP BY passenger_id
)
SELECT *,
  CASE
    WHEN total_records = 1 THEN 'One-time traveler'
    WHEN total_records BETWEEN 2 AND 4 THEN 'Occasional traveler'
    ELSE 'Frequent traveler'
  END AS customer_segment
FROM customer_summary
ORDER BY confirmed_revenue DESC;

WITH customer_summary AS (
  SELECT
    passenger_id,
    COUNT(*) AS total_records,
    SUM(booking_status = 'Confirmed') AS confirmed_bookings,
    SUM(CASE WHEN booking_status = 'Confirmed' THEN COALESCE(fare_amount, 0) ELSE 0 END) AS confirmed_revenue
  FROM airline_analysis
  WHERE passenger_id IS NOT NULL
  GROUP BY passenger_id
),
segmented AS (
  SELECT *,
    CASE
      WHEN total_records = 1 THEN 'One-time traveler'
      WHEN total_records BETWEEN 2 AND 4 THEN 'Occasional traveler'
      ELSE 'Frequent traveler'
    END AS customer_segment
  FROM customer_summary
)
SELECT
  customer_segment,
  COUNT(*) AS customers,
  SUM(total_records) AS total_records,
  SUM(confirmed_bookings) AS confirmed_bookings,
  SUM(confirmed_revenue) AS confirmed_revenue
FROM segmented
GROUP BY customer_segment
ORDER BY confirmed_revenue DESC;

WITH customer_revenue AS (
  SELECT passenger_id, MAX(passenger_name) AS passenger_name,
    SUM(CASE WHEN booking_status = 'Confirmed' THEN COALESCE(fare_amount, 0) ELSE 0 END) AS confirmed_revenue
  FROM airline_analysis
  WHERE passenger_id IS NOT NULL
  GROUP BY passenger_id
),
ranked AS (
  SELECT *,
    RANK() OVER (ORDER BY confirmed_revenue DESC) AS revenue_rank
  FROM customer_revenue
)
SELECT *
FROM ranked
WHERE revenue_rank <= 10
ORDER BY revenue_rank, passenger_id;
