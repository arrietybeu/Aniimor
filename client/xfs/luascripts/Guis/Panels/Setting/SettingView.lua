-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Setting\\SettingView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local SettingView = Class.LightClass("SettingView", UIView)

function SettingView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.choiceLabUList = self.objectReference:GetRefValue("choiceLabUList")
	self.mainLabUList = self.objectReference:GetRefValue("mainLabUList")
	self.root = self.objectReference:GetRefValue("root")
	self.consoleKeyUList = self.objectReference:GetRefValue("consoleKeyUList")
	self.btnReSetUButton = self.objectReference:GetRefValue("btnReSetUButton")
	self.equipmentWidgetUComponent = self.objectReference:GetRefValue("equipmentWidgetUComponent")
	self.sliderUSlider = self.objectReference:GetRefValue("sliderUSlider")
	self.currentState2UText = self.objectReference:GetRefValue("currentState2UText")
	self.textRecord = self.objectReference:GetRefValue("textRecord")
	self.btnDownloadAllUButton = self.objectReference:GetRefValue("btnDownloadAllUButton")
	self.btnClearUButton = self.objectReference:GetRefValue("btnClearUButton")
	self.tMPUSDFText = self.objectReference:GetRefValue("tMPUSDFText")
end

function SettingView:registerObjects()
	return
end

function SettingView:initView()
	return
end

return SettingView
