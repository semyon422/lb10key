local util = require("lapis.util")
local Scores = require("models.scores")

local score_c = {}

score_c.GET = function(self)
	local score = Scores:find(self.params.score_id)

	if not score then return {json = {}} end

	score:get_user()
	score:get_beatmap()
	score.time_ago = util.time_ago_in_words(score.date)

	if not score.user or not score.beatmap then
		score = nil
	end

	return {json = {score = score}}
end

return score_c
