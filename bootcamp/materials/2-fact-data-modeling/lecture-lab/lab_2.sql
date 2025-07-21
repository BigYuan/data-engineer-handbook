-- select * from events

-- CREATE TABLE users_cumulated (
-- 	 user_id TEXT,
-- 	 dates_active DATE[],
-- 	 date DATE,
-- 	 PRIMARY KEY (user_id, date)
-- )


-- WITH yesterday AS (
--     SELECT * FROM users_cumulated
--     WHERE date = DATE('2023-01-03')
-- ),
--     today AS (
--           SELECT cast(user_id as TEXT),
--                  DATE(cast(event_time as timestamp)) AS today_date,
--                  COUNT(1) AS num_events FROM events
--             WHERE DATE_TRUNC('day', cast(event_time as timestamp)) = DATE('2023-01-04')
--             AND user_id IS NOT NULL
--          GROUP BY user_id,  DATE(cast(event_time as timestamp))
--     )
-- INSERT INTO users_cumulated
-- SELECT
--        COALESCE(t.user_id, y.user_id),
--        COALESCE(y.dates_active,
--            ARRAY[]::DATE[])
--             || CASE WHEN
--                 t.user_id IS NOT NULL
--                 THEN ARRAY[t.today_date]
--                 ELSE ARRAY[]::DATE[]
--                 END AS date_list,
--        COALESCE(t.today_date, y.date + Interval '1 day') as date
-- From yesterday y
--     FULL OUTER JOIN
--     today t ON t.user_id = y.user_id;


-- select * from generate_series(Date('2023-01-01'),DATE('2023-01-04'),INTERVAL '1 day')

WITH starter AS (
    SELECT uc.dates_active @> ARRAY [DATE(d.valid_date)]   AS is_active,
           EXTRACT(
               DAY FROM DATE('2023-01-01') - d.valid_date) AS days_since,
           uc.user_id
    FROM users_cumulated uc
             CROSS JOIN
         (SELECT generate_series('2023-01-01', '2023-01-04', INTERVAL '1 day') AS valid_date) as d
    WHERE date = DATE('2023-01-01')
),
     bits AS (
         SELECT user_id,
                SUM(CASE
                        WHEN is_active THEN POW(2, 32 - days_since)
                        ELSE 0 END)::bigint::bit(32) AS datelist_int
         FROM starter
         GROUP BY user_id
     )

SELECT
       user_id,
       datelist_int,
       BIT_COUNT(datelist_int) > 0 AS monthly_active,
       BIT_COUNT(datelist_int) AS l32,
       BIT_COUNT(datelist_int &
       	CAST('11111110000000000000000000000000' AS BIT(32))) > 0 AS weekly_active,
       BIT_COUNT(datelist_int &
       	CAST('11111110000000000000000000000000' AS BIT(32)))  AS l7,
       BIT_COUNT(datelist_int &
       	CAST('00000001111111000000000000000000' AS BIT(32))) > 0 AS weekly_active_previous_week,
	   BIT_COUNT(datelist_int &
       	CAST('10000000000000000000000000000000' AS BIT(32))) > 0 AS daily
FROM bits;



