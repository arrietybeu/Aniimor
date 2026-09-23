-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetGiftTips\\PetGiftTipsView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetGiftTipsView = Class.LightClass("PetGiftTipsView", UIView)

function PetGiftTipsView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.listUList = objectReference:GetRefValue("listUList")
	self.rootCmp = objectReference:GetRefValue("rootCmp")
	self.tabHomeUButton = objectReference:GetRefValue("tabHomeUButton")
	self.tabBattleUButton = objectReference:GetRefValue("tabBattleUButton")
	self.bgSelHomeUImage = objectReference:GetRefValue("bgSelHomeUImage")
	self.bgSelBattleUImage = objectReference:GetRefValue("bgSelBattleUImage")
	self.tabPanelRectTransform = objectReference:GetRefValue("tabPanelRectTransform")
	self.txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	self.widgetBtnUWidget = objectReference:GetRefValue("widgetBtnUWidget")
	self.btnUseUButton = objectReference:GetRefValue("btnUseUButton")
	self.txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
end

function PetGiftTipsView:registerObjects()
	return
end

function PetGiftTipsView:initView()
	return
end

return PetGiftTipsView
