-- This file is licensed under the terms of the BSD 2-clause license.
-- See LICENSE.txt for details.

local request_https = require "ssl.https" .request
local request_http = require "socket.http" .request
local ltn12 = require "ltn12"
local url = matrix.config.webhook_url

local function make_request(reqbody)
   if url:sub(1, #"https://") == "https://" then
      http = request_https
   else
      http = request_http
   end
  local respbody = {}
  local body, code, headers, status = http {
    url = url,
    method = "POST",
    source = ltn12.source.string(reqbody),
    headers =
        {
          ["Accept"] = "*/*",
          ["Content-Type"] = "application/x-www-form-urlencoded",
          ["content-length"] = string.len(reqbody)
        },
    sink = ltn12.sink.table(respbody)
  }
end


minetest.register_on_joinplayer(function(player)
  local name = player:get_player_name()
  make_request("event=join&user_name=" .. name)

end)

minetest.register_on_leaveplayer(function(player, timed_out)
  local name = player:get_player_name()
  make_request("event=leave&user_name=" .. name)
end)

minetest.register_on_chat_message(function(name, message)
  if not matrix.connected
     or message:sub(1, 1) == "/"
     or message:sub(1, 5) == "[off]"
     --or not matrix.joined_players[name] # TODO fix in player_part
     or (not minetest.check_player_privs(name, {shout=true})) then
    return
  end
  local nl = message:find("\n", 1, true)
  if nl then
    message = message:sub(1, nl - 1)
  end
  make_request("event=message&user_name="..name.."&text="..message)
end)

minetest.register_on_shutdown(function()
  matrix.disconnect("Game shutting down.")
end)

