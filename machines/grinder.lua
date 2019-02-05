-- grinder

-- how many times we have to click on it
local grinder_progress = 30

minetest.register_node("tech:grinder", {
  description = "Grinder",
  tiles = {"tech_grinder_side.png",
    "tech_grinder_side.png",
    "tech_grinder_side.png",
    "tech_grinder_side.png",
    "tech_grinder_side.png",
    "tech_grinder_front.png"},
  groups = {cracky=2,},
  on_construct = function(pos)
    tech.register_processer(pos, {
      start_progress = 0,
      total_progress = grinder_progress
    })
  end,
  on_rightclick = function(pos, node, player, itemstack, pointed_thing)
    tech.play_sound(pos, "tech_grinder", 6)
    local proc = tech.get_processer(pos)
    if proc:get_progress() + 1 < grinder_progress then
      proc:set_progress(proc:get_progress() + 1)
      return
    end
    proc:set_progress(0)
    pos.y = pos.y + 1
    local upinv = minetest.get_inventory({type = "node", pos = pos})
    pos.y = pos.y - 2
    local downinv = minetest.get_inventory({type = "node", pos = pos})
    if upinv ~= nil and downinv ~= nil then
      local upsize = upinv:get_size("main")
      local i = 1
      local upstack = nil
      local item = nil
      while true do
        upstack = upinv:get_stack("main", i)
        item = upstack:take_item(1)
        if not item:is_empty() then
          break
        end
        i = i + 1
        if i > upsize then
          return
        end
      end
      local res = tech.get_craft({type = "grind", recipe = item:get_name()})
      if res then
        item = ItemStack(res.output)
      end
      upinv:set_stack("main", i, upstack)
      downinv:add_item("main", item)
    end
  end
})

minetest.register_craft({
  output = 'tech:grinder 1', 
  recipe = {
  {'default:cobble', 'default:steel_ingot', 'default:cobble'},
  {'default:cobble', 'default:steel_ingot', 'default:cobble'},
  {'default:cobble', 'default:cobble', 'default:cobble'},
  }
})
