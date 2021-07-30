local util = require("lapis.util")
local http = require("lapis.nginx.http")

local osuapi = {}

osuapi.url = "http://osu.ppy.sh/api"
osuapi.key = ""

function osuapi.get_beatmaps(params)
	params.k = osuapi.key
	local body, status_code, headers = http.simple(
		osuapi.url .. "/get_beatmaps?" .. util.encode_query_string(params)
	)

	if status_code ~= 200 then
		return {status = status_code, json = {
			body = body,
		}}
	end

	return util.from_json(body)
end

function osuapi.get_scores(beatmap_id)
	local body, status_code, headers = http.simple(
		osuapi.url .. "/get_scores?" .. util.encode_query_string({
			b = beatmap_id,
			m = 3,
			limit = 100,
			k = osuapi.key
		})
	)

	return util.from_json(body)
end

function osuapi.get_user(user_id)
	local body, status_code, headers = http.simple(
		osuapi.url .. "/get_user?" .. util.encode_query_string({
			u = user_id,
			k = osuapi.key
		})
	)

	local users = util.from_json(body)
	return users[1]
end

function osuapi.get_beatmap(beatmap_id)
	local body, status_code, headers = http.simple(
		"http://osu.ppy.sh/osu/" .. beatmap_id
	)

	return body
end

return osuapi
