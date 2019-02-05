-- creative generator

minetest.register_node("tech:creative_generator", {
  description = "creative generator",
  tiles = {"tech_creative_generator.png",},
  groups = {cracky=3,snoopy=3,oddly_breakable_by_hand=2},
  on_construct = function(pos)
    tech.register_powered(pos, {
      capacity = 100,
    })
  end
})

tech.register_generator("tech:creative_generator")

minetest.register_abm({
  nodenames = {"tech:creative_generator"},
  interval = 1,
  chance = 1,
  action = function(pos)
    local selfpow = tech.get_powered(pos)
    selfpow:set_energy(100)
  end,
})