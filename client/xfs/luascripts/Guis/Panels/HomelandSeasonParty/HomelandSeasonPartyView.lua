-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandSeasonParty\\HomelandSeasonPartyView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomelandSeasonPartyView = Class.LightClass("HomelandSeasonPartyView", UIView)

function HomelandSeasonPartyView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	self.txtTipsTextPlus = objectReference:GetRefValue("txtTipsTextPlus")
	self.scrollRectUScrollRect = objectReference:GetRefValue("scrollRectUScrollRect")
	self.txtTitleRewardUSDFText = objectReference:GetRefValue("txtTitleRewardUSDFText")
	self.listRewardUList = objectReference:GetRefValue("listRewardUList")
	self.btnConfirmUButton = objectReference:GetRefValue("btnConfirmUButton")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")

	local btnConfirmObjectReference = self.btnConfirmUButton:GetComponent("ObjectReference")

	self.txtConfirmUText = btnConfirmObjectReference:GetRefValue("txtNameUText")
end

function HomelandSeasonPartyView:registerObjects()
	return
end

function HomelandSeasonPartyView:initView()
	return
end

return HomelandSeasonPartyView
