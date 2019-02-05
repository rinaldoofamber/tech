minetest.register_node("tech:energium_power_output", {
  description = "Energium Power Output",
  tiles = {"tech_energium_power_output.png",},
  groups = {cracky=3,snoopy=3,oddly_breakable_by_hand=2},
  on_construct = function(pos)
    tech.register_powered(pos, {
      capacity = 5000,
    })
    --tech.register_wire(pos)
  end
})

tech.register_generator("tech:energium_power_output")

minetest.register_abm({
  nodenames = {"tech:energium_power_output"},
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
      local trans = math.min(pows[1]:get_capacity() - pows[1]:get_energy(), pows[2]:get_energy())
      pows[2]:set_energy(pows[2]:get_energy() - trans)
      pows[1]:set_energy(pows[1]:get_energy() + trans)
    end
  end,
})

minetest.register_craft({
 type = "shapeless",
 output = "tech:energium_power_output",
 recipe = {"tech:energium_wire",
  "tech:gold_power_output",},
})
