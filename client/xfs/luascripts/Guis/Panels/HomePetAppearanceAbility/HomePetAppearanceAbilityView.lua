-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomePetAppearanceAbility\\HomePetAppearanceAbilityView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomePetAppearanceAbilityView = Class.LightClass("HomePetAppearanceAbilityView", UIView)

function HomePetAppearanceAbilityView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	self.scrollRectUScrollRect = objectReference:GetRefValue("scrollRectUScrollRect")

	local contentTransform = self.scrollRectUScrollRect.content.transform

	self.txtDetailsUSDFText = contentTransform:Find("TxtDetails"):GetComponent("USDFText")
	self.listAppearanceUList = contentTransform:Find("ListAppearance"):GetComponent("UList")
end

function HomePetAppearanceAbilityView:registerObjects()
	return
end

function HomePetAppearanceAbilityView:initView()
	return
end

return HomePetAppearanceAbilityView
