USE airline_booking_analysis;

-- KPI definitions:
-- Total bookings = count of rows in the analysis view.
-- Confirmed revenue = sum of fares for Confirmed records only.
-- Cancellation/no-show rates use all records as the denominator.
SELECT
  COUNT(*) AS total_records,
  COUNT(DISTINCT booking_id) AS distinct_booking_ids,
  COUNT(DISTINCT passenger_id) AS unique_passengers,
  COUNT(DISTINCT flight_number) AS unique_flights,
  SUM(CASE WHEN booking_status = 'Confirmed' THEN 1 ELSE 0 END) AS confirmed_bookings,
  SUM(CASE WHEN booking_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_bookings,
  SUM(CASE WHEN booking_status = 'No-show' THEN 1 ELSE 0 END) AS no_show_bookings,
  SUM(CASE WHEN booking_status = 'Confirmed' THEN COALESCE(fare_amount, 0) ELSE 0 END) AS confirmed_revenue,
  ROUND(AVG(CASE WHEN booking_status = 'Confirmed' THEN fare_amount END), 2) AS average_confirmed_fare,
  ROUND(100.0 * SUM(booking_status = 'Cancelled') / NULLIF(COUNT(*), 0), 2) AS cancellation_rate_pct,
  ROUND(100.0 * SUM(booking_status = 'No-show') / NULLIF(COUNT(*), 0), 2) AS no_show_rate_pct
FROM airline_analysis;
