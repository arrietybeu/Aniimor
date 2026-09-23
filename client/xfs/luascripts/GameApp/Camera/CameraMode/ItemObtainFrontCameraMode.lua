-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Camera\\CameraMode\\ItemObtainFrontCameraMode.lua

local Class = require("Core.Framework.Class")
local CameraConst = require("GameApp.Camera.CameraConst")
local FixedWithTargetCameraMode = require("GameApp.Camera.CameraMode.FixedWithTargetCameraMode")
local ItemObtainFrontCameraMode = Class.OldLightClass("ItemObtainFrontCameraMode", FixedWithTargetCameraMode)

function ItemObtainFrontCameraMode:getCameraName()
	return CameraConst.CAMERA_NAME_ITEM_OBTAIN_FRONT
end

function ItemObtainFrontCameraMode:refreshCameraView()
	return
end

return ItemObtainFrontCameraMode
