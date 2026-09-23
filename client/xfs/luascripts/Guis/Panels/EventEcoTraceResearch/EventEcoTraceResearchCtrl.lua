-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\EventEcoTraceResearch\\EventEcoTraceResearchCtrl.lua

local Class = require("Core.Framework.Class")
local ClientTextUtils = require("Utils.ClientTextUtils")
local UICtrl = require("Guis.UICtrl")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local MessageName = require("Const.MessageName")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local EventEcoTraceResearchCtrl = Class.LightClass("EventEcoTraceResearchCtrl", UICtrl)

EventEcoTraceResearchCtrl.messages = {
	[MessageName.EVENT_GET_VITALITY_REWARD] = {
		"refreshTraceResearch",
		true
	},
	[MessageName.EVENT_TASK_STATE_CHANGE] = {
		"refreshTraceResearch",
		true
	}
}

local _stateNot = "Not"
local _lineNot = "Not"
local _proShowNum = {
	List2 = 6,
	List1 = 4
}

function EventEcoTraceResearchCtrl:onCreate(eventId)
	UICtrl.onCreate(self, eventId)

	self.eventId = eventId
end

function EventEcoTraceResearchCtrl:addListener()
	function self.view.btnClose.luaClick()
		self:dismiss()
	end

	local ecoCfg = ClientActivityUtils.getEcoTraceActivityCfg()

	function self.view.btnInfo.luaClick()
		pg.global.ui.tips:openEventRuleDesc(pg.getLocalizationText(ecoCfg.researchRule))
	end

	function self.view.btnPlateauFormUButton.luaClick()
		pg.global.ui:open(UIConst.UI_Pb_Event_EcologicalSurvey, self.eventId)
	end

	function self.view.list1UList.luaRenderItem(button, index, data)
		self:renderProgressItem(button, index, data)
	end

	function self.view.list2UList.luaRenderItem(button, index, data)
		self:renderProgressItem(button, index, data)
	end

	function self.view.topStageList.luaRenderItem(button, index, data)
		self:renderTopStageItem(button, index, data)
	end

	function self.view.topStageList.luaCheckCanSelected(data)
		local stageIndex = data and data[1]
		local stageData = stageIndex and self.stageInfo[stageIndex]

		return stageData ~= nil and stageData.state ~= UIConst.EventEcoTraceState.UnLock
	end

	function self.view.topStageList.luaClick(_, data)
		local stageIndex = data and data[1]
		local stageData = stageIndex and self.stageInfo[stageIndex]

		if stageData and stageData.state == UIConst.EventEcoTraceState.UnLock then
			pg.global.ui.tips:showTextTip(pg.getGameString("ECOLOGICAL_RESARCH_UNOPEN"))
		end
	end

	function self.view.topStageList.luaSelectedChanged(uList, select)
		if not select then
			return
		end

		local selectedItem = uList.selectedItem
		local stageIndex = selectedItem and selectedItem[1]

		if not stageIndex then
			return
		end

		self:onStageSelected(stageIndex)
	end
end

function EventEcoTraceResearchCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self:initUI()
end

function EventEcoTraceResearchCtrl:onShow()
	return
end

function EventEcoTraceResearchCtrl:onHide()
	return
end

function EventEcoTraceResearchCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function EventEcoTraceResearchCtrl:buildStageList()
	local stageList = {}
	local stageCount = table.getCount(Const.ECO_TRACE_PROJECT)

	for i = 1, stageCount do
		stageList[i] = {
			i
		}
	end

	return stageList
end

function EventEcoTraceResearchCtrl:onStageSelected(stageIndex)
	local stageData = self.stageInfo[stageIndex]

	if not stageData then
		return
	end

	if self.curStage == stageIndex then
		return
	end

	self.curStage = stageIndex

	self.view.topStageList:RefreshList()
	self:refreshTraceResearch()
end

function EventEcoTraceResearchCtrl:initUI()
	self.stageInfo, self.curStage = ClientActivityUtils.getEcoStageInfo()
	self.curStage = self.curStage or Const.ECO_TRACE_PROJECT.Shiny

	local stageList = self:buildStageList()

	self:refreshTraceResearch()

	if stageList and next(stageList) then
		self.view.topStageList:SetList(stageList)

		local res, button = self.view.topStageList:TryGetChildAt(self.curStage - 1)

		if res then
			button:OnClickSimulate()
		end
	end

	ClientTextUtils.setText(self.view.stageDescTitle, pg.getGameString("ECOLOGICAL_RESARCH_RULE_TITLE"))
	ClientTextUtils.setText(self.view.stageProTitle, pg.getGameString("ECOLOGICAL_RESARCH_TASK_COUNT"))
	ClientTextUtils.setText(self.view.txtBtnPlateauForm, pg.getGameString("ECOLOGICAL_TASK_TITLE"))
end

function EventEcoTraceResearchCtrl:renderProgressItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtPro = objectReference:GetRefValue("txtPro")
	local txtPro2 = objectReference:GetRefValue("txtPro2")
	local txtProIndex = objectReference:GetRefValue("txtProIndex")
	local progressText = string.format("%.0f%%", data.pro)
	local curProgressText = pg.getFormatText(pg.getGameString("ECOLOGICAL_RESARCH_UP_TIP"), progressText)

	button:TryChangePage("status", data.state)
	ClientTextUtils.setText(txtPro, progressText)
	ClientTextUtils.setText(txtPro2, curProgressText)
	ClientTextUtils.setText(txtProIndex, index + 1)
end

function EventEcoTraceResearchCtrl:renderTopStageItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtStageName = objectReference:GetRefValue("txtStageName")
	local textPro = objectReference:GetRefValue("textPro")
	local stageIndex = index + 1
	local stageState = self.stageInfo[stageIndex] and self.stageInfo[stageIndex].state or UIConst.EventEcoTraceState.UnLock
	local lineState = "Reach"
	local showState = "Active"

	if stageState == UIConst.EventEcoTraceState.Researching then
		lineState = _lineNot
		showState = "Researching"
	elseif stageState ~= UIConst.EventEcoTraceState.Active then
		lineState = _lineNot
		showState = _stateNot
	end

	if stageIndex == Const.ECO_TRACE_PROJECT.Shiny then
		lineState = "Dont"

		if ClientActivityUtils.checkEcologyCenterPoint() and stageState == UIConst.EventEcoTraceState.Researching then
			showState = _stateNot
		end
	end

	button:TryChangePage("Line", lineState)
	button:TryChangePage("State", showState)
	button:TryChangePage("Icon", index)
	ClientTextUtils.setText(txtStageName, pg.getGameString("ECOLOGICAL_RESARCH_TITLE_" .. stageIndex))

	local curPro, maxPro = ClientActivityUtils.getEcoStagePro(stageIndex)

	ClientTextUtils.setText(textPro, curPro .. "/" .. maxPro)
end

function EventEcoTraceResearchCtrl:getProgressListByStage(curStageIndex)
	local ecoCfg = ClientActivityUtils.getEcoTraceActivityCfg()
	local projectBoost = ecoCfg and ecoCfg.projectBoost and ecoCfg.projectBoost[curStageIndex]
	local showCount = tonumber(projectBoost and projectBoost[1]) or _proShowNum.List1
	local isList1 = showCount == _proShowNum.List1

	self.view.list1UList.gameObject:SetActiveEx(isList1)
	self.view.list2UList.gameObject:SetActiveEx(not isList1)

	return isList1 and self.view.list1UList or self.view.list2UList
end

function EventEcoTraceResearchCtrl:refreshTraceResearch()
	local curStageIndex = self.curStage
	local curStage = self.stageInfo[curStageIndex]

	if not curStage then
		return
	end

	self.view.rootUComponent:TryChangePage("Icon", curStageIndex - 1)
	ClientTextUtils.setText(self.view.stageName, pg.getGameString("ECOLOGICAL_RESARCH_UP_NAME_" .. curStageIndex))

	local petName = pg.getLocalizationText(self.model:getChosedPetName())
	local isActive = curStage.state == UIConst.EventEcoTraceState.Active

	self.view.rootUComponent:TryChangePage("Topic", isActive and "Active" or "Researching")

	local descKeyPrefix = curStage.state == UIConst.EventEcoTraceState.Researching and "ECOLOGICAL_RESARCH_RULE_DESC_" or "ECOLOGICAL_RESARCH_FINISH_RULE_DESC_"

	ClientTextUtils.setText(self.view.stageDesc, pg.getFormatText(pg.getGameString(descKeyPrefix .. curStageIndex), petName))

	local pro = ClientActivityUtils.getEcoStageProNum(curStageIndex)

	ClientTextUtils.setText(self.view.textActiveUBaseText, pg.getFormatText(pg.getGameString("ECOLOGICAL_RESARCH_FINISH_DESC_" .. curStageIndex), petName, pro))

	local curPro, maxPro = ClientActivityUtils.getEcoStagePro(curStageIndex)

	ClientTextUtils.setText(self.view.stageProNum, curPro .. "/" .. maxPro)

	if curStage.state == UIConst.EventEcoTraceState.Researching then
		self.view.progressUProgress.maxValue = maxPro
		self.view.progressUProgress.value = curPro
	end

	local traceList = ClientActivityUtils.getEcoTraceProInfo(curStageIndex)
	local showProList = self:getProgressListByStage(curStageIndex)

	showProList:SetList(traceList)
end

return EventEcoTraceResearchCtrl
