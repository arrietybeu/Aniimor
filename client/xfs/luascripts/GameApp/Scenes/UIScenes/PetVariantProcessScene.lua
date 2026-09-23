-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\UIScenes\\PetVariantProcessScene.lua

local AddressDataConst = require("Const.AddressDataConst")
local Class = require("Core.Framework.Class")
local UISceneBase = require("GameApp.UIScene.UISceneBase")
local Camera = CS.UnityEngine.Camera
local PetVariantProcessScene = Class.LightClass("PetVariantProcessScene", UISceneBase)
local EFFECT_PRELOAD_OWNER = "PetVariantProcessScene"

function PetVariantProcessScene:onCtor()
	pg.game.effect:preloadEntityEffect(EFFECT_PRELOAD_OWNER, AddressDataConst.PET_VARIANT_HEART_BOOM_EFFECT)

	self._heartBoomEffectPreloaded = true
end

function PetVariantProcessScene:onStart()
	local cameras = self.scene:GetComponentsInChildren(typeof(Camera), true)

	self.camera = cameras[0]

	pg.global.cameraMgr:SetUISceneCamera(self.camera)
end

function PetVariantProcessScene:getCamera()
	return self.camera
end

function PetVariantProcessScene:getCenterPosition()
	return self.scene.transform.position
end

function PetVariantProcessScene:onDestroy()
	if not self._heartBoomEffectPreloaded then
		return
	end

	self._heartBoomEffectPreloaded = nil

	pg.game.effect:unPreloadEntityEffect(EFFECT_PRELOAD_OWNER, AddressDataConst.PET_VARIANT_HEART_BOOM_EFFECT)
end

return PetVariantProcessScene
