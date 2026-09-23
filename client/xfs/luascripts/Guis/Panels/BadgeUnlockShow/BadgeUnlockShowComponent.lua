-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BadgeUnlockShow\\BadgeUnlockShowComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("BadgeCollectionComponent")
local Class = require("Core.Framework.Class")
local ClientTextUtils = require("Utils.ClientTextUtils")
local UIComponent = require("Guis.Helper.UIComponent")
local BadgeUtils = require("Guis.Utils.BadgeUtils")
local PlayerBadgeData = require("Data.player_badge_data")
local BadgeUnlockShowComponent = Class.LightClass("BadgeUnlockShowComponent", UIComponent)

function BadgeUnlockShowComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.backGroundCloseUButton = objectReference:GetRefValue("backGroundCloseUButton")
	self.textUnlockDayUSDFText = objectReference:GetRefValue("textTtileUSDFText")
	self.textNameUSDFText = objectReference:GetRefValue("textNameUSDFText")
	self.badgeIconUImage = objectReference:GetRefValue("badgeIconUImage")
	self.fxHongUWidget = objectReference:GetRefValue("fxHongUWidget")
	self.badgeIconBadgeGeneral = objectReference:GetRefValue("badgeIconBadgeGeneral")
	self.blurPopUWidget = objectReference:GetRefValue("blurPopUWidget")
	self.iconAnimation = self.badgeIconUImage.transform:GetComponent("Animation")
end

function BadgeUnlockShowComponent:registerObjects()
	function self.backGroundCloseUButton.luaClick()
		self:onClickCloseBtn()
	end
end

function BadgeUnlockShowComponent:onCtor(info)
	if info then
		self:setInfo(info)
	end
end

function BadgeUnlockShowComponent:initView()
	self:refreshView()
end

function BadgeUnlockShowComponent:refreshView()
	if self.unlockData == nil then
		return
	end

	self.textNameUSDFText:SetActiveFastest(true)
	self.backGroundCloseUButton:SetActiveFastest(true)

	local latestBadgeId = BadgeUtils.getLatestCompleteBadgeId(self.unlockData.badgeGroupId)
	local cfgData = PlayerBadgeData[latestBadgeId]
	local unlockTime, _, _ = BadgeUtils.getBadgeUnlockInfo(latestBadgeId)

	if cfgData then
		ClientTextUtils.setText(self.textNameUSDFText, pg.getLocalizationText(cfgData.name))

		self.badgeIconUImage.url = cfgData.icon
	end

	if unlockTime then
		self.textUnlockDayUSDFText:SetActiveFastest(true)
		ClientTextUtils.setText(self.textUnlockDayUSDFText, unlockTime)
	else
		self.textUnlockDayUSDFText:SetActiveFastest(false)
	end

	local quality = BadgeUtils.getBadgeQualityByBadgeId(latestBadgeId)

	if quality == BadgeUtils.RainBowQuality then
		self.badgeIconUImage:SetMaterial(BadgeUtils.RainBowMatPath)
		self.fxHongUWidget:SetActive(true)
	else
		self.badgeIconUImage.material = ""

		self.fxHongUWidget:SetActive(false)
	end
end

function BadgeUnlockShowComponent:setInfo(info)
	self.unlockData = info.unlockData
	self.closeCallback = info.closeCallback
	self.targetPosition = info.targetPosition
	self.targetSize = info.targetSize
end

function BadgeUnlockShowComponent:setClickCallback(callback)
	self.clickCallback = callback
end

function BadgeUnlockShowComponent:playFlyAnim()
	self.iconAnimation:Stop()
	self.blurPopUWidget:SetActive(false)
	self.textNameUSDFText:SetActiveFastest(false)
	self.backGroundCloseUButton:SetActiveFastest(false)

	if self.targetPosition == nil then
		self:onEndFly()

		return
	end

	local targetSizeX = self.targetSize and self.targetSize.x or 308
	local curSize = self.badgeIconUImage.sizeDelta
	local scale = targetSizeX / curSize.x * 1.2

	self.badgeIconUImage.localPosition = Vector3(0, 0, 0)
	self.badgeIconBadgeGeneral.subParent = self.badgeIconUImage.parentWidget.transform
	self.badgeIconBadgeGeneral.targetPosition = self.targetPosition

	function self.badgeIconBadgeGeneral.luaEndFly()
		self:onEndFly()
	end

	self.badgeIconBadgeGeneral.endScale = Vector3(scale, scale, scale)

	self.badgeIconBadgeGeneral:PlayBadge()
	pg.game.audio:playEvent("SFX_UI_BadgeSystem_BadgeBoxCollect_03")
end

function BadgeUnlockShowComponent:onEndFly()
	self.ctrl:dismiss()
end

function BadgeUnlockShowComponent:onDestroy()
	if self.badgeIconBadgeGeneral then
		self.badgeIconBadgeGeneral:StopBadge()
	end

	pg.game.audio:stopEvent("SFX_UI_BadgeSystem_BadgeBoxCollect_03")
	pg.game.audio:playEvent("SFX_UI_BadgeSystem_BadgeBoxCollect_04")

	if self.closeCallback then
		self.closeCallback(self.unlockData)
	end

	self.unlockData = nil
	self.closeCallback = nil
	self.targetPosition = nil
	self.targetSize = nil
	self.clickCallback = nil
end

function BadgeUnlockShowComponent:onClickCloseBtn()
	local callback = self.clickCallback

	if callback then
		callback()
	end

	self.clickCallback = nil

	self:playFlyAnim()
end

return BadgeUnlockShowComponent
