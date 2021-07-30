local auth = require("auth")
local db = require("lapis.db")
local preload = require("lapis.db.model").preload
local util = require("lapis.util")
local Beatmaps = require("models.beatmaps")
local Scores = require("models.scores")
local Users = require("models.users")
local omppc = require("omppc")
local osuapi = require("osuapi")

local scores_c = {}

scores_c.GET = function(self)
	local per_page = tonumber(self.params.per_page) or 10
	local page_num = tonumber(self.params.page_num) or 1

	local paginator = Scores:paginated("order by date desc", {per_page = per_page})
	local scores = paginator:get_page(page_num)
	preload(scores, {"user", "beatmap"})

	local valid_scores = {}
	for _, score in ipairs(scores) do
		score.time_ago = util.time_ago_in_words(score.date)
		if score.user and score.beatmap then
			table.insert(valid_scores, score)
		end
	end

	local count = Scores:count()

	return {json = {
		count = count,
		num_pages = math.ceil(count / per_page),
		scores = valid_scores
	}}
end

local function get_score_pp(beatmap, score)
	local mods = omppc.Mods:new():parse(tonumber(score.enabled_mods))
	local bm = omppc.Beatmap:new()
	bm.noteCount = beatmap.note_count
	bm.od = beatmap.od
	if mods.HalfTime then
		bm.starRate = beatmap.sr_ht
	elseif mods.DoubleTime then
		bm.starRate = beatmap.sr_dt
	else
		bm.starRate = beatmap.sr
	end
	local calc = omppc.Calculator:new({
		score = score.score,
		mods = mods,
		beatmap = bm
	})
	calc:computeTotalValue()

	return calc.totalValue
end

local function getAccuracyFromHits(numMiss, num50, num100, numKatu, num300, numGeki)
	local totalHits = numMiss + num50 + num100 + numKatu + num300 + numGeki
	return (num50 * 50 + num100 * 100 + numKatu * 200 + (num300 + numGeki) * 300) / (totalHits * 300)
end

local function update_scores(beatmap)
	local old_ids_map = {}
	local new_ids_map = {}

	local db_scores = Scores:select("where beatmap_id = ?", beatmap.id, {fields = "id"})
	for _, score in ipairs(db_scores) do
		old_ids_map[tonumber(score.id)] = true
	end

	local scores = osuapi.get_scores(beatmap.id)
	for _, score in ipairs(scores) do
		new_ids_map[tonumber(score.score_id)] = true
	end

	local delete_ids = {}
	for id in pairs(old_ids_map) do
		if not new_ids_map[id] then
			table.insert(delete_ids, id)
		end
	end

	local insert_ids = {}
	for id in pairs(new_ids_map) do
		if not old_ids_map[id] then
			table.insert(insert_ids, id)
		end
	end

	if #delete_ids > 0 then
		db.delete("scores", {id = db.list(delete_ids)})
	end

	local users_map = {}
	local added_scores = {}
	for _, score in ipairs(scores) do
		local id = tonumber(score.score_id)
		if new_ids_map[id] and not old_ids_map[id] then
			score.accuracy = getAccuracyFromHits(
				score.countmiss,
				score.count50,
				score.count100,
				score.countkatu,
				score.count300,
				score.countgeki
			)
			score.pp = get_score_pp(beatmap, score)
			score.beatmap_id = beatmap.id
			local db_score = Scores:add(score)
			users_map[score.user_id] = score.username
			table.insert(added_scores, db_score)
		end
	end

	return users_map, added_scores
end

scores_c.PUT = function(self)
	if not auth(self) then return {json = {}} end

	local beatmap = Beatmaps:select("order by updated_at asc limit 1")[1]
	local users_map, added_scores = update_scores(beatmap)

	for user_id, username in pairs(users_map) do
		local user = Users:find(user_id)
		if not user then
			user = Users:add(osuapi.get_user(user_id))
		end
		Users:update_stats(user, username)
	end

	local osu_beatmap = osuapi.get_beatmaps({b = beatmap.id})[1]
	Beatmaps:refresh(beatmap, osu_beatmap)

	return {json = {scores = added_scores}}
end

return scores_c
