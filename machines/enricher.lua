local progress = 2
-- per one progress step
local spends = 5000

local structure = tech.form_multiblock({
  ["a"] = "any",
  ["c"] = "tech:enricher_casing",
  ["@"] = "tech:enricher_casing",
  ["0"] = "air",
}, {
  {
  "aaacaaa",
  "accccca",
  "accccca",
  "ccccccc",
  "accccca",
  "accccca",
  "aaacaaa",
  },
  {
  "aaacaaa",
  "acc0cca",
  "ac000ca",
  "c00000c",
  "ac000ca",
  "acc0cca",
  "aaacaaa",
  },
  {
  "aaacaaa",
  "acc0cca",
  "ac000ca",
  "c00000c",
  "ac000ca",
  "acc0cca",
  "aaacaaa",
  },
  {
  "aaaaaaa",
  "accccca",
  "ac000ca",
  "ac000ca",
  "ac000ca",
  "accccca",
  "aaaaaaa",
  },
  {
  "aaaaaaa",
  "accccca",
  "accccca",
  "acc@cca",
  "accccca",
  "accccca",
  "aaaaaaa",
  },
})

local function can_dig_controller(pos, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	return inv:is_empty("dst") and inv:is_empty("src") and inv:is_empty("compost")
end

local function update_interface_pos(pos, data, is_used)
  for dy = -1,-5,-1 do
    for dx = -3,3 do
      for dz = -3,3 do
        local npos = vector.add(pos, {x = dx, y = dy, z = dz})
        if minetest.get_node(npos).name == "tech:enricher_casing" then
          local meta = minetest.get_meta(npos)
          meta:set_string("tech_multiblock_interface_x", tostring(pos.x))
          meta:set_string("tech_multiblock_interface_y", tostring(pos.y))
          meta:set_string("tech_multiblock_interface_z", tostring(pos.z))
          meta:set_int("tech_multiblock_is_used", is_used)
        end
      end
    end
  end
end

minetest.register_node("tech:enricher_casing", {
  description = "Enricher Casing",
  tiles = {"tech_enricher_casing.png",
    "tech_enricher_casing.png",
    "tech_enricher_casing.png",
    "tech_enricher_casing.png",
    "tech_enricher_casing.png",
    "tech_enricher_casing.png"},
  groups = {cracky=2,},
  can_dig = function(pos, player)
    local meta = minetest.get_meta(pos)
    if meta:get_int("tech_multiblock_is_used") == 1 then
      return false
    end
    return true
  end,
  on_destruct = function(pos)
    local meta = minetest.get_meta(pos)
    if meta:get_int("tech_multiblock_is_used") == 1 then
      local ipos = {}
      ipos.x = tonumber(meta:get_string("tech_multiblock_interface_x"))
      ipos.y = tonumber(meta:get_string("tech_multiblock_interface_y"))
      ipos.z = tonumber(meta:get_string("tech_multiblock_interface_z"))
      minetest.get_meta(ipos):set_int("has_structure", 0)
      update_interface_pos(ipos, {x = "", y = "", z = ""}, 0)
    end
  end,
})

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
    "list[current_name;compost;3.75,3.5;1,1;]" ..
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
    "list[current_name;compost;3.75,3.5;1,1;]" ..
    "image[3.75,2;1,1;gui_furnace_arrow_bg.png^[lowpart:"..
    progress_percent..":gui_furnace_arrow_fg.png^[transformR270]"
  return result
end

local function on_timer(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()
  local selfpow = tech.get_powered(pos)
  local proc = tech.get_processer(pos)
  local energy_percent = math.floor(selfpow:get_energy() / selfpow:get_capacity() * 100)
  if meta:get_int("has_structure") == 0 then
    proc:set_progress(0)
    meta:set_string("formspec", inactive_formspec(0))
    return
  end
  if inv then
    local src = inv:get_stack("src", 1)
    local item = src:take_item(1)
    local compoststack = inv:get_stack("compost", 1)
    meta:set_string("formspec", inactive_formspec(energy_percent))
    if item:is_empty() or compoststack:is_empty() then
      return
    end
    local res = tech.get_craft({type = "enrich", recipe = item:get_name()})
    if res and inv:room_for_item("dst", ItemStack(res.output)) and inv:contains_item("compost", ItemStack("tech:compost")) then
      if selfpow:get_energy() > spends then
        tech.play_sound(pos, "tech_enricher", 6)
        selfpow:set_energy(selfpow:get_energy() - spends)
        if proc:get_progress() + 1 < proc:get_total_progress() then
          proc:set_progress(proc:get_progress() + 1)
          local progress_percent = math.floor(proc:get_progress() / proc:get_total_progress() * 100)
          meta:set_string("formspec", active_formspec(energy_percent, progress_percent))
        else
          proc:set_progress(0)
          inv:set_stack("src", 1, src)
          compoststack:take_item(1)
          inv:set_stack("compost", 1, compoststack)
          inv:add_item("dst", ItemStack(res.output))
          meta:set_string("formspec", inactive_formspec(energy_percent))
        end
      end
    end
  end
end
on_timer = tech.shutdownable_timer(on_timer)

minetest.register_node("tech:enricher", {
  description = "Enricher",
  tiles = {"tech_powered_side.png",
    "tech_powered_side.png",
    "tech_powered_side.png",
    "tech_powered_side.png",
    "tech_powered_side.png",
    "tech_enricher_front.png"},
  paramtype2 = "facedir",
  groups = {cracky=2,},
  on_construct = function(pos)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    inv:set_size("src", 1)
    inv:set_size("dst", 1)
    inv:set_size("compost", 1)
    tech.register_powered(pos, {
      capacity = 50000,
    })
    tech.register_processer(pos, {
      start_progress = 0,
      total_progress = progress
    })
    if tech.check_multiblock(vector.add(pos, {x=0,y=-1,z=0}), structure) then
      meta:set_int("has_structure", 1)
      update_interface_pos(pos, pos, 1)
    else
      meta:set_int("has_structure", 0)
    end
    meta:set_int("tech_on", 1)
    meta:set_string("formspec", inactive_formspec(0))
  end,
  can_dig = can_dig_controller,
  mesecons = tech.shutdownable,
  on_destruct = function(pos)
    local meta = minetest.get_meta(pos)
    if meta:get_int("has_structure") == 1 then
      update_interface_pos(pos, {x = "", y = "", z = ""}, 0)
    end
  end
})

tech.register_consumer("tech:enricher")

minetest.register_abm({
  nodenames = {"tech:enricher"},
  interval = 1,
  chance = 1,
  action = on_timer,
})

minetest.register_craft({
  output = 'tech:enricher_casing 6', 
  recipe = {
  {'default:bronze_ingot', '', 'default:bronze_ingot'},
  {'default:bronze_ingot', 'tech:machine_casing', 'default:bronze_ingot'},
  {'default:bronze_ingot', '', 'default:bronze_ingot'},
  }
})

minetest.register_craft({
  output = 'tech:enricher 1', 
  recipe = {
  {'default:diamond', 'tech:motor', 'default:diamond'},
  {'tech:motor', 'tech:advanced_machine_casing', 'tech:motor'},
  {'default:diamond', 'tech:motor', 'default:diamond'},
  }
})
