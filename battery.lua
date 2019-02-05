local function doNothing(stack)
end

minetest.register_tool("tech:battery", {
  description = "Battery",
  inventory_image = "tech_battery.png",
})

tech.register_battery("tech:battery", 20000)

minetest.register_craft({
  output = 'tech:battery 1', 
  recipe = {
  {'', 'tech:wire', ''},
  {'', 'default:mese_crystal_fragment', ''},
  {'', 'default:mese_crystal_fragment', ''},
  }
})


minetest.register_tool("tech:diamond_battery", {
  description = "Diamond Battery",
  inventory_image = "tech_diamond_battery.png",
})

tech.register_battery("tech:diamond_battery", 10^6)

minetest.register_craft({
  output = 'tech:diamond_battery 1', 
  recipe = {
  {'', 'tech:energium_wire', ''},
  {'', 'default:diamond', ''},
  {'', 'default:diamond', ''},
  }
})
