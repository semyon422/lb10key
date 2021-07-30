if ngx.worker.id() ~= 0 then
	return
end

local http = require("resty.http.simple")
local config = require("lapis.config").get()

if not config.update_scores then
	return
end

local function update(premature, path)
	local res, err = http.request(
		"127.0.0.1",
		config.port,
		{
			method = "PUT",
			path = path,
			query = {k = config.api_key},
		}
	)
	if not res then
		ngx.log(ngx.ERR, err)
		return
	end

	if res.status >= 200 and res.status < 300 then
		ngx.log(ngx.NOTICE, res.body)
	else
		ngx.log(ngx.WARN, res.status)
	end
end
ngx.timer.every(config.scores_update_delay, update, "/api/scores")
ngx.timer.every(config.users_update_delay, update, "/api/users")
