-- Create a cleaned table from the raw staging table.
-- Assumptions: source dates are YYYY-MM-DD; fare amounts are numeric or comma/currency-prefixed.
-- Review the data-quality report first. This script preserves rows with missing non-key fields,
-- while excluding rows without a usable booking ID. It does not silently deduplicate conflicting IDs.
USE airline_booking_analysis;

DROP TABLE IF EXISTS airline_bookings_clean;

CREATE TABLE airline_bookings_clean AS
WITH normalized AS (
    SELECT
      NULLIF(TRIM(booking_id), '') AS booking_id,
      NULLIF(TRIM(passenger_id), '') AS passenger_id,
      NULLIF(TRIM(passenger_name), '') AS passenger_name,
      NULLIF(TRIM(flight_number), '') AS flight_number,
      UPPER(NULLIF(TRIM(origin), '')) AS origin,
      UPPER(NULLIF(TRIM(destination), '')) AS destination,
      STR_TO_DATE(NULLIF(TRIM(booking_date), ''), '%Y-%m-%d') AS booking_date,
      STR_TO_DATE(NULLIF(TRIM(travel_date), ''), '%Y-%m-%d') AS travel_date,
      CASE
        WHEN LOWER(TRIM(fare_class)) = 'economy' THEN 'Economy'
        WHEN LOWER(TRIM(fare_class)) = 'business' THEN 'Business'
        WHEN LOWER(TRIM(fare_class)) IN ('first', 'first class') THEN 'First'
        ELSE NULLIF(TRIM(fare_class), '')
      END AS fare_class,
      CAST(
        NULLIF(
          REPLACE(REPLACE(REPLACE(TRIM(fare_amount), ',', ''), '₹', ''), '$', ''),
          ''
        ) AS DECIMAL(12,2)
      ) AS fare_amount,
      CASE
        WHEN LOWER(TRIM(booking_channel)) IN ('website', 'web site', 'web') THEN 'Website'
        WHEN LOWER(TRIM(booking_channel)) IN ('mobile app', 'mobile', 'app') THEN 'Mobile App'
        WHEN LOWER(TRIM(booking_channel)) IN ('travel agent', 'agent') THEN 'Travel Agent'
        WHEN LOWER(TRIM(booking_channel)) IN ('airport counter', 'airport') THEN 'Airport Counter'
        ELSE NULLIF(TRIM(booking_channel), '')
      END AS booking_channel,
      CASE
        WHEN LOWER(TRIM(booking_status)) IN ('confirmed', 'confirm') THEN 'Confirmed'
        WHEN LOWER(TRIM(booking_status)) IN ('cancelled', 'canceled', 'cancel') THEN 'Cancelled'
        WHEN LOWER(TRIM(booking_status)) IN ('no-show', 'no show', 'noshow') THEN 'No-show'
        ELSE NULLIF(TRIM(booking_status), '')
      END AS booking_status
    FROM airline_bookings_raw
)
SELECT DISTINCT *
FROM normalized
WHERE booking_id IS NOT NULL;

-- Add indexes to support common groupings/joins.
CREATE INDEX idx_clean_booking_id ON airline_bookings_clean (booking_id);
CREATE INDEX idx_clean_passenger_id ON airline_bookings_clean (passenger_id);
CREATE INDEX idx_clean_travel_date ON airline_bookings_clean (travel_date);
CREATE INDEX idx_clean_route ON airline_bookings_clean (origin, destination);

-- Helpful analytical view with derived fields.
CREATE OR REPLACE VIEW airline_analysis AS
SELECT
  booking_id,
  passenger_id,
  passenger_name,
  flight_number,
  origin,
  destination,
  CONCAT(origin, ' -> ', destination) AS route,
  booking_date,
  travel_date,
  YEAR(travel_date) AS travel_year,
  MONTH(travel_date) AS travel_month_number,
  DATE_FORMAT(travel_date, '%Y-%m') AS travel_month,
  DAYNAME(travel_date) AS travel_day,
  fare_class,
  fare_amount,
  booking_channel,
  booking_status,
  DATEDIFF(travel_date, booking_date) AS booking_lead_days
FROM airline_bookings_clean;

SELECT COUNT(*) AS clean_rows FROM airline_bookings_clean;
