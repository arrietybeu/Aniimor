-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\PetBall\\PetBallSystem.lua

local Class = require("Core.Framework.Class")
local SystemBase = require("GameApp.Core.SystemBase")
local PetBallSystem = Class.LightClass("PetBallSystem", SystemBase)

function PetBallSystem:onCtor()
	SystemBase.onCtor(self)

	self.eggInfo = nil
end

function PetBallSystem:setEggInfo(info)
	self.eggInfo = info
end

function PetBallSystem:bindPreviewSceneCamera(cameraObj)
	self.previewSceneCameraGameObject = cameraObj
end

function PetBallSystem:setPreviewCameraEnabled(enable)
	if not self.previewSceneCameraGameObject then
		return
	end

	self.previewSceneCameraGameObject:SetActiveEx(enable)
end

return PetBallSystem
