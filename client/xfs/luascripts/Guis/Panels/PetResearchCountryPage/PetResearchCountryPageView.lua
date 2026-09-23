-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetResearchCountryPage\\PetResearchCountryPageView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetResearchCountryPageView = Class.LightClass("PetResearchCountryPageView", UIView)

function PetResearchCountryPageView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.rootView = self.transform:GetComponent("UComponent")
	self.cardListUList = objectReference:GetRefValue("cardListUList")
	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.btnSwitchUButton = objectReference:GetRefValue("btnSwitchUButton")
	self.txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	self.titleUSDFText = objectReference:GetRefValue("titleUSDFText")
end

function PetResearchCountryPageView:registerObjects()
	return
end

function PetResearchCountryPageView:initView()
	return
end

return PetResearchCountryPageView
