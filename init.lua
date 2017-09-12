-- This file is licensed under the terms of the BSD 2-clause license.
-- See LICENSE.txt for details.

local modpath = minetest.get_modpath(minetest.get_current_modname())

-- Handle mod security if needed
local ie, req_ie = _G, minetest.request_insecure_environment
if req_ie then ie = req_ie() end
if not ie then
  error("The Matrix mod requires access to insecure functions in order "..
    "to work. Please add matrix to secure.trusted_mods.")
end

ie.package.path =
    modpath.."/lua-matrix/?.lua;"
    ..modpath.."/neturl/lib/?.lua;"
    ..ie.package.path

matrix = {
  version = "0.0.1",
  joined_players = {},
  connected = false,
  modpath = modpath,
  lib = lib,
}

dofile(modpath.."/config.lua")
dofile(modpath.."/debug.lua")

-- Temporarily set require so that LuaIRC can access it
local old_require = require
require = ie.require

dofile(modpath.."/validate_server.lua")

local hs_url = validate_server(matrix.config.server)
local client = require("matrix").client(hs_url)

local start_ts = os.time() * 1000

client:hook("invite", function (client, room)
  -- When invited to a room, join it
  eprintf("Invited to room %s\n", room)
  if room.room_id == matrix.config.room_id then
    client:join_room(room)
  end
end):hook("logged-in", function (client)
  matrix.connected = true
  eprintf("Logged in successfully\n")
end):hook("logged-out", function (client)
  eprintf("Logged out... bye!\n")
  matrix.connected = false
end):hook("left", function (client, room)
  eprintf("Left room %s, active rooms:\n", room)
  for room_id, room in pairs(client.rooms) do
    assert(room_id == room.room_id)
    eprintf("  - %s\n", room)
  end
end):hook("joined", function (client, room)
  eprintf("Active rooms:\n")
  for room_id, room in pairs(client.rooms) do
    assert(room_id == room.room_id)
    eprintf("  - %s\n", room)
  end

   --room:send_text("Type “!bot quit” to make the bot exit")

  room:hook("message", function (room, sender, message, event)
    if event.origin_server_ts < start_ts then
      eprintf("%s: (Skipping message sent before bot startup)\n", room)
      return
    end
    if sender == room.client.user_id then
      eprintf("%s: (Skipping message sent by ourselves)\n", room)
      return
    end
    if message.msgtype ~= "m.text" then
      eprintf("%s: (Message of type %s ignored)\n", room, message.msgtype)
      return
    end

    eprintf("%s: <%s> %s\n", room, sender, message.body)

    if message.body == "!bot quit" then
      for _, room in pairs(client.rooms) do
        room:send_text("(gracefully shutting down)")
      end
      client:logout()
      matrix.connected = false
    elseif room.room_id == matrix.config.room_id and not string.match(sender, "^"..matrix.config.user_prefix) then
      minetest.chat_send_all("<"..sender.."> "..message.body)
    end
   end)
end)


dofile(modpath.."/callback.lua")

minetest.register_globalstep(function(dtime) return matrix.step(dtime) end)

local stepnum = 0
local interval = 1
local counter = 0

function matrix.step(dtime)
  if stepnum == 3 then
    matrix.connect()
  end
  stepnum = stepnum + 1
  counter = counter + dtime
  if counter >= interval and matrix.connected then
    counter = counter - interval
    local good, err = xpcall(function() client:_sync() end, debug.traceback)
    if not good then
      print(err)
      return
    end
  end
end

function matrix.connect()
  if matrix.connected then
    minetest.log("error", "Matrix: already connected")
    return
  end
  client:login_with_password(matrix.config.user, matrix.config.password, true)
  matrix.connected = true
  minetest.log("action", "Matrix: Connected!")
  minetest.chat_send_all("Matrix: Connected!")
end


function matrix.disconnect(message)
  if matrix.connected then
    --The OnDisconnect hook will clear matrix.connected and print a disconnect message
    client:logout()
  end
end

function matrix.say(message)
  for room_id, room in pairs(client.rooms) do
    if room.room_id == matrix.config.room_id then
      room:send_text(message)
    end
  end
end

-- Restore old (safe) functions
require = old_require
