local auth = require("auth")
local db = require("lapis.db")
local Users = require("models.users")
local osuapi = require("osuapi")

local users_c = {}

users_c.GET = function(self)
	local per_page = tonumber(self.params.per_page) or 10
	local page_num = tonumber(self.params.page_num) or 1
	local country = self.params.country

	local query = ""
	local where
	if country and country ~= "" then
		where = db.interpolate_query("country = ?", country)
		query = "where " .. where
	end

	local paginator = Users:paginated(query .. " order by total_pp desc", {per_page = per_page})
	local users = paginator:get_page(page_num)
	for i, user in ipairs(users) do
		user.rank = (page_num - 1) * per_page + i
	end

	return {json = {
		count = Users:count(),
		num_pages = math.ceil(Users:count(where) / per_page),
		users = users
	}}
end

users_c.PUT = function(self)
	if not auth(self) then return {json = {}} end

	local user = Users:select("order by updated_at asc limit 1")[1]
	local osu_user = osuapi.get_user(user.id)
	if not osu_user then
		user:delete()
	else
		Users:refresh(user, osu_user)
	end

	return {json = {user = user}}
end

return users_c
