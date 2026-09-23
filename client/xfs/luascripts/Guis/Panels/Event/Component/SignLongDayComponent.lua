-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Event\\Component\\SignLongDayComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local SignLongDayComponent = Class.LightClass("SignLongDayComponent", UIComponent)

function SignLongDayComponent:findObjects()
	local objectReference = self.transform:GetChild(0):GetComponent("ObjectReference")

	self.listUList = objectReference:GetRefValue("listUList")
	self.txtAllSignDay = objectReference:GetRefValue("txtAllSignDay")
end

function SignLongDayComponent:onCtor(info)
	self.eventId = info.eventId
end

function SignLongDayComponent:initView()
	self:addListener()
	self:refreshPage()
end

function SignLongDayComponent:addListener()
	function self.listUList.luaRenderItem(button, index, data)
		self:renderSignItem(button, index, data)
	end
end

function SignLongDayComponent:refreshPage()
	local signData = self.model:getSignData(self.eventId)

	self.curDay = signData and signData.activityBase and signData.activityBase.totalSignNum or 0

	ClientTextUtils.setText(self.txtAllSignDay, pg.getFormatText(pg.getGameString("SIGNIN_LONG_TERM_DAYS"), self.curDay))

	local signCfgList = self.model:getSignList(self.eventId) or {}
	local hasData = next(signCfgList) ~= nil

	if hasData then
		local previousTargetDay = 0

		for _, signCfg in ipairs(signCfgList) do
			signCfg.targetDay = pg.me.triggerMap:getConditionTargetCount(signCfg.taskCondition, 1)
			signCfg.previousTargetDay = previousTargetDay
			previousTargetDay = signCfg.targetDay
		end

		self:setSignProgress(signCfgList)
		self.listUList:SetList(signCfgList)
	end

	self.listUList.gameObject:SetActiveEx(hasData)
end

function SignLongDayComponent:setSignProgress(signCfgList)
	for index, signCfg in ipairs(signCfgList) do
		signCfg.barState = index == 1 and 0 or index == #signCfgList and 2 or 1
		signCfg.progressValue = 0
	end

	local firstSignCfg = signCfgList[1]
	local firstFinished = firstSignCfg.taskState ~= ActivityConst.TaskState.UnFinished

	if firstFinished then
		firstSignCfg.progressValue = 0.5
	elseif firstSignCfg.targetDay > 0 then
		firstSignCfg.progressValue = math.min(self.curDay / firstSignCfg.targetDay, 1) * 0.5
	end

	for index = 2, #signCfgList do
		local signCfg = signCfgList[index]
		local previousSignCfg = signCfgList[index - 1]
		local isFinished = signCfg.taskState ~= ActivityConst.TaskState.UnFinished
		local previousFinished = previousSignCfg.taskState ~= ActivityConst.TaskState.UnFinished

		if isFinished then
			previousSignCfg.progressValue = 1
			signCfg.progressValue = 0.5
		elseif previousFinished then
			local targetDay = signCfg.targetDay - signCfg.previousTargetDay
			local progressDay = math.max(self.curDay - signCfg.previousTargetDay, 0)
			local progress = targetDay > 0 and math.min(progressDay / targetDay, 1) or 0

			previousSignCfg.progressValue = 0.5 + math.min(progress, 0.5)
			signCfg.progressValue = math.max(progress - 0.5, 0)
		end
	end
end

function SignLongDayComponent:isCurrentItemCanGet()
	local navManager = pg.global.navMgr or CS.XGUI.Navigation.NavManager.Instance
	local focusedItem = navManager and navManager.CurrentFocusedUContent

	if not focusedItem or IsNil(focusedItem) then
		return false
	end

	local data = self.listUList:GetData(focusedItem)

	return data ~= nil and data.taskState == ActivityConst.TaskState.Finihed_CanRecv
end

function SignLongDayComponent:renderSignItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local itemUComponent = objectReference:GetRefValue("itemUComponent")
	local progressUProgress = objectReference:GetRefValue("progressUProgress")
	local progress1UProgress = objectReference:GetRefValue("progress1UProgress")
	local dayUBaseText = objectReference:GetRefValue("dayUBaseText")

	ClientTextUtils.setText(dayUBaseText, pg.getGameString("SIGNIN_LONG_TERM_1"))
	button:TryChangePage("number", data.showIndex - 1)
	button:TryChangePage("Bar", data.barState)

	local taskState = data.taskState
	local btnState = self.model:getTaskInfo(ActivityConst.SignDayType.SevenDay, taskState, self.curDay, data.showIndex)

	button:TryChangePage("Status", btnState)

	progressUProgress.minValue = 0
	progressUProgress.maxValue = 1
	progressUProgress.value = data.progressValue
	progress1UProgress.minValue = 0
	progress1UProgress.maxValue = 1
	progress1UProgress.value = data.progressValue

	local rewards = LuaUIUtils.getRewardItemByDropId(data.taskAward, taskState >= ActivityConst.TaskState.Received, taskState == ActivityConst.TaskState.Finihed_CanRecv)

	LuaUIUtils.renderRewardItem(itemUComponent, rewards[1])

	local canGet = taskState == ActivityConst.TaskState.Finihed_CanRecv

	function button.luaClick()
		if canGet then
			pg.me:reqActReceiveTaskReward(data.taskId, self.eventId)
		else
			self.ctrl:showSignItemInfo(rewards[1], button)
		end
	end

	self.ctrl:setSignRodDot(index, button, canGet)
end

function SignLongDayComponent:onDestroy()
	UIComponent.onDestroy(self)
end

return SignLongDayComponent
