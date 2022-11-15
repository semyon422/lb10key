local config = require("lapis.config")

local mysql = {
	host = "127.0.0.1",
	user = "username",
	password = "password",
	database = "lb10key"
}

local osu_api_key = ""
local api_key = ""

config("development", {
	port = 8080,
	mysql = mysql,
	update_scores = false,
	scores_update_delay = 60,
	users_update_delay = 60,
	views_exptime = 1,
	api_exptime = 1,
	osu_api_key = osu_api_key,
	api_key = api_key,
})

config("production", {
	port = 8080,
	mysql = mysql,
	num_workers = 4,
	code_cache = "on",
	update_scores = true,
	scores_update_delay = 10,
	users_update_delay = 60,
	views_exptime = 3600,
	api_exptime = 10,
	osu_api_key = osu_api_key,
	api_key = api_key,
})
