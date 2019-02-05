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

tech.register_conveyor("tech:distributing_conveyor_left", {
 description = "Distributing Conveyor (Left)",
 tiles = {"tech_distributing_conveyor_left.png",
  "default_steel_block.png",
  "default_steel_block.png",
  "default_steel_block.png",
  "default_steel_block.png",
  "default_steel_block.png"},
 on_construct = function(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()
  inv:set_size("conveyor", 1)
  meta:set_string("tech_output", "main")
  meta:set_string("formspec", formspec)
 end,
 on_receive_fields = function(pos, formname, fields, sender)
  local meta = minetest.get_meta(pos)
  for k, v in pairs(fields) do
   if k ~= "quit" then
    meta:set_string("tech_output", k)
   end
  end
 end,
 on_timer = function(pos)
  local dir = minetest.get_node(pos).param2
  local meta = minetest.get_meta(pos)
  local inv = minetest.get_inventory({type = "node", pos = pos})
  local posf = {x = pos.x, y = pos.y, z = pos.z}
  local posl = {x = pos.x, y = pos.y, z = pos.z}
  if dir == 0 then
   posf.z = pos.z - 1
   posl.x = pos.x + 1
  elseif dir == 1 then
   posf.x = pos.x - 1
   posl.z = pos.z - 1
  elseif dir == 2 then
   posf.z = pos.z + 1
   posl.x = pos.x - 1
  elseif dir == 3 then
   posf.x = pos.x + 1
   posl.z = pos.z + 1
  end
  local tolist = meta:get_string("tech_output")
  local toinv = minetest.get_inventory({type = "node", pos = posl})
  if toinv then
   local stack = inv:get_stack("conveyor", 1)
   if not stack:is_empty() and toinv:room_for_item(tolist, stack) then
    inv:set_stack("conveyor", 1, ItemStack(""))
    toinv:add_item(tolist, stack)
    tech.show_moving(pos, posl, stack:get_name())
   elseif not stack:is_empty() then
    local item = stack:take_item(1)
    if toinv:room_for_item(tolist, item) then
     inv:set_stack("conveyor", 1, stack)
     toinv:add_item(tolist, item)
     tech.show_moving(pos, posl, item:get_name())
    end
   end
  end
  if inv:get_stack("conveyor", 1):get_count() > 0 then
    tech.move_item(pos, posf)
  end
 end,
 on_rightclick = function(pos, node, player, itemstack, pointed_thing)
  local dir = minetest.get_node(pos).param2
  local meta = minetest.get_meta(pos)
  local inv = minetest.get_inventory({type = "node", pos = pos})
  local posf = {x = pos.x, y = pos.y, z = pos.z}
  local posl = {x = pos.x, y = pos.y, z = pos.z}
  if dir == 0 then
   posf.z = pos.z - 1
   posl.x = pos.x + 1
  elseif dir == 1 then
   posf.x = pos.x - 1
   posl.z = pos.z - 1
  elseif dir == 2 then
   posf.z = pos.z + 1
   posl.x = pos.x - 1
  elseif dir == 3 then
   posf.x = pos.x + 1
   posl.z = pos.z + 1
  end
  local to = minetest.get_meta(posl)
  local formspec = to:get_string("formspec")
  if #formspec == 0 then
   meta:set_string("formspec", "")
   meta:set_string("tech_output", "main")
  else
   meta:set_string("formspec", tech.replace_lists_with_buttons(formspec))
  end
 end,
})

minetest.register_craft({
  output = 'tech:distributing_conveyor_left 1', 
  recipe = {
  {'', '', ''},
  {'tech:conveyor', 'tech:conveyor', ''},
  {'', 'tech:conveyor', ''},
  }
})


tech.register_conveyor("tech:distributing_conveyor_right", {
 description = "Distributing Conveyor (Right)",
 tiles = {"tech_distributing_conveyor_right.png",
  "default_steel_block.png",
  "default_steel_block.png",
  "default_steel_block.png",
  "default_steel_block.png",
  "default_steel_block.png"},
 on_construct = function(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()
  inv:set_size("conveyor", 1)
  meta:set_string("tech_output", "main")
  meta:set_string("formspec", formspec)
 end,
 on_receive_fields = function(pos, formname, fields, sender)
  local meta = minetest.get_meta(pos)
  for k, v in pairs(fields) do
   if k ~= "quit" then
    meta:set_string("tech_output", k)
   end
  end
 end,
 on_timer = function(pos)
  local dir = minetest.get_node(pos).param2
  local meta = minetest.get_meta(pos)
  local inv = minetest.get_inventory({type = "node", pos = pos})
  local posf = {x = pos.x, y = pos.y, z = pos.z}
  local posr = {x = pos.x, y = pos.y, z = pos.z}
  if dir == 0 then
   posf.z = pos.z - 1
   posr.x = pos.x - 1
  elseif dir == 1 then
   posf.x = pos.x - 1
   posr.z = pos.z + 1
  elseif dir == 2 then
   posf.z = pos.z + 1
   posr.x = pos.x + 1
  elseif dir == 3 then
   posf.x = pos.x + 1
   posr.z = pos.z - 1
  end
  
  local tolist = meta:get_string("tech_output")
  local toinv = minetest.get_inventory({type = "node", pos = posr})
  if toinv then
   local stack = inv:get_stack("conveyor", 1)
   if not stack:is_empty() and toinv:room_for_item(tolist, stack) then
    inv:set_stack("conveyor", 1, ItemStack(""))
    toinv:add_item(tolist, stack)
    tech.show_moving(pos, posr, stack:get_name())
   elseif not stack:is_empty() then
    local item = stack:take_item(1)
    if toinv:room_for_item(tolist, item) then
     inv:set_stack("conveyor", 1, stack)
     toinv:add_item(tolist, item)
     tech.show_moving(pos, posr, item:get_name())
    end
   end
  end
  if inv:get_stack("conveyor", 1):get_count() > 0 then
    tech.move_item(pos, posf)
  end
 end,
 on_rightclick = function(pos, node, player, itemstack, pointed_thing)
  local dir = minetest.get_node(pos).param2
  local meta = minetest.get_meta(pos)
  local inv = minetest.get_inventory({type = "node", pos = pos})
  local posf = {x = pos.x, y = pos.y, z = pos.z}
  local posr = {x = pos.x, y = pos.y, z = pos.z}
  if dir == 0 then
   posf.z = pos.z - 1
   posr.x = pos.x - 1
  elseif dir == 1 then
   posf.x = pos.x - 1
   posr.z = pos.z + 1
  elseif dir == 2 then
   posf.z = pos.z + 1
   posr.x = pos.x + 1
  elseif dir == 3 then
   posf.x = pos.x + 1
   posr.z = pos.z - 1
  end
  local to = minetest.get_meta(posr)
  local formspec = to:get_string("formspec")
  if #formspec == 0 then
   meta:set_string("formspec", "")
   meta:set_string("tech_output", "main")
  else
   meta:set_string("formspec", tech.replace_lists_with_buttons(formspec))
  end
 end,
})

minetest.register_craft({
  output = 'tech:distributing_conveyor_right 1', 
  recipe = {
  {'', '', ''},
  {'', 'tech:conveyor', 'tech:conveyor'},
  {'', 'tech:conveyor', ''},
  }
})
