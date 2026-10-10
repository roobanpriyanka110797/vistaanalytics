USE airline_booking_analysis;

CREATE TABLE IF NOT EXISTS airline_bookings_raw (
    booking_id       VARCHAR(100),
    passenger_id     VARCHAR(100),
    passenger_name   VARCHAR(200),
    flight_number    VARCHAR(50),
    origin           VARCHAR(20),
    destination      VARCHAR(20),
    booking_date     VARCHAR(50),
    travel_date      VARCHAR(50),
    fare_class       VARCHAR(50),
    fare_amount      VARCHAR(50),
    booking_channel  VARCHAR(100),
    booking_status   VARCHAR(50)
);

SELECT COUNT(*) AS raw_row_count FROM airline_bookings_raw;
SELECT * FROM airline_bookings_raw LIMIT 10;
