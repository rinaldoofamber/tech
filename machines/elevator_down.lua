minetest.register_node("tech:elevator_down", {
  description = "Elevator: Down",
  --[[tiles = {"default_glass.png",
   "default_glass.png",
   "tech_elevator_up_side.png",
   "tech_elevator_up_side.png",
   "tech_elevator_up_side.png",
   "tech_elevator_up_side.png"},--]]
  tiles = {"tech_elevator_down_side.png",
  "tech_elevator_down_side.png",
  "default_glass.png",
  "default_glass.png",
  "default_glass.png",
  "default_glass.png",},
  drawtype = "glasslike_framed",
  --drawtype = "liquid",
  paramtype = "light",
  --alpha = 100,
  groups = {cracky=2,},
  --inventory_image = "tech_elevator_down_side.png",
  on_construct = function(pos)
   local meta = minetest.get_meta(pos)
   local inv = meta:get_inventory()
   inv:set_size("conveyor", 1)
  end,
})

minetest.register_abm({
 nodenames = {"tech:elevator_down"},
 interval = 1,
 chance = 1,
 action = function(pos)
  local pos1 = {x = pos.x, y = pos.y, z = pos.z}
  local inv = minetest.get_inventory({type = "node", pos = pos})
  pos.y = pos.y - 1
  local toinv = minetest.get_inventory({type = "node", pos = pos})
  if toinv ~= nil then
   local stack, item
   stack = inv:get_stack("conveyor", 1)
   item = stack:take_item(stack:get_count())
   if item:is_empty() then
    return
   end
   if toinv:room_for_item("conveyor", item) then
    inv:set_stack("conveyor", 1, stack)
    toinv:add_item("conveyor", item)
    tech.show_moving(pos1, pos, item:get_name())
   end
  end
 end,
})

minetest.register_craft({
  output = 'tech:elevator_down 1', 
  recipe = {
  {'', '', ''},
  {'', 'tech:conveyor', ''},
  {'', 'default:glass', ''},
  }
})