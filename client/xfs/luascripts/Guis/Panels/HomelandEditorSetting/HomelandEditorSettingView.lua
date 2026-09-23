-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandEditorSetting\\HomelandEditorSettingView.lua

local UIView = require("Guis.UIView")
local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local HomelandEditorSettingView = Class.LightClass("HomelandEditorSettingView", UIView)

function HomelandEditorSettingView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.ornamentFilterList = self.objectReference:GetRefValue("ornamentFilterList")
	self.comlTabLUButton = self.objectReference:GetRefValue("comlTabLUButton")
	self.comlTabRUButton = self.objectReference:GetRefValue("comlTabRUButton")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
end

function HomelandEditorSettingView:initView()
	return
end

return HomelandEditorSettingView
