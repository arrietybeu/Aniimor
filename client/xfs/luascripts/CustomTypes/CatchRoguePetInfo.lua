-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\CatchRoguePetInfo.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local Class = require("Core.Framework.Class")
local CatchRoguePetInfo = Class.LiteClass("CatchRoguePetInfo", CustomDict)

function CatchRoguePetInfo:updateByEntity(entity)
	self.hpRatio = entity.actorCombatAttribute:getHpRatio()
	self.epRatio = entity.actorCombatAttribute:getEpPercent() / 100
	self.spRatio = entity.actorCombatAttribute:getSpPercent() / 100
end

function CatchRoguePetInfo:applyToEntity(entity)
	entity:setHp(self.hpRatio * entity:getMaxHp())
	entity:setEp(self.epRatio * entity:getMaxEp())
	entity:setSp(self.spRatio * entity:getMaxSp())
end

return CatchRoguePetInfo
