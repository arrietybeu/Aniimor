-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\IsInRange.lua

local CTRNode = require("Common.AICt.CTRNode")
local Class = require("Core.Framework.Class")
local CalcUtils = require("Utils.CalcUtils")
local PhysicsUtils = require("Common.Utils.PhysicsUtils")
local Utils = require("Common.Utils.Utils")
local Vector3 = Vector3
local IsInRange = Class.LightClass("IsInRange", CTRNode)
local RangeType = {
	Sector = 0
}

function IsInRange:registerPorts()
	self.valueInput_targetActorId = self:addValueInput("targetActorId")
	self.valueInput_needRaycast = self:addValueInput("needRaycast")
	self.valueInput_originPosOffsetX = self:addValueInput("originPosOffsetX")
	self.valueInput_originPosOffsetY = self:addValueInput("originPosOffsetY")
	self.valueInput_originPosOffsetZ = self:addValueInput("originPosOffsetZ")
	self.valueInput_originAngleOffset = self:addValueInput("originAngleOffset")

	self:addValueOutput("out", function(flow)
		return self:Get_out_Value(flow)
	end)

	local rangeType = self.nodeData.rangeType

	if rangeType == RangeType.Sector then
		self:_registerSectorInput()
	end
end

function IsInRange:_registerSectorInput()
	self.valueInput_angleStart = self:addValueInput("angleStart")
	self.valueInput_angleEnd = self:addValueInput("angleEnd")
	self.valueInput_radius = self:addValueInput("radius")
	self.valueInput_heightStart = self:addValueInput("heightStart")
	self.valueInput_heightEnd = self:addValueInput("heightEnd")
end

function IsInRange:_getSectorInput(flow)
	local angleStart = self:getInputValue(self.valueInput_angleStart, flow)
	local angleEnd = self:getInputValue(self.valueInput_angleEnd, flow)
	local radius = self:getInputValue(self.valueInput_radius, flow)
	local heightStart = self:getInputValue(self.valueInput_heightStart, flow)
	local heightEnd = self:getInputValue(self.valueInput_heightEnd, flow)

	return angleStart, angleEnd, radius, heightStart, heightEnd
end

function IsInRange:Get_out_Value(flow)
	local targetActorId = self:getInputValue(self.valueInput_targetActorId, flow)

	if targetActorId == 0 then
		return false
	end

	local me = pg.getEntityByActorId(flow.context._entActorId)
	local target = pg.getEntityByActorId(targetActorId)

	if not me or not target then
		return false
	end

	local needRaycast = self:getInputValue(self.valueInput_needRaycast, flow)
	local originPosOffsetX = self:getInputValue(self.valueInput_originPosOffsetX, flow)
	local originPosOffsetY = self:getInputValue(self.valueInput_originPosOffsetY, flow)
	local originPosOffsetZ = self:getInputValue(self.valueInput_originPosOffsetZ, flow)
	local originAngleOffset = self:getInputValue(self.valueInput_originAngleOffset, flow)

	Vector3.enableCreateFromCache()

	local myPos = me:getPosition()
	local myDir = me:getRotation():Forward()
	local tmpTargetPos = target:getPosition()
	local targetPosX, targetPosY, targetPosZ = tmpTargetPos.x, tmpTargetPos.y + target:getHeight() * 0.5, tmpTargetPos.z
	local originPosX, originPosY, originPosZ = myPos.x + originPosOffsetX, myPos.y + originPosOffsetY, myPos.z + originPosOffsetZ
	local originDirX, originDirY, originDirZ = CalcUtils.clockwiseRotateDegree(myDir.x, myDir.y, myDir.z, originAngleOffset)

	Vector3.disableCreateFromCache()

	local inRange = false
	local rangeType = self.nodeData.rangeType

	if rangeType == RangeType.Sector then
		local angleStart, angleEnd, radius, heightStart, heightEnd = self:_getSectorInput(flow)

		if targetPosY < originPosY + heightStart or targetPosY > originPosY + heightEnd then
			return false
		end

		originDirX, originDirY, originDirZ = CalcUtils.clockwiseRotateDegree(originDirX, originDirY, originDirZ, (angleStart + angleEnd) * 0.5)

		local theta = Utils.normalizeAngle(angleEnd - angleStart) * 0.5

		inRange = CalcUtils.isPointInCirualSector(targetPosX, targetPosZ, originDirX, originDirZ, originPosX, originPosZ, radius, theta)
	end

	if inRange then
		if needRaycast then
			Vector3.enableCreateFromCache()

			local originPos = Vector3.New(originPosX, originPosY, originPosZ)
			local targetPos = Vector3.New(targetPosX, targetPosY, targetPosZ)
			local dir = targetPos - originPos
			local maxDist = Vector3.Magnitude(dir)

			dir:SetNormalize()

			local layerMask = CS.FunPlus.WorldX.Const.LayerDefine.STABLE_GROUND_LAYERS
			local raycastHit, succ = PhysicsUtils.getRaycastInfo(originPos, dir, maxDist, layerMask)

			Vector3.disableCreateFromCache()

			if not succ then
				return true
			end
		else
			return true
		end
	end

	return false
end

return IsInRange
