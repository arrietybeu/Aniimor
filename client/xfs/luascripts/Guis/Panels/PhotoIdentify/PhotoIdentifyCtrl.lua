-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PhotoIdentify\\PhotoIdentifyCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PhotoIdentifyCtrl = Class.LightClass("PhotoIdentifyCtrl", UICtrl)
local UIConst = require("Const.UIConst")

PhotoIdentifyCtrl.messages = {}

function PhotoIdentifyCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.durationTime = 2.2
	self.delayPlayEffectTime = 0.2

	pg.game.camera.photoCameraMode.cameraMode:UpdateCameraViewLookAtTarget()
	self:startTimer(function()
		if pg.global.ui:checkUIOpen(UIConst.UI_ID_PHOTO) then
			pg.global.ui:close(UIConst.UI_ID_PHOTO)
		end

		pg.game.camera.photoCameraMode.cameraMode.forceLookAtTarget = false

		self:close()
		pg.me:serverMsg("RPC_CS_TakePhotoGuess", info.curLockedEntity.staticId)
	end, self.durationTime)

	if info.curLockedEntity then
		self:startTimer(function()
			info.curLockedEntity.eModel.shaderView:PlayPhotoIdentifyEffect(self.durationTime - self.delayPlayEffectTime, pg.game.camera.photoCameraMode.stackCameraObj.transform.position, true)
		end, self.delayPlayEffectTime)
	end
end

function PhotoIdentifyCtrl:addListener()
	return
end

function PhotoIdentifyCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function PhotoIdentifyCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function PhotoIdentifyCtrl:onShow()
	return
end

function PhotoIdentifyCtrl:onHide()
	return
end

return PhotoIdentifyCtrl
