-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\BaseScene.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local ClientUtils = require("Utils.ClientUtils")
local logger = LoggerManager.getLogger("BaseScene")
local SceneData = require("Data.scene_data")
local BaseScene = Class.LightClass("BaseScene")

function BaseScene:ctor(sceneId)
	self.sceneId = sceneId

	self:initSceneParams()
	self:onCtor()
end

function BaseScene:initSceneParams()
	local sceneInfo = SceneData[self.sceneId]

	if sceneInfo == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("【BaseScene】SceneId not configured", self.sceneId)
		end

		return
	end

	self.sceneName = sceneInfo.file
	self.hideRedDot = sceneInfo.prompt == 1
	self.script = sceneInfo.script
end

function BaseScene:start(lastScene)
	if lastScene and lastScene.hideRedDot and not self.hideRedDot then
		CS.XGUI.RedDotMgr.ClearCacheTree()
	end

	self:onStart()
end

function BaseScene:loaded()
	self:onLoaded()
end

function BaseScene:reset(newSceneId)
	local oldSceneId = self.sceneId

	self.sceneId = newSceneId

	self:initSceneParams()
	self:onReset(oldSceneId, newSceneId)
end

function BaseScene:isSameFile(sceneId)
	local levelName = ClientUtils.getSceneName(sceneId)

	return levelName == self.sceneName
end

function BaseScene:isHideRedDot()
	return self.hideRedDot == true
end

function BaseScene:isSameScript(sceneId)
	if not SceneData[sceneId] then
		return
	end

	local script = SceneData[sceneId].script or "DefaultScene"

	return self.script == script
end

function BaseScene:onCtor()
	return
end

function BaseScene:onStart()
	return
end

function BaseScene:onLoaded()
	return
end

function BaseScene:onReset(oldSceneId, newSceneId)
	return
end

function BaseScene:onDestroy()
	return
end

return BaseScene
