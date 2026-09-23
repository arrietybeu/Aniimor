-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandLevelUpResult\\HomelandLevelUpResultView.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomelandLevelUpResultView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomelandLevelUpResultView = Class.LightClass("HomelandLevelUpResultView", UIView)

function HomelandLevelUpResultView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.rootComponent = self.objectReference:GetRefValue("rootComponent")
	self.btnClose = self.objectReference:GetRefValue("btnClose")
	self.txtLvNow = self.objectReference:GetRefValue("txtLvNow")
	self.txtLvAfter = self.objectReference:GetRefValue("txtLvAfter")
	self.listAttribute = self.objectReference:GetRefValue("listAttribute")
	self.txtTitleUBaseText = self.objectReference:GetRefValue("txtTitleUBaseText")
end

function HomelandLevelUpResultView:registerObjects()
	return
end

function HomelandLevelUpResultView:initView()
	return
end

return HomelandLevelUpResultView
