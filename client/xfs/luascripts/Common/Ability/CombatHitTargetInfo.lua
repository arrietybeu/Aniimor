-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\CombatHitTargetInfo.lua

local Class = require("Core.Framework.Class")
local ObjectPool = require("Common.Container.ObjectPool")
local Vector3 = Vector3
local Quaternion = Quaternion
local CombatHitTargetInfo = Class.LiteClass("CombatHitTargetInfo")

function CombatHitTargetInfo:ctor(actorId)
	self.actorId = actorId
	self.hitPos = nil
	self.hitDir = nil
	self.hitIdx = nil
	self.newCreationTemplateId = nil
	self.hitActorPartIdx = nil
end

function CombatHitTargetInfo:initTarget(actorId, pos, hitIdx, hitActorPartIdx, isVariantTarget)
	self.actorId = actorId
	self.hitPos = pos
	self.hitIdx = hitIdx
	self.hitActorPartIdx = hitActorPartIdx or 0
	self.isVariantTarget = isVariantTarget
end

function CombatHitTargetInfo:getRawTable(runtimeTargetInfo)
	local runtimeTargetInfo = runtimeTargetInfo or {}

	runtimeTargetInfo.actorId = self.actorId
	runtimeTargetInfo.isVariantTarget = self.isVariantTarget
	runtimeTargetInfo.newCreationTemplateId = self.newCreationTemplateId

	if self.hitPos then
		runtimeTargetInfo.hitPos = Vector3.Clone(self.hitPos)
	end

	if self.hitIdx then
		runtimeTargetInfo.hitIdx = self.hitIdx
	end

	if self.hitActorPartIdx then
		runtimeTargetInfo.hitActorPartIdx = self.hitActorPartIdx
	end

	return runtimeTargetInfo
end

function CombatHitTargetInfo.convert(rawTable)
	if not rawTable then
		return
	end

	setmetatable(rawTable, CombatHitTargetInfo)

	rawTable.hitPos = Vector3.Convert(rawTable.hitPos)
end

function CombatHitTargetInfo:clone()
	local rawTable = self:getRawTable()

	CombatHitTargetInfo.convert(rawTable)

	return rawTable
end

return CombatHitTargetInfo
