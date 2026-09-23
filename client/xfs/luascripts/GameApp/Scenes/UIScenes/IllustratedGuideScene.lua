-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\UIScenes\\IllustratedGuideScene.lua

local Class = require("Core.Framework.Class")
local UISceneBase = require("GameApp.UIScene.UISceneBase")
local IllustratedGuideScene = Class.LightClass("IllustratedGuideScene", UISceneBase)

function IllustratedGuideScene:onCtor()
	self.sceneReady = false
end

function IllustratedGuideScene:onStart(_param)
	self.rootTransform = self.scene.transform:Find("Global")
	self.objectReference = self.rootTransform:GetComponent("ObjectReference")
	self.camera = self.objectReference:GetRefValue("camera")
	self.sceneReady = true
end

function IllustratedGuideScene:isReady()
	return self.sceneReady
end

function IllustratedGuideScene:onDestroy()
	self.sceneReady = false
end

return IllustratedGuideScene
