-- create table players_scd
-- (
-- 	player_name text,
-- 	scoring_class scoring_class,
-- 	is_active boolean,
-- 	start_season integer,
-- 	end_season integer,
-- 	current_season INTEGER,
-- 	PRIMARY KEY (player_name, start_season)
-- );


-- INSERT INTO players_scd(
-- with with_previous as (
-- 	SELECT player_name,
-- 	           current_season,
-- 	           scoring_class,
-- 			   is_active,
-- 	           LAG(scoring_class, 1) OVER(PARTITION BY player_name ORDER BY current_season) as previous_scoring_class,
-- 			   LAG(is_active, 1) OVER(PARTITION BY player_name ORDER BY current_season) as previous_is_active
-- 	FROM players
-- 	WHERE current_season <=2021
-- ),
-- -- select *,
-- -- 		case
-- -- 			when scoring_class <> previous_scoring_class then 1
-- -- 			else 0
-- -- 		END as scoring_class_change_indicator,
-- -- 		case
-- -- 			when is_active <> previous_is_active then 1
-- -- 			else 0
-- -- 		END as is_active_change_indicator
-- -- from with_previous

-- with_indicator as(
-- 	select *,
-- 			case
-- 				when scoring_class <> previous_scoring_class then 1
-- 				when is_active <> previous_is_active then 1
-- 				else 0
-- 			END as change_indicator
-- 	from with_previous
-- ),
-- with_streak as (
-- 	SELECT *,
-- 			sum(change_indicator) OVER(PARTITION by player_name order by current_season) as streak_identifier
-- 	FROM with_indicator
-- )

-- SELECT player_name,
-- 		-- streak_identifier,
-- 		scoring_class,
-- 		is_active,
-- 		min(current_season) as start_season,
-- 		Max(current_season) as end_season,
-- 		2021 as current_season
-- from with_streak
-- group by player_name,streak_identifier,is_active,scoring_class
-- order by player_name,streak_identifier
-- )

select * from players_scd;

