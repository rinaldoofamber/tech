-- fuel

minetest.register_craft({
  type = "fuel",
  recipe = "tech:lava_cell",
  burntime = 60
})

minetest.register_craft({
  type = "fuel",
  recipe = "tech:biofuel_cell",
  burntime = 80
})

minetest.register_craft({
  type = "fuel",
  recipe = "tech:coke_coal",
  burntime = 80
})

-- furnace

-- charcoal analogy
minetest.register_craft({
  type = "cooking",
  recipe = "group:tree",
  output = "default:coal_lump",
})

minetest.register_craft({
  type = "cooking",
  recipe = "tech:steel_dust",
  output = "default:steel_ingot",
})

minetest.register_craft({
  type = "cooking",
  recipe = "tech:gold_dust",
  output = "default:gold_ingot",
})

minetest.register_craft({
  type = "cooking",
  recipe = "tech:tin_dust",
  output = "default:tin_ingot",
})

minetest.register_craft({
  type = "cooking",
  recipe = "tech:copper_dust",
  output = "default:copper_ingot",
})

minetest.register_craft({
  type = "cooking",
  recipe = "tech:energium_dust",
  output = "tech:energium_ingot",
})

minetest.register_craft({
  type = "cooking",
  recipe = "tech:mese_dust",
  output = "default:mese_crystal",
})

minetest.register_craft({
  type = "cooking",
  recipe = "tech:silver_dust",
  output = "sorcery:silver_ingot",
})

-- crafts

minetest.register_craft({
  output = "tech:machine_casing 1",
  recipe = {
    {"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
    {"default:steel_ingot", "", "default:steel_ingot"},
    {"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"}
  }
})

minetest.register_craft({
  output = "tech:power_collector 1",
  recipe = {
    {"default:tin_ingot", "tech:wire", ""},
    {"", "", ""},
    {"", "", ""}
  }
})

minetest.register_craft({
  output = "tech:motor 1",
  recipe = {
    {"default:copper_ingot", "tech:wire", ""},
    {"", "", ""},
    {"", "", ""}
  }
})

minetest.register_craft({
  output = "tech:cell 16",
  recipe = {
    {"", "default:glass", ""},
    {"default:glass", "", "default:glass"},
    {"", "default:glass", ""}
  }
})

minetest.register_craft({
  type = "shapeless",
  output = "tech:lava_cell",
  recipe = {"bucket:bucket_lava",
  "tech:cell",
  },
  replacements = {
    {"bucket:bucket_lava", "bucket:bucket_empty"}
  }
})

minetest.register_craft({
  type = "shapeless",
  output = "tech:water_cell",
  recipe = {"bucket:bucket_water",
  "tech:cell",
  },
  replacements = {
   {"bucket:bucket_water", "bucket:bucket_empty"}
  }
})

minetest.register_craft({
 output = "tech:advanced_machine_casing 1",
 recipe = {
  {"", "tech:microwires", ""},
  {"tech:components", "tech:machine_casing", "tech:components"},
  {"", "tech:microwires", ""}
 },
})

minetest.register_craft({
 output = "tech:heating_coil 1",
 recipe = {
  {"", "tech:wire", ""},
  {"tech:wire", "", "tech:wire"},
  {"", "tech:wire", ""}
 },
})

minetest.register_craft({
 output = "tech:cog 5",
 recipe = {
  {"", "default:steel_ingot", ""},
  {"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
  {"", "default:steel_ingot", ""}
 },
})

minetest.register_craft({
 output = "tech:laser 1",
 recipe = {
  {"", "tech:components", "tech:components"},
  {"tech:microwires", "default:diamond", "default:diamond"},
  {"", "tech:components", "tech:components"}
 },
})

minetest.register_craft({
  output = "default:torch 8",
  recipe = {
    {"", "", ""},
    {"", "tech:coke_coal", ""},
    {"", "default:stick", ""}
  }
})

minetest.register_craft({
  type = "shapeless",
  output = "tech:energium_dust",
  recipe = {"tech:gold_dust",
  "tech:gold_dust",
  "tech:mese_dust",
  },
})

-- grinder

tech.register_craft({
  type = "grind",
  recipe = "default:iron_lump",
  output = "tech:steel_dust 2",
})

tech.register_craft({
  type = "grind",
  recipe = "default:gold_lump",
  output = "tech:gold_dust 2",
})

tech.register_craft({
  type = "grind",
  recipe = "default:tin_lump",
  output = "tech:tin_dust 2",
})

tech.register_craft({
  type = "grind",
  recipe = "default:copper_lump",
  output = "tech:copper_dust 2",
})

tech.register_craft({
  type = "grind",
  recipe = "default:steel_ingot",
  output = "tech:steel_dust",
})

tech.register_craft({
  type = "grind",
  recipe = "default:gold_ingot",
  output = "tech:gold_dust",
})

tech.register_craft({
  type = "grind",
  recipe = "default:tin_ingot",
  output = "tech:tin_dust",
})

tech.register_craft({
  type = "grind",
  recipe = "default:copper_ingot",
  output = "tech:copper_dust",
})

tech.register_craft({
  type = "grind",
  recipe = "tech:energium_ingot",
  output = "tech:energium_dust",
})

tech.register_craft({
  type = "grind",
  recipe = "default:cobble",
  output = "default:gravel",
})

tech.register_craft({
  type = "grind",
  recipe = "default:gravel",
  output = "default:sand",
})

tech.register_craft({
  type = "grind",
  recipe = "default:mese_crystal",
  output = "tech:mese_dust",
})

tech.register_craft({
  type = "grind",
  recipe = "default:ice",
  output = "default:snowblock",
})

tech.register_craft({
  type = "grind",
  recipe = "sorcery:silver_lump",
  output = "tech:silver_dust 2",
})

tech.register_craft({
  type = "grind",
  recipe = "sorcery:silver_ingot",
  output = "tech:silver_dust",
})

tech.register_craft({
  type = "grind",
  recipe = "farming:wheat",
  output = "farming:flour",
})

-- shaper

tech.register_craft({
  type = "shape",
  recipe = "default:steel_ingot",
  output = "tech:components",
})

tech.register_craft({
  type = "shape",
  recipe = "default:copper_ingot",
  output = "tech:microwires",
})

tech.register_craft({
  type = "shape",
  recipe = "default:bronze_ingot",
  output = "tech:bronze_components",
})

tech.register_craft({
  type = "shape",
  recipe = "default:tin_ingot",
  output = "tech:microtubes",
})

tech.register_craft({
  type = "shape",
  recipe = "default:mese_crystal",
  output = "tech:micromesas 4",
})

-- freeze

tech.register_craft({
  type = "freeze",
  recipe = "tech:lava_cell",
  output = "default:obsidian",
})

tech.register_craft({
  type = "freeze",
  recipe = "tech:water_cell",
  output = "default:ice",
})

-- compose

tech.register_craft({
  type = "decompose",
  recipe = "group:leaves",
  recipe_count = 1,
  output = "tech:compost",
})

tech.register_craft({
  type = "decompose",
  recipe = "farming:wheat",
  recipe_count = 1,
  output = "tech:compost",
})

tech.register_craft({
  type = "decompose",
  recipe = "farming:cotton",
  recipe_count = 1,
  output = "tech:compost",
})

-- sqeeze

tech.register_craft({
  type = "sqeeze",
  recipe = "tech:compost",
  output = "tech:biomix_cell",
})

tech.register_craft({
  type = "sqeeze",
  recipe = "default:apple",
  output = "tech:apple_juice_cell",
})

-- centrifuge

tech.register_craft({
  type = "centrifuge",
  recipe = "tech:biomix_cell",
  recipe_count = 8,
  cells = -7,
  output = {{"tech:biofuel_cell", 1}},
})

tech.register_craft({
  type = "centrifuge",
  recipe = "tech:iron_mix_cell",
  recipe_count = 1,
  cells = -1,
  output = {{"tech:steel_dust", 1}},
})

tech.register_craft({
  type = "centrifuge",
  recipe = "tech:gold_mix_cell",
  recipe_count = 1,
  cells = -1,
  output = {{"tech:gold_dust", 1}},
})

tech.register_craft({
  type = "centrifuge",
  recipe = "tech:tin_mix_cell",
  recipe_count = 1,
  cells = -1,
  output = {{"tech:tin_dust", 1}},
})

tech.register_craft({
  type = "centrifuge",
  recipe = "tech:copper_mix_cell",
  recipe_count = 1,
  cells = -1,
  output = {{"tech:copper_dust", 1}},
})

tech.register_craft({
  type = "centrifuge",
  recipe = "tech:silver_mix_cell",
  recipe_count = 1,
  cells = -1,
  output = {{"tech:silver_dust", 1}},
})

tech.register_craft({
  type = "centrifuge",
  recipe = "group:sand",
  recipe_count = 1,
  cells = 0,
  output = {{"default:clay_lump", 0.25}},
})

tech.register_craft({
  type = "centrifuge",
  recipe = "default:leaves",
  recipe_count = 1,
  cells = 0,
  output = {{"default:sapling", 0.05}},
})

tech.register_craft({
  type = "centrifuge",
  recipe = "default:jungleleaves",
  recipe_count = 1,
  cells = 0,
  output = {{"default:junglesapling", 0.05}},
})

tech.register_craft({
  type = "centrifuge",
  recipe = "default:pine_needles",
  recipe_count = 1,
  cells = 0,
  output = {{"default:pine_sapling", 0.05}},
})

tech.register_craft({
  type = "centrifuge",
  recipe = "default:acacia_leaves",
  recipe_count = 1,
  cells = 0,
  output = {{"default:acacia_sapling", 0.05}},
})

tech.register_craft({
  type = "centrifuge",
  recipe = "default:aspen_leaves",
  recipe_count = 1,
  cells = 0,
  output = {{"default:aspen_sapling", 0.05}},
})

-- purify

tech.register_craft({
  type = "purify",
  recipe = "default:iron_lump",
  output = "tech:iron_mix_cell 3",
  cells = 3,
})

tech.register_craft({
  type = "purify",
  recipe = "default:gold_lump",
  output = "tech:gold_mix_cell 3",
  cells = 3,
})

tech.register_craft({
  type = "purify",
  recipe = "default:tin_lump",
  output = "tech:tin_mix_cell 3",
  cells = 3,
})

tech.register_craft({
  type = "purify",
  recipe = "default:copper_lump",
  output = "tech:copper_mix_cell 3",
  cells = 3,
})

tech.register_craft({
  type = "purify",
  recipe = "sorcery:silver_lump",
  output = "tech:silver_mix_cell 3",
  cells = 3,
})

tech.register_craft({
  type = "purify",
  recipe = "tech:rich_iron",
  output = "tech:iron_mix_cell 1",
  cells = 1,
})

tech.register_craft({
  type = "purify",
  recipe = "tech:rich_gold",
  output = "tech:gold_mix_cell 1",
  cells = 1,
})

tech.register_craft({
  type = "purify",
  recipe = "tech:rich_tin",
  output = "tech:tin_mix_cell 1",
  cells = 1,
})

tech.register_craft({
  type = "purify",
  recipe = "tech:rich_copper",
  output = "tech:copper_mix_cell 1",
  cells = 1,
})

tech.register_craft({
  type = "purify",
  recipe = "tech:rich_silver",
  output = "tech:silver_mix_cell 1",
  cells = 1,
})

-- coke oven

tech.register_craft({
  type = "coke",
  recipe = "default:coal_lump",
  output = "tech:coke_coal"
})

tech.register_craft({
  type = "coke",
  recipe = "group:tree",
  output = "default:coal_lump"
})

-- enrich

tech.register_craft({
  type = "enrich",
  recipe = "default:iron_lump",
  output = "tech:rich_iron 5",
})

tech.register_craft({
  type = "enrich",
  recipe = "default:gold_lump",
  output = "tech:rich_gold 5",
})

tech.register_craft({
  type = "enrich",
  recipe = "default:tin_lump",
  output = "tech:rich_tin 5",
})

tech.register_craft({
  type = "enrich",
  recipe = "default:copper_lump",
  output = "tech:rich_copper 5",
})

tech.register_craft({
  type = "enrich",
  recipe = "sorcery:silver_lump",
  output = "tech:rich_silver 5",
})
