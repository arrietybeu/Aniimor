-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\MakeSkill\\MakeSkillView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local MakeSkillView = Class.LightClass("MakeSkillView", UIView)

function MakeSkillView:findObjects()
	return
end

function MakeSkillView:registerObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.iName = self.objectReference:GetRefValue("iName")
	self.iIcon = self.objectReference:GetRefValue("iIcon")
	self.iBG = self.objectReference:GetRefValue("iBG")
	self.iElement = self.objectReference:GetRefValue("iElement")
	self.iFList = self.objectReference:GetRefValue("iFList")
	self.iPList = self.objectReference:GetRefValue("iPList")
	self.tName = self.objectReference:GetRefValue("tName")
	self.matList = self.objectReference:GetRefValue("matList")
	self.btnClose = self.objectReference:GetRefValue("btnClose")
	self.btnCancel = self.objectReference:GetRefValue("btnCancel")
	self.btnConfirm = self.objectReference:GetRefValue("btnConfirm")
	self.btnMin = self.objectReference:GetRefValue("btnMin")
	self.btnMax = self.objectReference:GetRefValue("btnMax")
	self.btnAdd = self.objectReference:GetRefValue("btnAdd")
	self.btnSub = self.objectReference:GetRefValue("btnSub")
end

function MakeSkillView:initView()
	return
end

return MakeSkillView
