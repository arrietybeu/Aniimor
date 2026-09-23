-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeBookFurnitureDetail\\HomeBookFurnitureDetailView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomeBookFurnitureDetailView = Class.LightClass("HomeBookFurnitureDetailView", UIView)

function HomeBookFurnitureDetailView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.tMPUSDFText = objectReference:GetRefValue("tMPUSDFText")
	self.btnPrevUButton = objectReference:GetRefValue("btnPrevUButton")
	self.btnNextUButton = objectReference:GetRefValue("btnNextUButton")
	self.scrollRectUScrollRect = objectReference:GetRefValue("scrollRectUScrollRect")
	self.modelURawImage = objectReference:GetRefValue("modelURawImage")

	local scrollRectObjectReference = self.scrollRectUScrollRect.content.transform:GetComponent("ObjectReference")

	self.txtTagUSDFText = scrollRectObjectReference:GetRefValue("txtTagUSDFText")
	self.txtNameUSDFText = scrollRectObjectReference:GetRefValue("txtNameUSDFText")
	self.txtLivabilityValueUSDFText = scrollRectObjectReference:GetRefValue("txtLivabilityValueUSDFText")
	self.txtLoadValueUSDFText = scrollRectObjectReference:GetRefValue("txtLoadValueUSDFText")
	self.txtDescUSDFText = scrollRectObjectReference:GetRefValue("txtDescUSDFText")
	self.txtInfoUSDFText = scrollRectObjectReference:GetRefValue("txtInfoUSDFText")
	self.txtSuitInfoTitleUSDFText = scrollRectObjectReference:GetRefValue("txtSuitInfoTitleUSDFText")
	self.addUWidget = scrollRectObjectReference:GetRefValue("addUWidget")
	self.txtAddUSDFText = scrollRectObjectReference:GetRefValue("txtAddUSDFText")
	self.txtNumUSDFText = scrollRectObjectReference:GetRefValue("txtNumUSDFText")
	self.listSuitUList = scrollRectObjectReference:GetRefValue("listSuitUList")
	self.suitInfo1UWidget = scrollRectObjectReference:GetRefValue("suitInfo1UWidget")
	self.suitInfo2UWidget = scrollRectObjectReference:GetRefValue("suitInfo2UWidget")
	self.buttonUButton = scrollRectObjectReference:GetRefValue("buttonUButton")
	self.iconUImage = scrollRectObjectReference:GetRefValue("iconUImage")
	self.txtGetUSDFText = scrollRectObjectReference:GetRefValue("txtGetUSDFText")
	self.listGetUList = scrollRectObjectReference:GetRefValue("listGetUList")
end

function HomeBookFurnitureDetailView:registerObjects()
	return
end

function HomeBookFurnitureDetailView:initView()
	self.scrollRectUScrollRect.content.gameObject:SetActiveEx(true)
end

return HomeBookFurnitureDetailView
