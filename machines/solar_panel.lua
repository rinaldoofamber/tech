minetest.register_node("tech:solar_panel", {
  description = "Solar Panel",
  tiles = {"tech_solar_panel_top.png",
  "tech_powered_side.png",
  "tech_powered_side.png",
  "tech_powered_side.png",
  "tech_powered_side.png",
  "tech_powered_side.png",
  },
  groups = {cracky=3,snoopy=3,oddly_breakable_by_hand=2},
  on_construct = function(pos)
   tech.register_powered(pos, {
    capacity = 100,
   })
  end
})

tech.register_generator("tech:solar_panel")

local output = 10

minetest.register_abm({
 nodenames = {"tech:solar_panel"},
 interval = 1,
 chance = 1,
 action = function(pos)
  pos.y = pos.y + 1
  local light = minetest.get_node_light(pos)
  if light == 15 then
   pos.y = pos.y - 1
   local selfpow = tech.get_powered(pos)
   selfpow:set_energy(math.min(selfpow:get_energy() + output, selfpow:get_capacity()))
  end
 end,
})

minetest.register_craft({
  output = "tech:solar_panel",
  recipe = {
  {"default:glass", "default:glass", "default:glass",},
  {"default:coal_lump", "default:coal_lump", "default:coal_lump"},
  {"tech:microwires", "tech:microwires", "tech:microwires"},
  }
})


