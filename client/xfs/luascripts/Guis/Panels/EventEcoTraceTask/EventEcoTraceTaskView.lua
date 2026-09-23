-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\EventEcoTraceTask\\EventEcoTraceTaskView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local EventEcoTraceTaskView = Class.LightClass("EventEcoTraceTaskView", UIView)

function EventEcoTraceTaskView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.topRewardList = self.objectReference:GetRefValue("topRewardList")
	self.tabList = self.objectReference:GetRefValue("tabList")
	self.taskList = self.objectReference:GetRefValue("taskList")
	self.btnInfoUButton = self.objectReference:GetRefValue("btnInfoUButton")
	self.btnBackUButton = self.objectReference:GetRefValue("btnBackUButton")
	self.txtQuestPro = self.objectReference:GetRefValue("txtQuestPro")
	self.txtNameUBaseText = self.objectReference:GetRefValue("txtNameUBaseText")
	self.btnDarkUComponent = self.objectReference:GetRefValue("btnDarkUComponent")
	self.imgTabIcon = self.objectReference:GetRefValue("imgTabIcon")
	self.txtTitle = self.objectReference:GetRefValue("txtTitle")
	self.btnGetUButton = self.objectReference:GetRefValue("btnGetUButton")
	self.txtBtnGet = self.objectReference:GetRefValue("txtBtnGet")
	self.txtBtnGot = self.objectReference:GetRefValue("txtBtnGot")
end

function EventEcoTraceTaskView:registerObjects()
	return
end

function EventEcoTraceTaskView:initView()
	return
end

return EventEcoTraceTaskView
