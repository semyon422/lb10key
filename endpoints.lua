local endpoints = {
	{
		name = "status",
		path = "/status",
	},
	{
		name = "users",
		path = "/users",
	},
	{
		name = "user",
		path = "/users/:user_id",
	},
	{
		name = "user.scores",
		path = "/users/:user_id/scores",
	},
	{
		name = "beatmaps",
		path = "/beatmaps",
	},
	{
		name = "beatmap",
		path = "/beatmaps/:beatmap_id",
	},
	{
		name = "beatmap.scores",
		path = "/beatmaps/:beatmap_id/scores",
	},
	{
		name = "scores",
		path = "/scores",
	},
	{
		name = "score",
		path = "/scores/:score_id",
	},
}

return endpoints
