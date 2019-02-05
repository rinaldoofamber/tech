tech.register_conveyor("tech:output_conveyor", {
 description = "Output Conveyor",
 tiles = {"tech_output_conveyor.png",
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
  local pos1 = {x = pos.x, y = pos.y, z = pos.z}
  local inv = minetest.get_inventory({type = "node", pos = pos})
  if dir == 0 then
   pos.z = pos.z - 1
  elseif dir == 1 then
   pos.x = pos.x - 1
  elseif dir == 2 then
   pos.z = pos.z + 1
  elseif dir == 3 then
   pos.x = pos.x + 1
  end
  local tolist = meta:get_string("tech_output")
  local toinv = minetest.get_inventory({type = "node", pos = pos})
  if toinv then
   local stack = inv:get_stack("conveyor", 1)
   if not stack:is_empty() and toinv:room_for_item(tolist, stack) then
    inv:set_stack("conveyor", 1, ItemStack(""))
    toinv:add_item(tolist, stack)
    tech.show_moving(pos1, pos, stack:get_name())
   elseif not stack:is_empty() then
    local item = stack:take_item(1)
    if toinv:room_for_item(tolist, item) then
     inv:set_stack("conveyor", 1, stack)
     toinv:add_item(tolist, item)
     tech.show_moving(pos1, pos, item:get_name())
    end
   end
  end
 end,
 on_rightclick = function(pos, node, player, itemstack, pointed_thing)
  local dir = minetest.get_node(pos).param2
  local meta = minetest.get_meta(pos)
  local inv = minetest.get_inventory({type = "node", pos = pos})
  if dir == 0 then
   pos.z = pos.z - 1
  elseif dir == 1 then
   pos.x = pos.x - 1
  elseif dir == 2 then
   pos.z = pos.z + 1
  elseif dir == 3 then
   pos.x = pos.x + 1
  end
  local to = minetest.get_meta(pos)
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
  output = 'tech:output_conveyor 1', 
  recipe = {
  {'', '', ''},
  {'', 'tech:conveyor', ''},
  {'', 'group:stick', ''},
  }
})
