-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggsSeasonInfo\\GrabEggsSeasonInfoView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local GrabEggsSeasonInfoView = Class.LightClass("GrabEggsSeasonInfoView", UIView)

function GrabEggsSeasonInfoView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")
	self.text2USDFText = objectReference:GetRefValue("text2USDFText")
	self.txtTimeUSDFText = objectReference:GetRefValue("txtTimeUSDFText")
	self.txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	self.txtSubUSDFText = objectReference:GetRefValue("txtSubUSDFText")
	self.txtResetUSDFText = objectReference:GetRefValue("txtResetUSDFText")
	self.textUSDFText = objectReference:GetRefValue("textUSDFText")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.listRewardUList = objectReference:GetRefValue("listRewardUList")
	self.iconUImage = objectReference:GetRefValue("iconUImage")
	self.tagNameUSDFText = objectReference:GetRefValue("tagNameUSDFText")
	self.txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	self.txtRewardDetailUSDFText = objectReference:GetRefValue("txtRewardDetailUSDFText")
	self.txtRuleUSDFText = objectReference:GetRefValue("txtRuleUSDFText")
	self.btnRewardDetailUButton = objectReference:GetRefValue("btnRewardDetailUButton")
	self.popupRewardUWidget = objectReference:GetRefValue("popupRewardUWidget")
	self.btnInfoUButton = objectReference:GetRefValue("btnInfoUButton")

	local popupRewardObjectReference = self.popupRewardUWidget:GetComponent("ObjectReference")

	self.popupRewardBtnCloseUButton = popupRewardObjectReference:GetRefValue("btnCloseUButton")
	self.popupRewardCloseUButton = popupRewardObjectReference:GetRefValue("confirmBtn")
	self.popupRewardTitleUSDFText = popupRewardObjectReference:GetRefValue("textTitleUSDFText")
	self.popupRewardListUList = popupRewardObjectReference:GetRefValue("listUList")
	self.btnBackUButton = popupRewardObjectReference:GetRefValue("btnBackUButton")
	self.txtSubUSDFText.supportRichText = true
end

function GrabEggsSeasonInfoView:registerObjects()
	return
end

function GrabEggsSeasonInfoView:initView()
	return
end

return GrabEggsSeasonInfoView
