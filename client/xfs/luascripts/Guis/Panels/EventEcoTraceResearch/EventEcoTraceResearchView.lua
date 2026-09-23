-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\EventEcoTraceResearch\\EventEcoTraceResearchView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local EventEcoTraceResearchView = Class.LightClass("EventEcoTraceResearchView", UIView)

function EventEcoTraceResearchView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.btnClose = objectReference:GetRefValue("btnClose")
	self.topStageList = objectReference:GetRefValue("topStageList")
	self.btnInfo = objectReference:GetRefValue("btnInfo")
	self.textActiveUBaseText = objectReference:GetRefValue("textActiveUBaseText")
	self.btnPlateauFormUButton = objectReference:GetRefValue("btnPlateauFormUButton")
	self.txtBtnPlateauForm = objectReference:GetRefValue("txtBtnPlateauForm")
	self.list1UList = objectReference:GetRefValue("list1UList")
	self.list2UList = objectReference:GetRefValue("list2UList")
	self.stageName = objectReference:GetRefValue("stageName")
	self.stageDesc = objectReference:GetRefValue("stageDesc")
	self.stageDescTitle = objectReference:GetRefValue("stageDescTitle")
	self.progressUProgress = objectReference:GetRefValue("progressUProgress")
	self.stageProTitle = objectReference:GetRefValue("stageProTitle")
	self.stageProNum = objectReference:GetRefValue("stageProNum")
end

function EventEcoTraceResearchView:registerObjects()
	return
end

function EventEcoTraceResearchView:initView()
	return
end

return EventEcoTraceResearchView
