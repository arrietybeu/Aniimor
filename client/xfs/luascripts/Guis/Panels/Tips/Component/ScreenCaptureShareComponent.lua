-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Component\\ScreenCaptureShareComponent.lua

local ClientConst = require("Const.ClientConst")
local MessageName = require("Const.MessageName")
local UIConst = require("Const.UIConst")
local Time = require("Core.Common.Time")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local TipAreaConst = require("Guis.Panels.Tips.TipAreaConst")
local PlatformPremiumFeatureService = require("SDK.Platform.PlatformPremiumFeatureService")
local SocialMediaShareService = require("SDK.SocialMediaShareService")
local ScreenCaptureShareComponent = Class.LightClass("ScreenCaptureShareComponent", UIComponent)

ScreenCaptureShareComponent.messages = {
	[MessageName.SCREENSHOT_DETECTED] = {
		"captureScreenForShare",
		true
	}
}

function ScreenCaptureShareComponent:onCtor()
	self.sessionVersion = 0
	self.nextScreenshotAllowedTime = 0
	self.screenshotCapturePending = false
	self.screenshotShareCache = nil
	self.isCacheCheckPending = false
	self.nextFrameId = nil
	self.isDestroyed = false

	function self.cacheCheckFunc()
		return self:checkCacheReady()
	end
end

function ScreenCaptureShareComponent:isCapturePending()
	return self.screenshotCapturePending
end

function ScreenCaptureShareComponent:captureScreenForShare()
	if ClientConfigCloudEnable == "true" then
		return
	end

	if pg.global.ui:checkUIVisible(UIConst.UI_ID_LOGIN) then
		return
	end

	local sharingPanelOpened = pg.global.ui:checkUIOpen(UIConst.UI_ID_HUD_SCREENSHOT_SHARING)

	if sharingPanelOpened or self.screenshotCapturePending then
		return
	end

	local imageShareConfig = SocialMediaShareService.getCurrentConfig(SocialMediaShareService.ConfigType.Image)

	if imageShareConfig == nil then
		return
	end

	local now = Time.realSecondCache

	if now < self.nextScreenshotAllowedTime then
		return
	end

	self.nextScreenshotAllowedTime = now + imageShareConfig.cdTime
	self.screenshotCapturePending = true

	local ownerView = self.view
	local sessionVersion = self.sessionVersion

	local function onScreenCaptured(sprite)
		if self.isDestroyed or self.sessionVersion ~= sessionVersion then
			return
		end

		self.screenshotCapturePending = false

		if self.view ~= ownerView or self.ctrl.view ~= ownerView or not self.ctrl:checkUIOpen() then
			return
		end

		self:cacheScreenCaptureShare(sprite, imageShareConfig)
	end

	pg.global.mobileCameraMgr:CaptureScreenDelaySave(onScreenCaptured)
end

function ScreenCaptureShareComponent:cacheScreenCaptureShare(sprite, imageShareConfig)
	if IsNil(sprite) then
		return
	end

	self.screenshotShareCache = {
		sprite = sprite,
		imageShareConfig = imageShareConfig
	}

	self:tryPushScreenCaptureShare()
end

function ScreenCaptureShareComponent:tryPushScreenCaptureShare()
	if self:isScreenCaptureShareBlocked() then
		self:waitForCacheReady()

		return
	end

	self:stopCacheCheck()
	self:scheduleNextFramePush()
end

function ScreenCaptureShareComponent:isScreenCaptureShareBlocked()
	if not self.ctrl:checkUIOpen() or not self.ctrl:checkUIVisible() then
		return true
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_HUD_SCREENSHOT_SHARING) then
		return true
	end

	return self:isGameProcessLocked()
end

function ScreenCaptureShareComponent:isGameProcessLocked()
	if pg.global.ui:checkUIVisible(UIConst.UI_ID_CREATE_ROLE_TIMELINE) then
		local createRoleTimeline = pg.global.ui.createRoleTimeline
		local _, statePage = createRoleTimeline.view.root:TryGetCurrentPage("State")

		if statePage == 0 then
			return true
		end
	end

	local cutsceneSystem = pg.game.cutscene
	local cutscene = cutsceneSystem:getCurCutScene()
	local isCutsceneLocked = pg.global.ui:checkUIOpen(UIConst.UI_ID_VIDEO) or cutscene and cutscene:isPlaying() or cutsceneSystem:isInCutsceneState()

	if isCutsceneLocked then
		return true
	end

	local isLoading = not pg.game.loading:isFinished() or pg.global.ui.loadProgress:checkUIVisible() or pg.global.ui:checkUIOpen(UIConst.UI_ID_LOADING_SHOW)

	if isLoading then
		return true
	end

	local isNetworkLocked = pg.game.gameState == ClientConst.GS_DISCONNECT or pg.global.ui:checkUIOpen(UIConst.UI_ID_NET_LOADING) or PlatformPremiumFeatureService.isDisconnectTipShown()

	if isNetworkLocked then
		return true
	end

	return false
end

function ScreenCaptureShareComponent:waitForCacheReady()
	if self.isCacheCheckPending then
		return
	end

	self.isCacheCheckPending = true

	self.ctrl:addPendingCheck(self.cacheCheckFunc)
end

function ScreenCaptureShareComponent:checkCacheReady()
	if self:isScreenCaptureShareBlocked() then
		return false
	end

	self.isCacheCheckPending = false

	self:scheduleNextFramePush()

	return true
end

function ScreenCaptureShareComponent:stopCacheCheck()
	if not self.isCacheCheckPending then
		return
	end

	self.isCacheCheckPending = false

	self.ctrl:removePendingCheck(self.cacheCheckFunc)
end

function ScreenCaptureShareComponent:scheduleNextFramePush()
	if self.nextFrameId then
		return
	end

	local function pushCache()
		self:pushCacheNextFrame()
	end

	self.nextFrameId = self:startFrameTimer(pushCache, 1)
end

function ScreenCaptureShareComponent:pushCacheNextFrame()
	self.nextFrameId = nil

	if self.isDestroyed or self.screenshotShareCache == nil then
		return
	end

	if self:isScreenCaptureShareBlocked() then
		self:waitForCacheReady()

		return
	end

	local cache = self.screenshotShareCache

	self.screenshotShareCache = nil

	self.ctrl:pushAreaManagerData({
		itemKey = "ScreenCaptureShare",
		areaType = TipAreaConst.AREAS.C,
		sprite = cache.sprite,
		imageShareConfig = cache.imageShareConfig
	})
end

function ScreenCaptureShareComponent:onDestroy()
	self.isDestroyed = true

	self:clear()
	UIComponent.onDestroy(self)
end

function ScreenCaptureShareComponent:clear()
	self.sessionVersion = self.sessionVersion + 1
	self.nextScreenshotAllowedTime = 0
	self.screenshotCapturePending = false

	self:stopCacheCheck()

	if self.nextFrameId then
		self:killFrameTimer(self.nextFrameId)

		self.nextFrameId = nil
	end

	self.screenshotShareCache = nil
end

return ScreenCaptureShareComponent
