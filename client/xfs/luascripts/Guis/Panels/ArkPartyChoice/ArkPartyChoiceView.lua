-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ArkPartyChoice\\ArkPartyChoiceView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local SysConfigData = require("Data.sys_config_data")
local ArkPartyChoiceView = Class.LightClass("ArkPartyChoiceView", UIView)
local ToBool = ToBool

function ArkPartyChoiceView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.list1UList = objectReference:GetRefValue("list1UList")
	self.list2UList = objectReference:GetRefValue("list2UList")
	self.list3UList = objectReference:GetRefValue("list3UList")
	self.list4UList = objectReference:GetRefValue("list4UList")
	self.btnDarkUButton = objectReference:GetRefValue("btnDarkUButton")
	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.rootUWidget = objectReference:GetRefValue("rootUWidget")
	self.title1UBaseText = objectReference:GetRefValue("title1UBaseText")
	self.title2UBaseText = objectReference:GetRefValue("title2UBaseText")
	self.title3UBaseText = objectReference:GetRefValue("title3UBaseText")
	self.title4UBaseText = objectReference:GetRefValue("title4UBaseText")
	self.text1UBaseText = objectReference:GetRefValue("text1UBaseText")
end

function ArkPartyChoiceView:registerObjects()
	return
end

function ArkPartyChoiceView:initView()
	return
end

return ArkPartyChoiceView
