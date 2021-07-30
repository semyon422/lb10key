local api_key = require("lapis.config").get().api_key

return function(self)
	return self.params.k == api_key
end
