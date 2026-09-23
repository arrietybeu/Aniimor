-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\PropertySync\\CustomTypeHelper.lua

local CustomTypeHelper = {}

function CustomTypeHelper.GetProp(tab, name)
	local props = tab._properties

	return props[name]
end

function CustomTypeHelper.GetDictFunc(tab, name)
	local clsTypes = tab.__ClassType

	return clsTypes[name]
end

return CustomTypeHelper
