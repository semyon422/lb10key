local auth = require("auth")
local db = require("lapis.db")
local Users = require("models.users")
local osuapi = require("osuapi")

local users_c = {}

users_c.GET = function(self)
    local per_page = tonumber(self.params.per_page) or 10
    local page_num = tonumber(self.params.page_num) or 1
    local score_time_range = self.params.score_time_range
    local country = self.params.country

    local where_clauses = {}

    if country and country ~= "" then
        table.insert(where_clauses, db.interpolate_query("country = ?", country))
    end

    if score_time_range and score_time_range ~= "" and score_time_range ~= "Any time" then
        local db_time
        if score_time_range == "1 Week" then
            db_time = "1 WEEK"
        elseif score_time_range == "1 Month" then
            db_time = "1 MONTH"
        elseif score_time_range == "3 Months" then
            db_time = "3 MONTH"
        elseif score_time_range == "1 Year" then
            db_time = "1 YEAR"
        end

        table.insert(where_clauses, [[
            EXISTS (
                SELECT 1 
                FROM `scores` s
                WHERE s.user_id = users.id 
                  AND s.date >= NOW() - INTERVAL ]] .. db_time .. [[ 
                ORDER BY s.date DESC 
                LIMIT 1
            )
        ]])
    end

    local where
    local query = ""
    if #where_clauses > 0 then
        where = table.concat(where_clauses, " AND ")
        query = "WHERE " .. where
    end

    query = query .. " ORDER BY total_pp DESC"

    local paginator = Users:paginated(query, {per_page = per_page})
    local users = paginator:get_page(page_num)
    for i, user in ipairs(users) do
        user.rank = (page_num - 1) * per_page + i
    end

    return {json = {
        count = Users:count(where),
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
