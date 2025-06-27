CREATE TABLE actors (
                        actorid INT PRIMARY KEY,
                        films ARRAY<STRUCT<
        film STRING,
                        votes INT,
                        rating FLOAT,
                        filmid INT
                            >>,
                        quality_class STRING,
                        is_active BOOLEAN
);

WITH latest_films AS (
    SELECT
        actorid,
        ARRAY_AGG(
                STRUCT(film, votes, rating, filmid)
                    ORDER BY year DESC
        ) AS films
    FROM actor_films
    GROUP BY actorid
),
     average_ratings AS (
         SELECT
             actorid,
             AVG(rating) AS avg_rating,
             MAX(CASE WHEN year = EXTRACT(YEAR FROM CURRENT_DATE) THEN 1 ELSE 0 END) AS is_active_flag
         FROM actor_films
         GROUP BY actorid
     )
INSERT INTO actors
SELECT
    f.actorid,
    f.films,
    CASE
        WHEN a.avg_rating > 8 THEN 'star'
        WHEN a.avg_rating > 7 THEN 'good'
        WHEN a.avg_rating > 6 THEN 'average'
        ELSE 'bad'
        END AS quality_class,
    a.is_active_flag = 1 AS is_active
FROM latest_films f
         JOIN average_ratings a
              ON f.actorid = a.actorid;


CREATE TABLE actors_history_scd (
                                    actorid INT,
                                    quality_class STRING,
                                    is_active BOOLEAN,
                                    start_date DATE,
                                    end_date DATE,
                                    PRIMARY KEY (actorid, start_date)
);

INSERT INTO actors_history_scd
WITH ranked_actors AS (
    SELECT
        actorid,
        quality_class,
        is_active,
        ROW_NUMBER() OVER (PARTITION BY actorid ORDER BY start_date ASC) AS row_num,
            start_date,
        LEAD(start_date) OVER (PARTITION BY actorid ORDER BY start_date ASC) AS next_start_date
    FROM actors
)
SELECT
    actorid,
    quality_class,
    is_active,
    start_date,
    COALESCE(next_start_date - INTERVAL 1 DAY, CAST('9999-12-31' AS DATE)) AS end_date
FROM ranked_actors;

WITH updated_data AS (
    SELECT
        a.actorid,
        a.quality_class,
        a.is_active,
        CURRENT_DATE AS start_date,
        NULL AS end_date
    FROM actors a
),
     closed_out AS (
UPDATE actors_history_scd
SET end_date = CURRENT_DATE - INTERVAL 1 DAY
WHERE actorid IN (SELECT actorid FROM updated_data)
    RETURNING *
    )
INSERT INTO actors_history_scd
SELECT * FROM updated_data;
