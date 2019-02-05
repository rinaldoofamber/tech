local max_queue_len = 4

if digilines then

  tech.wireless_digiline_queue = {}

  function tech.wireless_digiline_post(frequency, msg)
    if not tech.wireless_digiline_queue[frequency] then
      tech.wireless_digiline_queue[frequency] = {}
    end
    table.insert(tech.wireless_digiline_queue[frequency], msg)
    if #tech.wireless_digiline_queue[frequency] > max_queue_len then
      table.remove(tech.wireless_digiline_queue[frequency], 1)
    end
    --for i, v in ipairs(tech.wireless_digiline_queue[frequency]) do
    --  print(i, v)
    --end
  end

  function tech.wireless_digiline_pop(frequency)
    local queue = tech.wireless_digiline_queue[frequency] or {}
    --print("fq", frequency, "len", #queue)
    if #queue > 0 then
      local msg = queue[1]
      --print("msg", msg)
      table.remove(queue, 1)
      --print("newlen", #queue)
      return msg
    end
  end

  minetest.register_node("tech:digiline_wireless_reciever", {
	  description = "Digiline Wireless Reciever",
	  tiles = {"tech_digiline_wireless_reciever.png"},

	  groups = {dig_immediate=2},
	  digiline =
	  {
		  receptor = {},
		  effector = {
			  action = function() end
		  },
	  },
	  on_construct = function(pos)
		  local meta = minetest.get_meta(pos)
		  meta:set_string("formspec", "field[channel;Channel;${channel}]field[frequency;Frequency;${frequency}]")
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
		  if fields.frequency then
		    minetest.get_meta(pos):set_string("frequency", fields.frequency)
		  end
	  end,
  })

  local function on_timer(pos)
    local channel = minetest.get_meta(pos):get_string("channel")
    local frequency = minetest.get_meta(pos):get_string("frequency")
    local msg = tech.wireless_digiline_pop(frequency)
    if msg then
      digilines.receptor_send(pos, digilines.rules.default, channel, msg)
    end
  end

  minetest.register_abm({
    nodenames = {"tech:digiline_wireless_reciever"},
    interval = 1,
    chance = 1,
    action = on_timer,
  })
  
  minetest.register_craft({
    output = "tech:digiline_wireless_reciever",
    recipe = {
    {"", "default:mese_crystal_fragment", ""},
    {"", "tech:bronze_components", ""},
    {"", "digilines:wire_std_00000000", ""},
    }
  })


  local on_digiline_receive = function (pos, _, channel, msg)
    local frequency = minetest.get_meta(pos):get_string("frequency")
	  local setchan = minetest.get_meta(pos):get_string("channel")
	  if channel == setchan and frequency ~= "" then
		  tech.wireless_digiline_post(frequency, msg)
	  end
  end

  minetest.register_node("tech:digiline_wireless_transmitter", {
	  description = "Digiline Wireless Transmitter",
	  tiles = {"tech_digiline_wireless_transmitter.png"},

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
		  meta:set_string("formspec", "field[channel;Channel;${channel}]field[frequency;Frequency;${frequency}]")
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
		  if fields.frequency then
		    minetest.get_meta(pos):set_string("frequency", fields.frequency)
		  end
	  end,
  })
  
  minetest.register_craft({
    output = "tech:digiline_wireless_transmitter",
    recipe = {
    {"", "tech:micromesas", ""},
    {"", "tech:bronze_components", ""},
    {"", "digilines:wire_std_00000000", ""},
    }
  })
end
