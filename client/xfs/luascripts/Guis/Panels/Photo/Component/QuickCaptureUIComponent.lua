-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Photo\\Component\\QuickCaptureUIComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local logger = LoggerManager.getLogger("QuickCaptureUIComponent")
local UIComponent = require("Guis.Helper.UIComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientSettingUtils = require("Utils.ClientSettingUtils")
local NoticeDef = require("Common.NoticeDef")
local PhotoIdentifyData = require("Data.photo_identify_data")
local PetResearchContentData = require("Data.pet_research_content_data")
local QuickCaptureUIComponent = Class.LightClass("QuickCaptureUIComponent", UIComponent)
local LuaUIUtils = require("Utils.LuaUIUtils")

function QuickCaptureUIComponent:ctor(ctrl, trans)
	UIComponent.ctor(self, ctrl, trans)
end

function QuickCaptureUIComponent:onShow()
	self.view.rootComponent:TryChangePage("CaptureMode", 1)
	self:registerStpFinishCb()
	self:playEntryAni()
end

function QuickCaptureUIComponent:registerStpFinishCb()
	return
end

function QuickCaptureUIComponent:findObjects()
	return
end

function QuickCaptureUIComponent:playEntryAni()
	LuaUIUtils.setUIViewVisible(self.view.quickCaptureEntry, true)
	self.view.animation:Play("UI_Ani_Photograph_Capture_InAni")
	pg.game.audio:triggerEvent("ui_photo_catch_intro")
end

function QuickCaptureUIComponent:initView()
	function self.view.takePhotoBtn.luaClick()
		self.ctrl:takePhoto()
	end

	function self.view.captureBtn.luaClick()
		pg.global.ui:open(UIConst.UI_ID_PHOTO_SHOW, {
			sprite = self.view.photoSprite,
			photoTraitInfo = self.ctrl.photoTraitInfo
		})
	end

	if ClientSettingUtils.isCloudGame() then
		ClientTextUtils.setText(self.view.captureTip, "")
	else
		ClientTextUtils.setText(self.view.captureTip, pg.getGameString("SAVED_LOCAL"))
	end

	LuaUIUtils.setUIViewVisible(self.view.keys, true)
end

function QuickCaptureUIComponent:onDestroy()
	UIComponent.onDestroy(self)
	pg.game.camera:closeQuickPhotoCamera()
end

function QuickCaptureUIComponent:setPhotoTitle()
	local photoInfo = PhotoIdentifyData[self.quickPhotoId]

	if photoInfo.unlockId == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("unlockId not in PhotoIdentifyData")
		end

		return
	end

	local unlockId = photoInfo.unlockId[1]
	local photoName = photoInfo.desc

	if not PetResearchContentData[unlockId] then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("unlockId not in PetResearchContentData unlockId:", unlockId)
		end
	else
		local petName = PetResearchContentData[unlockId].name

		self.view:refreshUnlockInfo(petName, photoName)
	end
end

function QuickCaptureUIComponent:update()
	return
end

function QuickCaptureUIComponent:savePhoto()
	if pg.global.mobileCameraMgr.HasCapturedImage and not pg.global.mobileCameraMgr:HasCapturedImage() and ClientSettingUtils.isCloudGame() then
		return
	end

	if ClientSettingUtils.isCloudGame() then
		pg.global.mobileCameraMgr:SaveImageToAlbum(nil, function(path)
			if string.isNilOrEmpty(path) then
				pg.global.showBubbleMessage(NoticeDef.SAVE_PHOTOGRAPH_FAILED_DISC_FULL)

				return
			end

			pg.global.showBubbleMessageRaw(ClientSettingUtils.getPhotoSyncingToPhoneText())
		end)
	else
		pg.global.mobileCameraMgr:SaveImageToAlbum()
	end
end

return QuickCaptureUIComponent
