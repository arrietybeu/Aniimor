-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\Attribute\\ActorInterface.lua

local Class = require("Core.Framework.Class")
local AttributeConst = require("Common.Const.AttributeConst")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local LoggerManager = require("Core.Log.LoggerManager")
local PropertyData = require("Data.property_data")
local ActorInterface = Class.LiteClass("ActorInterface")

function ActorInterface:ctor(entity)
	self.actorId = entity.actorId
	self.entity = entity
end

function ActorInterface:getActorId()
	return self.actorId
end

function ActorInterface:getEntity()
	return self.entity
end

function ActorInterface:getTemplateId()
	return self.entity.templateId
end

function ActorInterface:getLevel()
	return self.entity.level or 0
end

function ActorInterface:repr()
	if self.entity.repr then
		return self.entity:repr()
	end

	return string.format("(actorId=%d)", self.actorId)
end

function ActorInterface:getLogger()
	if self.entity.logger then
		return self.entity.logger
	end

	self.logger = LoggerManager:getLogger(self.entity.getClassType and self.entity:getClassType() or "ActorInterface")

	return self.logger
end

function ActorInterface:getSpace()
	return self.entity.space
end

function ActorInterface:getConfigData()
	return Utils.getEntityConfigData(self.entity)
end

function ActorInterface:getPropData()
	local propId = Utils.getEntityPropId(self.entity, self:getConfigData())

	return PropertyData[propId] or {}
end

function ActorInterface:isPlayer()
	return Utils.isPlayer(self.entity) or Utils.isBotPlayer(self.entity)
end

function ActorInterface:isPuppet()
	return Utils.isPuppet(self.entity)
end

function ActorInterface:isPet()
	return Utils.isPet(self.entity)
end

function ActorInterface:isPlayerPet()
	return Utils.isPlayerPet(self.entity)
end

function ActorInterface:isPlayerCurPet()
	return Utils.isPlayerCurPet(self.entity)
end

function ActorInterface:isVirtualEntity()
	return Utils.isVirtualEntity(self.entity)
end

function ActorInterface:getMasterEntity()
	return self.entity.getMasterEntity and self.entity:getMasterEntity()
end

function ActorInterface:getCurPetEntity()
	return self.entity.getCurPetEntity and self.entity:getCurPetEntity()
end

function ActorInterface:getBaseAttr()
	return self.entity.baseAttr
end

function ActorInterface:getActorAttributeApplicator()
	return self.entity.actorAttributeApplicator
end

function ActorInterface:getActorCombatAttribute()
	return self.entity.actorCombatAttribute
end

function ActorInterface:getSp()
	return self.entity.getSp and self.entity:getSp() or 0
end

function ActorInterface:getEp()
	return self.entity.getEp and self.entity:getEp() or 0
end

function ActorInterface:getMaxSp()
	return self.entity.getMaxSp and self.entity:getMaxSp() or 0
end

function ActorInterface:getMaxEp()
	return self.entity.getMaxEp and self.entity:getMaxEp() or 0
end

function ActorInterface:isInCombat()
	return self.entity.isInCombat and self.entity:isInCombat() or false
end

function ActorInterface:inBreak()
	return self.entity.inBreak and self.entity:inBreak() or false
end

function ActorInterface:inBreakRecover()
	return self.entity.inBreakRecover and self.entity:inBreakRecover() or false
end

function ActorInterface:isDead()
	return self.entity.isDead and self.entity:isDead() or false
end

function ActorInterface:getActorBuff()
	return self.entity.actorBuff
end

function ActorInterface:hasBuffTag(buffTag)
	return self.entity.actorBuff and self.entity.actorBuff:hasTag(buffTag) or false
end

function ActorInterface:getCurModelScale()
	return self.entity.curModelScale or 1
end

function ActorInterface:getElementTypes()
	return self.entity.elementTypes or {}
end

function ActorInterface:receiveHeal(rawValue, combatContext, overrideCast)
	return self.entity.receiveHeal and self.entity:receiveHeal(rawValue, combatContext, overrideCast)
end

function ActorInterface:receiveAddEp(value, combatContext)
	return self.entity.receiveAddEp and self.entity:receiveAddEp(value, combatContext)
end

return ActorInterface
