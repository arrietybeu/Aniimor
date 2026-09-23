-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\RogBuffSelect\\RogBuffSelectView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local RogBuffSelectView = Class.LightClass("RogBuffSelectView", UIView)

function RogBuffSelectView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.buffList = self.objectReference:GetRefValue("buffList")
	self.btnConfirm = self.objectReference:GetRefValue("btnConfirm")
	self.btnReset = self.objectReference:GetRefValue("btnReset")
	self.resetTip = self.objectReference:GetRefValue("resetTip")
	self.btnBuffListUButton = self.objectReference:GetRefValue("btnBuffListUButton")
	self.title1UBaseText = self.objectReference:GetRefValue("title1UBaseText")
	self.title2UBaseText = self.objectReference:GetRefValue("title2UBaseText")
	self.tipUBaseText = self.objectReference:GetRefValue("tipUBaseText")
	self.buttomULayoutBox = self.objectReference:GetRefValue("buttomULayoutBox")
	self.rootUComponent = self.objectReference:GetRefValue("rootUComponent")
	self.rogueSkillUImage = self.objectReference:GetRefValue("rogueSkillUImage")
	self.titleUBaseText = self.objectReference:GetRefValue("titleUBaseText")
	self.textChoiceUBaseText = self.objectReference:GetRefValue("textChoiceUBaseText")
	self.barAddUWidget3 = self.objectReference:GetRefValue("barAddUWidget3")
	self.barAddUWidget2 = self.objectReference:GetRefValue("barAddUWidget2")
	self.barAddUWidget1 = self.objectReference:GetRefValue("barAddUWidget1")
	self.title3UBaseText = self.objectReference:GetRefValue("title3UBaseText")
	self.bgBlurUIBlurEffect = self.objectReference:GetRefValue("bgBlurUIBlurEffect")
end

function RogBuffSelectView:registerObjects()
	local objectReference = self.btnConfirm:GetComponent("ObjectReference")

	self.btnConfirmText = objectReference:GetRefValue("txtNameUText")
end

function RogBuffSelectView:initView()
	return
end

return RogBuffSelectView
