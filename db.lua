local schema = require("lapis.db.schema")
local types = schema.types

local db = {}

local tables = {
	"beatmaps",
	"users",
	"scores",
}

local table_declarations = {}

local type_id = types.id({null = false, unsigned = true})
local type_fk_id = types.integer({null = false, unsigned = true})
local type_size = types.integer({null = false, unsigned = true, default = 0})
local type_hash = "char(32) CHARACTER SET latin1 NOT NULL"
-- local type_time = types.bigint({unsigned = true})
local type_time = "TIMESTAMP NOT NULL DEFAULT 0"

local options = {
	engine = "InnoDB",
	charset = "utf8mb4 COLLATE=utf8mb4_unicode_ci"
}

table_declarations.scores = {
	{"id", type_id},
	{"beatmap_id", type_fk_id},
	{"user_id", type_fk_id},
	{"date", type_time},
	{"score", type_size},
	{"accuracy", types.float},
	{"pp", types.float},
}

table_declarations.beatmaps = {
	{"id", type_id},
	{"updated_at", types.bigint({unsigned = true})},
	{"set_id", type_fk_id},
	{"artist", types.varchar},
	{"title", types.varchar},
	{"creator", types.varchar},
	{"version", types.varchar},
	{"file_md5", type_hash},
	{"playcount", type_size},
	{"passcount", type_size},
	{"note_count", type_size},
	{"sr", types.float},
	{"sr_ht", types.float},
	{"sr_dt", types.float},
	{"pp", types.float},
	{"pp_ht", types.float},
	{"pp_dt", types.float},
	{"od", types.float},
}

table_declarations.users = {
	{"id", type_id},
	{"updated_at", types.bigint({unsigned = true})},
	{"username", types.varchar},
	{"score_count", type_size},
	{"total_score", type_size},
	{"total_pp", types.float},
	{"accuracy", types.float},
	{"country", types.varchar},
}

function db.drop()
	for _, table in ipairs(tables) do
		schema.drop_table(table)
	end
end

function db.create()
	for _, table in ipairs(tables) do
		schema.create_table(table, table_declarations[table], options)
	end
	return tables
end

return db
