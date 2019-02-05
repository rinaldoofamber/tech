tech.register_conveyor("tech:conveyor", {
 description = "Conveyor",
 tiles = {"tech_conveyor.png",
  "default_steel_block.png",
  "default_steel_block.png",
  "default_steel_block.png",
  "default_steel_block.png",
  "default_steel_block.png"},
 on_construct = function(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()
  inv:set_size("conveyor", 1)
 end,
 on_timer = function(pos)
  local dir = minetest.get_node(pos).param2
  local inv = minetest.get_inventory({type = "node", pos = pos})
  local pos1 = {x = pos.x, y = pos.y, z = pos.z}
  if dir == 0 then
   pos.z = pos.z - 1
  elseif dir == 1 then
   pos.x = pos.x - 1
  elseif dir == 2 then
   pos.z = pos.z + 1
  elseif dir == 3 then
   pos.x = pos.x + 1
  end
  tech.move_item(pos1, pos)
 end,
})

minetest.register_craft({
  output = 'tech:conveyor 24', 
  recipe = {
  {'', '', ''},
  {'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
  {'tech:cog', 'tech:cog', 'tech:cog'},
  }
})


