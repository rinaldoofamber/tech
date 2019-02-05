local max_range = 60
local spends_per_block = 1000
local period = 1
local particle_expiration = period / 2

tech.register_consumer("tech:plasma_miner")

local function formspec(energy_percent)
 local result = "size[8,9]"..
  default.gui_bg..
  default.gui_bg_img..
  default.gui_slots..
  "list[current_player;main;0,4.85;8,1;]" ..
  "list[current_player;main;0,6.08;8,3;8]" ..
  "image[0.75,1.5;1,2;tech_power_bar_bg.png^[lowpart:"..
  energy_percent..":tech_power_bar_fg.png]" ..
  "list[current_name;main;3,1;3,3]"
 return result
end

local function can_dig(pos, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	return inv:is_empty("main")
end

minetest.register_node("tech:plasma_miner", {
 description = "Plasma Miner",
 tiles = {"tech_advanced_powered_side.png",
  "tech_advanced_powered_side.png",
  "tech_advanced_powered_side.png",
  "tech_advanced_powered_side.png",
  "tech_advanced_powered_side.png",
  "tech_plasma_miner_front.png"},
 groups = {cracky=2,},
 on_construct = function(pos)
  tech.register_powered(pos, {
   capacity = 5000,
  })
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()
  inv:set_size("main", 9)
  inv:set_width("main", 3)
  meta:set_int("tech_r", 1)
  meta:set_int("tech_y", 1)
  meta:set_int("tech_c", 1)
  meta:set_int("tech_on", 1)
  meta:set_string("formspec", formspec(0))
 end,
 paramtype2 = "facedir",
 can_dig = can_dig,
 mesecons = tech.shutdownable,
})

local function on_timer(pos)
 local pow = tech.get_powered(pos)
 local meta = minetest.get_meta(pos)
 local pow = tech.get_powered(pos)
 local r, c, y
 r = meta:get_int("tech_r")
 c = meta:get_int("tech_c")
 y = meta:get_int("tech_y")
 local energy_percent = math.floor(pow:get_energy() / pow:get_capacity() * 100)
 meta:set_string("formspec", formspec(energy_percent))
 if r == 0 then
  return
 end
 if pow:get_energy() < spends_per_block then
  return
 end
 local dir = minetest.get_node(pos).param2
 local npos, particle_velocity
 if dir == 0 then
  npos = {x = pos.x + c, y = pos.y + y, z = pos.z - r}
  particle_velocity = {x = 0, y = 0, z = -1}
 elseif dir == 1 then
  npos = {x = pos.x - r, y = pos.y + y, z = pos.z + c}
  particle_velocity = {x = -1, y = 0, z = 0}
 elseif dir == 2 then
  npos = {x = pos.x + c, y = pos.y + y, z = pos.z + r}
  particle_velocity = {x = 0, y = 0, z = 1}
 elseif dir == 3 then
  npos = {x = pos.x + r, y = pos.y + y, z = pos.z + c}
  particle_velocity = {x = 1, y = 0, z = 0}
 end
 local node = minetest.get_node(npos).name
 if minetest.get_item_group(node, "immortal") ~= 0 then
  meta:set_int("tech_r", 0)
  return
 end
 if node ~= "air" then
  local factor = r / particle_expiration
  minetest.add_particle({
   pos = {x = pos.x + particle_velocity.x, y = pos.y, z = pos.z + particle_velocity.z},
   velocity = {x = particle_velocity.x * factor, y = 0, z = particle_velocity.z * factor},
   texture = "tech_plasma_particle.png",
   glow = 10,
   size = 4,
   expirationtime = particle_expiration ,
  })
  minetest.after(particle_expiration, function()
   local drops = minetest.get_node_drops(node, "default:pick_diamond")
   local inv = meta:get_inventory()
   for i,v in ipairs(drops) do
    inv:add_item("main", ItemStack(v))
   end
   tech.swap_node(npos, "air")
   pow:set_energy(pow:get_energy() - spends_per_block)
  end)
  -- this code causes energy < 0 sometimes
 end
 c = c + 1
 if c > 1 then
  c = -1
  y = y + 1
 end
 if y > 1 then
  y = -1
  r = r + 1
 end
 if r > max_range then
  r = 0
 end
 meta:set_int("tech_r", r)
 meta:set_int("tech_y", y)
 meta:set_int("tech_c", c)
 local energy_percent = math.floor(pow:get_energy() / pow:get_capacity() * 100)
 meta:set_string("formspec", formspec(energy_percent))
end
on_timer = tech.shutdownable_timer(on_timer)

minetest.register_abm({
  nodenames = {"tech:plasma_miner"},
  interval = period,
  chance = 1,
  action = on_timer,
})

minetest.register_craft({
  output = 'tech:plasma_miner 1', 
  recipe = {
  {'', '', ''},
  {'default:bronze_ingot', 'tech:advanced_machine_casing', 'default:diamond'},
  {'default:bronze_ingot', 'default:bronze_ingot', 'default:bronze_ingot'},
  }
})


