-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AppearanceV2\\AppearanceV2View.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ClientTextUtils = require("Utils.ClientTextUtils")
local AppearanceV2View = Class.LightClass("AppearanceV2View", UIView)

function AppearanceV2View:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.rootUComponent = self.objectReference:GetRefValue("rootUComponent")
	self.titleTabUList = self.objectReference:GetRefValue("titleTabUList")
	self.backUButton = self.objectReference:GetRefValue("backUButton")
	self.playerTransform = self.objectReference:GetRefValue("playerTransform")
	self.workShopTransform = self.objectReference:GetRefValue("workShopTransform")
	self.maskRayBoxTransform = self.objectReference:GetRefValue("maskRayBoxTransform")
	self.currencyUList = self.objectReference:GetRefValue("currencyUList")
	self.titleShadowUSDFText = self.objectReference:GetRefValue("titleShadowUSDFText")
	self.topbarUWidget = self.objectReference:GetRefValue("topbarUWidget")
	self.backgroundSelectorUSelector = self.objectReference:GetRefValue("backgroundSelectorUSelector")
	self.barUWidget = self.objectReference:GetRefValue("barUWidget")
	self.fashionNumUSDFText = self.objectReference:GetRefValue("fashionNumUSDFText")
	self.leftLayoutBoxUWidget = self.objectReference:GetRefValue("leftLayoutBoxUWidget")
	self.photographRoomTransform = self.objectReference:GetRefValue("photographRoomTransform")
	self.wardrobeUContainer = self.objectReference:GetRefValue("wardrobeUContainer")
	self.btnHairTieUButton = self.objectReference:GetRefValue("btnHairTieUButton")
	self.infoRightUComponent = self.objectReference:GetRefValue("infoRightUComponent")
end

function AppearanceV2View:registerObjects()
	return
end

function AppearanceV2View:initView()
	local wardrobe = self.wardrobeUContainer.content

	wardrobe.gameObject:SetActiveEx(false)
end

function AppearanceV2View:renderFashionTips(prop, fashion)
	local objectReference = prop:GetComponent("ObjectReference")
	local txtTitle = objectReference:GetRefValue("txtTitle")
	local txtDesc = objectReference:GetRefValue("txtDesc")

	ClientTextUtils.setText(txtTitle, pg.getGameString("AVATAR_FASHION_TIP_2"))
	ClientTextUtils.setText(txtDesc, string.format(pg.getGameString("AVATAR_FASHION_TIP_3"), fashion))
end

return AppearanceV2View
