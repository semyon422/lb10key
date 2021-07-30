local db = require("lapis.db")
local preload = require("lapis.db.model").preload
local util = require("lapis.util")
local Scores = require("models.scores")

local user_scores_c = {}

user_scores_c.GET = function(self)
	local per_page = tonumber(self.params.per_page) or 10
	local page_num = tonumber(self.params.page_num) or 1
	local user_id = tonumber(self.params.user_id)

	local clause = " order by date desc"
	if self.params.best then
		clause = " order by pp desc"
	end

	local where = db.interpolate_query("user_id = ?", user_id)
	local query = "where " .. where

	local paginator = Scores:paginated(query .. clause, {per_page = per_page})
	local scores = paginator:get_page(page_num)
	preload(scores, "beatmap")

	local valid_scores = {}
	for _, score in ipairs(scores) do
		score.time_ago = util.time_ago_in_words(score.date)
		if score.beatmap then
			table.insert(valid_scores, score)
		end
	end

	local count = Scores:count()

	return {json = {
		count = count,
		num_pages = math.ceil(Scores:count(where) / per_page),
		scores = valid_scores
	}}
end

return user_scores_c
