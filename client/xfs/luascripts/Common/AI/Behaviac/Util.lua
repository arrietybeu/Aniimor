-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Util.lua

local lib_util = {}
local rand = math.random
local _M = lib_util

function _M.createUUID()
	local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"

	return string.gsub(template, "[xy]", function(c)
		local v = c == "x" and rand(0, 15) or rand(8, 11)

		return string.format("%x", v)
	end)
end

function _M.makeReadOnly(t)
	local proxy = {}
	local mt = {
		__index = t,
		__newindex = function(t, k, v)
			error("attempt to update a read-only table", 2)
		end
	}

	setmetatable(proxy, mt)

	return proxy
end

return _M
