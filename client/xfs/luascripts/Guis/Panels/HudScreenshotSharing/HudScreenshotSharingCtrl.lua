-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudScreenshotSharing\\HudScreenshotSharingCtrl.lua

local Time = require("Core.Common.Time")
local Class = require("Core.Framework.Class")
local SocialMediaShareListComponent = require("Guis.Helper.SocialMediaShareListComponent")
local UICtrl = require("Guis.UICtrl")
local HudScreenshotSharingCtrl = Class.LightClass("HudScreenshotSharingCtrl", UICtrl)

function HudScreenshotSharingCtrl:addListener()
	UICtrl.addListener(self)

	function self.view.btnCloseUButton.luaClick()
		self:close()
	end

	function self.view.btnDownloadUButton.luaClick()
		self:saveScreenshot()
	end

	local function requestImagePath(callback)
		callback(self:getScreenshotImagePath(), self.screenshotSprite)
	end

	self.shareListComponent = SocialMediaShareListComponent.new(self, self.view.listBtnUList, requestImagePath)
end

function HudScreenshotSharingCtrl:saveScreenshot()
	local function onScreenshotSaved(path)
		local message = string.format(pg.getGameString("AVATAR_SAVE"), path)

		pg.global.showBubbleMessageRaw(message, 3)
	end

	local function onImageChecked(canSave)
		if canSave ~= true then
			return
		end

		pg.global.mobileCameraMgr:SaveImageToAlbum(nil, onScreenshotSaved)
	end

	self.shareListComponent:checkImage(self.screenshotSprite, onImageChecked)
end

function HudScreenshotSharingCtrl:getScreenshotImagePath()
	if string.isNilOrEmpty(self.screenshotImagePath) then
		self.screenshotImagePath = pg.global.mobileCameraMgr:SaveCapturedImageToCache(self.screenshotShareKey)
	end

	return self.screenshotImagePath
end

function HudScreenshotSharingCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.screenshotShareKey = string.format("%.0f_%d", Time.getMillisecond(), Time.frameCount)
	self.screenshotSprite = info.sprite
	self.screenshotImagePath = nil
	self.view.photoUImage.sprite = self.screenshotSprite

	self.shareListComponent:refresh()
end

function HudScreenshotSharingCtrl:onDestroy()
	self.screenshotShareKey = nil
	self.screenshotSprite = nil
	self.screenshotImagePath = nil

	UICtrl.onDestroy(self)
end

return HudScreenshotSharingCtrl
