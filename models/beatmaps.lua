local Model = require("lapis.db.model").Model
local omppc = require("omppc")
local osuapi = require("osuapi")

local Beatmaps = Model:extend("beatmaps")

function Beatmaps:add(osu_beatmap)
	local beatmap = self:find(osu_beatmap.beatmap_id)
	if beatmap then
		return beatmap
	end

	return self:create({
		id = osu_beatmap.beatmap_id,
		set_id = osu_beatmap.beatmapset_id,
		artist = osu_beatmap.artist,
		title = osu_beatmap.title,
		creator = osu_beatmap.creator,
		version = osu_beatmap.version,
		file_md5 = osu_beatmap.file_md5,
		playcount = osu_beatmap.playcount,
		passcount = osu_beatmap.passcount,
		note_count = 0,
		sr = 0,
		sr_ht = 0,
		sr_dt = 0,
		pp = 0,
		pp_ht = 0,
		pp_dt = 0,
		od = 0,
	})
end

function Beatmaps:refresh(beatmap, osu_beatmap)
	return beatmap:update({
		artist = osu_beatmap.artist,
		title = osu_beatmap.title,
		creator = osu_beatmap.creator,
		version = osu_beatmap.version,
		file_md5 = osu_beatmap.file_md5,
		playcount = osu_beatmap.playcount,
		passcount = osu_beatmap.passcount,
		updated_at = os.time(),
	})
end

function Beatmaps:update_stats(db_beatmap)
	local beatmap_file = osuapi.get_beatmap(db_beatmap.id)

	local beatmap = omppc.Beatmap:new()
	beatmap:parse(beatmap_file)

	local calculator = omppc.Calculator:new()
	calculator.beatmap = beatmap

	beatmap.mods = omppc.Mods:new():parse("")
	beatmap:calculateStarRate()
	calculator.mods = beatmap.mods
	calculator.score = 1000000
	calculator:computeTotalValue()
	db_beatmap.sr = beatmap.starRate
	db_beatmap.pp = calculator.totalValue

	beatmap.mods = omppc.Mods:new():parse("HT")
	beatmap:calculateStarRate()
	calculator.mods = beatmap.mods
	calculator.score = 500000
	calculator:computeTotalValue()
	db_beatmap.sr_ht = beatmap.starRate
	db_beatmap.pp_ht = calculator.totalValue

	beatmap.mods = omppc.Mods:new():parse("DT")
	beatmap:calculateStarRate()
	calculator.mods = beatmap.mods
	calculator.score = 1000000
	calculator:computeTotalValue()
	db_beatmap.sr_dt = beatmap.starRate
	db_beatmap.pp_dt = calculator.totalValue

	db_beatmap.od = beatmap.od
	db_beatmap.note_count = beatmap.noteCount

	db_beatmap:update("sr", "sr_ht", "sr_dt", "pp", "pp_ht", "pp_dt", "od", "note_count")
end

return Beatmaps
