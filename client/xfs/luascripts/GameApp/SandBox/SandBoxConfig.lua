-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\SandBoxConfig.lua

local _cache
local SandBoxConfig = {}

function SandBoxConfig.convertToLuaTable(tab)
	if not tab then
		return nil
	end

	local metatable = getmetatable(tab)

	if metatable and metatable._BddData_ == true then
		if _cache == nil then
			_cache = {}

			setmetatable(_cache, {
				__mode = "kv"
			})
		end

		local val = _cache[tab]

		if not val then
			val = bdd2DeepTable(tab)
			_cache[tab] = val
		end

		return val
	else
		return tab
	end
end

function SandBoxConfig.clearCache()
	return
end

function SandBoxConfig.getCache()
	return _cache
end

return SandBoxConfig
