local function contains(arr, val)
 for i, v in ipairs(arr) do
  if v == val then
   return true
  end
 end
 return false
end

local formspec = "size[8,9]"..
 default.gui_bg..
 default.gui_bg_img..
 default.gui_slots..
 "list[current_player;main;0,4.85;8,1;]" ..
 "list[current_player;main;0,6.08;8,3;8]" ..
 "list[current_name;left;0,1;3,3;]" ..
 "list[current_name;right;5,1;3,3;]" ..
 "button[3.5,2;1,1;button_ok;ok]"

tech.register_conveyor("tech:sorting_conveyor", {
 description = "Sorting Conveyor",
 tiles = {"tech_sorting_conveyor.png^[transformR180]",
  "default_steel_block.png",
  "default_steel_block.png",
  "default_steel_block.png",
  "default_steel_block.png",
  "default_steel_block.png"},
 on_construct = function(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()
  inv:set_size("conveyor", 1)
  inv:set_size("left", 9)
  inv:set_size("right", 9)
  local i
  for i = 1, 9 do
   meta:set_string("tech_left_" .. i, "")
   meta:set_string("tech_right_" .. i, "")
  end
  meta:set_string("formspec", formspec)
 end,
 on_receive_fields = function(pos, formname, fields, sender)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()
  if not fields.button_ok then
   return
  end
  for i = 1, 9 do
   meta:set_string("tech_left_" .. i, inv:get_stack("left", i):get_name())
   meta:set_string("tech_right_" .. i, inv:get_stack("right", i):get_name())
  end
 end,
 on_timer = function(pos)
  local dir = minetest.get_node(pos).param2
  local meta = minetest.get_meta(pos)
  local inv = minetest.get_inventory({type = "node", pos = pos})
  local posf = {x = pos.x, y = pos.y, z = pos.z}
  local posl = {x = pos.x, y = pos.y, z = pos.z}
  local posr = {x = pos.x, y = pos.y, z = pos.z}
  if dir == 0 then
   posf.z = pos.z - 1
   posl.x = pos.x + 1
   posr.x = pos.x - 1
  elseif dir == 1 then
   posf.x = pos.x - 1
   posl.z = pos.z - 1
   posr.z = pos.z + 1
  elseif dir == 2 then
   posf.z = pos.z + 1
   posl.x = pos.x - 1
   posr.x = pos.x + 1
  elseif dir == 3 then
   posf.x = pos.x + 1
   posl.z = pos.z + 1
   posr.z = pos.z - 1
  end
  local left_filter = {}
  local right_filter = {}
  for i = 1, 9 do
   left_filter[i] = meta:get_string("tech_left_" .. i)
   right_filter[i] = meta:get_string("tech_right_" .. i)
  end
  if contains(left_filter, inv:get_stack("conveyor", 1):get_name()) then
   tech.move_item(pos, posl)
  elseif contains(right_filter, inv:get_stack("conveyor", 1):get_name()) then
   tech.move_item(pos, posr)
  else
   tech.move_item(pos, posf)
  end
 end,
})

minetest.register_craft({
  output = 'tech:sorting_conveyor 1', 
  recipe = {
  {'', 'tech:micromesas', ''},
  {'', 'tech:conveyor', ''},
  {'', 'tech:micromesas', ''},
  }
})


