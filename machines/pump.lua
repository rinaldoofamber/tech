local progress = 3
-- per one progress step
local spends = 15

local function inactive_formspec(energy_percent)
  local result = "size[8,9]"..
    default.gui_bg..
    default.gui_bg_img..
    default.gui_slots..
    "list[current_player;main;0,4.85;8,1;]" ..
    "list[current_player;main;0,6.08;8,3;8]" ..
    "image[0.75,1.5;1,2;tech_power_bar_bg.png^[lowpart:"..
    energy_percent..":tech_power_bar_fg.png]" ..
    "list[current_name;src;2.75,2;1,1;]" ..
    "list[current_name;dst;4.75,2;1,1;]" ..
    "image[3.75,2;1,1;gui_furnace_arrow_bg.png^[transformR270]"
  return result
end

local function active_formspec(energy_percent, progress_percent)
  local result = "size[8,9]"..
    default.gui_bg..
    default.gui_bg_img..
    default.gui_slots..
    "list[current_player;main;0,4.85;8,1;]" ..
    "list[current_player;main;0,6.08;8,3;8]" ..
    "image[0.75,1.5;1,2;tech_power_bar_bg.png^[lowpart:"..
    energy_percent..":tech_power_bar_fg.png]" ..
    "list[current_name;src;2.75,2;1,1;]" ..
    "list[current_name;dst;4.75,2;1,1;]" ..
    "image[3.75,2;1,1;gui_furnace_arrow_bg.png^[lowpart:"..
    progress_percent..":gui_furnace_arrow_fg.png^[transformR270]"
  return result
end

local function on_timer(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()
  local selfpow = tech.get_powered(pos)
  local energy_percent = math.floor(selfpow:get_energy() / selfpow:get_capacity() * 100)
  if inv then
    local src = inv:get_stack("src", 1)
    local item = src:take_item(1)
    meta:set_string("formspec", inactive_formspec(energy_percent))
    if item:get_name() ~= "tech:cell" then
      return
    end
    local under = {x = pos.x, y = pos.y - 1, z = pos.z}
    local willget
    local undername = minetest.get_node(under).name
    if undername == "default:water_source" then
      willget = "tech:water_cell"
    elseif undername == "default:lava_source" then
      willget = "tech:lava_cell"
    end
    if willget and inv:room_for_item("dst", ItemStack(willget)) then
      if selfpow:get_energy() > spends then
        tech.play_sound(pos, "tech_freezer", 6)
        selfpow:set_energy(selfpow:get_energy() - spends)
        local proc = tech.get_processer(pos)
        if proc:get_progress() + 1 < proc:get_total_progress() then
          proc:set_progress(proc:get_progress() + 1)
          local progress_percent = math.floor(proc:get_progress() / proc:get_total_progress() * 100)
          meta:set_string("formspec", active_formspec(energy_percent, progress_percent))
        else
          proc:set_progress(0)
          inv:set_stack("src", 1, src)
          minetest.remove_node(under)
          inv:add_item("dst", ItemStack(willget))
          meta:set_string("formspec", inactive_formspec(energy_percent))
        end
      end
    end
  end
end
on_timer = tech.shutdownable_timer(on_timer)

local function can_dig(pos, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	return inv:is_empty("dst") and inv:is_empty("src")
end

minetest.register_node("tech:pump", {
 description = "Pump",
 tiles = {"tech_powered_side.png",
  "tech_powered_side.png",
  "tech_powered_side.png",
  "tech_powered_side.png",
  "tech_powered_side.png",
  "tech_pump_front.png"},
 paramtype2 = "facedir",
 groups = {cracky=2,},
 on_construct = function(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()
  inv:set_size("src", 1)
  inv:set_size("dst", 1)
  tech.register_powered(pos, {
   capacity = 5000,
  })
  tech.register_processer(pos, {
   start_progress = 0,
   total_progress = progress
  })
  meta:set_int("tech_on", 1)
  meta:set_string("formspec", inactive_formspec(0))
 end,
 can_dig = can_dig,
 mesecons = tech.shutdownable,
})

tech.register_consumer("tech:pump")

minetest.register_abm({
 nodenames = {"tech:pump"},
 interval = 1,
 chance = 1,
 action = on_timer,
})

minetest.register_craft({
  output = 'tech:pump 1', 
  recipe = {
  {'', 'tech:motor', ''},
  {'', 'tech:machine_casing', ''},
  {'', 'bucket:bucket_empty', ''},
  }
})

