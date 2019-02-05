minetest.register_tool("tech:multimeter", {
  description = "Multimeter",
  inventory_image = "tech_multimeter.png",
  on_use = function(itemstack, user, pointed_thing)
    if pointed_thing.type ~= "node" then
		    return
    end
    local pos = pointed_thing.under
    if minetest.is_protected(pos, user:get_player_name()) then
      minetest.record_protection_violation(pos, user:get_player_name())
      return
    end
    local nodepow = tech.get_powered(pos)
    local meta = minetest.get_meta(pos)
    local node = minetest.get_node(pos)
    if user:is_player() then
      --minetest.chat_send_player(user:get_player_name(), node.name .. " " .. meta:get_int("tech_on"))
      if nodepow == nil then
        return
      end
      minetest.chat_send_player(user:get_player_name(), tostring(nodepow:get_energy()) .. " / " .. tostring(nodepow:get_capacity()))
    end
  end,

})

minetest.register_craft({
  output = 'tech:multimeter 1', 
  recipe = {
  {'tech:wire', '', 'tech:wire'},
  {'default:steel_ingot', 'default:tin_ingot', 'default:steel_ingot'},
  {'', '', ''},
  }
})

if mobs then
-- laser gun
  local damage_per_shoot = 10
  local spends_per_shoot = 500
  local range = 40
  local arrow_velocity = 16

  local hit = function(self, player)
	  player:punch(self.object, 1.0, {
		  full_punch_interval = 1.0,
   	damage_groups = {fleshy = damage_per_shoot},
	  }, nil)
	  --local pvel = player:getvelocity()
	  --local avel = self.object:getvelocity()
	  --pvel = {x = pvel.x + avel.x, y = pvel.y + avel.y, z = pvel.z + avel.z}
	  --player:setvelocity(pvel)
  end

  mobs:register_arrow("tech:laser_gun_ray", {
	  visual = "sprite",
  --	visual = "wielditem",
	  visual_size = {x = 0.5, y = 0.5},
	  textures = {"tech_laser_gun_ray.png"},
	  --textures = {"default:mese_crystal_fragment"},
	  velocity = 16,
  --	rotate = 180,

	  hit_player = hit,

	  hit_mob = hit,

	  hit_node = function(self, pos, node)
	  end
  })

  minetest.register_tool("tech:laser_gun", {
   description = "Laser Gun",
   inventory_image = "tech_laser_gun.png",
   range = range,
   on_use = function(itemstack, user, pointed_thing)
    if not user:is_player() then
     return
    end
    if tech.get_charge(itemstack) < spends_per_shoot then
     return
    end
    local tgpos
    if pointed_thing.type == "node" then
     tgpos = pointed_thing.under
    elseif pointed_thing.type == "object" then
     tgpos = pointed_thing.ref:getpos()
    else
     return
    end
    local ppos = user:getpos()
    ppos = {x = ppos.x, y = ppos.y + 1.5, z = ppos.z}
    local dir = {x = tgpos.x - ppos.x, y = tgpos.y - ppos.y, z = tgpos.z - ppos.z}
    dirlen = math.sqrt(dir.x ^ 2 + dir.y ^ 2 + dir.z ^ 2)
    if dirlen > range then
     return
    end
    dir = {x = dir.x / dirlen, y = dir.y / dirlen, z = dir.z / dirlen}
    local obj = minetest.add_entity({x = ppos.x + dir.x * 2.5, y = ppos.y + dir.y, z = ppos.z + dir.z * 2.5}, "tech:laser_gun_ray")
    local ent = obj:get_luaentity()
    if ent then
     -- without next line code doesn't work
     ent.switch = 1 -- for mob specific arrows
     ent.owner_id = tostring(user.object) -- so arrows dont hurt entity you are riding
     local vec = {x = dir.x * arrow_velocity, y = dir.y * arrow_velocity, z = dir.z * arrow_velocity}
     local yaw = user:get_look_horizontal()
     obj:setyaw(yaw + math.pi / 2)
     obj:setvelocity(vec)
    else
     obj:remove()
    end
    tech.spend_charge(itemstack, spends_per_shoot)
    return itemstack
   end,
  })

  tech.register_battery("tech:laser_gun", 2*10^6)

  minetest.register_craft({
   output = 'tech:laser_gun 1', 
   recipe = {
    {'', '', ''},
    {'tech:diamond_battery', 'tech:diamond_battery', 'tech:laser'},
    {'tech:components', '', ''},
   }
  })

end

