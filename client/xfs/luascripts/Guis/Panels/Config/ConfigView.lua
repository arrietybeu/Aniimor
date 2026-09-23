-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Config\\ConfigView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ConfigView = Class.LightClass("ConfigView", UIView)

function ConfigView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.sliderUSlider = self.objectReference:GetRefValue("sliderUSlider")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.listUList = self.objectReference:GetRefValue("listUList")
	self.searchInputUInputField = self.objectReference:GetRefValue("searchInputUInputField")
	self.itemListUList = self.objectReference:GetRefValue("itemListUList")
	self.uIPbConfigUComponent = self.objectReference:GetRefValue("uIPbConfigUComponent")
	self.inputUComponent = self.objectReference:GetRefValue("inputUComponent")
	self.searchHistoryList = self.objectReference:GetRefValue("searchHistoryList")
	self.btnSearchSwitchUButton = self.objectReference:GetRefValue("btnSearchSwitchUButton")
end

function ConfigView:registerObjects()
	return
end

function ConfigView:initView()
	return
end

function ConfigView:refreshFuncTypeList(funcList)
	self.listUList:SetList(funcList)
end

function ConfigView:refreshFuncList(funcList)
	self.itemListUList:SetList(funcList)
end

return ConfigView
