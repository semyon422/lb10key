local Users = require("models.users")

local user_c = {}

user_c.GET = function(self)
	local user = Users:find(self.params.user_id)

	return {json = {user = user}}
end

return user_c
