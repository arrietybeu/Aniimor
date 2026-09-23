-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\CombatCasterInfo.lua

local Class = require("Core.Framework.Class")
local Vector3 = Vector3
local Quaternion = Quaternion
local CombatCasterInfo = Class.LiteClass("CombatCasterInfo")

function CombatCasterInfo:ctor(actorId)
	self.actorId = actorId
	self.srcActorId = actorId
	self.attackPos = nil
	self.attackRot = nil
	self.targetActorId = nil
	self.aimPos = nil
	self.targetPos = nil
	self.partId = nil
	self.castSource = nil
	self.chaseActorId = nil
	self.isFromAutoCast = nil
end

function CombatCasterInfo:releasePooledSpatialFields()
	Vector3.returnToPool(self.attackPos)

	self.attackPos = nil

	Quaternion.returnToPool(self.attackRot)

	self.attackRot = nil

	Vector3.returnToPool(self.aimPos)

	self.aimPos = nil

	Vector3.returnToPool(self.targetPos)

	self.targetPos = nil
end

function CombatCasterInfo:clear()
	self:releasePooledSpatialFields()

	for key in pairs(self) do
		self[key] = nil
	end
end

function CombatCasterInfo:copyFrom(source)
	self:clear()

	self.actorId = source.actorId
	self.srcActorId = source.srcActorId
	self.targetActorId = source.targetActorId
	self.partId = source.partId
	self.castSource = source.castSource
	self.chaseActorId = source.chaseActorId
	self.isFromAutoCast = source.isFromAutoCast
	self.attackPos = Vector3.CloneFromPool(source.attackPos)
	self.attackRot = Quaternion.CloneFromPool(source.attackRot)
	self.aimPos = Vector3.CloneFromPool(source.aimPos)
	self.targetPos = Vector3.CloneFromPool(source.targetPos)

	return self
end

function CombatCasterInfo:getRawTable()
	return {
		actorId = self.actorId,
		srcActorId = self.srcActorId,
		attackPos = self.attackPos and self.attackPos:getRawTable() or nil,
		attackRot = self.attackRot and self.attackRot:getRawTable() or nil,
		targetActorId = self.targetActorId,
		partId = self.partId,
		castSource = self.castSource
	}
end

function CombatCasterInfo.convert(rawTable)
	if not rawTable then
		return
	end

	setmetatable(rawTable, CombatCasterInfo)

	rawTable.attackPos = Vector3.Convert(rawTable.attackPos)
	rawTable.attackRot = Quaternion.Convert(rawTable.attackRot)
	rawTable.aimPos = Vector3.Convert(rawTable.aimPos)
	rawTable.targetPos = Vector3.Convert(rawTable.targetPos)
end

function CombatCasterInfo:clone()
	if not getmetatable(self) then
		CombatCasterInfo.convert(self)
	end

	local target = pg.global.abilityMgr.constCasterInfoPool:get(true)

	return target:copyFrom(self)
end

return CombatCasterInfo
