-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Ability\\ProjAroundSelf.lua

local Class = require("Core.Framework.Class")
local EffectConst = require("Const.EffectConst")
local Lume = require("Core.Common.lume")
local ClientProjectile = require("GameApp.Ability.ClientProjectile")
local Const = require("Common.Const.Const")
local Vector3 = Vector3
local Quaternion = Quaternion
local ProjAroundSelf = Class.LiteClass("ProjAroundSelf")
local cacheTable = {}

function ProjAroundSelf:ctor(ctrl, startAngle)
	self.angle = startAngle + Quaternion.ToYaw(ctrl.owner:getRotation())
	self.curAngle = self.angle
	self.ctrl = ctrl
	self.pos = Vector3()

	Vector3.enableCreateFromCache()
	Lume.clear(cacheTable)

	cacheTable.position = self:getPosByAngle(self.angle)
	cacheTable.followType = EffectConst.FollowType.Global
	cacheTable.mountType = EffectConst.MountType.World
	cacheTable.duration = -1
	cacheTable.maxInsCount = 20
	cacheTable.enableMultipleLoop = true
	cacheTable.isMergeSameEffect = false

	self.pos:Copy(cacheTable.position)

	self.effectId = self.ctrl.owner:playEffect(ctrl.effectId, cacheTable)
	self.isLaunching = false

	Vector3.disableCreateFromCache()
end

function ProjAroundSelf:getPosByAngle(angle)
	local followEnt = self.ctrl:getFollowEntity()
	local rad = angle * math.deg2Rad
	local radius = self.ctrl.radius * (followEnt.curModelScale or 1)

	return followEnt:getPositionAgentPosition() + Vector3.up * followEnt.eModel.height * 0.5 + Vector3(math.sin(rad), 0, math.cos(rad)) * radius
end

function ProjAroundSelf.lerpAngle(a, b, t)
	a = a % 360
	b = b % 360

	local delta = (b - a + 360) % 360

	return (a + t * delta) % 360
end

function ProjAroundSelf:tickReady(deltaSeconds, idx, removeList)
	local curTime = self.readyTime + deltaSeconds

	if curTime >= self.launchDuration then
		Vector3.enableCreateFromCache()

		deltaSeconds = self.launchDuration - self.readyTime
		self.angle = self.angle + self.rotateSpeed * deltaSeconds

		local pos = self:getPosByAngle(self.angle)

		self.pos:Copy(pos)

		local effectTrans = self.ctrl.owner.eModel:GetEffect(Const.COMPONENT_INDEX_EFFECT, self.effectId)

		if effectTrans then
			effectTrans.position = pos
		end

		Vector3.disableCreateFromCache()
		self:launch()
		table.insert(removeList, idx)
	else
		Vector3.enableCreateFromCache()

		local angle = self.angle + deltaSeconds * self.rotateSpeed

		self.angle = angle

		local pos = self:getPosByAngle(angle)

		self.pos:Copy(pos)

		local effectTrans = self.ctrl.owner.eModel:GetEffect(Const.COMPONENT_INDEX_EFFECT, self.effectId)

		if effectTrans then
			effectTrans.position = pos
		end

		Vector3.disableCreateFromCache()
	end

	self.readyTime = curTime
end

function ProjAroundSelf:tickReadyV2(deltaSeconds, idx, removeList)
	local curTime = self.readyTime + deltaSeconds

	if curTime >= self.launchDuration then
		deltaSeconds = self.launchDuration - self.readyTime
		self.angle = self.angle + self.rotateSpeed * deltaSeconds

		Vector3.enableCreateFromCache()

		local pos = self:getPosByAngle(self.angle)

		self.pos:Copy(pos)

		local effectTrans = self.ctrl.owner.eModel:GetEffect(Const.COMPONENT_INDEX_EFFECT, self.effectId)

		if effectTrans then
			effectTrans.position = pos
		end

		Vector3.disableCreateFromCache()
		self:launch()
		table.insert(removeList, idx)
	else
		self.angle = self.angle + self.rotateSpeed * deltaSeconds
		self.curAngle = math.lerp(self.curAngle, self.angle, deltaSeconds / 0.3)

		Vector3.enableCreateFromCache()

		local pos = self:getPosByAngle(self.curAngle)

		self.pos:Copy(pos)

		local effectTrans = self.ctrl.owner.eModel:GetEffect(Const.COMPONENT_INDEX_EFFECT, self.effectId)

		if effectTrans then
			effectTrans.position = pos
		end

		Vector3.disableCreateFromCache()
	end

	self.readyTime = self.readyTime + deltaSeconds
end

function ProjAroundSelf:tick(deltaSeconds, idx, removeList)
	if self.launchDuration then
		self:tickReady(deltaSeconds, idx, removeList)
	else
		self.angle = self.angle + self.ctrl.rotateSpeed * deltaSeconds
		self.curAngle = math.lerp(self.curAngle, self.angle, deltaSeconds / 0.3)

		Vector3.enableCreateFromCache()

		local pos = self:getPosByAngle(self.curAngle)

		self.pos:Copy(pos)

		local effectTrans = self.ctrl.owner.eModel:GetEffect(Const.COMPONENT_INDEX_EFFECT, self.effectId)

		if effectTrans then
			effectTrans.position = pos
		end

		Vector3.disableCreateFromCache()
	end
end

function ProjAroundSelf:readyLaunch(combatContext, launchAngle, launchDuration, targetActorId, targetPos, rotateSpeed)
	self.rotateSpeed = rotateSpeed
	self.isLaunching = true
	self.launchAngle = launchAngle % 360
	self.angle = self.angle % 360
	self.curAngle = self.angle
	self.launchDuration = launchDuration
	self.combatContext = combatContext
	self.readyTime = 0
	self.targetActorId = targetActorId
	self.targetPos = targetPos
end

function ProjAroundSelf:launch()
	local combatContext = self.combatContext

	ClientProjectile.projEffectId = self.effectId
	self.combatContext.overrideProjStartPos = self.pos
	combatContext.overrideProjTargetActorId = self.targetActorId
	combatContext.overrideProjTargetPos = self.targetPos

	local actionData = combatContext.nodeMap[combatContext.nodeStack[#combatContext.nodeStack]]

	self.ctrl.owner.combatAction:doActions(actionData, combatContext)

	ClientProjectile.projEffectId = nil
	combatContext.overrideProjTargetActorId = nil
	combatContext.overrideProjTargetPos = nil
end

function ProjAroundSelf:clear()
	self.ctrl.owner:stopEffectById(self.effectId)
end

return ProjAroundSelf
