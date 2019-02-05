-- generator

local function inactive_formspec(energy_percent)
  local result = "size[8,9]"..
    default.gui_bg..
    default.gui_bg_img..
    default.gui_slots..
    "list[current_name;fuel;2.75,2.5;1,1;]" ..
    "image[2.75,1.5;1,1;default_furnace_fire_bg.png]" ..
    "list[current_player;main;0,4.85;8,1;]" ..
    "list[current_player;main;0,6.08;8,3;8]" ..
    "image[0.75,1.5;1,2;tech_power_bar_bg.png^[lowpart:"..
    (energy_percent)..":tech_power_bar_fg.png]"
  return result
end

local function active_formspec(fuel_percent, energy_percent)
  local result = "size[8,9]"..
    default.gui_bg..
    default.gui_bg_img..
    default.gui_slots..
    "list[current_name;fuel;2.75,2.5;1,1;]" ..
    "image[2.75,1.5;1,1;default_furnace_fire_bg.png^[lowpart:"..
    (100-fuel_percent)..":default_furnace_fire_fg.png]"..
    "list[current_player;main;0,4.85;8,1;]" ..
    "list[current_player;main;0,6.08;8,3;8]" ..
    "image[0.75,1.5;1,2;tech_power_bar_bg.png^[lowpart:"..
    (energy_percent)..":tech_power_bar_fg.png]"
  return result
end

local function can_dig(pos, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	return inv:is_empty("fuel")
end

minetest.register_node("tech:diamond_destructurizer", {
  description = "Diamond Destructurizer",
  tiles = {"tech_high_powered_side.png",
    "tech_high_powered_side.png",
    "tech_high_powered_side.png",
    "tech_high_powered_side.png",
    "tech_high_powered_side.png",
    "tech_diamond_destructurizer_front.png",
  },
  paramtype2 = "facedir",
  groups = {cracky=2,},
  on_construct = function(pos)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    inv:set_size("fuel", 1)
    inv:set_width("fuel", 1)
    tech.register_powered(pos, {
      capacity = 4*10^6,
    })
    tech.register_processer(pos, {
      start_progress = 0,
      total_progress = 0
    })
    meta:set_int("tech_on", 1)
    meta:set_string("formspec", inactive_formspec(0))
  end,
  can_dig = can_dig,
  mesecons = tech.shutdownable,
})

tech.register_generator("tech:diamond_destructurizer")

local generator_output = 10000
local one_fuel_time = 60 * 5
-- so, per one diamond it produces 3 000 000 energy

local function on_timer(pos)
  local selfpow = tech.get_powered(pos)
  local proc = tech.get_processer(pos)
  local meta = minetest.get_meta(pos)
  local energy_percent = math.floor(selfpow:get_energy() / selfpow:get_capacity() * 100)
  if proc:get_progress() + 1 < proc:get_total_progress() then
    proc:set_progress(proc:get_progress() + 1)
    selfpow:set_energy(selfpow:get_energy() + generator_output)
    local fuel_percent = math.floor(proc:get_progress() / proc:get_total_progress() * 100)
    meta:set_string("formspec", active_formspec(fuel_percent, energy_percent))
    return
  end
  local inv = meta:get_inventory()
  if inv ~= nil then
    local stack = inv:get_stack("fuel", 1)
    local item = stack:take_item(1)
    if item:is_empty() then
      meta:set_string("formspec", inactive_formspec(energy_percent))
    end
    --local res = minetest.get_craft_result({method = "fuel", items = {item}}, {})
    if item:get_name() == "default:diamond" then
      proc:set_progress(0)
      proc:set_total_progress(one_fuel_time)
      inv:set_stack("fuel", 1, stack)
      selfpow:set_energy(selfpow:get_energy() + generator_output)
      meta:set_string("formspec", active_formspec(100, energy_percent))
    else
      meta:set_string("formspec", inactive_formspec(energy_percent))
    end
  end
end
on_timer = tech.shutdownable_timer(on_timer)

minetest.register_abm({
  nodenames = {"tech:diamond_destructurizer",},
  interval = 1,
  chance = 1,
  action = on_timer,
})

minetest.register_craft({
  output = 'tech:diamond_destructurizer 1', 
  recipe = {
  {'', 'tech:power_collector', ''},
  {'default:diamond', 'tech:advanced_machine_casing', 'default:diamond'},
  {'default:diamond', 'default:diamond', 'default:diamond'},
  }
})
