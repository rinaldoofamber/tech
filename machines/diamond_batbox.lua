local function formspec(energy_percent)
  local result = "size[8,9]"..
    default.gui_bg..
    default.gui_bg_img..
    default.gui_slots..
    "list[current_player;main;0,4.85;8,1;]" ..
    "list[current_player;main;0,6.08;8,3;8]" ..
    "image[0.75,1.5;1,2;tech_power_bar_bg.png^[lowpart:"..
    energy_percent..":tech_power_bar_fg.png]" ..
    "list[current_name;charge;2.75,1;1,1;]" ..
    "list[current_name;uncharge;2.75,3;1,1;]"
  return result
end

local charge_per_second = 20000

local function on_batbox_timer(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()
  local selfpow = tech.get_powered(pos)
  local charge = inv:get_stack("charge", 1)
  local uncharge = inv:get_stack("uncharge", 1)
  tech.charge_tool(selfpow, "charge", inv, charge_per_second)
  tech.uncharge_tool(selfpow, "uncharge", inv, charge_per_second)
  local energy_percent = math.floor(selfpow:get_energy() / selfpow:get_capacity() * 100)
  meta:set_string("formspec", formspec(energy_percent))
end

local function can_dig(pos, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	return inv:is_empty("charge") and inv:is_empty("uncharge")
end

tech.register_batbox("tech:diamond_batbox")

minetest.register_node("tech:diamond_batbox", {
  description = "Diamond Batbox",
  tiles = {"tech_diamond_batbox_side.png",
    "tech_diamond_batbox_side.png",
    "tech_diamond_batbox_side.png",
    "tech_diamond_batbox_side.png",
    "tech_diamond_batbox_side.png",
    "tech_diamond_batbox_side.png"},
  groups = {cracky=2,},
  on_construct = function(pos)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    inv:set_size("charge", 1)
    inv:set_size("uncharge", 1)
    tech.register_powered(pos, {
      capacity = 10*10^6,
    })
    meta:set_string("formspec", formspec(0))
  end,
  can_dig = can_dig,
})

minetest.register_abm({
  nodenames = {"tech:diamond_batbox"},
  interval = 1,
  chance = 1,
  action = on_batbox_timer,
})

minetest.register_craft({
  output = 'tech:diamond_batbox 1', 
  recipe = {
  {'tech:diamond_battery', 'tech:energium_wire', 'tech:diamond_battery'},
  {'tech:diamond_battery', 'tech:advanced_machine_casing', 'tech:diamond_battery'},
  {'tech:diamond_battery', 'tech:diamond_battery', 'tech:diamond_battery'},
  }
})
