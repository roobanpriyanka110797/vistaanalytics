USE airline_booking_analysis;

SELECT
  DATE_FORMAT(booking_date, '%Y-%m') AS booking_month,
  COUNT(*) AS bookings
FROM airline_bookings_clean
WHERE booking_date IS NOT NULL
GROUP BY DATE_FORMAT(booking_date, '%Y-%m')
ORDER BY booking_month;

SELECT
  travel_year,
  travel_month_number,
  travel_month,
  COUNT(*) AS total_records,
  SUM(booking_status = 'Confirmed') AS confirmed_bookings,
  SUM(CASE WHEN booking_status = 'Confirmed' THEN COALESCE(fare_amount, 0) ELSE 0 END) AS confirmed_revenue
FROM airline_analysis
WHERE travel_date IS NOT NULL
GROUP BY travel_year, travel_month_number, travel_month
ORDER BY travel_year, travel_month_number;

SELECT
  WEEKDAY(travel_date) AS weekday_number,
  DAYNAME(travel_date) AS travel_day,
  COUNT(*) AS total_records,
  SUM(booking_status = 'Confirmed') AS confirmed_bookings
FROM airline_analysis
WHERE travel_date IS NOT NULL
GROUP BY WEEKDAY(travel_date), DAYNAME(travel_date)
ORDER BY weekday_number;

SELECT
  CASE
    WHEN booking_lead_days BETWEEN 0 AND 3 THEN '0-3 days'
    WHEN booking_lead_days BETWEEN 4 AND 7 THEN '4-7 days'
    WHEN booking_lead_days BETWEEN 8 AND 30 THEN '8-30 days'
    WHEN booking_lead_days BETWEEN 31 AND 60 THEN '31-60 days'
    WHEN booking_lead_days > 60 THEN '61+ days'
  END AS booking_window,
  COUNT(*) AS bookings,
  ROUND(AVG(CASE WHEN booking_status = 'Confirmed' THEN fare_amount END), 2) AS average_confirmed_fare
FROM airline_analysis
WHERE booking_lead_days >= 0
GROUP BY
  CASE
    WHEN booking_lead_days BETWEEN 0 AND 3 THEN '0-3 days'
    WHEN booking_lead_days BETWEEN 4 AND 7 THEN '4-7 days'
    WHEN booking_lead_days BETWEEN 8 AND 30 THEN '8-30 days'
    WHEN booking_lead_days BETWEEN 31 AND 60 THEN '31-60 days'
    WHEN booking_lead_days > 60 THEN '61+ days'
  END
ORDER BY MIN(booking_lead_days);
