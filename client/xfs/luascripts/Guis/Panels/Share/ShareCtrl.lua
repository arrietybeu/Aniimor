-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Share\\ShareCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("ShareCtrl")
local MessageName = require("Const.MessageName")
local GlobalData = require("Core.Client.GlobalData")
local Class = require("Core.Framework.Class")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientSettingUtils = require("Utils.ClientSettingUtils")
local NoticeDef = require("Common.NoticeDef")
local UICtrl = require("Guis.UICtrl")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local ShareCtrl = Class.LightClass("ShareCtrl", UICtrl)

ShareCtrl.messages = {}

function ShareCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.info = info

	self:init(info)
end

function ShareCtrl:init(info)
	self.view.rootUComponent:TryChangePage("state", 0)

	self.uploadId = info.qrCodeText

	pg.global.qrCodeMgr:DrawQRCode(self.view.qrCodeRawImage, self.uploadId)
	ClientTextUtils.setText(self.view.idUBaseText, self.uploadId or "")

	local avatarType = info.avatarType or AvatarUtils.AVATAR_TYPE.FACE
	local partStr

	if avatarType == AvatarUtils.AVATAR_TYPE.HAIR then
		partStr = pg.getGameString("CREATE_PLAYER_HAIR")
	elseif avatarType == AvatarUtils.AVATAR_TYPE.CLOTHES then
		partStr = pg.getGameString("APPEARANCE_CLOTHES")
	else
		partStr = pg.getGameString("CREATE_PLAYER_FACE")
	end

	if string.isNilOrEmpty(GlobalData.PlayerName) then
		ClientTextUtils.setText(self.view.nameUBaseText, partStr)
	else
		ClientTextUtils.setText(self.view.nameUBaseText, GlobalData.PlayerName .. partStr)
	end
end

function ShareCtrl:setScreenShot(screenShot)
	self.view.rootUComponent:TryChangePage("state", 1)

	self.view.picUImage.sprite = screenShot
end

function ShareCtrl:addListener()
	function self.view.exitUButton.luaClick()
		self:closePanel()
	end

	function self.view.saveUButton.luaClick()
		if ClientSettingUtils.isCloudGame() then
			pg.global.mobileCameraMgr:SaveImageToAlbum(nil, function(path)
				if string.isNilOrEmpty(path) then
					pg.global.showBubbleMessage(NoticeDef.SAVE_PHOTOGRAPH_FAILED_DISC_FULL)

					return
				end

				pg.global.showBubbleMessageRaw(ClientSettingUtils.getPhotoSyncingToPhoneText(), 3)
				self:dismiss()
			end)
		else
			pg.global.mobileCameraMgr:SaveImageToAlbum(nil, function(path)
				local msg = string.format(pg.getGameString("AVATAR_SAVE"), path)

				pg.global.showBubbleMessageRaw(msg, 3)
				self:dismiss()
			end)
		end
	end

	function self.view.copyUButton.luaClick()
		UIUtils.ClipboardWriter(self.uploadId)
		pg.global.showBubbleMessageRaw(pg.getGameString("AVATAR_COPY"), 3)
	end
end

function ShareCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function ShareCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function ShareCtrl:onShow()
	return
end

function ShareCtrl:onHide()
	return
end

return ShareCtrl
