-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\HomePetSingleData.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local PropertyTypes = require("Core.PropertySync.PropertyTypes")
local class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local SceneUtils = require("Common.Utils.SceneUtils")
local HomePetSingleData = class.LiteClass("HomePetSingleData", CustomDict)

function HomePetSingleData:getPosition()
	return Utils.pos3ToPosition(self.pos3)
end

function HomePetSingleData:getRotation()
	return Utils.yawAngleIntToQuaternion(self.yawAngle)
end

function HomePetSingleData:checkIsVertical()
	return Utils.checkRotationIsVertical(self:getRotation())
end

function HomePetSingleData.genPlaceInfo(sceneId, pointId, ent)
	local pos, rot = SceneUtils.getCommonBasicsPosition(sceneId, pointId)

	pos = pos or ent and ent:getPosition() or Vector3.zero
	rot = rot or ent and ent:getRotation() or Quaternion.identity

	return {
		pos3 = Utils.positionToPos3(pos:getRawTable()),
		yawAngle = rot:ToYaw()
	}
end

return HomePetSingleData
