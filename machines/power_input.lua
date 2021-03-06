-- wire

minetest.register_node("tech:power_input", {
  description = "Power Input",
  tiles = {"tech_power_input.png",},
  groups = {cracky=3,snoopy=3,oddly_breakable_by_hand=2},
  on_construct = function(pos)
    tech.register_powered(pos, {
      capacity = 300,
    })
    --tech.register_wire(pos)
  end
})

tech.register_consumer("tech:power_input")

minetest.register_abm({
  nodenames = {"tech:power_input"},
  interval = 1,
  chance = 1,
  action = function(pos)
    local pows = {}
    pows[#pows+1] = tech.get_powered(pos)
    pos.y = pos.y + 1
    if tech.is_batbox(pos) then
      pows[#pows+1] = tech.get_powered(pos)
    end
    pos.y = pos.y - 2
    if tech.is_batbox(pos) then
      pows[#pows+1] = tech.get_powered(pos)
    end
    pos.y = pos.y + 1
    pos.x = pos.x + 1
    if tech.is_batbox(pos) then
      pows[#pows+1] = tech.get_powered(pos)
    end
    pos.x = pos.x - 2
    if tech.is_batbox(pos) then
      pows[#pows+1] = tech.get_powered(pos)
    end
    pos.x = pos.x + 1
    pos.z = pos.z + 1
    if tech.is_batbox(pos) then
      pows[#pows+1] = tech.get_powered(pos)
    end
    pos.z = pos.z - 2
    if tech.is_batbox(pos) then
      pows[#pows+1] = tech.get_powered(pos)
    end
    if #pows > 1 then
      local trans = math.min(pows[2]:get_capacity() - pows[2]:get_energy(), pows[1]:get_energy())
      pows[2]:set_energy(pows[2]:get_energy() + trans)
      pows[1]:set_energy(pows[1]:get_energy() - trans)
    end
  end,
})

minetest.register_craft({
  output = "tech:power_input",
  recipe = {
  {"", "tech:wire", "",},
  {"", "tech:wire", ""},
  {"", "", ""},
  }
})
