-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\ShieldData.lua

local Class = require("Core.Framework.Class")
local CustomDict = require("Core.PropertySync.CustomDict")
local ShieldData = Class.LiteClass("ShieldData", CustomDict)

function ShieldData:isValid()
	return self.buffInsId ~= 0
end

function ShieldData:copy(shieldData)
	self.curPoint = shieldData.curPoint
	self.absorbRate = shieldData.absorbRate
	self.elementType = shieldData.elementType
	self.buffInsId = shieldData.buffInsId
	self.isGeneral = shieldData.isGeneral
	self.isDestroyBuff = shieldData.isDestroyBuff
	self.templateId = shieldData.templateId
end

function ShieldData:clear()
	self.curPoint = 0
	self.buffInsId = 0
	self.elementType = -1
end

return ShieldData
