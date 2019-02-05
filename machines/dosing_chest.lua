-- mychest

local gui_bg = "bgcolor[#080808BB;true]"
local gui_bg_img = "background[5,5;1,1;gui_formbg.png;true]"
local gui_slots = "listcolors[#00000069;#5A5A5A;#141318;#30434C;#FFF]"

local function mychest_formspec(pos)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local result = "size[8,10;]" ..
  gui_bg .. -- set color of background
  gui_bg_img .. -- makes gui background not transparent
  gui_slots .. -- slots color
  "list[nodemeta:" .. spos .. ";main;0.1,1.5;8,4;]" .. -- shows the upper part: inventoty of the chest
  "list[current_name;dose;0.1,0.3;1,1]" ..
  "list[current_player;main;0,5.8;8,1;]" .. -- player's hand
  "list[current_player;main;0,7.0.75;8,3;8]" .. -- player's inventoty main part
  "listring[nodemeta:" .. spos .. ";main]" -- i don't know what this line does, the effect is invisible
  return result
end

minetest.register_node("tech:dosing_chest", {
  tiles = {"default_chest_top.png"},
  groups = {cracky = 3, oddly_breakable_by_hand = 2},
  on_construct = function(pos)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    inv:set_size("main", 32)
    inv:set_width("main", 8)
    inv:set_size("dose", 1)
    meta:set_string("formspec", mychest_formspec(pos))
  end,
})

local function on_timer(pos)
 local meta = minetest.get_meta(pos)
 local inv = meta:get_inventory()
 local stack, first
 first = inv:get_stack("dose", 1)
 if first:is_empty() then
  for i = 1, 32 do
   stack = inv:get_stack("main", i)
   if not stack:is_empty() then
    inv:set_stack("dose", 1, stack:take_item(1))
    inv:set_stack("main", i, stack)
    return
   end
  end
 end
end

minetest.register_abm({
 nodenames = {"tech:dosing_chest"},
 interval = 1,
 chance = 1,
 action = on_timer,
})


