local util = require("lapis.util")
local Beatmaps = require("models.beatmaps")
local Scores = require("models.scores")
local Users = require("models.users")

local score_c = {}

score_c.GET = function(self)
	local score = Scores:select("order by date desc limit 1")[1]
	if score then
		score:get_user()
		score:get_beatmap()
		score.time_ago = util.time_ago_in_words(score.date)
	end

	local beatmap = Beatmaps:select("order by updated_at desc limit 1")[1]
	if beatmap then
		beatmap.updated_ago = util.time_ago_in_words(tonumber(beatmap.updated_at))
	end

	local user = Users:select("order by total_pp desc limit 1")[1]

	return {json = {
		beatmaps_count = Beatmaps:count(),
		users_count = Users:count(),
		scores_count = Scores:count(),
		score = score,
		beatmap = beatmap,
		user = user,
	}}
end

return score_c
