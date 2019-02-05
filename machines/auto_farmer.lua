local spends = 5

local function formspec(energy_percent)
  local result = "size[8,9]"..
    default.gui_bg..
    default.gui_bg_img..
    default.gui_slots..
    "list[current_player;main;0,4.85;8,1;]" ..
    "list[current_player;main;0,6.08;8,3;8]" ..
    "image[0.75,1.5;1,2;tech_power_bar_bg.png^[lowpart:"..
    energy_percent..":tech_power_bar_fg.png]" ..
    "list[current_name;main;4.75,1.5;3,3;]"
  return result
end

local function on_timer(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()
  local selfpow = tech.get_powered(pos)
  local energy_percent = math.floor(selfpow:get_energy() / selfpow:get_capacity() * 100)
  for i = -5,5 do
    for j = -5,5 do
      local npos = {x = pos.x + i, y = pos.y, z = pos.z + j}
      local name = minetest.get_node(npos).name
      local node = minetest.registered_nodes[name]
      if farming.registered_plants[string.sub(name, (string.find(name, ':') or 0) + 1, (string.find(name, "_") or 0) - 1)] and not node.next_plant then
        if selfpow:get_energy() < spends then
          return
        end
        local willdrop = {}
        for _, item in pairs(minetest.get_node_drops(name)) do
          if not inv:room_for_item("main", item) then
            return
          end
          willdrop[#willdrop + 1] = item
        end
        for _, item in ipairs(willdrop) do
          inv:add_item("main", item)
        end
        minetest.remove_node(npos)
        local seed, n
        n = 1
        while n < 10 do
          seed = inv:get_stack("main", n)
          if string.find(seed:get_name(), "seed") then
            break
          end
          n = n + 1
        end
        if seed then
          --minetest.set_node(npos, {name = seed:get_name(), param2 = 1})
          inv:set_stack("main", n, farming.place_seed(seed, nil, {type="node", under={x=npos.x,y=npos.y-1,z=npos.z}, above=npos}, seed:get_name()))
        end
        selfpow:set_energy(selfpow:get_energy() - spends)
      end
    end
  end
end
on_timer = tech.shutdownable_timer(on_timer)

local function formspec_update_timer(pos)
  local meta = minetest.get_meta(pos)
  local selfpow = tech.get_powered(pos)
  local energy_percent = math.floor(selfpow:get_energy() / selfpow:get_capacity() * 100)
  meta:set_string("formspec", formspec(energy_percent))
end

local function can_dig(pos, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	return inv:is_empty("main")
end

minetest.register_node("tech:auto_farmer", {
  description = "Auto Farmer",
  tiles = {"tech_powered_side.png",
    "tech_powered_side.png",
    "tech_powered_side.png",
    "tech_powered_side.png",
    "tech_powered_side.png",
    "tech_auto_farmer_front.png"},
  paramtype2 = "facedir",
  groups = {cracky=2,},
  on_construct = function(pos)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    inv:set_size("main", 9)
    tech.register_powered(pos, {
      capacity = 5000,
    })
    meta:set_int("tech_on", 1)
    meta:set_string("formspec", formspec(0))
  end,
  can_dig = can_dig,
  mesecons = tech.shutdownable,
})

tech.register_consumer("tech:auto_farmer")

minetest.register_abm({
  nodenames = {"tech:auto_farmer"},
  interval = 1,
  chance = 1,
  action = on_timer,
})
minetest.register_abm({
  nodenames = {"tech:auto_farmer"},
  interval = 1,
  chance = 1,
  action = formspec_update_timer,
})

minetest.register_craft({
  output = 'tech:auto_farmer 1',
  recipe = {
  {'', 'tech:motor', ''},
  {'', 'tech:machine_casing', ''},
  {'tech:components', 'tech:bronze_components', 'tech:components'},
  }
})
