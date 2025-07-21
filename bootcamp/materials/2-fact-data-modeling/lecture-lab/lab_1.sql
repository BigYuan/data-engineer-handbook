-- SELECT game_id,team_id,player_id,count(1)
-- FROM public.game_details
-- GROUP by 1,2,3
-- HAVING count(1)>1

with deduped as(
	select
	gd.*,
	g.season,
	g.home_team_id,
	g.visitor_team_id,
	g.game_date_est,
	row_number() over(partition by gd.game_id,team_id,player_id order by g.game_date_est) as row_num
	FROM public.game_details gd
		JOIN public.games g on gd.game_id = g.game_id
)

select
	game_date_est,
	season,
	team_id,
	home_team_id,
	team_id = home_team_id as dim_is_playing_at_home,
	player_id,
	player_name,
	start_position,
	coalesce(position('DNP' in "comment"),0) >0 as dim_did_not_play,
	"comment",
	split_part("min",':',1) as minutes,
	split_part("min",':',2) as secends,
	"min",
	fgm,
	fga,
	fg3a
from deduped
where row_num=1


create table fct_game_details(
	dim_game_date Date,
	dim_season Integer,
	dim_team_id Integer,
	dim_player_id Integer,
	dim_player_name Text,
	dim_start_position Text,
	dim_is_playing_at_home Boolean,
	dim_did_not_play Boolean,
)



