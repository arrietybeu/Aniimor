-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandPlayerEditorSetting\\HomelandPlayerEditorSettingView.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomelandPlayerEditorSettingView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomelandPlayerEditorSettingView = Class.LightClass("HomelandPlayerEditorSettingView", UIView)

function HomelandPlayerEditorSettingView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.textUSDFText = objectReference:GetRefValue("textUSDFText")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.listUList = objectReference:GetRefValue("listUList")
	self.btnClosePanalUButton = objectReference:GetRefValue("btnClosePanalUButton")
end

function HomelandPlayerEditorSettingView:registerObjects()
	return
end

function HomelandPlayerEditorSettingView:initView()
	return
end

return HomelandPlayerEditorSettingView
