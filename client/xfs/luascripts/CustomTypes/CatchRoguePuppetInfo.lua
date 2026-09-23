-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\CatchRoguePuppetInfo.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local Class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local CatchRoguePuppetInfo = Class.LiteClass("CatchRoguePuppetInfo", CustomDict)

function CatchRoguePuppetInfo:updateByEntity(entity)
	self.templateId = entity.templateId
	self.level = entity.level
	self.label = entity.label
	self.addOnId = entity.catchRogueAddOnId or 0
	self.position = {}

	self.position:updateByPosAndRot(entity:getPosition(), entity:getRotation())

	if entity.destroyReason == Const.DESTROY_REASON.CAPTURE_SUCCESS or entity.destroyReason == Const.DESTROY_REASON.CAPTURE_FAILED then
		self.hpRatio = 0
	else
		self.hpRatio = entity.actorCombatAttribute:getHpRatio()
	end
end

function CatchRoguePuppetInfo:applyToInitProps(initProps)
	initProps.templateId = self.templateId or 0
	initProps.level = self.level or 0
	initProps.forceLabel = self.label or 0

	local pos, rot = self.position:toPosAndRot()

	initProps.position = pos
	initProps.rotation = rot
end

function CatchRoguePuppetInfo:applyToEntity(entity)
	local maxHp = entity:getMaxHp()

	if maxHp > 0 then
		entity:setHp(self.hpRatio * maxHp)
	end

	entity.catchRogueAddOnId = self.addOnId or 0
end

return CatchRoguePuppetInfo
