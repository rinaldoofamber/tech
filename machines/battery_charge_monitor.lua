local formspec = "size[8,9]"..
 default.gui_bg..
 default.gui_bg_img..
 "field[1,1;3,1;level;level;${tech_level}]"..
 "textlist[1,2;4,4;more_mode;more,less]"..
 "textlist[5,2;3,4;charge_uncharge;charge,uncharge]"..
 "button_exit[1,5;1,1;button_exit;ok]"

local mesecons_off, mesecons_om
if mesecon then
 mesecons_off = {receptor = {
		state = mesecon.state.off,
	}}
	mesecons_on = {receptor = {
		state = mesecon.state.on,
	}}
end


minetest.register_node("tech:battery_charge_monitor_off", {
 description = "Battery Charge Monitor",
 tiles = {"tech_not_powered_side.png",
  "tech_not_powered_side.png",
  "tech_not_powered_side.png",
  "tech_not_powered_side.png",
  "tech_not_powered_side.png",
  "tech_battery_charge_monitor_front.png"},
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
  if fields.charge_uncharge == "CHG:1" then
   meta:set_string("tech_charge", 1)
  elseif fields.charge_uncharge == "CHG:2" then
   meta:set_string("tech_charge", 0)
  end
 end,
 mesecons = mesecons_off,
})

minetest.register_node("tech:battery_charge_monitor_on", {
 description = "Battery Charge Monitor",
 tiles = {"tech_not_powered_side.png",
  "tech_not_powered_side.png",
  "tech_not_powered_side.png",
  "tech_not_powered_side.png",
  "tech_not_powered_side.png",
  "tech_battery_charge_monitor_front.png"},
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
  if fields.charge_uncharge == "CHG:1" then
   meta:set_string("tech_charge", 1)
  elseif fields.charge_uncharge == "CHG:2" then
   meta:set_string("tech_charge", 0)
  end
 end,
 mesecons = mesecons_on,
 drop = "tech:battery_charge_monitor_off",
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
 if not tech.is_batbox(batbox) then
  return
 end
 local inv = minetest.get_meta(batbox):get_inventory()
 local stackname = "uncharge"
 if meta:get_int("tech_charge") == 1 then
  stackname = "charge"
 end
 local battery = inv:get_stack(stackname, 1)
 local charge
 if not tech.get_battery(battery:get_name()) then
  if more_mode then
   charge = 0
  else
   charge = 100000000
  end
 else
  charge = tech.get_charge(battery)
 end
 if (more_mode and charge >= level) or ((not more_mode) and charge <= level) then
  minetest.swap_node(pos, {name = "tech:battery_charge_monitor_on", param2 = node.param2})
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
 if not tech.is_batbox(batbox) then
  return
 end
 local inv = minetest.get_meta(batbox):get_inventory()
 local stackname = "uncharge"
 if meta:get_int("tech_charge") == 1 then
  stackname = "charge"
 end
 local battery = inv:get_stack(stackname, 1)
 local charge
 if not tech.get_battery(battery:get_name()) then
  if more_mode then
   charge = 0
  else
   charge = 100000000
  end
 else
  charge = tech.get_charge(battery)
 end
 if (more_mode and charge < level) or ((not more_mode) and charge > level) then
  minetest.swap_node(pos, {name = "tech:battery_charge_monitor_off", param2 = node.param2})
  mesecon.receptor_off(pos, mesecon.rules.pplate)
 end
end

if mesecon then
 minetest.register_abm({
  nodenames = {"tech:battery_charge_monitor_off"},
  interval = 1,
  chance = 1,
  action = on_off_timer,
 })

 minetest.register_abm({
  nodenames = {"tech:battery_charge_monitor_on"},
  interval = 1,
  chance = 1,
  action = on_on_timer,
 })
end

minetest.register_craft({
 output = "tech:battery_charge_monitor_off",
 recipe = {
 {"", "", ""},
 {"tech:microwires", "tech:components", "mesecons:wire_00000000_off"},
 {"", "", ""},
 }
})
