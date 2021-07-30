local Model = require("lapis.db.model").Model

local Scores = Model:extend("scores", {
	relations = {
		{"user", belongs_to = "users", key = "user_id"},
		{"beatmap", belongs_to = "beatmaps", key = "beatmap_id"},
	}
})

function Scores:add(osu_score)
	local score = self:find(osu_score.score_id)
	if score then
		return score
	end

	return self:create({
		id = osu_score.score_id,
		beatmap_id = osu_score.beatmap_id,
		user_id = osu_score.user_id,
		date = osu_score.date,
		score = osu_score.score,
		accuracy = osu_score.accuracy,
		pp = osu_score.pp,
	})
end

return Scores
