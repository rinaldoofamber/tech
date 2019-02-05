-- centrifuge

local progress = 10
-- per one progress step
local spends = 80

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
    "list[current_name;dst;4.75,1.5;2,2;]" ..
    "list[current_name;empty;3.75,3.5;1,1;]" ..
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
    "list[current_name;dst;4.75,1.5;2,2;]" ..
    "list[current_name;empty;3.75,3.5;1,1;]" ..
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
    meta:set_string("formspec", inactive_formspec(energy_percent))
    if src:is_empty() then
      return
    end
    local res = tech.get_craft({type = "centrifuge", recipe = src:get_name()})
    if res and src:get_count() >= res.recipe_count and inv:room_for_item("dst", ItemStack(res.output[1][1])) and inv:contains_item("empty", ItemStack("tech:cell" .. " " .. tostring(math.max(res.cells, 0)))) then
      if selfpow:get_energy() > spends then
        tech.play_sound(pos, "tech_centrifuge", 6)
        selfpow:set_energy(selfpow:get_energy() - spends)
        local proc = tech.get_processer(pos)
        if proc:get_progress() + 1 < proc:get_total_progress() then
          proc:set_progress(proc:get_progress() + 1)
          local progress_percent = math.floor(proc:get_progress() / proc:get_total_progress() * 100)
          meta:set_string("formspec", active_formspec(energy_percent, progress_percent))
        else
          proc:set_progress(0)
          local srcstack = inv:get_stack("src", 1)
          srcstack:set_count(srcstack:get_count() - res.recipe_count)
          inv:set_stack("src", 1, srcstack)
          if res.cells >= 0 then
           inv:remove_item("empty", ItemStack("tech:cell" .. " " .. tostring(res.cells)))
          else
           inv:add_item("empty", ItemStack("tech:cell" .. " " .. tostring(-res.cells)))
          end
          for _, v in ipairs(res.output) do
            if math.random() < v[2] then
              inv:add_item("dst", ItemStack(v[1]))
            end
          end
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
	return inv:is_empty("dst") and inv:is_empty("src") and inv:is_empty("empty")
end

minetest.register_node("tech:centrifuge", {
  description = "Centrifuge",
  tiles = {"tech_powered_side.png",
    "tech_powered_side.png",
    "tech_powered_side.png",
    "tech_powered_side.png",
    "tech_powered_side.png",
    "tech_centrifuge_front.png"},
  paramtype2 = "facedir",
  groups = {cracky=2,},
  on_construct = function(pos)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    inv:set_size("src", 1)
    inv:set_size("empty", 1)
    inv:set_size("dst", 4)
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

tech.register_consumer("tech:centrifuge")

minetest.register_abm({
  nodenames = {"tech:centrifuge"},
  interval = 1,
  chance = 1,
  action = on_timer,
})

minetest.register_craft({
  output = 'tech:centrifuge 1',
  recipe = {
  {'', 'tech:motor', ''},
  {'', 'tech:advanced_machine_casing', ''},
  {'', 'tech:cell', ''},
  }
})
