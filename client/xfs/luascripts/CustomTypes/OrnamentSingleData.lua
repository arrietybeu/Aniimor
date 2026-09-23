-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\OrnamentSingleData.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local lume = require("Core.Common.lume")
local PropertyTypes = require("Core.PropertySync.PropertyTypes")
local class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local HomelandConfigData = require("Data.homeland_config_data")
local OrnamentSingleData = class.LiteClass("OrnamentSingleData", CustomDict)
local POSITION_INT_BASE = HomeLandUtils.ORNAMENT_POSITION_INT_BASE
local ROTATION_INT_BASE = HomeLandUtils.ORNAMENT_ROTATION_INT_BASE
local SCALE_INT_BASE = HomeLandUtils.ORNAMENT_SCALE_INT_BASE

function OrnamentSingleData:getPosition()
	return Vector3(self.posX / POSITION_INT_BASE, self.posY / POSITION_INT_BASE, self.posZ / POSITION_INT_BASE)
end

function OrnamentSingleData:getRotation()
	return Quaternion.Euler(self.rotX / ROTATION_INT_BASE, self.rotY / ROTATION_INT_BASE, self.rotZ / ROTATION_INT_BASE)
end

function OrnamentSingleData:getYawAngle()
	return self.rotY / ROTATION_INT_BASE
end

function OrnamentSingleData:getScale()
	return Vector3(self.scaleX / SCALE_INT_BASE, self.scaleY / SCALE_INT_BASE, self.scaleZ / SCALE_INT_BASE)
end

function OrnamentSingleData:checkIsVertical()
	return Utils.checkYawIsVertical(self:getYawAngle())
end

function OrnamentSingleData:isFoodSlot()
	return lume.find(HomelandConfigData.foodFacilityIds, self.homeId) ~= nil
end

return OrnamentSingleData
