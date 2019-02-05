function tech.check_multiblock(pos, data)
 local pos2 = {}
 for i, v in ipairs(data) do
  pos2.x = pos.x + v.x
  pos2.y = pos.y + v.y
  pos2.z = pos.z + v.z
  local real = minetest.get_node(pos2).name
  if (real ~= v.name and v.name ~= "any") or minetest.get_meta(pos2):get_int("tech_multiblock_is_used") == 1 then
   return false
  end
 end
 return true
end

-- legend:
-- {["0"] = "air", g = "sorcery:moon_glass"}
-- "@" - center
-- scheme:
-- 0g0
-- g@g
-- 0g0
function tech.form_multiblock(legend, scheme)
  local cx, cy, cz-- center coordinates
  local i, j
  i = 1
  while i <= #scheme do
    j = 1
    local schlen = #scheme[i]
    while j <= schlen do
      local fnd = scheme[i][j]:find("@")
      if fnd then
        cz = j
        cy = i
        cx = fnd
        i = #scheme + 1
        break
      end
      j = j + 1
    end
    i = i + 1
  end
  local result = {}
  for i = 1, #scheme do
    local schlen = #scheme[i]
    for j = 1, schlen do
      for k = 1, scheme[i][j]:len() do
        table.insert(result, {
        	  y = i - cy,
        	  z = j - cz,
        	  x = k - cx,
        	  name = legend[scheme[i][j]:sub(k, k)]
        	})
      end
    end
  end
  return result
end
