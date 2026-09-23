-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\VitalityRedeem\\VitalityRedeemView.lua

local logger = require("Core.Log.LoggerManager").getLogger("VitalityRedeemView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local VitalityRedeemView = Class.LightClass("VitalityRedeemView", UIView)

function VitalityRedeemView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnCancelUButton = self.objectReference:GetRefValue("btnCancelUButton")
	self.btnConfirmUButton = self.objectReference:GetRefValue("btnConfirmUButton")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.numSelectorSliderUNumSelector = self.objectReference:GetRefValue("numSelector")
	self.describeUSDFText = self.objectReference:GetRefValue("describeUSDFText")
	self.titleUSDFText = self.objectReference:GetRefValue("titleUSDFText")
	self.currencyUList = self.objectReference:GetRefValue("currencyUList")
	self.listItemFrontUList = self.objectReference:GetRefValue("listItemFrontUList")
	self.listItemBackUList = self.objectReference:GetRefValue("listItemBackUList")
	self.consumeNum = self.objectReference:GetRefValue("consumeNum")
	self.consumeIcon = self.objectReference:GetRefValue("consumeIcon")
	self.costUWidget = self.objectReference:GetRefValue("costUWidget")
end

function VitalityRedeemView:registerObjects()
	return
end

function VitalityRedeemView:initView()
	return
end

return VitalityRedeemView
