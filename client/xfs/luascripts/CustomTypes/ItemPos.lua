-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\ItemPos.lua

local CustomList = require("Core.PropertySync.CustomList")
local class = require("Core.Framework.Class")
local ItemPos = class.LiteClass("ItemPos", CustomList)

function ItemPos:isValid()
	if #self ~= 2 then
		return false
	end

	return self[1] ~= 0 and self[2] ~= 0
end

function ItemPos:equal(invId, genId)
	return self[1] == invId and self[2] == genId
end

function ItemPos:unpack()
	return self[1], self[2]
end

function ItemPos:invId()
	return self[1] or 0
end

function ItemPos:genId()
	return self[2] or 0
end

function ItemPos:repr()
	return string.format("{%s, %s}", self:invId(), self:genId())
end

return ItemPos
