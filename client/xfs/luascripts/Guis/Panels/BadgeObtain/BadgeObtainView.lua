-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BadgeObtain\\BadgeObtainView.lua

local logger = require("Core.Log.LoggerManager").getLogger("BadgeObtainView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local BadgeObtainView = Class.LightClass("BadgeObtainView", UIView)

function BadgeObtainView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")
	local badgeAcquireObjectReference = objectReference:GetRefValue("badgeAcquireObjectReference")

	self.badgeFristAcquireUWidget = objectReference:GetRefValue("badgeFristAcquireUWidget")

	self:initObtainView(badgeAcquireObjectReference)
end

function BadgeObtainView:initObtainView(objectReference)
	self.backGroundCloseUButton = objectReference:GetRefValue("backGroundCloseUButton")
	self.textNameUSDFText = objectReference:GetRefValue("textNameUSDFText")
	self.abilityTtileUSDFText = objectReference:GetRefValue("abilityTtileUSDFText")
	self.badgeIconUImage = objectReference:GetRefValue("badgeIconUImage")
	self.abilityUList = objectReference:GetRefValue("abilityUList")
	self.btnLookUButton = objectReference:GetRefValue("btnLookUButton")
	self.badgeIcon1UImage = objectReference:GetRefValue("badgeIcon1UImage")
	self.conditionListUList = objectReference:GetRefValue("conditionListUList")
	self.fxHongUWidget = objectReference:GetRefValue("fxHongUWidget")

	local btnOC = self.btnLookUButton:GetComponent("ObjectReference")

	self.btnTxtNameUText = btnOC:GetRefValue("txtNameUText")
	self.rootAnimation = self.transform:GetComponent("Animation")
	self.rootView = self.transform:GetComponent("UComponent")
end

function BadgeObtainView:registerObjects()
	return
end

function BadgeObtainView:initView()
	return
end

return BadgeObtainView
