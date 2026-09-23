-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetReport\\PetReportView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetReportView = Class.LightClass("PetReportView", UIView)

function PetReportView:findObjects()
	self.rootView = self.transform:GetComponent("UComponent")

	local objectReference = self.transform:GetComponent("ObjectReference")

	self.getCoinsPanelUWidget = objectReference:GetRefValue("getCoinsPanelUWidget")
	self.researchPointsPanelUWidget = objectReference:GetRefValue("researchPointsPanelUWidget")
	self.btnEnterUButton = objectReference:GetRefValue("btnEnterUButton")
	self.consoleBarTransform = objectReference:GetRefValue("consoleBarTransform")
	self.txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	self.safeBoxMobileAnimation = objectReference:GetRefValue("safeBoxMobileAnimation")
	self.txtGliserUSDFText = objectReference:GetRefValue("txtGliserUSDFText")
end

function PetReportView:registerObjects()
	return
end

function PetReportView:initView()
	return
end

return PetReportView
