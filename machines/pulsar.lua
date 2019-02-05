local formspec = "size[8,9]"..
 default.gui_bg..
 default.gui_bg_img..
 "field[1,1;3,1;time_on;time on;${tech_time_on}]"..
 "field[1,1;3,1;time_off;time off;${tech_time_off}]"..
 "button_exit[1,5;1,1;button_exit;ok]"

local mesecons_off, mesecons_on
if mesecon then
 mesecons_off = {receptor = {
		state = mesecon.state.off,
	}}
	mesecons_on = {receptor = {
		state = mesecon.state.on,
	}}
end


minetest.register_node("tech:pulsar_off", {
 description = "Charge Monitor",
 tiles = {"tech_not_powered_side.png",
  "tech_not_powered_side.png",
  "tech_not_powered_side.png",
  "tech_not_powered_side.png",
  "tech_not_powered_side.png",
  "tech_charge_monitor_front.png"},
 paramtype2 = "facedir",
 groups = {cracky=2,},
 on_construct = function(pos)
  local meta = minetest.get_meta(pos)
  meta:set_int("tech_level", 0)
  meta:set_int("tech_more", 0)
  meta:set_string("formspec", formspec)
 end,
 on_receive_fields = function(pos, formname, fields, sender)
  local meta = minetest.get_meta(pos)
  meta:set_string("tech_level", fields.level)
  if fields.more_mode == "CHG:1" then
   meta:set_string("tech_more_mode", 1)
  elseif fields.more_mode == "CHG:2" then
   meta:set_string("tech_more_mode", 0)
  end
 end,
 mesecons = mesecons_off,
})

minetest.register_node("tech:pulsar_on", {
 description = "Charge Monitor",
 tiles = {"tech_not_powered_side.png",
  "tech_not_powered_side.png",
  "tech_not_powered_side.png",
  "tech_not_powered_side.png",
  "tech_not_powered_side.png",
  "tech_charge_monitor_front.png"},
 paramtype2 = "facedir",
 groups = {cracky=2,},
 on_construct = function(pos)
  local meta = minetest.get_meta(pos)
  meta:set_int("tech_level", 0)
  meta:set_int("tech_more", 0)
  meta:set_string("formspec", formspec)
 end,
 on_receive_fields = function(pos, formname, fields, sender)
  local meta = minetest.get_meta(pos)
  meta:set_string("tech_level", fields.level)
  if fields.more_mode == "CHG:1" then
   meta:set_string("tech_more_mode", 1)
  elseif fields.more_mode == "CHG:2" then
   meta:set_string("tech_more_mode", 0)
  end
 end,
 mesecons = mesecons_on,
})

local function on_off_timer(pos)
 local node = minetest.get_node(pos)
 local meta = minetest.get_meta(pos)
 local more_mode = meta:get_int("tech_more_mode") == 1
 local level = meta:get_int("tech_level")
 local batbox
 if node.param2 == 0 then
  batbox = {x = pos.x, y = pos.y, z = pos.z - 1}
 elseif node.param2 == 1 then
  batbox = {x = pos.x - 1, y = pos.y, z = pos.z}
 elseif node.param2 == 2 then
  batbox = {x = pos.x, y = pos.y, z = pos.z + 1}
 elseif node.param2 == 3 then
  batbox = {x = pos.x + 1, y = pos.y, z = pos.z}
 end
 if tech.is_powered(batbox) and ((more_mode and tech.get_powered(batbox):get_energy() >= level) or ((not more_mode) and tech.get_powered(batbox):get_energy() <= level)) then
  minetest.swap_node(pos, {name = "tech:charge_monitor_on", param2 = node.param2})
  mesecon.receptor_on(pos, mesecon.rules.default)
 end
end

local function on_on_timer(pos)
 local node = minetest.get_node(pos)
 local meta = minetest.get_meta(pos)
 local more_mode = meta:get_int("tech_more_mode") == 1
 local level = meta:get_int("tech_level")
 local batbox
 if node.param2 == 0 then
  batbox = {x = pos.x, y = pos.y, z = pos.z - 1}
 elseif node.param2 == 1 then
  batbox = {x = pos.x - 1, y = pos.y, z = pos.z}
 elseif node.param2 == 2 then
  batbox = {x = pos.x, y = pos.y, z = pos.z + 1}
 elseif node.param2 == 3 then
  batbox = {x = pos.x + 1, y = pos.y, z = pos.z}
 end
 if (not tech.is_powered(batbox)) or (more_mode and tech.get_powered(batbox):get_energy() < level) or ((not more_mode) and tech.get_powered(batbox):get_energy() > level) then
  minetest.swap_node(pos, {name = "tech:charge_monitor_off", param2 = node.param2})
  mesecon.receptor_off(pos, mesecon.rules.pplate)
 end
end

if mesecon then
 minetest.register_abm({
  nodenames = {"tech:charge_monitor_off"},
  interval = 1,
  chance = 1,
  action = on_off_timer,
 })

 minetest.register_abm({
  nodenames = {"tech:charge_monitor_on"},
  interval = 1,
  chance = 1,
  action = on_on_timer,
 })
end


