-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Homeland\\HomelandFastFindInfo.lua

local Class = require("Core.Framework.Class")
local HomelandFastFindInfo = Class.LightClass("HomelandFastFindInfo")
local Utils = require("Common.Utils.Utils")

function HomelandFastFindInfo:ctor(ornamentId)
	self.ornamentId = ornamentId
	self.chunkIds = {}
	self.position = Vector3.ForceNew(0, 0, 0)
	self.rotation = Quaternion.NewReadOnly(0, 0, 0, 1)
end

function HomelandFastFindInfo:setBounds(boundSize)
	self.halfBoundX = boundSize[1] * 0.5
	self.halfBoundZ = boundSize[2] * 0.5
end

function HomelandFastFindInfo:setExtraInfo(extraInfo)
	self.extraInfo = extraInfo
end

function HomelandFastFindInfo:setTrans(position, rotation)
	self.position:Copy(position)
	self.rotation:refreshReadOnly(rotation[1], rotation[2], rotation[3], rotation[4])

	self.isVertical = Utils.checkRotationIsVertical(rotation)
end

function HomelandFastFindInfo:checkInRange(minX, maxX, minZ, maxZ, includeContact, threshold)
	local boundX, boundZ = self:getHalfBoundWithRot()

	threshold = threshold or 0

	local selfMinX = self.position.x - boundX + threshold
	local selfMaxX = self.position.x + boundX - threshold
	local selfMinZ = self.position.z - boundZ + threshold
	local selfMaxZ = self.position.z + boundZ - threshold

	if includeContact then
		if selfMaxX < minX or maxX < selfMinX then
			return false
		end

		if selfMaxZ < minZ or maxZ < selfMinZ then
			return false
		end

		return true
	end

	if selfMaxX <= minX or maxX <= selfMinX then
		return false
	end

	if selfMaxZ <= minZ or maxZ <= selfMinZ then
		return false
	end

	return true
end

function HomelandFastFindInfo:getHalfBoundWithRot()
	if self.isVertical then
		return self.halfBoundZ, self.halfBoundX
	else
		return self.halfBoundX, self.halfBoundZ
	end
end

return HomelandFastFindInfo
