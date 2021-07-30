local util = require("lapis.util")
local Beatmaps = require("models.beatmaps")

local beatmap_c = {}

beatmap_c.GET = function(self)
	local beatmap = Beatmaps:find(self.params.beatmap_id)

	if not beatmap then return {json = {}} end

	beatmap.updated_ago = util.time_ago_in_words(tonumber(beatmap.updated_at))

	return {json = {beatmap = beatmap}}
end

return beatmap_c
