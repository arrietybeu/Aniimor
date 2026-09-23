-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Framework\\TableHelper.lua

local TableHelper = {}

function TableHelper.tableLength(t)
	local count = 0

	for _ in pairs(t) do
		count = count + 1
	end

	return count
end

return TableHelper
