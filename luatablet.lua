local function meta_class(meta_table)
  return {
    data = meta_table,
    get_string = function(self, name)
      return self.data[name]
    end,
    set_string = function(self, name, value)
      self.data[name] = value
    end,
    get_int = function(self, name)
      return self.data[name]
    end,
    set_int = function(self, name, value)
      self.data[name] = value
    end,
    unwrap = function(self)
      return self.data
    end,
  }
end

local function safe_print(param)
	local string_meta = getmetatable("")
	local sandbox = string_meta.__index
	string_meta.__index = string -- Leave string sandbox temporarily
	print(dump(param))
	string_meta.__index = sandbox -- Restore string sandbox
end

local function safe_date()
	return(os.date("*t",os.time()))
end

-- string.rep(str, n) with a high value for n can be used to DoS
-- the server. Therefore, limit max. length of generated string.
local function safe_string_rep(str, n)
	if #str * n > mesecon.setting("luacontroller_string_rep_max", 64000) then
		debug.sethook() -- Clear hook
		error("string.rep: string length overflow", 2)
	end
	return string.rep(str, n)
end

-- string.find with a pattern can be used to DoS the server.
-- Therefore, limit string.find to patternless matching.
local function safe_string_find(...)
	if (select(4, ...)) ~= true then
		debug.sethook() -- Clear hook
		error("string.find: 'plain' (fourth parameter) must always be true in a Luacontroller")
	end
	return string.find(...)
end

local function remove_functions(x)
	local tp = type(x)
	if tp == "function" then
		return nil
	end
	-- Make sure to not serialize the same table multiple times, otherwise
	-- writing mem.test = mem in the Luacontroller will lead to infinite recursion
	local seen = {}

	local function rfuncs(x)
		if x == nil then return end
		if seen[x] then return end
		seen[x] = true
		if type(x) ~= "table" then return end
		for key, value in pairs(x) do
			if type(key) == "function" or type(value) == "function" then
				x[key] = nil
			else
				if type(key) == "table" then
					rfuncs(key)
				end
				if type(value) == "table" then
					rfuncs(value)
				end
			end
		end
	end
	rfuncs(x)
	return x
end



local function clean_and_weigh_digiline_message(msg, back_references)
	local t = type(msg)
	if t == "string" then
		-- Strings are immutable so can be passed by reference, and cost their
		-- length plus the size of the Lua object header (24 bytes on a 64-bit
		-- platform) plus one byte for the NUL terminator.
		return msg, #msg + 25
	elseif t == "number" then
		-- Numbers are passed by value so need not be touched, and cost 8 bytes
		-- as all numbers in Lua are doubles.
		return msg, 8
	elseif t == "boolean" then
		-- Booleans are passed by value so need not be touched, and cost 1
		-- byte.
		return msg, 1
	elseif t == "table" then
		-- Tables are duplicated. Check if this table has been seen before
		-- (self-referential or shared table); if so, reuse the cleaned value
		-- of the previous occurrence, maintaining table topology and avoiding
		-- infinite recursion, and charge zero bytes for this as the object has
		-- already been counted.
		back_references = back_references or {}
		local bref = back_references[msg]
		if bref then
			return bref, 0
		end
		-- Construct a new table by cleaning all the keys and values and adding
		-- up their costs, plus 8 bytes as a rough estimate of table overhead.
		local cost = 8
		local ret = {}
		back_references[msg] = ret
		for k, v in pairs(msg) do
			local k_cost, v_cost
			k, k_cost = clean_and_weigh_digiline_message(k, back_references)
			v, v_cost = clean_and_weigh_digiline_message(v, back_references)
			if k ~= nil and v ~= nil then
				-- Only include an element if its key and value are of legal
				-- types.
				ret[k] = v
			end
			-- If we only counted the cost of a table element when we actually
			-- used it, we would be vulnerable to the following attack:
			-- 1. Construct a huge table (too large to pass the cost limit).
			-- 2. Insert it somewhere in a table, with a function as a key.
			-- 3. Insert it somewhere in another table, with a number as a key.
			-- 4. The first occurrence doesn’t pay the cost because functions
			-- are stripped and therefore the element is dropped.
			-- 5. The second occurrence doesn’t pay the cost because it’s in
			-- back_references.
			-- By counting the costs regardless of whether the objects will be
			-- included, we avoid this attack; it may overestimate the cost of
			-- some messages, but only those that won’t be delivered intact
			-- anyway because they contain illegal object types.
			cost = cost + k_cost + v_cost
		end
		return ret, cost
	else
		return nil, 0
	end
end

local safe_globals = {
	-- Don't add pcall/xpcall unless willing to deal with the consequences (unless very careful, incredibly likely to allow killing server indirectly)
	"assert", "error", "ipairs", "next", "pairs", "select", "tonumber", "tostring", "type", "unpack", "_VERSION"
}

local function create_environment(meta, mem, event, itbl, send_warning)
	-- Gather variables for the environment
	-- Create new library tables on each call to prevent one Luacontroller
	-- from breaking a library and messing up other Luacontrollers.
	
	local radio
	if digilines then
	  radio = {
	    send = function(frequency, msg)
	      frequency = tostring(frequency)
	      local message, cost = clean_and_weigh_digiline_message(msg)
	      if message and cost <= 1024*16 then
	        tech.wireless_digiline_post(frequency, message)
	      end
	    end,
	    recieve = function(frequency)
	      frequency = tostring(frequency)
	      return tech.wireless_digiline_pop(frequency)
	    end,
	  }
	end

	local env = {
		event = event,
		mem = mem,
		--heat = mesecon.get_heat(pos),
		--heat_max = mesecon.setting("overheat_max", 20),
		print = safe_print,
		string = {
			byte = string.byte,
			char = string.char,
			format = string.format,
			len = string.len,
			lower = string.lower,
			upper = string.upper,
			rep = safe_string_rep,
			reverse = string.reverse,
			sub = string.sub,
			find = safe_string_find,
		},
		math = {
			abs = math.abs,
			acos = math.acos,
			asin = math.asin,
			atan = math.atan,
			atan2 = math.atan2,
			ceil = math.ceil,
			cos = math.cos,
			cosh = math.cosh,
			deg = math.deg,
			exp = math.exp,
			floor = math.floor,
			fmod = math.fmod,
			frexp = math.frexp,
			huge = math.huge,
			ldexp = math.ldexp,
			log = math.log,
			log10 = math.log10,
			max = math.max,
			min = math.min,
			modf = math.modf,
			pi = math.pi,
			pow = math.pow,
			rad = math.rad,
			random = math.random,
			sin = math.sin,
			sinh = math.sinh,
			sqrt = math.sqrt,
			tan = math.tan,
			tanh = math.tanh,
		},
		table = {
			concat = table.concat,
			insert = table.insert,
			maxn = table.maxn,
			remove = table.remove,
			sort = table.sort,
		},
		os = {
			clock = os.clock,
			difftime = os.difftime,
			time = os.time,
			datetable = safe_date,
		},
		gui = {
		  item = function(id, x, y, itemstring)
		    if (type(id)~="string") or (type(itemstring)~="string") or (type(x)~="number") or (type(y)~="number") then
		      return
		    end
		    local id = minetest.formspec_escape(id)
		    local itemstring = minetest.formspec_escape(itemstring)
		    local raw_formspec = meta:get_string("raw_formspec") or ""
		    raw_formspec = raw_formspec .. "item_image_button["..x..","..y..";1,1;"..itemstring..";"..id..";]"
		    meta:set_string("raw_formspec", raw_formspec)
		  end,
		  clear = function()
		    meta:set_string("raw_formspec", "")
		  end,
		  field = function(id, x, y, w, h, label, default)
		    if (type(id)~="string") or (type(label)~="string") or (type(default)~="string") or (type(x)~="number") or (type(y)~="number") or (type(w)~="number") or (type(h)~="number") then
		      return
		    end
		    local id = minetest.formspec_escape(id)
		    local label = minetest.formspec_escape(label)
		    local default = minetest.formspec_escape(default)
		    local raw_formspec = meta:get_string("raw_formspec") or ""
		    raw_formspec = raw_formspec .. "field["..x..","..y..";"..w..","..h..";"..id..";"..label..";"..default.."]"
		    meta:set_string("raw_formspec", raw_formspec)
		  end,
		  button = function(id, x, y, w, h, label)
		    if (type(id)~="string") or (type(label)~="string") or (type(x)~="number") or (type(y)~="number") or (type(w)~="number") or (type(h)~="number") then
		      return
		    end
		    local id = minetest.formspec_escape(id)
		    local label = minetest.formspec_escape(label)
		    local raw_formspec = meta:get_string("raw_formspec") or ""
		    raw_formspec = raw_formspec .. "button["..x..","..y..";"..w..","..h..";"..id..";"..label.."]"
		    meta:set_string("raw_formspec", raw_formspec)
		  end,
		},
		radio = radio,
	}
	env._G = env
	for _, name in pairs(safe_globals) do
		env[name] = _G[name]
	end
	return env
end

local function timeout()
	debug.sethook() -- Clear hook
	error("Code timed out!", 2)
end

local function create_sandbox(code, env)
  if not code then
    return nil, "No code"
  end
  if code:byte(1) == 27 then
		return nil, "Binary code prohibited."
	end
	local f, msg = loadstring(code)
	if not f then return nil, msg end
	setfenv(f, env)

	-- Turn off JIT optimization for user code so that count
	-- events are generated when adding debug hooks
	if rawget(_G, "jit") then
		jit.off(f, true)
	end

	local maxevents = mesecon.setting("luacontroller_maxevents", 100000)

	return function(...)
		-- NOTE: This runs within string metatable sandbox, so the setting's been moved out for safety
		-- Use instruction counter to stop execution
		-- after luacontroller_maxevents

		debug.sethook(timeout, "", maxevents)
		local ok, ret = pcall(f, ...)
		debug.sethook() -- Clear hook

		if not ok then error(ret, 0) end
		return ret
	end

end


local function load_memory(meta)

	return minetest.deserialize(meta:get_string("memory"), true) or {}

end



local function save_memory(meta, mem)

	local memstring = minetest.serialize(remove_functions(mem))

	local memsize_max = mesecon.setting("luacontroller_memsize", 100000)


	if (#memstring <= memsize_max) then

		meta:set_string("memory", memstring)


	else

		print("Error: Luacontroller memory overflow. "..memsize_max.." bytes available, "

				..#memstring.." required. Controller overheats.")

		--burn_controller(pos)

	end

end


-- Returns success (boolean), errmsg (string)

-- run (as opposed to run_inner) is responsible for setting up meta according to this output

local function run_inner(meta, code, event)

	-- Note: These return success, presumably to avoid changing LC ID.

	--if overheat(pos) then return true, "" end

	-- Load code & mem from meta

	local mem = load_memory(meta)

	local code = meta:get_string("code")
  --print("debug code", minetest.serialize(meta.data))

	-- 'Last warning' label.

	local warning = ""

	local function send_warning(str)

		warning = "Warning: " .. str

	end


	-- Create environment

	local itbl = {}
	local env = create_environment(meta, mem, event, itbl, send_warning)
	-- Create the sandbox and execute code
	
	local f, msg = create_sandbox(code, env)
	if not f then return false, msg end
	-- Start string true sandboxing
	local onetruestring = getmetatable("")
	-- If a string sandbox is already up yet inconsistent, something is very wrong
	assert(onetruestring.__index == string)
	onetruestring.__index = env.string
	local success, msg = pcall(f)
	onetruestring.__index = string
	-- End string true sandboxing
	if not success then return false, msg end
	-- Save memory. This may burn the luacontroller if a memory overflow occurs.
	save_memory(meta, env.mem)
	--print("debug data", minetest.serialize(meta.data))
	-- Execute deferred tasks

	for _, v in ipairs(itbl) do

		local failure = v()

		if failure then

			return false, failure

		end

	end

	return true, warning

end

local function reset_formspec(meta, code, errmsg)

	meta:set_string("code", code)

	--code = minetest.formspec_escape(code or "")

	errmsg = minetest.formspec_escape(tostring(errmsg or ""))

	meta:set_string("formspec", "size[12,9]"..
    default.gui_bg..
    default.gui_bg_img..
    default.gui_slots..
    (meta:get_string("raw_formspec") or ""))

end


local function reset_meta(meta, code, errmsg)

	reset_formspec(meta, code, errmsg)

	meta:set_int("luac_id", math.random(1, 65535))

end


-- Wraps run_inner with LC-reset-on-error

local function run(itemstack, event)

	local meta = meta_class(minetest.deserialize(itemstack:get_metadata()) or {})

	local code = meta:get_string("code")

	local ok, errmsg = run_inner(meta, code, event)

	if not ok then
    print("Luatablet error :", errmsg)
		reset_meta(meta, code, errmsg)
		itemstack:set_metadata(minetest.serialize(meta:unwrap()))

	else

		reset_formspec(meta, code, errmsg)
		itemstack:set_metadata(minetest.serialize(meta:unwrap()))

	end

	return ok, errmsg

end




minetest.register_tool("tech:luatablet", {
  description = "Luatablet",
  inventory_image = "tech_luatablet.png",
  on_place = function(itemstack, user, pointed_thing)
    run(itemstack, { type = "run" })
    local meta = meta_class(minetest.deserialize(itemstack:get_metadata()) or {})
    minetest.show_formspec(user:get_player_name(), "tech:luatablet_gui", meta:get_string("formspec"))
    return itemstack
  end,
  on_use = function(itemstack, user, pointed_thing)
    local meta = meta_class(minetest.deserialize(itemstack:get_metadata()) or {})
    local code = minetest.formspec_escape(meta:get_string("code") or "")
    local formspec = "size[12,10]"..
		"background[-0.2,-0.25;12.4,10.75;jeija_luac_background.png]"..
		"textarea[0.2,0.2;12.2,9.5;code;;"..code.."]"..
		"image_button_exit[11.72,-0.25;0.425,0.4;jeija_close_window.png;exit;]"
    if not user:is_player() then
      return
    end
    minetest.show_formspec(user:get_player_name(), "tech:program_luatablet", formspec)
  end
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "tech:program_luatablet" then
		if fields.code then
		  local itemstack = player:get_wielded_item()
		  local meta = meta_class(minetest.deserialize(itemstack:get_metadata()) or {})
		  meta:set_string("code", fields.code)
		  itemstack:set_metadata(minetest.serialize(meta:unwrap()))
		  player:set_wielded_item(itemstack)
		end
	elseif formname == "tech:luatablet_gui" then
	  --for k, v in pairs(fields) do
	  --  print("field", k, v)
	  --end
	  if formname.quit then
	    return
	  end
	  local itemstack = player:get_wielded_item()
    run(itemstack, { type = "input", input = fields })
    player:set_wielded_item(itemstack)
    local meta = meta_class(minetest.deserialize(itemstack:get_metadata()) or {})
    minetest.show_formspec(player:get_player_name(), "tech:luatablet_gui", meta:get_string("formspec"))
	end
end)

minetest.register_craft({
  output = "tech:luatablet",
  recipe = {
  {"digilines:lcd", "digilines:lcd", "digilines:lcd"},
  {"digilines:lcd", "digilines:lcd", "digilines:lcd"},
  {"tech:digiline_wireless_reciever", "mesecons_luacontroller:luacontroller0000", "tech:digiline_wireless_transmitter"},
  }
})
