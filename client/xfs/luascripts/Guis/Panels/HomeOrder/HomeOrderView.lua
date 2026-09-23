-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeOrder\\HomeOrderView.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomeOrderView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomeOrderView = Class.LightClass("HomeOrderView", UIView)

function HomeOrderView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnInfoUButton = objectReference:GetRefValue("btnInfoUButton")
	self.countownUSDFText = objectReference:GetRefValue("countownUSDFText")
	self.listOrderUList = objectReference:GetRefValue("listOrderUList")
	self.textAmountUSDFText = objectReference:GetRefValue("textAmountUSDFText")
	self.refreshCountUSDFText = objectReference:GetRefValue("refreshCountUSDFText")
	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.listCurrencyUList = objectReference:GetRefValue("listCurrencyUList")
	self.txtCostUSDFText = objectReference:GetRefValue("txtCostUSDFText")
	self.refreshUComponent = objectReference:GetRefValue("refreshUComponent")
	self.coinFlyNodeUWidget = objectReference:GetRefValue("coinFlyNodeUWidget")
	self.coinGeneral = objectReference:GetRefValue("coinGeneral")
	self.txtContentUSDFText = objectReference:GetRefValue("txtContentUSDFText")
	self.aITipsRectTransform = objectReference:GetRefValue("aITipsRectTransform")
	self.aIUContainer = objectReference:GetRefValue("aIUContainer")
	self.textNumberUSDFText = objectReference:GetRefValue("textNumberUSDFText")
	self.txtCompletedUSDFText = objectReference:GetRefValue("txtCompletedUSDFText")
	self.txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	self.textUSDFText = objectReference:GetRefValue("textUSDFText")
end

function HomeOrderView:registerObjects()
	return
end

function HomeOrderView:initView()
	return
end

return HomeOrderView
