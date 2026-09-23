-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ExchangeItem\\ExchangeItemView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ExchangeItemView = Class.LightClass("ExchangeItemView", UIView)

function ExchangeItemView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnCancelUButton = self.objectReference:GetRefValue("btnCancelUButton")
	self.btnConfirmUButton = self.objectReference:GetRefValue("btnConfirmUButton")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.numSelectorSliderUNumSelector = self.objectReference:GetRefValue("numSelectorSliderUNumSelector")
	self.describeUSDFText = self.objectReference:GetRefValue("describeUSDFText")
	self.titleUSDFText = self.objectReference:GetRefValue("titleUSDFText")
	self.currencyUList = self.objectReference:GetRefValue("currencyUList")
	self.listItemFrontUList = self.objectReference:GetRefValue("listItemFrontUList")
	self.listItemBackUList = self.objectReference:GetRefValue("listItemBackUList")
	self.consumeNum = self.objectReference:GetRefValue("consumeNum")
	self.consumeIcon = self.objectReference:GetRefValue("consumeIcon")
	self.costUWidget = self.objectReference:GetRefValue("costUWidget")
end

function ExchangeItemView:initView()
	return
end

return ExchangeItemView
