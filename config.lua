-- This file is licensed under the terms of the BSD 2-clause license.
-- See LICENSE.txt for details.

matrix.config = {}

local function setting(stype, name, default, required)
  local value
  if stype == "bool" then
    value = minetest.setting_getbool("matrix."..name)
  elseif stype == "string" then
    value = minetest.setting_get("matrix."..name)
  elseif stype == "number" then
    value = tonumber(minetest.setting_get("matrix."..name))
  end
  if value == nil then
    if required then
      error("Required configuration option matrix."..
        name.." missing.")
    end
    value = default
  end
  matrix.config[name] = value
end

-------------------------
-- BASIC USER SETTINGS --
-------------------------

setting("string", "user", nil, true)      -- User name, fe @digbot:matrix.org
setting("string", "server", nil, true)    -- Server address to connect to
setting("string", "room_id", nil, true)   -- Channel to join (not needed?)
setting("string", "password", nil, true)  -- Server password
