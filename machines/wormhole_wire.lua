-- A wire, which allows to transmit energy through a wormhole

local formspec = "size[8,9]"..
  default.gui_bg..
  default.gui_bg_img..
  "field[1,1;3,1;network_name;network_name;]"..
  "button_exit[1,5;1,1;button_exit;ok]"

local function get_far_node(pos)
	local node = minetest.get_node(pos)
	local meta = minetest.get_meta(pos)
	if node.name == "ignore" then
		minetest.get_voxel_manip():read_from_map(pos, pos)
		node = minetest.get_node(pos)
		minetest.get_meta(pos)
	end
	return node, meta
end

tech.registered_wormhole_wires = {}-- [network_name][pos] = true/nil where pos = pos.x .. " " .. pos.y .. " " ..pos.z

minetest.register_node("tech:wormhole_wire", {
 description = "Wormhole Wire",
 tiles = {"tech_wormhole_wire.png",},
 groups = {cracky=3,snoopy=3,oddly_breakable_by_hand=2},
 on_construct = function(pos)
  tech.register_powered(pos, {
   capacity = 1000,
  })
  tech.register_wire(pos)
 end,
 formspec = formspec,
 on_receive_fields = function(pos, formname, fields, sender)
  local meta = minetest.get_meta(pos)
  local network_name = fields.network_name or ""
  local old_network_name = meta:get_string("tech_network_name")
  if old_network_name ~= "" then
   tech.registered_wormhole_wires[old_network_name][pos.x .. " " .. pos.y .. " " ..pos.z] = nil
  end
  if network_name ~= "" then
   
  end
  meta:set_string("tech_network_name", network_name)
 end,
})

minetest.register_lbm({
 name = "tech:load_wormhole_wire",
 nodenames = {"tech:wormhole_wire"},
 action = function(pos, node)
  
 end,
})

--[[ minetest.register_abm({
  nodenames = {"tech:wormhole_wire"},
  interval = 1,
  chance = 1,
  action = function(pos)
    local pows = {}
    if tech.is_wire(pos) then
      pows[#pows+1] = tech.get_powered(pos)
    end
    pos.y = pos.y + 1
    if tech.is_wire(pos) then
      pows[#pows+1] = tech.get_powered(pos)
    end
    pos.y = pos.y - 2
    if tech.is_wire(pos) then
      pows[#pows+1] = tech.get_powered(pos)
    end
    pos.y = pos.y + 1
    pos.x = pos.x + 1
    if tech.is_wire(pos) then
      pows[#pows+1] = tech.get_powered(pos)
    end
    pos.x = pos.x - 2
    if tech.is_wire(pos) then
      pows[#pows+1] = tech.get_powered(pos)
    end
    pos.x = pos.x + 1
    pos.z = pos.z + 1
    if tech.is_wire(pos) then
      pows[#pows+1] = tech.get_powered(pos)
    end
    pos.z = pos.z - 2
    if tech.is_wire(pos) then
      pows[#pows+1] = tech.get_powered(pos)
    end
    local total_energy = 0
    local total_capacity = 0
    local i, v
    for i,v in ipairs(pows) do
      total_energy = total_energy + v:get_energy()
      total_capacity = total_capacity + v:get_capacity()
    end
    local trans = 0
    for i = 2,#pows,1 do
      v = pows[i]
      local transone = math.floor(v:get_capacity() * total_energy / total_capacity)
      trans = trans + transone
      v:set_energy(transone)
    end
    pows[1]:set_energy(total_energy - trans)
  end,
}) --]]

minetest.register_craft({
  output = "tech:wormhole_wire 12",
  recipe = {
  {"default:gold_wire", "pocket_dimension:ender_pearl", "default:gold_wire",},
  {"", "", ""},
  {"", "", ""},
  }
})
