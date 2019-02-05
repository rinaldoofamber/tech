local function dig_one_block(pos, player, groupcaps)
  if minetest.is_protected(pos, player:get_player_name()) then
    minetest.record_protection_violation(pos, player:get_player_name())
    return
  end
  local node=minetest.get_node(pos)
  local ok = false
  for k,v in pairs(groupcaps) do
    if minetest.get_node_group(node.name, k) >= v.maxlevel then
      ok = true
    end
  end
  if not ok then
    return
  end
  if node.name == "air" or node.name == "ignore" then return end
  if node.name == "default:lava_source" then return end
  if node.name == "default:lava_flowing" then return end
  if node.name == "default:water_source" then minetest.remove_node(pos) return end
  if node.name == "default:water_flowing" then minetest.remove_node(pos) return end
  minetest.node_dig(pos, node, player)
end

local function dig_it(pos, player, look, groupcaps)
  if look == "y" then
    dig_one_block(pos, player, groupcaps)
    pos.z = pos.z + 1
    dig_one_block(pos, player, groupcaps)
    pos.z = pos.z - 2
    dig_one_block(pos, player, groupcaps)
    pos.z = pos.z + 1
    pos.x = pos.x + 1
    dig_one_block(pos, player, groupcaps)
    pos.z = pos.z + 1
    dig_one_block(pos, player, groupcaps)
    pos.z = pos.z - 2
    dig_one_block(pos, player, groupcaps)
    pos.z = pos.z + 1
    pos.x = pos.x - 2
    dig_one_block(pos, player, groupcaps)
    pos.z = pos.z + 1
    dig_one_block(pos, player, groupcaps)
    pos.z = pos.z - 2
    dig_one_block(pos, player, groupcaps)
    return true
  end
  if look == "z" then
    dig_one_block(pos, player, groupcaps)
    pos.y = pos.y + 1
    dig_one_block(pos, player, groupcaps)
    pos.y = pos.y - 2
    dig_one_block(pos, player, groupcaps)
    pos.y = pos.y + 1
    pos.x = pos.x + 1
    dig_one_block(pos, player, groupcaps)
    pos.y = pos.y + 1
    dig_one_block(pos, player, groupcaps)
    pos.y = pos.y - 2
    dig_one_block(pos, player, groupcaps)
    pos.y = pos.y + 1
    pos.x = pos.x - 2
    dig_one_block(pos, player, groupcaps)
    pos.y = pos.y + 1
    dig_one_block(pos, player, groupcaps)
    pos.y = pos.y - 2
    dig_one_block(pos, player, groupcaps)
    return true
  end
  if look == "x" then
    dig_one_block(pos, player, groupcaps)
    pos.z = pos.z + 1
    dig_one_block(pos, player, groupcaps)
    pos.z = pos.z - 2
    dig_one_block(pos, player, groupcaps)
    pos.z = pos.z + 1
    pos.y = pos.y + 1
    dig_one_block(pos, player, groupcaps)
    pos.z = pos.z + 1
    dig_one_block(pos, player, groupcaps)
    pos.z = pos.z - 2
    dig_one_block(pos, player, groupcaps)
    pos.z = pos.z + 1
    pos.y = pos.y - 2
    dig_one_block(pos, player, groupcaps)
    pos.z = pos.z + 1
    dig_one_block(pos, player, groupcaps)
    pos.z = pos.z - 2
    dig_one_block(pos, player, groupcaps)
    return true
  end
  return false
end

local uses_num = 80
local damage_per_use = math.floor(65536 / uses_num)

local groupcaps={
  cracky = {times={[1]=4.00, [2]=1.60, [3]=1.0}, uses=20, maxlevel=3},
}

minetest.register_tool("tech:steel_hammer", {
  description = "Steel Hammer",
  inventory_image = "tech_steel_hammer.png",
  tool_capabilities = {
    full_punch_interval = 1.0,
    max_drop_level=1,
    damage_groups = {fleshy=4},
  },
  on_use = function(itemstack, user, pointed_thing)
    if pointed_thing.type ~= "node" then
		    return
    end
    local pos = pointed_thing.under
    if minetest.is_protected(pos, user:get_player_name()) then
      minetest.record_protection_violation(pos, user:get_player_name())
      return
    end
    local look = tech.player_look_side(user, pos)
    if dig_it(pos, user, look, groupcaps) then
      itemstack:set_wear(itemstack:get_wear() + damage_per_use)
    end
    return itemstack
  end,
})

minetest.register_craft({
  output = 'tech:steel_hammer 1', 
  recipe = {
  {'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
  {'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
  {'', 'group:wood', ''},
  }
})


