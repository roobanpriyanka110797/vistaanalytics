-- Run after importing data into airline_bookings_raw.
USE airline_booking_analysis;

-- 1) Overall size and distinct identifiers
SELECT COUNT(*) AS raw_rows FROM airline_bookings_raw;
SELECT COUNT(DISTINCT NULLIF(TRIM(booking_id), '')) AS distinct_booking_ids
FROM airline_bookings_raw;
SELECT COUNT(DISTINCT NULLIF(TRIM(passenger_id), '')) AS distinct_passengers
FROM airline_bookings_raw;

-- 2) Blank or NULL values in key columns
SELECT
  SUM(booking_id IS NULL OR TRIM(booking_id) = '') AS missing_booking_id,
  SUM(passenger_id IS NULL OR TRIM(passenger_id) = '') AS missing_passenger_id,
  SUM(flight_number IS NULL OR TRIM(flight_number) = '') AS missing_flight_number,
  SUM(origin IS NULL OR TRIM(origin) = '') AS missing_origin,
  SUM(destination IS NULL OR TRIM(destination) = '') AS missing_destination,
  SUM(booking_date IS NULL OR TRIM(booking_date) = '') AS missing_booking_date,
  SUM(travel_date IS NULL OR TRIM(travel_date) = '') AS missing_travel_date,
  SUM(fare_class IS NULL OR TRIM(fare_class) = '') AS missing_fare_class,
  SUM(fare_amount IS NULL OR TRIM(fare_amount) = '') AS missing_fare_amount,
  SUM(booking_channel IS NULL OR TRIM(booking_channel) = '') AS missing_booking_channel,
  SUM(booking_status IS NULL OR TRIM(booking_status) = '') AS missing_booking_status
FROM airline_bookings_raw;

-- 3) Duplicate booking IDs (inspect before deciding how to handle them)
SELECT TRIM(booking_id) AS booking_id, COUNT(*) AS row_count
FROM airline_bookings_raw
WHERE booking_id IS NOT NULL AND TRIM(booking_id) <> ''
GROUP BY TRIM(booking_id)
HAVING COUNT(*) > 1
ORDER BY row_count DESC;

-- 4) Category values / possible inconsistent labels
SELECT DISTINCT TRIM(fare_class) AS fare_class FROM airline_bookings_raw ORDER BY 1;
SELECT DISTINCT TRIM(booking_status) AS booking_status FROM airline_bookings_raw ORDER BY 1;
SELECT DISTINCT TRIM(booking_channel) AS booking_channel FROM airline_bookings_raw ORDER BY 1;

-- 5) Date/fare values that need review. These assume ISO dates (YYYY-MM-DD).
SELECT *
FROM airline_bookings_raw
WHERE (NULLIF(TRIM(booking_date), '') IS NOT NULL
       AND STR_TO_DATE(TRIM(booking_date), '%Y-%m-%d') IS NULL)
   OR (NULLIF(TRIM(travel_date), '') IS NOT NULL
       AND STR_TO_DATE(TRIM(travel_date), '%Y-%m-%d') IS NULL);

SELECT *
FROM airline_bookings_raw
WHERE NULLIF(TRIM(fare_amount), '') IS NOT NULL
  AND CAST(REPLACE(REPLACE(TRIM(fare_amount), ',', ''), '₹', '') AS DECIMAL(12,2)) < 0;

-- 6) Booking date after travel date (valid ISO dates only)
SELECT *
FROM airline_bookings_raw
WHERE STR_TO_DATE(TRIM(booking_date), '%Y-%m-%d') IS NOT NULL
  AND STR_TO_DATE(TRIM(travel_date), '%Y-%m-%d') IS NOT NULL
  AND STR_TO_DATE(TRIM(booking_date), '%Y-%m-%d')
      > STR_TO_DATE(TRIM(travel_date), '%Y-%m-%d');
