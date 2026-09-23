-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PhotoScanCode\\PhotoScanCodeCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("PhotoScanCodeCtrl")
local MessageName = require("Const.MessageName")
local Utils = require("Common.Utils.Utils")
local ClientUtils = require("Utils.ClientUtils")
local PhotographyStudioUtils = require("Utils.PhotographyStudioUtils")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PhotoScanCodeCtrl = Class.LightClass("PhotoScanCodeCtrl", UICtrl)

PhotoScanCodeCtrl.messages = {}

function PhotoScanCodeCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self:setOpenInfo(info)
end

function PhotoScanCodeCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:close()
	end

	function self.view.btnScanUButton.luaClick()
		if IS_MOBILE then
			pg.global.mobileCameraMgr:OpenPictureOnEditor()
		else
			ClientUtils.openPictureOnEditor()
		end
	end

	function pg.global.mobileCameraMgr.luaCallBackPickImage(texture)
		pg.global.qrCodeMgr:ScanTexture(texture)
	end

	function pg.global.qrCodeMgr.onScannedSuccess(qrText)
		self:submitCode(qrText, false)
	end

	function pg.global.qrCodeMgr.onScannedFail()
		pg.global.showBubbleMessageRaw(pg.getGameString("SCAN_AVATAR_FAIL"))
	end

	function self.view.btnPasteUButton.luaClick()
		self.view.inputField.text = UIUtils.ClipboardReader()
	end

	function self.view.btnUseUButton.luaClick()
		local codeStr = tostring(self.view.inputField.text)

		if self:checkValidCode(codeStr) then
			if self.isPhotographyStudio then
				self:submitCode(codeStr, true)
			else
				local qrText = Utils.genPhotoPresetUniqueId(false, codeStr)

				self:submitCode(qrText, true)
			end
		else
			local errorKey = self.isPhotographyStudio and "PHOTO_STUDIO_ERROR_CODE" or "PHOTO_ERROR_CODE"

			pg.global.showBubbleMessageRaw(pg.getGameString(errorKey))
		end
	end
end

function PhotoScanCodeCtrl:setOpenInfo(info)
	self.isPhotographyStudio = info ~= nil and info.isPhotographyStudio == true
	self.codeCallback = info and info.codeCallback

	self.view:refreshText(self.isPhotographyStudio)
end

function PhotoScanCodeCtrl:submitCode(qrText, notDecode)
	if self.codeCallback then
		self.codeCallback(qrText, notDecode)

		return
	end

	facade:sendMsgToUI(MessageName.PHOTO_SCAN_CODE, {
		qrText = qrText,
		notDecode = notDecode
	})
end

function PhotoScanCodeCtrl:checkValidCode(codeStr)
	if self.isPhotographyStudio then
		return PhotographyStudioUtils.getPhotographyStudioUidByShareCode(codeStr) ~= nil
	end

	if #codeStr ~= 16 then
		return false
	end

	return true
end

function PhotoScanCodeCtrl:onDestroy()
	UICtrl.onDestroy(self)

	pg.global.mobileCameraMgr.luaCallBackPickImage = nil
	pg.global.qrCodeMgr.onScannedSuccess = nil
	pg.global.qrCodeMgr.onScannedFail = nil
end

function PhotoScanCodeCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self:setOpenInfo(info)
end

return PhotoScanCodeCtrl
