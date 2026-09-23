-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Swallower.lua

local Swallower = {}

function Swallower.__index(t, k)
	return Swallower
end

function Swallower.__call(t, ...)
	return Swallower
end

function Swallower.__newindex(t, k, v)
	return
end

local function mathFun(a, b)
	if a == Swallower then
		return b
	else
		return a
	end
end

Swallower.__add = mathFun
Swallower.__sub = mathFun
Swallower.__mul = mathFun
Swallower.__div = mathFun
Swallower.__unm = mathFun

function Swallower.__eq()
	return false
end

setmetatable(Swallower, Swallower)

return Swallower
