-- for debug purpuses
--local tm = 0

function tech.replace_lists_with_buttons(str)
    local result = ""
    local i = 1
    while i < #str do
        local res = string.find(str, "list", i)
        local fin = string.find(str, "]", res)
        if res then
            local list = string.sub(str, res, fin)
            local button = ""
            if string.find(list, "current_name") then
                local name = string.sub(list, string.find(list, ";") + 1, string.find(list, ";", string.find(list, ";") + 1) - 1)
                local j = #list
                while string.sub(list, j, j) ~= ";" do
                    j = j - 1
                end
                if string.find(string.sub(list, j, #list), ",") then
                  j = #list
                end
                local coord = string.sub(list, string.find(list, ";", string.find(list, ";") + 1) + 1, j - 1)
                button = "button[" .. coord .. ";" .. name .. ";]"
            end
            result = result .. string.sub(str, i, res-1) .. button
            i = fin + 1
        else
            break
        end
    end
    return result .. string.sub(str, i)
end

function tech.move_item(pos1, pos2)
 local inv = minetest.get_inventory({type = "node", pos = pos1})
 local toinv = minetest.get_inventory({type = "node", pos = pos2})
 if toinv ~= nil then
  local stack, item
  stack = inv:get_stack("conveyor", 1)
  item = stack:take_item(stack:get_count())
  if item:is_empty() then
   return
  end
  if toinv:room_for_item("conveyor", item) then
   inv:set_stack("conveyor", 1, stack)
   toinv:add_item("conveyor", item)
   tech.show_moving(pos1, pos2, item:get_name())
   --minetest.chat_send_all(""..(minetest.get_us_time() - tm))
   --tm = minetest.get_us_time()
  end
 end
end

function tech.show_moving(pos1, pos2, item)
 local image
 if minetest.registered_items[item] then
  image = minetest.registered_items[item].inventory_image
  if image == "" and minetest.registered_nodes[item] then
   image = minetest.registered_nodes[item].tiles[1]
  end
 end
 local direction = {x = pos2.x - pos1.x, y = pos2.y - pos1.y, z = pos2.z - pos1.z}
 local start = {x = pos1.x - direction.x / 2, y = pos1.y - direction.y / 2, z = pos1.z - direction.z / 2}
 minetest.add_particle({
  pos = start,
  velocity = direction,
  texture = image,
  glow = 0,
  size = 1,
  expirationtime = 1,
 })
end

local mesecons
if mesecon then
 mesecons = {effector = {
		action_on = function (pos, node)
		 local meta = minetest.get_meta(pos)
		 meta:set_int("tech_on", 0)
	 end,
	 action_off = function (pos, node)
		 local meta = minetest.get_meta(pos)
	  meta:set_int("tech_on", 1)
	 end,
	}}
end
function tech.register_conveyor(name, data)
 minetest.register_node(name, {
  description = data.description,
  tiles = data.tiles,
  paramtype = "light",
  drawtype = "nodebox",
  node_box = {
   type = "fixed",
   fixed = { -0.5, -0.5, -0.5, 0.5, -7/16, 0.5 },
  },
  paramtype2 = "facedir",
  is_ground_content = false,
  groups = {cracky = 3},
  sounds = data.sounds,
  on_construct = function(pos)
   local meta = minetest.get_meta(pos)
   meta:set_int("tech_on", 1)
   data.on_construct(pos)
  end,
  on_receive_fields = data.on_receive_fields,
  on_punch = data.on_punch,
  on_rightclick = data.on_rightclick,
  mesecons = tech.shutdownable,
  digiline = data.digiline,
  on_destruct = function(pos)
   local meta = minetest.get_meta(pos)
   local inv = meta:get_inventory()
   local itemstack = inv:get_stack("conveyor", 1)
   minetest.add_item(pos, itemstack)
  end,
 })
 minetest.register_abm({
  nodenames = {name},
  interval = 1,
  chance = 1,
  action = function(pos)
   local meta = minetest.get_meta(pos)
   if meta:get_int("tech_on") ~= 0 then
    data.on_timer(pos)
   end
  end,
 })
end


