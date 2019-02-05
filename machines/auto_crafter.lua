local spends = 20 -- per craft

tech.register_consumer("tech:auto_crafter")

local function formspec(energy_percent)
 local result = "size[9,9;]" ..
 default.gui_bg ..
 default.gui_bg_img ..
 default.gui_slots ..
 "list[current_name;recipe;2,0.25;3,3;]" ..
 "list[current_name;output;6,1.25;1,1]" ..
 "list[current_name;replaces;0,3.5;9,1]" ..
 "list[current_player;main;0,4.85;8,1;]" ..
 "list[current_player;main;0,6.08;8,3;8]" ..
 "image[0.75,1;1,2;tech_power_bar_bg.png^[lowpart:" ..
 energy_percent..":tech_power_bar_fg.png]" ..
 "image[5,1.25;1,1;gui_furnace_arrow_bg.png^[transformR270]" ..
 "button[5,0.25;3,0.5;remember;remember]" ..
 "button[5,2.5;3,0.5;forget;forget]"
 return result
end

local function can_dig(pos, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	return inv:is_empty("recipe") and inv:is_empty("replaces") and inv:is_empty("output")
end

local function on_timer(pos)
 local meta = minetest.get_meta(pos)
 local inv = minetest.get_inventory({type = "node", pos = pos})
 pos.y = pos.y + 1
 local upinv = minetest.get_inventory({type = "node", pos = pos})
 pos.y = pos.y - 1
 if upinv then
  local name, invstack, item
  for i = 1, 9 do
   name = meta:get_string("tech_" .. tostring(i))
   if name ~= "" then
    item = ItemStack(name .. " 1")
    if upinv:contains_item("main", item) and inv:get_stack("recipe", i):get_free_space() > 0 then
     upinv:remove_item("main", item)
     invstack = inv:get_stack("recipe", i)
     invstack:add_item(item)
     inv:set_stack("recipe", i, invstack)
    end
   end
  end
 end
 local pow = tech.get_powered(pos)
 local energy_percent = math.floor(pow:get_energy() / pow:get_capacity() * 100)
 meta:set_string("formspec", formspec(energy_percent))
 local items = {}
 for i = 1,9 do
  items[i] = inv:get_stack("recipe", i)
 end
 for i = 1,9 do
  if items[i]:get_name() ~= meta:get_string("tech_" .. tostring(i)) then
   return
  end
 end
 local res, remnants = minetest.get_craft_result({
  method = "normal",
  width = 3,
  items = items,
 })
 if res.item:is_empty() then
  return
 end
 if not inv:room_for_item("output", res.item) then
  return
 end
 if pow:get_energy() < spends then
  return
 end
 --[[if remnants then
  for i, v in ipairs(remnants.items) do
   if v:get_count() == items[i]:get_count() then
    --inv:add_item("replaces", v)
    inv:set_stack("recipe", i, v)
   end
  end
 end]]
 inv:add_item("output", res.item)
 for i = 1,9 do
  --items[i]:set_count(items[i]:get_count() - 1)
  inv:set_stack("recipe", i, remnants.items[i])
 end
 pow:set_energy(pow:get_energy() - spends)
end
on_timer = tech.shutdownable_timer(on_timer)

minetest.register_node("tech:auto_crafter", {
 description = "Auto Crafter",
 tiles = {"tech_auto_crafter_top.png"},
 groups = {cracky = 3, oddly_breakable_by_hand = 2},
 on_construct = function(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()
  inv:set_size("recipe", 9)
  inv:set_width("recipe", 3)
  inv:set_size("output", 1)
  inv:set_size("replaces", 9)
  inv:set_width("replaces", 9)
  for i = 1, 9 do
   meta:set_string("tech_" .. tostring(i), "")
  end
  tech.register_powered(pos, {
   capacity = 1000,
  })
  meta:set_int("tech_on", 1)
  meta:set_string("formspec", formspec(0))
 end,
 can_dig = can_dig,
 on_receive_fields = function(pos, formname, fields, sender)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()
  if fields.remember then
   for i = 1, 9 do
    meta:set_string("tech_" .. tostring(i), inv:get_stack("recipe", i):get_name())
   end
  end
  if fields.forget then
   for i = 1, 9 do
    meta:set_string("tech_" .. tostring(i), "")
   end
  end
 end,
 mesecons = tech.shutdownable,
})

minetest.register_abm({
 nodenames = {"tech:auto_crafter",},
 interval = 1,
 chance = 1,
 action = on_timer,
})

minetest.register_craft({
  output = 'tech:auto_crafter 1', 
  recipe = {
  {'', 'tech:motor', ''},
  {'tech:components', 'tech:machine_casing', 'tech:components'},
  {'default:chest', 'tech:micromesas', 'default:chest'},
  }
})
