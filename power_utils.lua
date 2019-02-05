-- wires

function tech.register_powered(pos, data)
  local meta = minetest.get_meta(pos)
  meta:set_string("tech_ispowered", "true")
  meta:set_int("tech_capacity", data.capacity)
  meta:set_int("tech_energy", 0)
end
function tech.get_powered(pos)
  local meta = minetest.get_meta(pos)
  if meta:get_string("tech_ispowered") ~= "true" then
    return nil
  end
  local result = {
    meta = minetest.get_meta(pos),
    get_energy = function(self)
      return self.meta:get_int("tech_energy")
    end,
    set_energy = function(self, value)
      if value > self.meta:get_int("tech_capacity") then
        value = self.meta:get_int("tech_capacity")
      end
      self.meta:set_int("tech_energy", value)
    end,
    get_capacity = function(self)
      return self.meta:get_int("tech_capacity")
    end,
  }
  return result
end
function tech.is_powered(pos)
 local meta = minetest.get_meta(pos)
 return (meta:get_string("tech_ispowered") == "true")
end

function tech.register_generator(name)
  minetest.register_abm({
    nodenames = {name},
    interval = 1,
    chance = 1,
    action = function(pos)
      local pows = {}
      pows[#pows+1] = tech.get_powered(pos)
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
      if #pows > 1 then
        local trans = math.min(pows[2]:get_capacity() - pows[2]:get_energy(), pows[1]:get_energy())
        pows[2]:set_energy(pows[2]:get_energy() + trans)
        pows[1]:set_energy(pows[1]:get_energy() - trans)
      end
    end,
  })
end

function tech.register_consumer(name)
  minetest.register_abm({
    nodenames = {name},
    interval = 1,
    chance = 1,
    action = function(pos)
      local pows = {}
      pows[#pows+1] = tech.get_powered(pos)
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
      if #pows > 1 then
        local trans = math.min(pows[1]:get_capacity() - pows[1]:get_energy(), pows[2]:get_energy())
        pows[2]:set_energy(pows[2]:get_energy() - trans)
        pows[1]:set_energy(pows[1]:get_energy() + trans)
      end
    end,
  })
end

tech.batboxes = {}
function tech.register_batbox(name)
  tech.batboxes[name] = true
end

function tech.is_batbox(pos)
  return tech.batboxes[minetest.get_node(pos).name]
end

function tech.register_wire(pos)
  local meta = minetest.get_meta(pos)
  meta:set_string("tech_iswire", "true")
end
function tech.is_wire(pos)
  local meta = minetest.get_meta(pos)
  if meta:get_string("tech_iswire") == "true" then
    return true
  end
  return false
end

-- chargable items

tech.batteries = {}
function tech.register_battery(name, capacity)
  tech.batteries[name] = capacity
end
function tech.get_battery(name)
  return tech.batteries[name]
end

function tech.chargable_wear(energy, capacity)
  local newcharge = 65536 - math.floor(energy / capacity * 65535)
  if newcharge < 1 then
    newcharge = 1
  end
  if newcharge > 65535 then
    newcharge = 0
  end
  return newcharge
end 

function tech.get_charge(itemstack)
 local tool_capacity = tech.get_battery(itemstack:get_name())
 if not tool_capacity then
  return
 end
 local tool_meta = minetest.deserialize(itemstack:get_metadata()) or {}
 if not tool_meta.energy then
  tool_meta.energy = 0
 end
 return tool_meta.energy
end

function tech.spend_charge(itemstack, spends)
 local tool_capacity = tech.get_battery(itemstack:get_name())
 if not tool_capacity then
  return
 end
 local tool_meta = minetest.deserialize(itemstack:get_metadata()) or {}
 if not tool_meta.energy then
  tool_meta.energy = 0
 end
 tool_meta.energy = math.max(tool_meta.energy - spends, 0)
 itemstack:set_metadata(minetest.serialize(tool_meta))
 itemstack:set_wear(tech.chargable_wear(tool_meta.energy, tool_capacity))
 return itemstack
end

function tech.charge_tool(selfpow, listname, inv, charge_per_second)
  local charge = inv:get_stack(listname, 1)
  if charge:is_empty() then
    return
  end
  local tool_capacity = tech.get_battery(charge:get_name())
  if not tool_capacity then
    return
  end
  local tool_meta = minetest.deserialize(charge:get_metadata()) or {}
  if not tool_meta.energy then
    tool_meta.energy = 0
  end
  local spend = math.min(charge_per_second, tool_capacity - tool_meta.energy)
  spend = math.min(selfpow:get_energy(), spend)
  tool_meta.energy = tool_meta.energy + spend
  charge:set_metadata(minetest.serialize(tool_meta))
  charge:set_wear(tech.chargable_wear(tool_meta.energy, tool_capacity))
  inv:set_stack(listname, 1, charge)
  selfpow:set_energy(selfpow:get_energy() - spend)
end

function tech.uncharge_tool(selfpow, listname, inv, charge_per_second)
  local uncharge = inv:get_stack(listname, 1)
  if uncharge:is_empty() then
    return
  end
  local tool_capacity = tech.get_battery(uncharge:get_name())
  if not tool_capacity then
    return
  end
  local tool_meta = minetest.deserialize(uncharge:get_metadata()) or {}
  if not tool_meta.energy then
    tool_meta.energy = 0
  end
  local spend = math.min(charge_per_second, tool_meta.energy)
  spend = math.min(selfpow:get_capacity() - selfpow:get_energy(), spend)
  tool_meta.energy = tool_meta.energy - spend
  uncharge:set_metadata(minetest.serialize(tool_meta))
  uncharge:set_wear(tech.chargable_wear(tool_meta.energy, tool_capacity))
  inv:set_stack(listname, 1, uncharge)
  selfpow:set_energy(selfpow:get_energy() + spend)
end
