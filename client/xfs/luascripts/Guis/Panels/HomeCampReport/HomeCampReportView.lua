-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeCampReport\\HomeCampReportView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomeCampReportView = Class.LightClass("HomeCampReportView", UIView)

function HomeCampReportView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.txtTitle = objectReference and objectReference:GetRefValue("txtTitle")
	self.btnConfirmUButton = objectReference and objectReference:GetRefValue("btnConfirmUButton")
	self.btnCloseUButton = objectReference and objectReference:GetRefValue("btnCloseUButton")
	self.listUList = objectReference and objectReference:GetRefValue("listUList")
end

function HomeCampReportView:registerObjects()
	local objectReference = self.btnConfirmUButton and self.btnConfirmUButton:GetComponent("ObjectReference")

	self.txtConfirm = objectReference and objectReference:GetRefValue("txtNameUText")
end

function HomeCampReportView:initView()
	return
end

return HomeCampReportView
