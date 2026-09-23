-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandLevelUp\\HomelandLevelUpView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomelandLevelUpView = Class.LightClass("HomelandLevelUpView", UIView)

function HomelandLevelUpView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.btnCloseBGUButton = self.objectReference:GetRefValue("btnCloseBGUButton")
	self.btnCancelUButton = self.objectReference:GetRefValue("btnCancelUButton")
	self.btnConfirmUButton = self.objectReference:GetRefValue("btnConfirmUButton")
	self.txtLvNowUBaseText = self.objectReference:GetRefValue("txtLvNowUBaseText")
	self.txtLvAfterUBaseText = self.objectReference:GetRefValue("txtLvAfterUBaseText")
	self.listAttributeUList = self.objectReference:GetRefValue("listAttributeUList")
	self.listRewardUList = self.objectReference:GetRefValue("listRewardUList")
	self.listNewUList = self.objectReference:GetRefValue("listNewUList")
	self.iconConsumeUImage = self.objectReference:GetRefValue("iconConsumeUImage")
	self.txtNumUSDFText = self.objectReference:GetRefValue("txtNumUSDFText")
	self.listCurrencyUList = self.objectReference:GetRefValue("listCurrencyUList")
	self.textCostUSDFText = self.objectReference:GetRefValue("textCostUSDFText")
	self.costUWidget = self.objectReference:GetRefValue("costUWidget")
	self.layoutConsumeUWidget = self.objectReference:GetRefValue("layoutConsumeUWidget")
end

function HomelandLevelUpView:registerObjects()
	return
end

function HomelandLevelUpView:initView()
	return
end

return HomelandLevelUpView
