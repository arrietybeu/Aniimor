-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\UIScenes\\FishingCaptureResultScene.lua

local Class = require("Core.Framework.Class")
local UISceneBase = require("GameApp.UIScene.UISceneBase")
local ClientVirtualEntityUtils = require("Utils.ClientVirtualEntityUtils")
local ClientConst = require("Const.ClientConst")
local FishingCaptureResultScene = Class.LightClass("FishingCaptureResultScene", UISceneBase)

function FishingCaptureResultScene:onCtor()
	self._bossEntityKey = nil
end

function FishingCaptureResultScene:onStart(param)
	local objectReference = self.scene:GetComponent("ObjectReference")

	self.bossModelRoot = objectReference:GetRefValue("bossModelRoot")
end

function FishingCaptureResultScene:showBossModel(bossTemplateId)
	if self._bossEntityKey then
		self:removeEntity(self._bossEntityKey)

		self._bossEntityKey = nil
	end

	_ = bossTemplateId
	_ = ClientVirtualEntityUtils
	_ = ClientConst
end

function FishingCaptureResultScene:onActiveChanged(active)
	for _, entity in pairs(self.entPool) do
		if entity.eModel then
			entity.eModel:SetActive(active)
		end
	end
end

function FishingCaptureResultScene:onDestroy()
	self._bossEntityKey = nil
end

return FishingCaptureResultScene
