-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CommonLeftItemSel\\CommonLeftItemSelView.lua

local logger = require("Core.Log.LoggerManager").getLogger("CommonLeftItemSelView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local CommonLeftItemSelView = Class.LightClass("CommonLeftItemSelView", UIView)

function CommonLeftItemSelView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.textTitleUBaseText = self.objectReference:GetRefValue("textTitleUBaseText")
	self.listUList = self.objectReference:GetRefValue("listUList")
	self.rootWidget = self.objectReference:GetRefValue("rootWidget")
	self.emptyTxtNameUBaseText = self.objectReference:GetRefValue("emptyTxtNameUBaseText")
	self.numSelectorUNumSelector = self.objectReference:GetRefValue("numSelectorUNumSelector")
	self.btnLeftUButton = self.objectReference:GetRefValue("btnLeftUButton")
	self.btnRightUButton = self.objectReference:GetRefValue("btnRightUButton")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.btnCornerClose = self.objectReference:GetRefValue("btnCornerClose")
end

function CommonLeftItemSelView:registerObjects()
	return
end

function CommonLeftItemSelView:initView()
	return
end

return CommonLeftItemSelView
