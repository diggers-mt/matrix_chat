-- This file is licensed under the terms of the BSD 2-clause license.
-- See LICENSE.txt for details.

local modpath = minetest.get_modpath(minetest.get_current_modname())

-- Handle mod security if needed
local ie, req_ie = _G, minetest.request_insecure_environment
if req_ie then ie = req_ie() end
if not ie then
	error("The Matrix mod requires access to insecure functions in order "..
		"to work.  Please add the matrix mod to your secure.trusted_mods "..
		"setting or disable the matrix mod.")
end

ie.package.path =
		modpath.."/lua-matrix/?.lua;"
		..ie.package.path

matrix = {
	version = "0.0.1",
	joined_players = {},
	connected = false,
	modpath = modpath,
	lib = lib,
}

dofile(modpath.."/config.lua")

local function eprintf(fmt, ...)
	 minetest.log("info", fmt:format(...))
end

local client = require("matrix").client("https://"..matrix.config.server..":"..matrix.config.port)

client:login_with_password(matrix.config.user, matrix.config.password, true)

local running, start_ts = true, os.time() * 1000

client:hook("invite", function (client, room)
   -- When invited to a room, join it
   eprintf("Invited to room %s\n", room)
   client:join_room(room)
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

   room:send_text("Type “!bot quit” to make the bot exit")

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
      else
        minetest.chat_send_all("<"..sender.."> "..message.body)
      end
   end)
end)


dofile(modpath.."/callback.lua")

local stepnum = 0

minetest.register_globalstep(function(dtime) return matrix.step(dtime) end)

function matrix.step()
	if stepnum == 3 then
		matrix.connect()
	end
	stepnum = stepnum + 1

	if not matrix.connected then return end

	-- Hooks will manage incoming messages and errors
	local good, err = xpcall(function() client:_sync() end, debug.traceback)
	if not good then
		print(err)
		return
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

function matrix.say(to, message)
	if not message then
		message = to
		to = matrix.config.channel
	end
	to = to or matrix.config.channel
	for room_id, room in pairs(client.rooms) do
	  room:send_text(message)
	end
end
