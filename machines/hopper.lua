-- hopper

local formspec = "size[8,9]"..
  default.gui_bg..
  default.gui_bg_img..
  "field[1,1;3,1;input;input;${tech_input}]"..
  "field[1,3;3,1;output;output;${tech_output}]"..
  "button_exit[1,5;1,1;button_exit;ok]"

minetest.register_node("tech:hopper", {
  description = "Hopper",
  tiles = {"tech_hopper_top.png",
    "tech_hopper_bottom.png",
    "tech_hopper_side.png",
    "tech_hopper_side.png",
    "tech_hopper_side.png",
    "tech_hopper_side.png"},
  groups = {cracky=2,},
  on_construct = function(pos)
    local meta = minetest.get_meta(pos)
    meta:set_string("tech_input", "main")
    meta:set_string("tech_output", "main")
    meta:set_string("formspec", formspec)
  end,
  on_receive_fields = function(pos, formname, fields, sender)
    local meta = minetest.get_meta(pos)
    --for k,v in pairs(fields) do
    --  minetest.chat_send_all(tostring(k) .. " " .. tostring(v))
    --end
    meta:set_string("tech_input", fields.input)
    meta:set_string("tech_output", fields.output)
  end
})

minetest.register_abm({
  nodenames = {"tech:hopper"},
  interval = 1,
  chance = 1,
  action = function(pos)
    local meta = minetest.get_meta(pos)
    local uplist = meta:get_string("tech_input")
    local downlist = meta:get_string("tech_output")
    pos.y = pos.y + 1
    local upinv = minetest.get_inventory({type = "node", pos = pos})
    pos.y = pos.y - 2
    local downinv = minetest.get_inventory({type = "node", pos = pos})
    if upinv ~= nil and downinv ~= nil then
      local upsize = upinv:get_size(uplist)
      local upstack, item
      local i = 1
      while true do
        upstack = upinv:get_stack(uplist, i)
        item = upstack:take_item(upstack:get_count())
        if not item:is_empty() then
          break
        end
        i = i + 1
        if i > upsize then
          return
        end
      end
      if downinv:room_for_item(downlist, item) then
        upinv:set_stack(uplist, i, upstack)
        downinv:add_item(downlist, item)
      end
    end
  end,
})

minetest.register_craft({
  output = 'tech:hopper 1', 
  recipe = {
  {'default:cobble', '', 'default:cobble'},
  {'default:cobble', '', 'default:cobble'},
  {'', 'default:cobble', ''},
  }
})