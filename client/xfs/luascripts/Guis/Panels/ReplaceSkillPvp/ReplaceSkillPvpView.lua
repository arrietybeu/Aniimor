-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ReplaceSkillPvp\\ReplaceSkillPvpView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ReplaceSkillPvpView = Class.LightClass("ReplaceSkillPvpView", UIView)

function ReplaceSkillPvpView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.tab01UButton = self.objectReference:GetRefValue("tab01UButton")
	self.tab02UButton = self.objectReference:GetRefValue("tab02UButton")
	self.tab03UButton = self.objectReference:GetRefValue("tab03UButton")
	self.tab04UButton = self.objectReference:GetRefValue("tab04UButton")
	self.root = self.objectReference:GetRefValue("root")
	self.listEquipmentUList = self.objectReference:GetRefValue("listEquipmentUList")
	self.listLearnUList = self.objectReference:GetRefValue("listLearnUList")
	self.consoleKeyUList = self.objectReference:GetRefValue("consoleKeyUList")
end

function ReplaceSkillPvpView:initView()
	self.planBtns = {
		self.tab01UButton,
		self.tab02UButton,
		self.tab03UButton,
		self.tab04UButton
	}
end

return ReplaceSkillPvpView
