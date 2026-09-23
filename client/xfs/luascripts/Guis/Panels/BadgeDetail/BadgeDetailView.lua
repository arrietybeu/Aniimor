-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BadgeDetail\\BadgeDetailView.lua

local logger = require("Core.Log.LoggerManager").getLogger("BadgeDetailView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local BadgeDetailView = Class.LightClass("BadgeDetailView", UIView)

function BadgeDetailView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.abilityTtileUSDFText = objectReference:GetRefValue("abilityTtileUSDFText")
	self.abilityInUseUSDFText = objectReference:GetRefValue("abilityInUseUSDFText")
	self.abilityUList = objectReference:GetRefValue("abilityUList")
	self.badgeIconUImage = objectReference:GetRefValue("badgeIconUImage")
	self.lockedUSDFText = objectReference:GetRefValue("lockedUSDFText")
	self.progressUProgress = objectReference:GetRefValue("progressUProgress")
	self.unlockStarUSDFText = objectReference:GetRefValue("unlockStarUSDFText")
	self.unlockDayUSDFText = objectReference:GetRefValue("unlockDayUSDFText")
	self.descUSDFText = objectReference:GetRefValue("descUSDFText")
	self.textNameUSDFText = objectReference:GetRefValue("textNameUSDFText")
	self.btnLeftUButton = objectReference:GetRefValue("btnLeftUButton")
	self.btnRightUButton = objectReference:GetRefValue("btnRightUButton")
	self.backGroundCloseUButton = objectReference:GetRefValue("backGroundCloseUButton")
	self.conditionUList = objectReference:GetRefValue("conditionUList")
	self.unlockTitleUSDFText = objectReference:GetRefValue("unlockTitleUSDFText")
	self.conditionTtileUSDFText = objectReference:GetRefValue("conditionTtileUSDFText")
	self.textIDUSDFText = objectReference:GetRefValue("textIDUSDFText")
	self.tabListUList = objectReference:GetRefValue("tabListUList")
	self.privilegTitleUWidget = objectReference:GetRefValue("privilegTitleUWidget")
	self.badgeIconMysticalUImage = objectReference:GetRefValue("badgeIconMysticalUImage")
	self.detailsAnimation = objectReference:GetRefValue("detailsAnimation")
	self.tagUWidget = objectReference:GetRefValue("tagUWidget")
	self.rootView = self.transform:GetComponent("UComponent")
end

function BadgeDetailView:registerObjects()
	return
end

function BadgeDetailView:initView()
	return
end

return BadgeDetailView
