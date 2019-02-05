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

minetest.register_node("tech:collector", {
 description = "Item Collector",
 tiles = {"tech_collector.png"},
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
 local objs   = minetest.get_objects_inside_radius(pos, 2)

 for k, obj in pairs(objs) do
	local objpos = obj:getpos()
	local lua_entity = obj:get_luaentity()
	if lua_entity and lua_entity.name == "__builtin:item" then
	 local itemstack = ItemStack(loadstring(lua_entity:get_staticdata())().itemstring)
	 if inv:room_for_item("main", itemstack) then
	  obj:remove()
	  inv:add_item("main", itemstack)
	 end
	end
 end
end

minetest.register_abm({
 nodenames = {"tech:collector"},
 interval = 1,
 chance = 1,
 action = on_timer,
})

minetest.register_craft({
  output = "tech:collector",
  recipe = {
  {"", "", ""},
  {"", "default:chest", ""},
  {"", "default:copper_ingot", ""},--maybe, replace it with a permanent magnet (made with magnetizer)
  }
})

minetest.register_tool("tech:who", {
 inventory_image = "default_stick.png",
 on_use = function(itemstack, user, pointed_thing)
  if not user:is_player() then
   return
  end
  local tgpos, target
  if pointed_thing.type == "object" then
   tgpos = pointed_thing.ref:getpos()
   target = pointed_thing.ref
  else
   return
  end
  local lua_entity = target:get_luaentity()
  local staticdata = lua_entity:get_staticdata()
  local firstcomma = string.find(staticdata, ",")
  minetest.chat_send_all(loadstring(staticdata)().itemstring)
  --local aftercomma = 
  --minetest.chat_send_all
 end,
})
