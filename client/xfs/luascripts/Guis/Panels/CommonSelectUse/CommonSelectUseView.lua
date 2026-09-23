-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CommonSelectUse\\CommonSelectUseView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local CommonSelectUseView = Class.LightClass("CommonSelectUseView", UIView)

function CommonSelectUseView:findObjects()
	return
end

function CommonSelectUseView:registerObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.iTitle = self.objectReference:GetRefValue("iTitle")
	self.iPropList = self.objectReference:GetRefValue("iPropList")
	self.btnConfirm = self.objectReference:GetRefValue("btnConfirm")
	self.btnCancel = self.objectReference:GetRefValue("btnCancel")
	self.btnExit = self.objectReference:GetRefValue("btnExit")
	self.selector = self.objectReference:GetRefValue("selector")
	self.root = self.objectReference:GetRefValue("root")
	self.txtLevelNowUText = self.objectReference:GetRefValue("txtLevelNowUText")
	self.txtLevelMax = self.objectReference:GetRefValue("txtLevelMax")
	self.imgPetUImage = self.objectReference:GetRefValue("imgPetUImage")
	self.sliderAddUSlider = self.objectReference:GetRefValue("sliderAddUSlider")
	self.sliderNowUSlider = self.objectReference:GetRefValue("sliderNowUSlider")
	self.btnRulesUButton = self.objectReference:GetRefValue("btnRulesUButton")
	self.txtWarning = self.objectReference:GetRefValue("txtWarning")
	self.btnPetUButton = self.objectReference:GetRefValue("btnPetUButton")
	self.txtLevelMinus = self.objectReference:GetRefValue("txtLevelMinus")
	self.txtLevelAdd = self.objectReference:GetRefValue("txtLevelAdd")
	self.rootComponent = self.transform:GetComponent("UComponent")
	self.txtLvUSDFText = self.objectReference:GetRefValue("txtLvUSDFText")
	self.breakThroughTip = self.objectReference:GetRefValue("breakThroughTip")
	self.breakThroughTipOld = self.objectReference:GetRefValue("breakThroughTipOld")
end

function CommonSelectUseView:initView()
	return
end

return CommonSelectUseView
