USE airline_booking_analysis;

-- Overall booking status distribution
SELECT booking_status, COUNT(*) AS records,
  ROUND(100.0 * COUNT(*) / NULLIF((SELECT COUNT(*) FROM airline_analysis), 0), 2) AS pct_of_records
FROM airline_analysis
GROUP BY booking_status
ORDER BY records DESC;

-- Cancellation rate by channel
SELECT
  booking_channel,
  COUNT(*) AS total_records,
  SUM(booking_status = 'Cancelled') AS cancellations,
  ROUND(100.0 * SUM(booking_status = 'Cancelled') / NULLIF(COUNT(*), 0), 2) AS cancellation_rate_pct
FROM airline_analysis
GROUP BY booking_channel
ORDER BY cancellation_rate_pct DESC;

-- Cancellation rate by fare class
SELECT
  fare_class,
  COUNT(*) AS total_records,
  SUM(booking_status = 'Cancelled') AS cancellations,
  ROUND(100.0 * SUM(booking_status = 'Cancelled') / NULLIF(COUNT(*), 0), 2) AS cancellation_rate_pct
FROM airline_analysis
GROUP BY fare_class
ORDER BY cancellation_rate_pct DESC;

-- No-show rate by route
SELECT
  route,
  COUNT(*) AS total_records,
  SUM(booking_status = 'No-show') AS no_shows,
  ROUND(100.0 * SUM(booking_status = 'No-show') / NULLIF(COUNT(*), 0), 2) AS no_show_rate_pct
FROM airline_analysis
GROUP BY route
HAVING COUNT(*) >= 10
ORDER BY no_show_rate_pct DESC;
