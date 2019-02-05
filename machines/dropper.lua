local gui_bg = "bgcolor[#080808BB;true]"
local gui_bg_img = "background[5,5;1,1;gui_formbg.png;true]"
local gui_slots = "listcolors[#00000069;#5A5A5A;#141318;#30434C;#FFF]"

local formspec = "size[8,10;]" ..
  gui_bg .. -- set color of background
  gui_bg_img .. -- makes gui background not transparent
  gui_slots .. -- slots color
  "list[current_name;main;3,1;3,3]" ..
  "list[current_player;main;0,4.8;8,1;]" .. -- player's hand
  "list[current_player;main;0,6.0.75;8,3;8]" -- player's inventoty main part

minetest.register_node("tech:dropper", {
 description = "Item Dropper",
 tiles = {"tech_dropper.png"},
 groups = {cracky = 3, oddly_breakable_by_hand = 2},
 on_construct = function(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()
  inv:set_size("main", 9)
  inv:set_width("main", 3)
  meta:set_string("formspec", formspec)
 end,
 can_dig = function(pos, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	return inv:is_empty("main")
 end,
})

local function on_timer(pos)
 local meta = minetest.get_meta(pos)
 local inv = meta:get_inventory()
 local stack
 for i = 1, 32 do
  stack = inv:get_stack("main", i)
  if not stack:is_empty() then
   local todrop = stack:take_item(1)
   inv:set_stack("main", i, stack)
   minetest.add_item({x = pos.x, y = pos.y - 1, z = pos.z}, todrop:to_string())
   break
  end
 end
end

minetest.register_abm({
 nodenames = {"tech:dropper"},
 interval = 1,
 chance = 1,
 action = on_timer,
})

minetest.register_craft({
  output = "tech:dropper",
  recipe = {
  {"", "", ""},
  {"", "default:chest", ""},
  {"", "default:steel_ingot", ""},
  }
})
