 -- CREATE TYPE season_stats AS (
 --                         season Integer,
 --                         pts REAL,
 --                         ast REAL,
 --                         reb REAL,
 --                         weight INTEGER
 --                       );
 -- CREATE TYPE scoring_class AS
 --     ENUM ('bad', 'average', 'good', 'star');

 -- CREATE TABLE players (
 --     player_name TEXT,
 --     height TEXT,
 --     college TEXT,
 --     country TEXT,
 --     draft_year TEXT,
 --     draft_round TEXT,
 --     draft_number TEXT,
 --     seasons season_stats[],
 --     -- scoring_class scoring_class,
 --     -- years_since_last_active INTEGER,
 --     -- is_active BOOLEAN,
 --     current_season INTEGER,
 --     PRIMARY KEY (player_name, current_season)
 -- );


-- SELECT * FROM public.player_seasons


-- INSERT INTO players
-- WITH yesterday as(
-- 	SELECT * FROM players
-- 	WHERE current_season = 1996
-- ),
-- 	today as(
-- 		select * from player_seasons
-- 		WHERE season = 1997
-- 	)

-- SELECT 
-- 	COALESCE(t.player_name,y.player_name) as player_name,
-- 	COALESCE(t.height,y.height) as height,
-- 	COALESCE(t.college,y.college) as college,
-- 	COALESCE(t.country,y.country) as country,
-- 	COALESCE(t.draft_year,y.draft_year) as draft_year,
-- 	COALESCE(t.draft_round,y.draft_round) as draft_round,
-- 	COALESCE(t.draft_number,y.draft_number) as draft_number,
-- 	case 
-- 		WHEN y.seasons is null
-- 			then ARRAY[row(
-- 				t.season,
-- 				t.pts,
-- 				t.ast,
-- 				t.reb,
-- 				t.weight
-- 			)::season_stats]
-- 		WHEN t.season is not null then y.seasons || ARRAY[row(
-- 				t.season,
-- 				t.pts,
-- 				t.ast,
-- 				t.reb,
-- 				t.weight
-- 			)::season_stats]
-- 		else y.seasons
-- 	END as season_stats,
-- 	COALESCE(t.season,y.current_season + 1) as current_season
-- 	-- case 
-- 	-- 	WHEN t.season is not null then t.season
-- 	-- 	else y.current_season+1
-- 	-- END as season
	
-- FROM today t FULL outer join yesterday y
-- 		on t.player_name = y.player_name


---- go back schema and sort it
-- with unnested as (
-- 	SELECT player_name,
-- 		unnest(seasons)::season_stats as seasons
-- 	from players
-- 	WHERE current_season = 1997
-- )
-- SELECT player_name,
-- 	(seasons::season_stats).*
-- from unnested


---- add scoring_class and years_since_last_active

-- DROP TABLE players;

-- CREATE TABLE players (
--      player_name TEXT,
--      height TEXT,
--      college TEXT,
--      country TEXT,
--      draft_year TEXT,
--      draft_round TEXT,
--      draft_number TEXT,
--      seasons season_stats[],
--      scoring_class scoring_class,
--      years_since_last_active INTEGER,
--      current_season INTEGER,
--      PRIMARY KEY (player_name, current_season)
--  );


-- INSERT INTO players
-- WITH yesterday as(
-- 	SELECT * FROM players
-- 	WHERE current_season = 1997
-- ),
-- 	today as(
-- 		select * from player_seasons
-- 		WHERE season = 1998
-- 	)

-- SELECT 
-- 	COALESCE(t.player_name,y.player_name) as player_name,
-- 	COALESCE(t.height,y.height) as height,
-- 	COALESCE(t.college,y.college) as college,
-- 	COALESCE(t.country,y.country) as country,
-- 	COALESCE(t.draft_year,y.draft_year) as draft_year,
-- 	COALESCE(t.draft_round,y.draft_round) as draft_round,
-- 	COALESCE(t.draft_number,y.draft_number) as draft_number,
-- 	case 
-- 		WHEN y.seasons is null
-- 			then ARRAY[row(
-- 				t.season,
-- 				t.pts,
-- 				t.ast,
-- 				t.reb,
-- 				t.weight
-- 			)::season_stats]
-- 		WHEN t.season is not null then y.seasons || ARRAY[row(
-- 				t.season,
-- 				t.pts,
-- 				t.ast,
-- 				t.reb,
-- 				t.weight
-- 			)::season_stats]
-- 		else y.seasons
-- 	END as season_stats,
-- 	case
-- 		WHEN t.season is not null then 
-- 			case when t.pts>20 then 'star'
-- 				WHEN t.pts>15 then 'good'
-- 				WHEN t.pts>10 then 'average'
-- 				else 'bad'
-- 			END::scoring_class
-- 		ELSE y.scoring_class
-- 	END as scoring_class,
-- 	case WHEN t.season is not null then 0
-- 		else COALESCE(y.years_since_last_active,0)+1
-- 	END as years_since_last_active,
-- 	COALESCE(t.season,y.current_season + 1) as current_season
	
-- FROM today t FULL outer join yesterday y
-- 		on t.player_name = y.player_name

---- to see performance
-- SELECT
-- 	player_name,
-- 	(seasons[1]::season_stats).pts as first_season,
-- 	(seasons[cardinality(seasons)]::season_stats).pts as latest_season
-- from players 
-- where current_season = 1998

SELECT
	player_name,
	(seasons[cardinality(seasons)]::season_stats).pts/
	CASE
		when (seasons[1]::season_stats).pts = 0 THEN 1 
		else (seasons[1]::season_stats).pts
	 end as score
from players 
where current_season = 1998
and scoring_class = 'star'
order by 2 desc