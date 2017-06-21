-- This file is licensed under the terms of the BSD 2-clause license.
-- See LICENSE.txt for details.

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	if matrix.connected then --and matrix.config.send_join_part then
		matrix.say("*** "..name.." joined the game")
	end
end)

minetest.register_on_leaveplayer(function(player, timed_out)
	local name = player:get_player_name()
	if matrix.connected then -- and matrix.config.send_join_part then
		matrix.say("*** "..name.." left the game"..
				(timed_out and " (Timed out)" or ""))
	end
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
	matrix.say("<"..name.."> "..message)
end)


minetest.register_on_shutdown(function()
	matrix.disconnect("Game shutting down.")
end)

