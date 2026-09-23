-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\LevelBreakthrough\\LevelBreakthroughView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local LevelBreakthroughView = Class.LightClass("LevelBreakthroughView", UIView)

function LevelBreakthroughView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.iPropList = self.objectReference:GetRefValue("iPropList")
	self.btnConfirm = self.objectReference:GetRefValue("btnConfirm")
	self.btnCancel = self.objectReference:GetRefValue("btnCancel")
	self.btnExit = self.objectReference:GetRefValue("btnExit")
	self.root = self.objectReference:GetRefValue("root")
	self.imgPetUImage = self.objectReference:GetRefValue("imgPetUImage")
	self.sliderNowUSlider = self.objectReference:GetRefValue("sliderNowUSlider")
	self.txtLvUSDFText = self.objectReference:GetRefValue("txtLvUSDFText")
	self.breakThroughTip = self.objectReference:GetRefValue("breakThroughTip")
	self.iTitle = self.objectReference:GetRefValue("iTitle")
	self.btnPetUButton = self.objectReference:GetRefValue("btnPetUButton")
	self.txtWarning = self.objectReference:GetRefValue("txtWarning")
end

function LevelBreakthroughView:initView()
	return
end

return LevelBreakthroughView
