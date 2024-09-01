# lb10key

## Prerequisites

- OpenResty
- Luarocks
- mysql-server

## Setting up (Linux)

1. Make sure mysql is running.
2. Run: `./install`
   - If you get an error about luaossl, try installing the package `libssl-dev`.
3. Run:
   1. `mkdir temp`
   2. `mkdir -p resty/http`
   3. `wget https://github.com/semyon422/omppc/raw/master/omppc.lua`
   4. `cd resty/http/`
   5. `wget https://github.com/bakins/lua-resty-http-simple/raw/master/lib/resty/http/simple.lua`
   6. `cd ../..`
   7. `cp config.example.lua config.lua`
4. In `config.lua`, enter your mysql credentials, your osu_api_key, and a random string as api_key.
   - You can get an osu api key in your settings on osu's website. Create a legacy key, not an OAuth one.
5. Run: `./lapis_exec_db_empty_development`

## Setting up (Docker)

1. It's recommended to use the docker image: `openresty/openresty:[CURRENT_VERSION]-bionic`.
2. The other steps are identical to `Setting up (Linux)`.

## Running (Linux)

1. Run: `./lapis_server_development` or `./lapis_server_production`. Development doesn't send api requests to osu for data.
2. The program will run until you `ctrl+c` out of it. You can also make it run indefinitely by making a [screen](https://linuxize.com/post/how-to-use-linux-screen/) with `./lapis_server_production_screen`.

## Usage

- By default, the site will be available on any browser at: http://localhost:8080
  - If 8080 is already in use by a different program, you can change the port in `config.lua`.
- You can add beatmap sets at http://localhost:8080/beatmaps/add with your custom api key from the config and the beatmap set id. The beatmap id is not required. If you're in `production`, scores and the users that set them will be added gradually.
- When developing, you can see if something is going wrong in the `logs/*.log` files and the http response payloads.

## Used libraries

- https://leafo.net/lapis/
- https://github.com/bakins/lua-resty-http-simple
- https://github.com/semyon422/omppc
