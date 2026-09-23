-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetDispatchTask\\PetDispatchTaskCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("PetDispatchTaskCtrl")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local MessageName = require("Const.MessageName")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local Utils = require("Common.Utils.Utils")
local Time = require("Core.Common.Time")
local TimerManager = require("Core.Timer.TimerManager")
local SysConfigData = require("Data.sys_config_data")
local EventTaskData = require("Data.event_task_data")
local PetDispatchUtils = require("GameApp.PetDispatch.PetDispatchUtils")
local RATING_TO_ACCESS = {
	S = 2,
	A = 1,
	B = 0
}
local PetDispatchTaskCtrl = Class.LightClass("PetDispatchTaskCtrl", UICtrl)

PetDispatchTaskCtrl.messages = {
	[MessageName.EVENT_CUR_PAGE_REFRESH] = {
		"refreshUI",
		true
	},
	[MessageName.EVENT_TASK_STATE_CHANGE] = {
		"refreshUI",
		true
	}
}

function PetDispatchTaskCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function PetDispatchTaskCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.model.eventId = info.eventId
	self.model.clueId = info.clueId
	self.model.selectMode = "leader"
	self.model.selectedLeaderId = nil
	self.model.selectedFollowerIds = {}

	self:refreshUI()
end

function PetDispatchTaskCtrl:onDestroy()
	self:_clearCountDownFormatTimer()
	UICtrl.onDestroy(self)
end

function PetDispatchTaskCtrl:_clearCountDownFormatTimer()
	if self._countDownFmtTimer then
		TimerManager.removeTimer(self._countDownFmtTimer)

		self._countDownFmtTimer = nil
	end
end

function PetDispatchTaskCtrl:addListener()
	if self.view.btnClose then
		function self.view.btnClose.luaClick()
			self:dismiss()
		end
	end

	if self.view.btnDark then
		function self.view.btnDark.luaClick()
			if not self.model.btnDarkEnabled then
				return
			end

			self:onMainAction()
		end
	end

	if self.view.btnBlueUButton then
		function self.view.btnBlueUButton.luaClick()
			if self.model.taskState == ActivityConst.TaskState.Finihed_CanRecv then
				self:onMainAction()
			end
		end
	end

	if self.view.btnRules then
		function self.view.btnRules.luaClick()
			pg.global.ui.tips:openEventRuleDesc(pg.getGameString("DISPATCH_PET_RULE"))
		end
	end

	if self.view.btnInfoPossibly then
		self.view.btnInfoPossibly.tooltipId = pg.getGameString("DISPATCH_TASK_ADVENTURE_DESC")
	end

	if self.view.listLeaderUList then
		function self.view.listLeaderUList.luaRenderItem(button, index, data)
			self:renderTeamSlot(button, data, "leader", index)
		end
	end

	if self.view.listMemberUList then
		function self.view.listMemberUList.luaRenderItem(button, index, data)
			self:renderTeamSlot(button, data, "follower", index)
		end
	end

	if self.view.listRewardUList then
		function self.view.listRewardUList.luaRenderItem(button, index, data)
			LuaUIUtils.renderRewardItem(button, data)
		end
	end

	if self.view.listPossiblyUList then
		function self.view.listPossiblyUList.luaRenderItem(button, index, data)
			LuaUIUtils.renderRewardItem(button, data)
		end
	end

	if self.view.btnChoose then
		function self.view.btnChoose.luaClick()
			self:onClickAutoChoose()
		end
	end
end

function PetDispatchTaskCtrl:refreshUI()
	self.model:refresh()
	self:refreshHeader()
	self:refreshCountDown()
	self:refreshTeamSlots()
	self:refreshExtraReward()
	self:refreshPossiblyReward()
	self:refreshMainAction()
end

function PetDispatchTaskCtrl:refreshAfterTeamChange()
	self:refreshTeamSlots()
	self:refreshExtraReward()
	self:refreshCountDown()
	self:refreshMainAction()
end

function PetDispatchTaskCtrl:refreshExtraReward()
	local conditions = self.model.clueId and PetDispatchUtils.getExtraConditions(self.model.clueId) or {}

	if self.view.clueItems then
		for i = 1, 3 do
			local btn = self.view.clueItems[i]

			if btn then
				local objectReference = btn:GetComponent("ObjectReference")
				local txtName = objectReference and objectReference:GetRefValue("txtName")

				if txtName then
					local text

					if i <= 2 then
						local cond = conditions[i]

						text = cond and cond.name and pg.getLocalizationText(cond.name) or ""
					else
						text = pg.getGameString("DISPATCH_TASK_RAINBOW_SHINY")
					end

					ClientTextUtils.setText(txtName, text)
				end
			end
		end
	end

	local team = {}

	for _, petId in ipairs(self:getCurrentTeamIds()) do
		team[#team + 1] = {
			id = petId
		}
	end

	local rating = PetDispatchUtils.calcRating(team, conditions)
	local state = RATING_TO_ACCESS[rating] or 0

	if self.view.rewardUComponent then
		self.view.rewardUComponent:TryChangePage("Access", state)
	end

	if self.view.rootUComponent and self._lastAccessState ~= nil and state > self._lastAccessState and self.model.taskState ~= ActivityConst.PetDispatchTaskSubState.UnFinished_Disptaching then
		self.view.rootUComponent:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
	end

	self._lastAccessState = state

	if self.view.listRewardUList then
		local taskCfg = self.model.clueId and EventTaskData[self.model.clueId]
		local extraAward = taskCfg and taskCfg.extraAward or {}
		local dropId = extraAward[state]
		local rewards = dropId and LuaUIUtils.getRewardItemByDropId(dropId) or {}

		self.view.listRewardUList:SetList(rewards)
	end
end

function PetDispatchTaskCtrl:refreshPossiblyReward()
	if not self.view.listPossiblyUList then
		return
	end

	local activityData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.PetDispatch)
	local phase = activityData and activityData.eventPhase or 1
	local dropIds = PetDispatchUtils.getAdventureRewardDropIds(phase)
	local rewards = {}

	for _, dropId in ipairs(dropIds) do
		for _, item in ipairs(LuaUIUtils.getRewardItemByDropId(dropId) or EMPTY_TABLE) do
			rewards[#rewards + 1] = item
		end
	end

	self.view.listPossiblyUList:SetList(rewards)
end

function PetDispatchTaskCtrl:refreshTeamSlots()
	if self.view.listLeaderUList then
		self.view.listLeaderUList:SetList({
			self:buildSlotData(self.model.selectedLeaderId)
		})
	end

	if self.view.listMemberUList then
		local members = {}
		local followers = self.model.selectedFollowerIds or {}

		for i = 1, ActivityConst.PetDispatchPetMaxNum - 1 do
			members[i] = self:buildSlotData(followers[i])
		end

		self.view.listMemberUList:SetList(members)
	end
end

function PetDispatchTaskCtrl:buildSlotData(petId)
	if not petId then
		return {
			tIndex = 1
		}
	end

	local petInfo = pg.me and pg.me:getPetInfo(petId)
	local pet = petInfo and LuaUIUtils.getDispatchPetInfo(petInfo)

	if not pet then
		return {
			tIndex = 1
		}
	end

	return {
		tIndex = 0,
		petInfo = pet
	}
end

function PetDispatchTaskCtrl:_calcSlotMatchCount(petInfo)
	local conditions = self.model.clueId and PetDispatchUtils.getExtraConditions(self.model.clueId) or {}
	local matchCount = 0

	for _, cond in ipairs(conditions) do
		if PetDispatchUtils.isPetMatchCondition(petInfo, cond) then
			matchCount = matchCount + 1
		end
	end

	return matchCount
end

function PetDispatchTaskCtrl:renderTeamSlot(button, data, mode, slotIndex)
	if not button or not data then
		return
	end

	local objectReference = button:GetComponent("ObjectReference")

	if objectReference then
		local imgFrameSelUImage = objectReference:GetRefValue("imgFrameSelUImage")

		imgFrameSelUImage:SetActive(self.model.pickingMode and self.model.pickingMode == mode)
	end

	if data.tIndex == 0 and data.petInfo and objectReference then
		local iconUImage = objectReference:GetRefValue("iconUImage")

		if iconUImage then
			iconUImage.url = LuaUIUtils.getPetIcon(data.petInfo.iconName, LuaUIUtils.PET_ICON, data.petInfo.label, data.petInfo.gender)
		end

		button:TryChangePage("Type", data.petInfo.isShiny and 1 or 0)

		local rconmmendQualityUContainer = objectReference:GetRefValue("rconmmendQualityUContainer")

		if rconmmendQualityUContainer then
			data.petInfo.matchCount = self:_calcSlotMatchCount(data.petInfo)

			local recommendCount = PetDispatchUtils.getRecommendCount(data.petInfo)

			if recommendCount > 0 then
				rconmmendQualityUContainer:SetActive(true)
				rconmmendQualityUContainer:LoadDefaultUrlManually()

				if rconmmendQualityUContainer.content then
					rconmmendQualityUContainer.content:TryChangePage("Quality", math.min(recommendCount - 1, 3))
				end
			else
				rconmmendQualityUContainer:SetActive(false)
			end
		end
	end

	function button.luaClick()
		if self.model.taskState ~= ActivityConst.TaskState.UnFinished then
			return
		end

		self:openPetPick(mode, mode == "follower" and slotIndex or nil)
	end
end

function PetDispatchTaskCtrl:refreshHeader()
	local clueConfig = self.model.clueId and PetDispatchUtils.getClueConfig(self.model.clueId)
	local bgUrl = clueConfig and clueConfig.taskBackImage

	if self.view.bgUImage and bgUrl then
		self.view.bgUImage.url = bgUrl
	end

	if self.view.txtBlockName and self.model.eventTitle then
		ClientTextUtils.setText(self.view.txtBlockName, pg.getLocalizationText(self.model.eventTitle))
	end

	if self.view.textDescription and self.model.taskDes then
		ClientTextUtils.setText(self.view.textDescription, pg.getLocalizationText(self.model.taskDes))
	end
end

function PetDispatchTaskCtrl:refreshCountDown()
	local cd = self.view.countDownUCountDown

	if not cd then
		return
	end

	local state = self.model.taskState

	if state == ActivityConst.TaskState.Finihed_CanRecv then
		self:_clearCountDownFormatTimer()
		cd:SetActive(false)

		if cd.Stop then
			cd:Stop()
		end

		if self.view.timeReduceUWidget then
			self.view.timeReduceUWidget.gameObject:SetActiveEx(false)
		end

		return
	end

	cd:SetActive(true)

	if state == ActivityConst.PetDispatchTaskSubState.UnFinished_Disptaching and self.model.endTime then
		self:_applyDispatchingCountDown(cd)

		if self.view.timeReduceUWidget then
			self.view.timeReduceUWidget.gameObject:SetActiveEx(false)
		end

		return
	end

	self:_clearCountDownFormatTimer()

	if cd.Stop then
		cd:Stop()
	end

	local team = self:getCurrentTeamIds()
	local ratio = #team > 0 and Utils.getPetDisptachReduceTimeRatio(pg.me, team) or 0
	local baseHours = SysConfigData.DISPATCH_TIME
	local totalSeconds = math.floor(baseHours * 3600 * (1 - ratio))

	if self.view.timeReduceUWidget then
		self.view.timeReduceUWidget.gameObject:SetActiveEx(ratio > 0)
	end

	if ratio > 0 and self.view.txttime then
		ClientTextUtils.setText(self.view.txttime, pg.getFormatText(pg.getGameString("DISPATCH_TASK_TIME_CONSUME"), baseHours))
	end

	if self.view.txtCountDoum then
		local des = ratio > 0 and LuaUIUtils.getCountDownString(totalSeconds, UIConst.TimeType.Short, true) or pg.getFormatText(pg.getGameString("DISPATCH_TASK_TIME_CONSUME"), baseHours)

		ClientTextUtils.setText(self.view.txtCountDoum, des)
	end
end

function PetDispatchTaskCtrl:_applyDispatchingCountDown(cd)
	self:_clearCountDownFormatTimer()

	local remainTime = (self.model.endTime or 0) - Time.getSecond()

	if remainTime <= 0 then
		return
	end

	local hourL10n = pg.getGameString("HOUR")
	local minuteL10n = pg.getGameString("MINUTE")
	local secondL10n = pg.getGameString("SECOND")
	local fmt, nextSwitchAt

	if remainTime > 3600 then
		fmt = ClientTextUtils.concatCountDownUnitsByLanguage("{1}", hourL10n, "{2}", minuteL10n)
		nextSwitchAt = remainTime - 3600 + 1
	elseif remainTime > 60 then
		fmt = ClientTextUtils.concatCountDownUnitsByLanguage("{2}", minuteL10n, "{3}", secondL10n)
		nextSwitchAt = remainTime - 60 + 1
	else
		fmt = ClientTextUtils.concatCountDownUnitsByLanguage("{3}", secondL10n)
	end

	cd.formatText = fmt

	cd:Play(remainTime)

	if nextSwitchAt and nextSwitchAt > 0 then
		self._countDownFmtTimer = TimerManager.addTimer(nextSwitchAt, function()
			self._countDownFmtTimer = nil

			if self.view and self.view.countDownUCountDown then
				self:_applyDispatchingCountDown(self.view.countDownUCountDown)
			end
		end)
	end
end

function PetDispatchTaskCtrl:refreshMainAction()
	local state = self.model.taskState

	if self.view.btnChoose then
		self.view.btnChoose:SetActive(state == ActivityConst.TaskState.UnFinished)
	end

	if state == ActivityConst.TaskState.Finihed_CanRecv then
		if self.view.btnBlueUButton then
			self.view.btnBlueUButton:SetActive(true)
		end

		if self.view.btnDark then
			self.view.btnDark:SetActive(false)
		end

		if self.view.txtbtnBlue then
			ClientTextUtils.setText(self.view.txtbtnBlue, pg.getLocalizationText(pg.getGameString("DISPATCH_TASK_BUTTON_3")))
		end

		return
	end

	if self.view.btnBlueUButton then
		self.view.btnBlueUButton:SetActive(false)
	end

	if self.view.btnDark then
		self.view.btnDark:SetActive(true)
	end

	local textKey, enable

	if state == ActivityConst.PetDispatchTaskSubState.UnFinished_Disptaching then
		textKey, enable = "DISPATCH_TASK_BUTTON_2", true
	elseif state == ActivityConst.TaskState.UnFinished then
		textKey = "DISPATCH_TASK_BUTTON_1"
		enable = self:canDispatch()
	else
		textKey, enable = "DISPATCH_MAP_CONDITION_3", false
	end

	if self.view.txtBtn then
		ClientTextUtils.setText(self.view.txtBtn, pg.getLocalizationText(pg.getGameString(textKey)))
	end

	if self.view.btnDark then
		self.view.btnDark:TryChangePage("button", enable and 0 or 4)
	end

	self.model.btnDarkEnabled = enable
end

function PetDispatchTaskCtrl:openPetPick(mode, slotIndex)
	self.model.selectMode = mode
	self.model.pickingMode = mode

	self:refreshTeamSlots()
	pg.global.ui:open(UIConst.UI_ID_PET_DISPATCH_PET_SELECT, {
		eventId = self.model.eventId,
		clueId = self.model.clueId,
		mode = mode,
		slotIndex = slotIndex,
		excludePetIds = self:getCurrentTeamSlots(),
		onPicked = function(petId)
			self:onPetPicked(mode, slotIndex, petId)
		end,
		onClose = function()
			self.model.pickingMode = nil

			self:refreshTeamSlots()
		end
	})
end

function PetDispatchTaskCtrl:getCurrentTeamSlots()
	local slots = {}

	slots[1] = self.model.selectedLeaderId

	local followers = self.model.selectedFollowerIds or {}

	for i = 1, ActivityConst.PetDispatchPetMaxNum - 1 do
		slots[i + 1] = followers[i]
	end

	return slots
end

function PetDispatchTaskCtrl:onPetPicked(mode, slotIndex, payload)
	if mode == "leader" then
		self.model.selectedLeaderId = payload
	else
		self.model.selectedFollowerIds = {}

		for i, petId in ipairs(payload or EMPTY_TABLE) do
			self.model.selectedFollowerIds[i] = petId
		end
	end

	self:refreshAfterTeamChange()
end

function PetDispatchTaskCtrl:getCurrentTeamIds()
	local ids = {}

	if self.model.selectedLeaderId then
		ids[#ids + 1] = self.model.selectedLeaderId
	end

	for i = 1, ActivityConst.PetDispatchPetMaxNum - 1 do
		local pid = self.model.selectedFollowerIds[i]

		if pid then
			ids[#ids + 1] = pid
		end
	end

	return ids
end

function PetDispatchTaskCtrl:onClickAutoChoose()
	if self.model.taskState ~= ActivityConst.TaskState.UnFinished then
		return
	end

	if not self.model.clueId then
		return
	end

	local clueId = self.model.clueId
	local conditions = PetDispatchUtils.getExtraConditions(clueId) or {}
	local followerPets = PetDispatchUtils.listSelectablePets(clueId, nil, "follower")
	local freshLeaders, rewardedLeaders = {}, {}

	for _, pet in ipairs(PetDispatchUtils.listSelectablePets(clueId, nil, "leader")) do
		if not pet.dispatching then
			local group = pet.isGoldAdveRewarded and rewardedLeaders or freshLeaders

			group[#group + 1] = pet
		end
	end

	local leader, followerIds = self:_pickAutoLeader(freshLeaders, conditions, followerPets)

	if not leader or self:_teamRating(leader, followerIds, conditions) ~= "S" then
		local rwLeader, rwFollowers = self:_pickAutoLeader(rewardedLeaders, conditions, followerPets)

		if rwLeader and (not leader or self:_teamRating(rwLeader, rwFollowers, conditions) == "S") then
			leader, followerIds = rwLeader, rwFollowers
		end
	end

	self.model.selectedLeaderId = leader and leader.id or nil
	self.model.selectedFollowerIds = {}

	for i, id in ipairs(followerIds or EMPTY_TABLE) do
		self.model.selectedFollowerIds[i] = id
	end

	self:refreshAfterTeamChange()
end

function PetDispatchTaskCtrl:_pickAutoLeader(leaders, conditions, followerPets)
	local fallbackLeader, fallbackFollowers

	for _, pet in ipairs(leaders) do
		local followerIds = self:_pickAutoFollowers(pet, conditions, followerPets)

		if self:_teamRating(pet, followerIds, conditions) == "S" then
			return pet, followerIds
		end

		if not fallbackLeader then
			fallbackLeader, fallbackFollowers = pet, followerIds
		end
	end

	return fallbackLeader, fallbackFollowers
end

function PetDispatchTaskCtrl:_pickAutoFollowers(leader, conditions, followerPets)
	local cap = ActivityConst.PetDispatchPetMaxNum - 1
	local candidates = {}

	for _, pet in ipairs(followerPets) do
		if not pet.dispatching and not pet.outOfBlock and pet.id ~= leader.id then
			candidates[#candidates + 1] = pet
		end
	end

	local team = {
		leader
	}
	local taken = {}

	for _, cond in ipairs(conditions) do
		if cap <= #team - 1 then
			break
		end

		if not PetDispatchUtils.isTeamMatchCondition(team, cond) then
			for _, pet in ipairs(candidates) do
				if not taken[pet.id] and PetDispatchUtils.isPetMatchCondition(pet, cond) then
					taken[pet.id] = true
					team[#team + 1] = pet

					break
				end
			end
		end
	end

	for _, pet in ipairs(candidates) do
		if cap <= #team - 1 then
			break
		end

		if not taken[pet.id] then
			taken[pet.id] = true
			team[#team + 1] = pet
		end
	end

	local ids = {}

	for _, pet in ipairs(candidates) do
		if taken[pet.id] then
			ids[#ids + 1] = pet.id
		end
	end

	return ids
end

function PetDispatchTaskCtrl:_teamRating(leader, followerIds, conditions)
	local team = {
		leader
	}

	for _, id in ipairs(followerIds) do
		team[#team + 1] = {
			id = id
		}
	end

	return PetDispatchUtils.calcRating(team, conditions)
end

function PetDispatchTaskCtrl:onMainAction()
	if self.model.taskState == ActivityConst.TaskState.UnFinished then
		if not self:canDispatch() then
			pg.global.ui.tips:showTextTip(pg.getLocalizationText(pg.getGameString("DISPATCH_TASK_PET_TITLE")))

			return
		end

		local eventTimeCfg = Utils.getEventTimeConfig(self.model.eventId)
		local stageEndTime = eventTimeCfg and eventTimeCfg.tabEndDayTime

		if stageEndTime then
			local team = self:getCurrentTeamIds()
			local ratio = #team > 0 and Utils.getPetDisptachReduceTimeRatio(pg.me, team) or 0
			local finishTime = Time.secondCache + math.floor(SysConfigData.DISPATCH_TIME * 3600 * (1 - ratio))

			if stageEndTime <= finishTime then
				pg.global.ui.tips:showTextTip(pg.getLocalizationText(pg.getGameString("DISPATCH_TASK_TIME_FORBIDDEN")))

				return
			end
		end

		local leaderInfo = self.model.selectedLeaderId and pg.me and pg.me:getPetInfo(self.model.selectedLeaderId)

		if leaderInfo and pg.me:hasPetGoldAdveRewarded(leaderInfo.id) then
			pg.global.ui:open(UIConst.UI_ID_COMMON_CONFIRM, {
				title = pg.getGameString("RELEASE_WARN"),
				desc = pg.getGameString("DISPATCH_PET_RESONATED_TIP"),
				okCb = function()
					pg.me:reqActivityPetDisPatchStart(self.model.eventId, self.model.clueId, self:getCurrentTeamIds())
				end
			})

			return
		end

		pg.me:reqActivityPetDisPatchStart(self.model.eventId, self.model.clueId, self:getCurrentTeamIds())
	elseif self.model.taskState == ActivityConst.PetDispatchTaskSubState.UnFinished_Disptaching then
		pg.global.ui:open(UIConst.UI_ID_COMMON_CONFIRM, {
			title = pg.getGameString("DISPATCH_TASK_RACALL_TLTLE"),
			desc = pg.getGameString("DISPATCH_TASK_RACALL_DESC"),
			okCb = function()
				pg.me:reqActivityPetDisPatchRecall(self.model.eventId, self.model.clueId)
			end
		})
	elseif self.model.taskState == ActivityConst.TaskState.Finihed_CanRecv then
		pg.me:reqActReceiveTaskReward(self.model.clueId, self.model.eventId)
	end
end

function PetDispatchTaskCtrl:canDispatch()
	if not self.model.selectedLeaderId then
		return false
	end

	return #self:getCurrentTeamIds() >= ActivityConst.PetDispatchPetMinNum
end

return PetDispatchTaskCtrl
