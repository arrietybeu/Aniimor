-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PlayerAssess\\PlayerAssessView.lua

local logger = require("Core.Log.LoggerManager").getLogger("PlayerAssessView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PlayerAssessView = Class.LightClass("PlayerAssessView", UIView)

function PlayerAssessView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnClose = self.objectReference:GetRefValue("btnClose")
	self.starText = self.objectReference:GetRefValue("starText")
	self.starText2 = self.objectReference:GetRefValue("starText2")
	self.assessTitle = self.objectReference:GetRefValue("assessTitle")
	self.btnConfirm = self.objectReference:GetRefValue("btnConfirm")
	self.assessTime = self.objectReference:GetRefValue("assessTime")
	self.animWidget = self.objectReference:GetRefValue("animWidget")
	self.skillList = self.objectReference:GetRefValue("skillList")
	self.skillPointList = self.objectReference:GetRefValue("skillPointList")
	self.starIcon = self.objectReference:GetRefValue("starIcon")
	self.starIcon2 = self.objectReference:GetRefValue("starIcon2")
	self.rootWidget = self.transform:GetComponent("UWidget")

	local btnOC = self.btnClose:GetComponent("ObjectReference")

	self.btnNameUText = btnOC:GetRefValue("txtNameUText")
end

function PlayerAssessView:registerObjects()
	return
end

function PlayerAssessView:initView()
	return
end

return PlayerAssessView
