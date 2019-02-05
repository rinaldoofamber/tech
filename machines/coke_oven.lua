local function formspec(progress_percent)
  local result = "size[8,9]"..
    default.gui_bg..
    default.gui_bg_img..
    default.gui_slots..
    "list[current_player;main;0,4.85;8,1;]" ..
    "list[current_player;main;0,6.08;8,3;8]" ..
    "list[current_name;src;2.75,2;1,1;]" ..
    "list[current_name;dst;4.75,2;1,1;]" ..
    "image[3.75,2;1,1;gui_furnace_arrow_bg.png^[lowpart:"..
    progress_percent..":gui_furnace_arrow_fg.png^[transformR270]"
  return result
end

local structure = tech.form_multiblock({["0"] = "air", ["c"] = "tech:coke_brick", ["@"] = "tech:coke_brick"},
  {
   {"ccc",
    "ccc",
    "ccc",},
   {"ccc",
    "@0c",
    "ccc",},
   {"ccc",
    "ccc",
    "ccc",},
   
  })

local function update_interface_pos(pos, data, is_used)
  for dx = 0,2 do
    for dy = -1,1 do
      for dz = -1,1 do
        local npos = vector.add(pos, {x = dx, y = dy, z = dz})
        if not vector.equals(pos, npos) then
          local meta = minetest.get_meta(npos)
          meta:set_string("tech_multiblock_interface_x", tostring(pos.x))
          meta:set_string("tech_multiblock_interface_y", tostring(pos.y))
          meta:set_string("tech_multiblock_interface_z", tostring(pos.z))
          meta:set_int("tech_multiblock_is_used", is_used)
          --minetest.debug("isused " .. meta:get_int("tech_multiblock_is_used"))
        end
      end
    end
  end
end

local function on_brick_timer(pos)
  local meta = minetest.get_meta(pos)
  if meta:get_int("tech_multiblock_is_used") == 1 then
    return
  end
  if tech.check_multiblock(pos, structure) then
    update_interface_pos(pos, pos, 1)
    minetest.set_node(pos, {name = "tech:coke_oven"})
  end
end

local function can_dig_oven(pos, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	return inv:is_empty("dst") and inv:is_empty("src")
end

minetest.register_abm({
 nodenames = {"tech:coke_brick"},
 interval = 1,
 chance = 1,
 action = on_brick_timer,
})

minetest.register_node("tech:coke_brick", {
  description = "Coke Oven Brick",
  tiles = {"tech_coke_oven.png",
    "tech_coke_oven.png",
    "tech_coke_oven.png",
    "tech_coke_oven.png",
    "tech_coke_oven.png",
    "tech_coke_oven.png"},
  groups = {cracky=2,},
  can_dig = function(pos, player)
    local meta = minetest.get_meta(pos)
    if meta:get_int("tech_multiblock_is_used") == 1 then
      --minetest.debug("is_used = 1")
      local ipos = {}
      ipos.x = tonumber(meta:get_string("tech_multiblock_interface_x"))
      ipos.y = tonumber(meta:get_string("tech_multiblock_interface_y"))
      ipos.z = tonumber(meta:get_string("tech_multiblock_interface_z"))
      return can_dig_oven(ipos, player)
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
      minetest.set_node(ipos, {name = "tech:coke_brick"})
      update_interface_pos(ipos, {x = "", y = "", z = ""}, 0)
    end
  end
})

local function on_oven_timer(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()
  if inv then
    local src = inv:get_stack("src", 1)
    local item = src:take_item(1)
    local proc = tech.get_processer(pos)
    if item:is_empty() then
      proc:set_progress(0)
      meta:set_string("formspec", formspec(0))
      tech.swap_node(pos, "tech:coke_oven")
      return
    end
    local res = tech.get_craft({type = "coke", recipe = item:get_name()})
    if res and inv:room_for_item("dst", ItemStack(res.output)) then
      tech.swap_node(pos, "tech:coke_oven_on")
      if proc:get_progress() + 1 < proc:get_total_progress() then
        proc:set_progress(proc:get_progress() + 1)
        local progress_percent = math.floor(proc:get_progress() / proc:get_total_progress() * 100)
        meta:set_string("formspec", formspec(progress_percent))
      else
        proc:set_progress(0)
        inv:set_stack("src", 1, src)
        inv:add_item("dst", ItemStack(res.output))
        if math.random() > 0.9 then
          inv:add_item("dst", ItemStack(res.output))
        end
        meta:set_string("formspec", formspec(0))
      end
    end
  end
end

local progress = 40
minetest.register_node("tech:coke_oven", {
  description = "Coke Oven",
  tiles = {"tech_coke_oven.png",
    "tech_coke_oven.png",
    "tech_coke_oven_off.png",
    "tech_coke_oven_off.png",
    "tech_coke_oven_off.png",
    "tech_coke_oven_off.png"},
  paramtype2 = "facedir",
  groups = {cracky=2,},
  on_construct = function(pos)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    inv:set_size("src", 1)
    inv:set_size("dst", 1)
    tech.register_processer(pos, {
      start_progress = 0,
      total_progress = progress
    })
    meta:set_string("formspec", formspec(0))
  end,
  can_dig = can_dig_oven,
  on_destruct = function(pos)
    update_interface_pos(pos, {x = "", y = "", z = ""}, 0)
  end,
  drop = {"tech:coke_brick"},
})

minetest.register_node("tech:coke_oven_on", {
  description = "Coke Oven",
  tiles = {"tech_coke_oven.png",
    "tech_coke_oven.png",
    "tech_coke_oven_on.png",
    "tech_coke_oven_on.png",
    "tech_coke_oven_on.png",
    "tech_coke_oven_on.png"},
  paramtype2 = "facedir",
  groups = {cracky=2,},
  on_construct = function(pos)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    inv:set_size("src", 1)
    inv:set_size("dst", 1)
    tech.register_processer(pos, {
      start_progress = 0,
      total_progress = progress
    })
    meta:set_string("formspec", formspec(0))
  end,
  can_dig = can_dig_oven,
  on_destruct = function(pos)
    update_interface_pos(pos, {x = "", y = "", z = ""}, 0)
  end,
  drop = {"tech:coke_brick"},
})

minetest.register_abm({
 nodenames = {"tech:coke_oven", "tech:coke_oven_on"},
 interval = 1,
 chance = 1,
 action = on_oven_timer,
})

minetest.register_craft({
  output = 'tech:coke_brick 1', 
  recipe = {
  {'group:sand', 'default:clay_brick', 'group:sand'},
  {'default:clay_brick', 'group:sand', 'default:clay_brick'},
  {'group:sand', 'default:clay_brick', 'group:sand'},
  }
})

