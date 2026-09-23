-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeBookScorePopup\\HomeBookScorePopupView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomeBookScorePopupView = Class.LightClass("HomeBookScorePopupView", UIView)

function HomeBookScorePopupView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.iconCampUImage = objectReference:GetRefValue("iconCampUImage")
	self.txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	self.txtAddUSDFText = objectReference:GetRefValue("txtAddUSDFText")
	self.txtScoreTitleUSDFText = objectReference:GetRefValue("txtScoreTitleUSDFText")
	self.txtScoreNumUSDFText = objectReference:GetRefValue("txtScoreNumUSDFText")
	self.listUList = objectReference:GetRefValue("listUList")
	self.textUSDFText = objectReference:GetRefValue("textUSDFText")
	self.addRectTransform = objectReference:GetRefValue("addRectTransform")
end

function HomeBookScorePopupView:registerObjects()
	return
end

function HomeBookScorePopupView:initView()
	return
end

return HomeBookScorePopupView
