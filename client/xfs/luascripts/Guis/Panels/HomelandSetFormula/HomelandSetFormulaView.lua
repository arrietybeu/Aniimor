-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandSetFormula\\HomelandSetFormulaView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomelandSetFormulaView = Class.LightClass("HomelandSetFormulaView", UIView)

function HomelandSetFormulaView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.bgCloseBtn = self.objectReference:GetRefValue("bgCloseBtn")
	self.btnClose = self.objectReference:GetRefValue("btnClose")
	self.btnConfirm = self.objectReference:GetRefValue("btnConfirm")
	self.confirmName = self.objectReference:GetRefValue("confirmName")
	self.formulaList = self.objectReference:GetRefValue("formulaList")
	self.contentUWidget = self.objectReference:GetRefValue("contentUWidget")
	self.btnCleanUButton = self.objectReference:GetRefValue("btnCleanUButton")
end

function HomelandSetFormulaView:registerObjects()
	return
end

function HomelandSetFormulaView:initView()
	return
end

return HomelandSetFormulaView
