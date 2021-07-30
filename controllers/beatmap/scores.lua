local db = require("lapis.db")
local preload = require("lapis.db.model").preload
local util = require("lapis.util")
local Scores = require("models.scores")

local beatmap_scores_c = {}

beatmap_scores_c.GET = function(self)
	local per_page = tonumber(self.params.per_page) or 10
	local page_num = tonumber(self.params.page_num) or 1
	local beatmap_id = tonumber(self.params.beatmap_id)

	local where = db.interpolate_query("beatmap_id = ?", beatmap_id)

	local paginator = Scores:paginated("where " .. where .. " order by pp desc", {per_page = per_page})
	local scores = paginator:get_page(page_num)
	preload(scores, "user")

	local valid_scores = {}
	for _, score in ipairs(scores) do
		score.time_ago = util.time_ago_in_words(score.date)
		if score.user then
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

return beatmap_scores_c
