-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AvatarImport\\AvatarImportCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("AvatarImportCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local AvatarShareService = require("Guis.Utils.AvatarShareService")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientUtils = require("Utils.ClientUtils")
local AvatarImportCtrl = Class.LightClass("AvatarImportCtrl", UICtrl)

AvatarImportCtrl.messages = {}

function AvatarImportCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)
end

function AvatarImportCtrl:addListener()
	function self.view.backUButton.luaClick()
		self:closePanel()
	end

	function self.view.scanUButton.luaClick()
		if IS_MOBILE then
			pg.global.mobileCameraMgr:OpenQRCodeScanner()
		else
			ClientUtils.openPictureOnEditor()
		end
	end

	function pg.global.mobileCameraMgr.luaCallBackPickImage(texture)
		pg.global.qrCodeMgr:ScanTexture(texture)
	end

	function pg.global.qrCodeMgr.onScannedSuccess(qrText)
		self:submitById(qrText)
	end

	function pg.global.qrCodeMgr.onScannedFail()
		pg.global.showBubbleMessageRaw(pg.getGameString("SCAN_AVATAR_FAIL"), 3)
	end

	function self.view.confirmUButton.luaClick()
		self:submitById(self.view.idUTMPInputField.text)
		self.view.idUTMPInputField:DeSelect()
	end

	function self.view.idUTMPInputField.luaOnSelect()
		self:SetConfirmKeyActive(true)
	end

	function self.view.idUTMPInputField.luaOnDeSelect()
		self:SetConfirmKeyActive(false)
	end
end

function AvatarImportCtrl:submitById(id)
	AvatarShareService.importById(id)
end

function AvatarImportCtrl:onDestroy()
	pg.global.qrCodeMgr:StopScan()

	pg.global.mobileCameraMgr.luaCallBackPickImage = nil
	pg.global.qrCodeMgr.onScannedSuccess = nil
	pg.global.qrCodeMgr.onScannedFail = nil

	UICtrl.onDestroy(self)
end

function AvatarImportCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self.avatarScene:addCameraZoomKeyBinding(self.view.gameObject)
	ClientTextUtils.setText(self.view.textUSDFText, pg.getGameString("AVATAR_IMPORT_TIP"))
	ClientTextUtils.setText(self.view.tMPUSDFText, pg.getGameString("BACK_TO_PRE"))
	ClientTextUtils.setText(self.view.txtNameUSDFText, pg.getGameString("AVATAR_IMPORT_SCAN"))

	local shareType = info and info.shareType or AvatarShareService.SHARE_TYPE.FACE
	local titleKey = "AVATAR_IMPORT_TITLE"

	if shareType == AvatarShareService.SHARE_TYPE.HAIR then
		titleKey = "HAIR_IMPORT_TITLE"
	elseif shareType == AvatarShareService.SHARE_TYPE.CLOTHES then
		titleKey = "STAIN_IMPORT_TITLE"
	end

	ClientTextUtils.setText(self.view.titleUSDFText, pg.getGameString(titleKey))

	local scanKey = "AVATAR_IMPORT_INPUT"

	if shareType == AvatarShareService.SHARE_TYPE.HAIR then
		scanKey = "HAIR_IMPORT_INPUT"
	elseif shareType == AvatarShareService.SHARE_TYPE.CLOTHES then
		scanKey = "STAIN_IMPORT_INPUT"
	end

	ClientTextUtils.setText(self.view.idUTMPInputField.placeHolder, pg.getGameString(scanKey))
end

function AvatarImportCtrl:refreshConsoleBarState()
	if self.view.idUTMPInputField and not self.view.idUTMPInputField.allowInput then
		self:SetConfirmKeyActive(false)
	end
end

function AvatarImportCtrl:SetConfirmKeyActive(active)
	if self.view.confirmKeyHotKeyContent then
		if active then
			self.view.confirmKeyHotKeyContent:SetHotKeyPaths("Raw/GamepadButtonSouth")
		else
			self.view.confirmKeyHotKeyContent:SetHotKeyPaths("")
		end
	end
end

function AvatarImportCtrl:onShow()
	return
end

function AvatarImportCtrl:onHide()
	return
end

function AvatarImportCtrl:onVisibleChange(visible)
	if visible then
		self.avatarScene:registerGesture(self.uid, {
			maskRayBoxTrans = self.view.maskRayBoxTrans
		})
		self.avatarScene:setAvatarCameraModeCloseHead()
	else
		pg.global.qrCodeMgr:StopScan()
		self.avatarScene:unRegisterGesture(self.uid)
	end
end

return AvatarImportCtrl
