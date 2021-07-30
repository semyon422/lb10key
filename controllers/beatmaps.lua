local auth = require("auth")
local db = require("lapis.db")
local util = require("lapis.util")
local Beatmaps = require("models.beatmaps")
local osuapi = require("osuapi")

local beatmaps_c = {}

beatmaps_c.GET = function(self)
	local per_page = tonumber(self.params.per_page) or 10
	local page_num = tonumber(self.params.page_num) or 1

	local paginator = Beatmaps:paginated("order by set_id asc, sr asc", {per_page = per_page})
	local beatmaps = paginator:get_page(page_num)

	for _, beatmap in ipairs(beatmaps) do
		beatmap.updated_ago = util.time_ago_in_words(tonumber(beatmap.updated_at))
	end

	local count = Beatmaps:count()

	return {json = {
		count = count,
		num_pages = math.ceil(count / per_page),
		beatmaps = beatmaps
	}}
end

beatmaps_c.POST = function(self)
	if not auth(self) then return {json = {}} end

	local beatmaps = osuapi.get_beatmaps(self.params)

	local db_beatmaps = {}
	for _, beatmap in ipairs(beatmaps) do
		if beatmap.diff_size == "10" then
			db.delete("scores", {beatmap_id = beatmap.beatmap_id})
			local db_beatmap = Beatmaps:add(beatmap)
			Beatmaps:update_stats(db_beatmap, beatmap)
			table.insert(db_beatmaps, db_beatmap)
		end
	end

	return {json = {beatmaps = db_beatmaps}}
end

return beatmaps_c
