-- wire

minetest.register_node("tech:wire", {
  description = "Wire",
  tiles = {"tech_wire.png",},
  groups = {cracky=3,snoopy=3,oddly_breakable_by_hand=2},
  on_construct = function(pos)
    tech.register_powered(pos, {
      capacity = 200,
    })
    tech.register_wire(pos)
  end
})

minetest.register_abm({
  nodenames = {"tech:wire"},
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
})

minetest.register_craft({
  output = "tech:wire 9",
  recipe = {
  {"default:copper_ingot", "default:copper_ingot", "default:copper_ingot",},
  {"", "", ""},
  {"", "", ""},
  }
})