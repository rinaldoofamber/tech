math.randomseed(minetest.get_us_time())

-- utils

local function eqtables(t1, t2)
  if type(t1) ~= "table" or type(t2) ~= "table" then
    local group = string.find(t1, "group:")
    if group then
     group = string.sub(t1, 7)
     return (minetest.get_item_group(t2, group) > 0)
    end
    return t1 == t2
  end
  for k, v in pairs(t1) do
    return eqtables(v, t2[k])
  end
  for k, v in pairs(t2) do
    if t1[k] == nil then
      return false
    end
  end
  return true
end

-- mod initialisation

tech = rawget(_G, "tech") or {}
local modpath = minetest.get_modpath("tech")
tech.modpath = modpath
if string.find(modpath, "/") then-- then it is linux
  tech.dir_sep = "/"
else-- it is windows
  tech.dir_sep = "\\"
end
modpath = modpath .. tech.dir_sep
tech.storage = minetest.get_mod_storage()

-- mesecons integration

if mesecon then
 function tech.shutdownable_timer(on_timer)
  return function(pos)
   local meta = minetest.get_meta(pos)
   if meta:get_int("tech_on") ~= 0 then
    on_timer(pos)
   end
  end
 end
else
 function tech.shutdownable_timer(on_timer)
  return on_timer
 end
end

if mesecon then
 tech.shutdownable = {effector = {
		action_on = function (pos, node)
		 local meta = minetest.get_meta(pos)
		 meta:set_int("tech_on", 0)
	 end,
	 action_off = function (pos, node)
		 local meta = minetest.get_meta(pos)
	  meta:set_int("tech_on", 1)
	 end,
 }}
end

-- another utils
function tech.swap_node(pos, name)
  local node = minetest.get_node(pos)
  if node.name == name then
    return
  end
  node.name = name
  minetest.swap_node(pos, node)
end

function tech.player_look_side(player, pos)
  local player = player:getpos()
  local res
  local abs = math.abs
  if (abs(player.x - pos.x) >= abs(player.y - pos.y)) and (abs(player.x - pos.x) >= abs(player.z - pos.z)) then
    res = "x"
  end
  if (abs(player.y - pos.y) >= abs(player.x - pos.x)) and (abs(player.y - pos.y) >= abs(player.z - pos.z)) then
    res = "y"
  end
  if (abs(player.z - pos.z) >= abs(player.y - pos.y)) and (abs(player.z - pos.z) >= abs(player.x - pos.x)) then
    res = "z"
  end
  return res
end

function tech.play_sound(pos, sound, radius)
  local all_objects = minetest.get_objects_inside_radius(pos, radius)
  local players = {}
  local _,obj
  for _,obj in ipairs(all_objects) do
	  if obj:is_player() then
		  table.insert(players, obj)
      minetest.sound_play({ name = sound, gain = 1, to_player =  obj:get_player_name()})
	  end
  end
end
-- recipes

tech.recipes = {}
function tech.register_craft(data)
  tech.recipes[#tech.recipes + 1] = data
end
function tech.get_craft(data)
  for k, v in ipairs(tech.recipes) do
    if v.type == data.type and eqtables(v.recipe, data.recipe) then
      return v
    end
  end
  return nil
end

-- machines with progress bar
-- fuel time left is also progress

function tech.register_processer(pos, data)
  local meta = minetest.get_meta(pos)
  meta:set_string("tech_isprocesser", "true")
  meta:set_int("tech_progress", data.start_progress)
  meta:set_int("tech_progress_total", data.total_progress)
end
function tech.get_processer(pos)
  local meta = minetest.get_meta(pos)
  if meta:get_string("tech_isprocesser") ~= "true" then
    return nil
  end
  local result = {
    meta = minetest.get_meta(pos),
    get_progress = function(self)
      return self.meta:get_int("tech_progress")
    end,
    set_progress = function(self, value)
      self.meta:set_int("tech_progress", value)
    end,
    get_total_progress = function(self)
      return self.meta:get_int("tech_progress_total")
    end,
    set_total_progress = function(self, value)
      self.meta:set_int("tech_progress_total", value)
    end,
  }
  return result
end

-- executing other modules

dofile(modpath .. "power_utils.lua")
dofile(modpath .. "multiblocks.lua")
dofile(modpath .. "conveyors.lua")
dofile(modpath .. "machines" .. tech.dir_sep .. "init.lua")
dofile(modpath .. "materials.lua")
dofile(modpath .. "tools.lua")
dofile(modpath .. "recipes.lua")
dofile(modpath .. "battery.lua")
dofile(modpath .. "hammer.lua")
dofile(modpath .. "luatablet.lua")
