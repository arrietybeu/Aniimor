-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Common\\Platform.lua

local Platform = {}

function Platform.addLibPath()
	package.path = package.path .. ";Lib/?.lua;Lib/?/init.lua"

	local separator = package.config:sub(1, 1)

	if separator == "/" then
		package.cpath = package.cpath .. ";Lib/?.so"
	else
		package.cpath = package.cpath .. ";Lib/?.dll"
	end
end

function Platform.getSeparator()
	return package.config:sub(1, 1)
end

return Platform
