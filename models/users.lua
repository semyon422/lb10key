local Model = require("lapis.db.model").Model
local Scores = require("models.scores")

local Users = Model:extend("users")

function Users:add(osu_user)
	local user = self:find(osu_user.user_id)
	if user then
		return user
	end

	return self:create({
		id = osu_user.user_id,
		username = osu_user.username,
		country = osu_user.country,
		score_count = 0,
		total_score = 0,
		total_pp = 0,
		accuracy = 0,
	})
end

function Users:refresh(user, osu_user)
	return user:update({
		username = osu_user.username,
		country = osu_user.country,
		updated_at = os.time(),
	})
end

function Users:update_stats(user, username)
	local scores = Scores:find_all({user.id}, {
		key = "user_id",
		clause = "ORDER BY `pp` DESC"
	})

	local total_pp = 0
	local total_score = 0
	local score_count = #scores
	local accuracy = 0
	local accuracy_counter = 0
	for i, score in ipairs(scores) do
		total_score = total_score + score.score
		total_pp = total_pp + score.pp * 0.95 ^ (i - 1)
		accuracy = accuracy + score.accuracy * 0.95 ^ (i - 1)
		accuracy_counter = accuracy_counter + 1 * 0.95 ^ (i - 1)
	end
	accuracy = accuracy / accuracy_counter

	user.username = username
	user.total_pp = total_pp
	user.total_score = total_score
	user.score_count = score_count
	user.accuracy = accuracy
	user:update("username", "total_pp", "total_score", "score_count", "accuracy")
end

return Users
