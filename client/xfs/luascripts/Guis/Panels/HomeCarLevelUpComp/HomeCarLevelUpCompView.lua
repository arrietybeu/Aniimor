-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeCarLevelUpComp\\HomeCarLevelUpCompView.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomeCarLevelUpCompView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomeCarLevelUpCompView = Class.LightClass("HomeCarLevelUpCompView", UIView)

function HomeCarLevelUpCompView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.tMPUSDFText = objectReference:GetRefValue("tMPUSDFText")
	self.textNameUSDFText = objectReference:GetRefValue("textNameUSDFText")
	self.textLevelUSDFText = objectReference:GetRefValue("textLevelUSDFText")
	self.textDetailUSDFText = objectReference:GetRefValue("textDetailUSDFText")
	self.scrollRectUScrollRect = objectReference:GetRefValue("scrollRectUScrollRect")
	self.textUSDFText = objectReference:GetRefValue("textUSDFText")
	self.listCostUList = objectReference:GetRefValue("listCostUList")
	self.textNoFillUSDFText = objectReference:GetRefValue("textNoFillUSDFText")
	self.costCoinListUList = objectReference:GetRefValue("costCoinListUList")
	self.btnComfirmUButton = objectReference:GetRefValue("btnComfirmUButton")
	self.txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	self.txtMaxUSDFText = objectReference:GetRefValue("txtMaxUSDFText")
	self.listItemTabUList = objectReference:GetRefValue("listItemTabUList")
	self.listItemUList = objectReference:GetRefValue("listItemUList")
	self.uIPanelUWidget = objectReference:GetRefValue("uIPanelUWidget")
	self.listLelLevelUList = objectReference:GetRefValue("listLelLevelUList")
	self.listCurrencyUList = objectReference:GetRefValue("listCurrencyUList")
	self.costItemUWidget = objectReference:GetRefValue("costItemUWidget")
	self.btnReadyUWidget = objectReference:GetRefValue("btnReadyUWidget")

	local scrollRectobjectReference = self.scrollRectUScrollRect.content.transform:GetComponent("ObjectReference")

	self.titleUSDFText = scrollRectobjectReference:GetRefValue("titleUSDFText")
	self.listUList = scrollRectobjectReference:GetRefValue("listUList")
	self.titleTextPlus = scrollRectobjectReference:GetRefValue("titleTextPlus")
	self.contentUpgradeUWidget = scrollRectobjectReference:GetRefValue("contentUpgradeUWidget")
	self.listUnlockUList = scrollRectobjectReference:GetRefValue("listUnlockUList")
end

function HomeCarLevelUpCompView:registerObjects()
	return
end

function HomeCarLevelUpCompView:initView()
	return
end

return HomeCarLevelUpCompView
