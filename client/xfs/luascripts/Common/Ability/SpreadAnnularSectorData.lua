-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\SpreadAnnularSectorData.lua

local Class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local Utils = require("Common.Utils.Utils")
local LxGeometry = require("Common.Ability.LxGeometry")
local ActionConst = require("Common.Const.ActionConst")
local CombatActionTool = require("Common.Ability.CombatActionTool")
local pg = pg
local Vector3 = Vector3
local Vector4 = Vector4
local Quaternion = Quaternion
local ToBool = ToBool
local unpack = unpack
local SpreadAnnularSectorData = Class.LiteClass("SpreadAnnularSectorData")

function SpreadAnnularSectorData:ctor(owner, actionData, targetData, combatContext)
	self.time = 0
	self.speed = actionData.speed or 0
	self.acceleration = actionData.acceleration or 0
	self.maxRadius = actionData.maxRadius
	self.needUpdateCenter = actionData.needUpdateCenter or false
	self.inverseDir = self.speed < 0
	self.accumulateOffset = 0

	if actionData.useStartTransform ~= false then
		self:updateCenterPosAndRot(owner, actionData, targetData, combatContext)
	end

	self.isEnd = false
	self.actionData = {}

	for k, v in pairs(actionData) do
		if k == "target" then
			targetData.shapeKind = "AnnularSector3D"
			self.actionData[k] = {
				Utils.deepCopyTable(targetData)
			}
		else
			self.actionData[k] = v
		end
	end

	self.actionData.name = ActionConst.COMMON_ACTIONS.COMBAT_ACTION_ACT_ON_TARGETS
	self.lxAnnularSector = LxGeometry.LxAnnularSector3D(nil, nil, table.unpack(targetData.shapeArgs))
	self.startInnerRadius = self.lxAnnularSector.innerRadius
	self.startOuterRadius = self.lxAnnularSector.outerRadius
	self.combatContext = combatContext

	owner:addCombatContextRefCnt(combatContext)

	self.owner = owner
end

function SpreadAnnularSectorData:activate(deltaSecond)
	if self.needUpdateCenter then
		self:updateCenterPosAndRot(self.owner, self.actionData, self.actionData.target[1], self.combatContext)
	end

	self.time = self.time + deltaSecond

	local offset = self.speed * self.time + 0.5 * self.acceleration * self.time * self.time

	if self.inverseDir then
		if self.maxRadius + offset < self.startInnerRadius then
			self.lxAnnularSector.innerRadius = self.startInnerRadius
			self.lxAnnularSector.outerRadius = self.startOuterRadius
			self.isEnd = true
		else
			self.lxAnnularSector.innerRadius = self.maxRadius + offset
			self.lxAnnularSector.outerRadius = self.maxRadius + offset + (self.startOuterRadius - self.startInnerRadius)
		end
	elseif self.startInnerRadius + offset > self.maxRadius then
		self.lxAnnularSector.innerRadius = self.maxRadius
		self.lxAnnularSector.outerRadius = self.maxRadius + (self.startOuterRadius - self.startInnerRadius)
		self.isEnd = true
	else
		self.lxAnnularSector.innerRadius = self.startInnerRadius + offset
		self.lxAnnularSector.outerRadius = self.startOuterRadius + offset
	end

	self.actionData.target[1].shapeArgs = self.lxAnnularSector:getArgs()

	pg.global.abilityMgr.combatAction:actOnTargets(self.actionData, self.combatContext, self.overridePos, self.overrideRot)

	if self.isEnd and self.owner then
		self.owner:returnCombatContext(self.combatContext)
	end
end

function SpreadAnnularSectorData:updateCenterPosAndRot(owner, actionData, targetData, combatContext)
	local pos = owner:getPosition():Clone()
	local rot = owner:getRotation():Clone()
	local offsetXYZ = Vector3(unpack(targetData.offsetXYZ))
	local offsetRotation = Vector3(unpack(targetData.offsetRotation))
	local scale = 1

	if actionData.isScaleWithModel ~= false then
		scale = owner.curModelScale or 1
	end

	if CombatActionTool.parsePosition(combatContext, targetData.center, pos) then
		CombatActionTool.parseRotationFromTo(combatContext, targetData.rotFrom, targetData.rotTo, rot)

		pos = CombatActionTool.translatePoint(pos, rot, offsetXYZ * scale)

		if offsetRotation.x ~= 0 then
			rot = rot * Quaternion.AngleAxis(offsetRotation.x, Vector3.left)
		end

		if offsetRotation.y ~= 0 then
			rot = rot * Quaternion.AngleAxis(offsetRotation.y, Vector3.up)
		end

		if offsetRotation.z ~= 0 then
			rot = rot * Quaternion.AngleAxis(offsetRotation.z, Vector3.forward)
		end
	elseif actionData.noTargetOffsetXYZ then
		local noTargetOffsetXYZ = Vector3(unpack(actionData.noTargetOffsetXYZ))

		pos = CombatActionTool.translatePoint(pos, rot, noTargetOffsetXYZ * scale)

		if actionData.noTargetOffsetRotation then
			local noTargetOffsetRotation = Vector3(unpack(actionData.noTargetOffsetRotation))

			if noTargetOffsetRotation.x ~= 0 then
				rot = rot * Quaternion.AngleAxis(noTargetOffsetRotation.x, Vector3.left)
			end

			if noTargetOffsetRotation.y ~= 0 then
				rot = rot * Quaternion.AngleAxis(noTargetOffsetRotation.y, Vector3.up)
			end

			if noTargetOffsetRotation.z ~= 0 then
				rot = rot * Quaternion.AngleAxis(noTargetOffsetRotation.z, Vector3.forward)
			end
		end
	end

	self.overridePos = pos
	self.overrideRot = rot
end

return SpreadAnnularSectorData
