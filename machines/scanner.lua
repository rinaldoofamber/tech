-- command structure :
-- { type = <node/item> property = <name/a_scannable_meta_property for nodes, name/count/a_scannable_meta_property for items> list = <inv list name> stack = <inv stack number> }

tech.registered_scans = {}
function tech.register_scan_function(name, func)
  tech.registered_scans[name] = func
end

tech.register_scan_function("energy", function(msg, scanpos)
  if msg.type == "node" then
    local pow = tech.get_powered(scanpos)
    if pow then
      return pow:get_energy()
    else
      return "ERROR"
    end
  elseif msg.type == "item" and type(msg.list) == "string" and type(msg.stack) == "number" then
    local inv = minetest.get_meta(scanpos):get_inventory()
    local stack = inv:get_stack(msg.list, msg.stack)
    return tech.get_charge(stack) or "ERROR"
  else
    return "ERROR"
  end
end)

tech.register_scan_function("capacity", function(msg, scanpos)
  if msg.type == "node" then
    local pow = tech.get_powered(scanpos)
    if pow then
      return pow:get_capacity()
    else
      return "ERROR"
    end
  elseif msg.type == "item" and type(msg.list) == "string" and type(msg.stack) == "number" then
    local inv = minetest.get_meta(scanpos):get_inventory()
    local stack = inv:get_stack(msg.list, msg.stack)
    return tech.get_battery(stack:get_name()) or "ERROR"
  else
    return "ERROR"
  end
end)

if digilines then

  local on_digiline_receive = function (pos, _, channel, msg)
	  local setchan = minetest.get_meta(pos):get_string("channel")
	  if channel == setchan and type(msg) == "table" then
		  --local timeofday = minetest.get_timeofday()
		  local dir = minetest.get_node(pos).param2
		  local scanpos = {x = pos.x, y = pos.y, z = pos.z}
		  if dir == 0 then
        scanpos.z = pos.z - 1
      elseif dir == 1 then
        scanpos.x = pos.x - 1
      elseif dir == 2 then
        scanpos.z = pos.z + 1
      elseif dir == 3 then
        scanpos.x = pos.x + 1
      end
      --print(msg.type)
      
      local response = "ERROR"
      if msg.type == "node" then
        if msg.property == "name" then
          response = minetest.get_node(scanpos).name
        end
      elseif msg.type == "item" and type(msg.list) == "string" and type(msg.stack) == "number" then
        local inv = minetest.get_meta(scanpos):get_inventory()
        local stack = inv:get_stack(msg.list, msg.stack)
        if msg.property == "name" then
          response = stack:get_name()
        elseif msg.property == "count" then
          response = stack:get_count()
        elseif msg.property == "wear" then
          response = (stack:get_wear() or 0) / 65536
        elseif msg.property == "itemstring" then
          response = stack:to_string()
        end
      end
      if tech.registered_scans[msg.property] then
        response = tech.registered_scans[msg.property](msg, scanpos)
      end
		  digilines.receptor_send(pos, digilines.rules.default, channel, response)
	  end
  end

  minetest.register_node("tech:scanner", {
	  description = "Scanner",
	  tiles = {"tech_not_powered_side.png",
	    "tech_not_powered_side.png",
	    "tech_not_powered_side.png",
	    "tech_not_powered_side.png",
	    "tech_not_powered_side.png",
	    "tech_scanner_front.png",
	  },
	  paramtype = "light",
	  paramtype2 = "facedir",
	  groups = {dig_immediate=2},
	  digiline =
	  {
		  receptor = {},
		  effector = {
			  action = on_digiline_receive
		  },
	  },
	  on_construct = function(pos)
		  local meta = minetest.get_meta(pos)
		  meta:set_string("formspec", "field[channel;Channel;${channel}]")
	  end,
	  on_receive_fields = function(pos, _, fields, sender)
		  local name = sender:get_player_name()
		  if minetest.is_protected(pos, name) and not minetest.check_player_privs(name, {protection_bypass=true}) then
			  minetest.record_protection_violation(pos, name)
			  return
		  end
		  if (fields.channel) then
			  minetest.get_meta(pos):set_string("channel", fields.channel)
		  end
	  end,
  })
  
  minetest.register_craft({
    output = "tech:scanner",
    recipe = {
    {"", "", ""},
    {"tech:micromesas", "tech:components", "digilines:wire_std_00000000"},
    {"", "", ""},
    }
  })
end
