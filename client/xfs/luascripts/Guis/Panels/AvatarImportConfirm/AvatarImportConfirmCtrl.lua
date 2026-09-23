-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AvatarImportConfirm\\AvatarImportConfirmCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("AvatarImportConfirmCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local AvatarShareService = require("Guis.Utils.AvatarShareService")
local AvatarImportConfirmCtrl = Class.LightClass("AvatarImportConfirmCtrl", UICtrl)

AvatarImportConfirmCtrl.messages = {}

function AvatarImportConfirmCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	if info then
		self.confirmCb = info.confirmCb
		self.cancelCb = info.cancelCb
		self.customData = info.customData
		self.shareType = info.shareType or info.customData and info.customData.shareType

		ClientTextUtils.setText(self.view.idUBaseText, info.id or "")
		ClientTextUtils.setText(self.view.nameUBaseText, info.name or "")
	end

	self.avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)

	local titleKey = "AVATAR_IMPORT_TITLE"

	if self.shareType == AvatarShareService.SHARE_TYPE.HAIR then
		titleKey = "HAIR_IMPORT_TITLE"
	elseif self.shareType == AvatarShareService.SHARE_TYPE.CLOTHES then
		titleKey = "STAIN_IMPORT_TITLE"
	end

	ClientTextUtils.setText(self.view.titleUSDFText, pg.getGameString(titleKey))
end

function AvatarImportConfirmCtrl:closePanel()
	print("[ClothesShare] AvatarImportConfirmCtrl.closePanel cancelCb=" .. tostring(self.cancelCb ~= nil))

	if self.cancelCb then
		self:cancelCb()
	end

	UICtrl.closePanel(self)
end

function AvatarImportConfirmCtrl:addListener()
	function self.view.cancelUButton.luaClick()
		self:closePanel()
	end

	function self.view.confirmUButton.luaClick()
		if self.confirmCb then
			self.confirmCb()
		end

		self.cancelCb = nil

		self:dismiss()
	end
end

function AvatarImportConfirmCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function AvatarImportConfirmCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self.avatarScene:addCameraZoomKeyBinding(self.view.gameObject)
end

function AvatarImportConfirmCtrl:onShow()
	return
end

function AvatarImportConfirmCtrl:onHide()
	return
end

function AvatarImportConfirmCtrl:onVisibleChange(visible)
	if visible then
		self.avatarScene:registerGesture(self.uid, {
			maskRayBoxTrans = self.view.maskRayBoxTrans
		})

		if self.shareType == AvatarShareService.SHARE_TYPE.CLOTHES then
			local stainCtrl = pg.global.ui and pg.global.ui.workShopCostumeStain

			if stainCtrl and stainCtrl.model then
				stainCtrl.model:initAvatarSceneData(true)
			else
				self.avatarScene:setAvatarCameraModeFar()
			end
		else
			self.avatarScene:setAvatarCameraModeCloseHead()
		end
	else
		self.avatarScene:unRegisterGesture(self.uid)
	end
end

return AvatarImportConfirmCtrl
