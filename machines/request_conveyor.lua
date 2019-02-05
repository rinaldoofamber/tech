if digilines then

  local on_digiline_receive = function (pos, _, channel, msg)
	  local setchan = minetest.get_meta(pos):get_string("channel")
	  if channel == setchan then
	    if string.sub(msg, 1, 8) == "channel=" then
	      minetest.get_meta(pos):set_string("channel", string.sub(msg, 9, #msg))
	      --digilines.receptor_send(pos, digilines.rules.default, channel, "channel successfully changed")
	      return
	    end
		  local dir = minetest.get_node(pos).param2
      local meta = minetest.get_meta(pos)
      local pos2 = {x = pos.x, y = pos.y, z = pos.z}
      local pos1 = {x = pos.x, y = pos.y, z = pos.z}
      local inv = minetest.get_inventory({type = "node", pos = pos})
      if dir == 0 then
        pos.z = pos.z - 1
        pos2.z = pos.z + 2
      elseif dir == 1 then
        pos.x = pos.x - 1
        pos2.x = pos.x + 2
      elseif dir == 2 then
        pos.z = pos.z + 1
        pos2.z = pos.z - 2
      elseif dir == 3 then
        pos.x = pos.x + 1
        pos2.x = pos.x - 2
      end
      local fromlist = meta:get_string("tech_input")
      local toinv = minetest.get_inventory({type = "node", pos = pos})
      local frominv = minetest.get_inventory({type = "node", pos = pos2})
      if frominv then
        local item = ItemStack(msg)
        if not frominv:contains_item(fromlist, item) then
          --print("no item")
          --digilines.receptor_send(pos, digilines.rules.default, channel, "ERROR : no item " .. item:to_string())
          return
        end
        if inv:room_for_item("conveyor", item) then
          item = frominv:remove_item(fromlist, item)
          inv:add_item("conveyor", item)
          tech.show_moving(pos1, pos, item:get_name())
          --digilines.receptor_send(pos, digilines.rules.default, channel, "item successfully taken")
        else
          --digilines.receptor_send(pos, digilines.rules.default, channel, "ERROR : the conveyor is busy")
        end
      end
	  end
  end

  tech.register_conveyor("tech:request_conveyor", {
    description = "Request Conveyor",
      tiles = {"tech_request_conveyor.png",
      "default_steel_block.png",
      "default_steel_block.png",
      "default_steel_block.png",
      "default_steel_block.png",
      "default_steel_block.png"},
    digiline =
	  {
		  receptor = {},
		  effector = {
			  action = on_digiline_receive
		  },
	  },
    on_construct = function(pos)
      local meta = minetest.get_meta(pos)
      local inv = meta:get_inventory()
      inv:set_size("conveyor", 1)
      meta:set_string("tech_input", "main")
      meta:set_string("formspec", "main")
      meta:set_string("channel", "setchan")
    end,
    on_receive_fields = function(pos, formname, fields, sender)
      local meta = minetest.get_meta(pos)
      for k, v in pairs(fields) do
        if k ~= "quit" then
          meta:set_string("tech_input", k)
        end
      end
    end,
    on_timer = function(pos)
      local dir = minetest.get_node(pos).param2
      local meta = minetest.get_meta(pos)
      local pos2 = {x = pos.x, y = pos.y, z = pos.z}
      local pos1 = {x = pos.x, y = pos.y, z = pos.z}
      local inv = minetest.get_inventory({type = "node", pos = pos})
      if dir == 0 then
        pos.z = pos.z - 1
        pos2.z = pos.z + 2
      elseif dir == 1 then
        pos.x = pos.x - 1
        pos2.x = pos.x + 2
      elseif dir == 2 then
        pos.z = pos.z + 1
        pos2.z = pos.z - 2
      elseif dir == 3 then
        pos.x = pos.x + 1
        pos2.x = pos.x - 2
      end
      local toinv = minetest.get_inventory({type = "node", pos = pos})
      if toinv then
        local stack, item
        stack = inv:get_stack("conveyor", 1)
        item = stack:take_item(stack:get_count())
        if item:is_empty() then
          return
        end
        if toinv:room_for_item("conveyor", item) then
          inv:set_stack("conveyor", 1, stack)
          toinv:add_item("conveyor", item)
        end
      end
    end,
    on_rightclick = function(pos, node, player, itemstack, pointed_thing)
      local dir = minetest.get_node(pos).param2
      local meta = minetest.get_meta(pos)
      local pos2 = {x = pos.x, y = pos.y, z = pos.z}
      if dir == 0 then
        pos2.z = pos.z + 1
      elseif dir == 1 then
        pos2.x = pos.x + 1
      elseif dir == 2 then
        pos2.z = pos.z - 1
      elseif dir == 3 then
        pos2.x = pos.x - 1
      end
      local from = minetest.get_meta(pos2)
      local formspec = from:get_string("formspec")
      if #formspec == 0 then
        meta:set_string("formspec", "")
        meta:set_string("tech_input", "main")
      else
        meta:set_string("formspec", tech.replace_lists_with_buttons(formspec))
      end
    end,
  })

  minetest.register_craft({
    output = 'tech:request_conveyor 1', 
    recipe = {
    {'', '', ''},
    {'', 'tech:conveyor', ''},
    {'', 'digilines:wire_std_00000000', ''},
    }
  })

end
