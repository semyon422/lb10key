package.path = package.path .. ";./?.lua;./?/init.lua"

local lapis = require("lapis")
local respond_to = require("lapis.application").respond_to
local json_params = require("lapis.application").json_params
local cached = require("lapis.cache").cached
local auth = require("auth")
local db = require("db")
local app = lapis.Application()
app:enable("etlua")
app.layout = require("views.layout")

local config = require("lapis.config").get()

local endpoints = require("endpoints")

local osuapi = require("osuapi")
osuapi.key = config.osu_api_key

for _, endpoint in ipairs(endpoints) do
	local controller = require("controllers." .. endpoint.name)
	app:match("/api" .. endpoint.path, cached({
		exptime = config.api_exptime,
		json_params(respond_to(controller))}
	))
end
app:get("/api/(*)", function(self)
	return {json = {}}
end)

app:get("/views/:view", cached({
	exptime = config.views_exptime,
	function(self)
		self.config = config
		return {render = self.params.view, layout = false}
	end
}))
app:get("/(*)", cached({
	exptime = config.views_exptime,
	function(self)
		self.config = config
		return {render = "index"}
	end
}))

app:post("/api/database", function(self)
	if not auth(self) then return {json = {}} end
	db.drop()
	local tables = db.create()
	return {json = {tables = tables}}
end)

return app
