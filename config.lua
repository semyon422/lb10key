local config = require("lapis.config")
local secret = {}
local ok, ret = pcall(require, "secret")
if ok then
	secret = ret
end

config("development", {
	port = 8080,
	mysql = secret.mysql_development,
	update_scores = false,
	scores_update_delay = 60,
	users_update_delay = 60,
	views_exptime = 1,
	api_exptime = 1,
	osu_api_key = secret.osu_api_key,
	api_key = secret.api_key,
})

config("production", {
	port = 8080,
	mysql = secret.mysql_production,
	num_workers = 4,
	code_cache = "on",
	update_scores = true,
	scores_update_delay = 10,
	users_update_delay = 60,
	views_exptime = 3600,
	api_exptime = 10,
	osu_api_key = secret.osu_api_key,
	api_key = secret.api_key,
})
