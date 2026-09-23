-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SelectLanguage\\SelectLanguageView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local SelectLanguageView = Class.LightClass("SelectLanguageView", UIView)

function SelectLanguageView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnContinueUButton = objectReference:GetRefValue("btnContinueUButton")
	self.txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	self.txtTipsUSDFText = objectReference:GetRefValue("txtTipsUSDFText")
	self.listUList = objectReference:GetRefValue("listUList")

	local buttonObjectReference = self.btnContinueUButton:GetComponent("ObjectReference")

	self.btnContinueTextUSDFText = buttonObjectReference:GetRefValue("txtNameUText")
end

return SelectLanguageView
