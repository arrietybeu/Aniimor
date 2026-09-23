-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\BoolList.lua

local CustomList = require("Core.PropertySync.CustomList")
local class = require("Core.Framework.Class")
local BoolList = class.LiteClass("BoolList", CustomList)

function BoolList:setTrue(index)
	for i = #self + 1, index do
		self:insert(i, false)
	end

	self[index] = true
end

function BoolList:setFalse(index)
	for i = #self + 1, index do
		self:insert(i, false)
	end

	self[index] = false
end

return BoolList
