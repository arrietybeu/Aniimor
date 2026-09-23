-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Event\\Component\\AreaActivityComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("AreaActivityComponent")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local EventContainerComponent = require("Guis.Panels.Event.Component.EventContainerComponent")
local GameEventData = require("Data.game_event_data")
local RedDotConst = require("Const.RedDotConst")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local Time = require("Core.Common.Time")
local ClientConst = require("Const.ClientConst")
local Utils = require("Common.Utils.Utils")
local PetData = require("Data.pet_data")
local PetAvatarData = require("Data.pet_avatar_data")
local LimitData = require("Data.limit_data")
local EventAreaActivityData = require("Data.event_area_activity_data")
local AddressDataConst = require("Const.AddressDataConst")
local NoticeDef = require("Common.NoticeDef")
local ActivityConst = require("Common.Const.ActivityConst")
local EventTaskData = require("Data.event_task_data")
local AreaActivityComponent = Class.LightClass("AreaActivityComponent", EventContainerComponent)

function AreaActivityComponent:findObjects()
	if not self:checkContentLoaded() then
		return
	end

	local objectReference = self.transform:GetChild(0):GetComponent("ObjectReference")

	self.txtTitleUBaseText = objectReference:GetRefValue("txtTitleUBaseText")
	self.listRewardUList = objectReference:GetRefValue("listRewardUList")
	self.taskEntrance1 = objectReference:GetRefValue("taskEntrance1")
	self.taskEntrance2 = objectReference:GetRefValue("taskEntrance2")
	self.taskEntrance3 = objectReference:GetRefValue("taskEntrance3")
	self.taskEntrance4 = objectReference:GetRefValue("taskEntrance4")
	self.taskEntranceRoot = objectReference:GetRefValue("taskEntranceRoot")
	self.btnGotoUButton = objectReference:GetRefValue("btnGotoUButton")
	self.activityLockUWidget = objectReference:GetRefValue("activityLockUButton")
	self.txtLockUBaseText = objectReference:GetRefValue("txtLockUBaseText")
	self.rootWidget = objectReference:GetRefValue("rootWidget")
	self.eventTitleUContainer = objectReference:GetRefValue("eventTitleUContainer")
	self.eggUWidget = objectReference:GetRefValue("eggUWidget")
	self.eggDescTxt = objectReference:GetRefValue("eggDescTxt")
	self.eggUButton = objectReference:GetRefValue("eggUButton")
	self.petNameTxt = objectReference:GetRefValue("petNameTxt")
	self.btnSearchUButton = objectReference:GetRefValue("btnSearchUButton")
	self.elementUButton = objectReference:GetRefValue("elementUButton")
	self.formItemUButton = objectReference:GetRefValue("formItemUButton")
	self.qualityUImage = objectReference:GetRefValue("qualityUImage")
	self.petImg = objectReference:GetRefValue("petImg")
	self.islandTextNameUBaseText = objectReference:GetRefValue("islandTextNameUBaseText")
	self.formItemTxt = objectReference:GetRefValue("formItemTxt")
end

function AreaActivityComponent:addListener()
	function self.listRewardUList.luaRenderItem(button, index, data)
		LuaUIUtils.renderRewardItem(button, data)
	end

	function self.btnGotoUButton.luaClick()
		local areaTaskData = EventAreaActivityData[self.eventPhase]
		local eventId = areaTaskData.event

		if eventId then
			pg.global.showConfirmMsgRaw(pg.getGameString("PET_RESEARCH_TEXT1"), pg.getGameString("PET_RESEARCH_TEXT2"), function()
				pg.me:doEvent(eventId)
			end, nil)
		end
	end

	function self.taskEntranceRoot.luaClick()
		if self.isLock then
			pg.global.showBubbleMessageById(NoticeDef.LOCK_CONDITION_NOT_MEET)
		else
			self:clearCacheRemoveMap()
			pg.global.ui:enableVisibleWhitelistForDuration({
				UIConst.UI_ID_EVENT
			})
			pg.global.ui:open(UIConst.UI_ID_EVENT_AREA_ACTIVITY, {
				rootTask = true,
				subTaskIndex = 0,
				eventId = self.eventId,
				eventPhase = self.eventPhase
			})
		end
	end

	if self.btnSearchUButton then
		function self.btnSearchUButton.luaClick()
			local templateId = self.model:getRewardShowPetId(self.eventId, self.eventPhase)

			if not templateId then
				return
			end

			pg.global.ui:open(UIConst.UI_ID_PET_DETAIL, {
				templateId = templateId
			})
		end
	end

	if self.eggUButton then
		function self.eggUButton.luaClick()
			local taskId = self.model:getAreaActivityBigTaskId(self.eventId, self.eventPhase)

			if not taskId then
				return
			end

			local taskState = ActivityUtils.getActTaskState(pg.me, taskId)

			if taskState == ActivityConst.TaskState.Finihed_CanRecv then
				pg.me:reqActReceiveTaskReward(taskId, self.eventId)
			else
				local taskCfg = EventTaskData[taskId]

				if not taskCfg or not taskCfg.award then
					return
				end

				local rewards = LuaUIUtils.getRewardItemByDropId(taskCfg.award)
				local firstItem = rewards and rewards[1]

				if not firstItem or not firstItem.id then
					return
				end

				pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
					id = firstItem.id,
					num = firstItem.num,
					targetRect = self.eggUButton
				})
			end
		end
	end
end

function AreaActivityComponent:onBeforeRefreshPage()
	EventContainerComponent.onBeforeRefreshPage(self)

	self.isLock = ActivityUtils.getOprActivityUnlockCond(self.eventId) == false
	self._cacheRemoveMap = {}
end

function AreaActivityComponent:onEnterPlayEvent()
	pg.game.audio:playEvent("SFX_UI_WaterArea_MoveIn")
end

function AreaActivityComponent:refreshPage()
	local areaTaskData = EventAreaActivityData[self.eventPhase]
	local eventTimeCfg = Utils.getEventTimeConfig(self.eventId)
	local eventEndDayTime = eventTimeCfg and eventTimeCfg.tabEndDayTime

	self:setEventTitle(self.eventTitleUContainer, eventEndDayTime, pg.getLocalizationText(areaTaskData.trainTitle))
	ClientTextUtils.setText(self.islandTextNameUBaseText, pg.getGameString("DISPATCH_MAP_CONDITION_1"))

	local rewards = LuaUIUtils.getRewardItemByDropId(areaTaskData.trainReward)

	self.listRewardUList:SetList(rewards)
	self.rootWidget:TryChangePage("LevelRestrictions", self.isLock and "Lock" or "Unlock")

	if self.isLock then
		ClientTextUtils.setText(self.txtLockUBaseText, self.model:getEventLockInfo(self.eventId))
	end

	self:renderRootEntrance()

	for i = 1, #areaTaskData.petResearchTaskGroupId do
		self:renderSubEntrance(i)
	end

	self:renderRewardShow()
end

function AreaActivityComponent:renderRootEntrance()
	local objectReference = self.taskEntranceRoot:GetComponent("ObjectReference")
	local scheduleUBaseText = objectReference:GetRefValue("scheduleUBaseText")
	local titleUBaseText = objectReference:GetRefValue("titleUBaseText")
	local islandBaseUImage = objectReference:GetRefValue("islandBaseUImage")
	local islandUImage = objectReference:GetRefValue("islandUImage")
	local data = EventAreaActivityData[self.eventPhase]

	if not data then
		return
	end

	self.taskEntranceRoot:TryChangePage("State", self.isLock and "Lock" or "UnLock")

	local taskGroupId = data.islandTaskGroupId
	local finishCnt, totalCnt, taskIds = ActivityUtils.getActTaskNumByGroupId(nil, taskGroupId)

	ClientTextUtils.setText(scheduleUBaseText, string.format("%s/%s", finishCnt, totalCnt))
	ClientTextUtils.setText(titleUBaseText, pg.getLocalizationText(data.islandName))

	islandUImage.url = data.islandMainImage

	local getReward = ClientActivityUtils.getCanGetRewardByTaskGroupId(taskGroupId)

	pg.global.setRedDot(string.format(RedDotConst.RedDotPath.EVENT_AREA_ACTIVITY_ENTRANCE, 0), self.taskEntranceRoot, getReward, RedDotConst.RedDotStyle.REWARD)
end

function AreaActivityComponent:renderSubEntrance(index)
	local rootBtn = self["taskEntrance" .. index]
	local data = EventAreaActivityData[self.eventPhase]

	if not rootBtn or not data then
		return
	end

	local objectReference = rootBtn:GetComponent("ObjectReference")
	local emoUImage = objectReference:GetRefValue("emoUImage")
	local titleUBaseText = objectReference:GetRefValue("titleUBaseText")
	local lockTitleTxt = objectReference:GetRefValue("lockTitleTxt")
	local scheduleUBaseText = objectReference:GetRefValue("scheduleUBaseText")
	local finishTitleTxt = objectReference:GetRefValue("finishTitleTxt")
	local fxRewardUWidget = objectReference:GetRefValue("fxRewardUWidget")
	local rootAni = objectReference:GetRefValue("rootAni")
	local state = self.model:getSubTaskState(self.eventId, index)
	local taskGroupId = data.petResearchTaskGroupId[index]
	local finishCnt, totalCnt = ActivityUtils.getActTaskNumByGroupId(nil, taskGroupId)

	emoUImage.url = string.format(AddressDataConst.AREA_ACTIVITY_ENTRANCE_OPEN, data.petResearchImage[index])

	ClientTextUtils.setText(titleUBaseText, pg.getLocalizationText(data.petResearchName[index]))
	ClientTextUtils.setText(scheduleUBaseText, string.format("%s/%s", finishCnt, totalCnt))

	if state == self.model.AREA_TASK_STATE.OPEN then
		UIUtils.PlayAnimation(rootAni, "VX_Ani_Node_Event_WaterArea_TaskEntrance_Normal", function()
			return
		end)
	elseif state == self.model.AREA_TASK_STATE.FINISH then
		ClientTextUtils.setText(finishTitleTxt, pg.getLocalizationText(data.petResearchName[index]))
		self.model:setSubTaskPrefCache(self.eventId, index, false)

		local justFinish = ClientActivityUtils.getAreaActivitySubTaskPrefCache(self.eventId, index, true) == 0

		if justFinish then
			self:startTimer(function()
				if fxRewardUWidget then
					fxRewardUWidget:SetActive(true)
				end
			end, 0.5)

			self._cacheRemoveMap[index] = 2
		end
	end

	rootBtn:TryChangePage("State", state)

	if not self.isLock then
		function rootBtn.luaClick()
			self:clearCacheRemoveMap()
			pg.global.ui:enableVisibleWhitelistForDuration({
				UIConst.UI_ID_EVENT
			})
			pg.global.ui:open(UIConst.UI_ID_EVENT_AREA_ACTIVITY, {
				eventId = self.eventId,
				subTaskIndex = index,
				eventPhase = self.eventPhase,
				subTaskState = state
			})
		end
	else
		ClientTextUtils.setText(lockTitleTxt, pg.getLocalizationText(data.petResearchName[index]))

		function rootBtn.luaClick()
			pg.global.showBubbleMessageById(NoticeDef.LOCK_CONDITION_NOT_MEET)
		end
	end

	local getReward = ClientActivityUtils.getCanGetRewardByTaskGroupId(taskGroupId)

	pg.global.setRedDot(string.format(RedDotConst.RedDotPath.EVENT_AREA_ACTIVITY_ENTRANCE, index), rootBtn, getReward, getReward and RedDotConst.RedDotStyle.REWARD or nil)
end

function AreaActivityComponent:onBeforeExitPage()
	self:clearCacheRemoveMap()
	self:refreshCommonNodeRedDot()
end

function AreaActivityComponent:clearCacheRemoveMap()
	for index, cacheType in pairs(self._cacheRemoveMap or EMPTY_TABLE) do
		self.model:setSubTaskPrefCache(self.eventId, index, cacheType == 2)
	end

	self._cacheRemoveMap = {}
end

function AreaActivityComponent:renderRewardShow()
	if not self.eggUWidget then
		return
	end

	local templateId = self.model:getRewardShowPetId(self.eventId, self.eventPhase)

	if not templateId then
		self.eggUWidget:SetActive(false)

		return
	end

	self.eggUWidget:SetActive(true)

	local pData = PetData[templateId]

	if not pData then
		return
	end

	if self.petNameTxt then
		ClientTextUtils.setText(self.petNameTxt, pg.getLocalizationText(pData.name))
	end

	local triggerMap = pg.me.triggerMap
	local taskId = self.model:getAreaActivityBigTaskId(self.eventId, self.eventPhase)
	local taskConfig = taskId and EventTaskData[taskId]
	local conditionId = taskConfig and EventTaskData[taskId].taskCondition
	local progress = conditionId and triggerMap:getConditionFinishCount(conditionId, 1) or 0
	local target = conditionId and triggerMap:getConditionTargetCount(conditionId, 1) or 0
	local taskState = ActivityUtils.getActTaskState(pg.me, taskId)
	local state

	state = (not taskState or taskState == ActivityConst.TaskState.UnFinished) and 0 or taskState == ActivityConst.TaskState.Received and 2 or 1

	self.eggUButton:TryChangePage("State", state)

	if state == 1 then
		self.eggUWidget:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
	else
		self.eggUWidget:InvokeCallback(CS.XGUI.EInvokeTime.Custom2)
	end

	if taskState ~= ActivityConst.TaskState.UnFinished then
		progress = target
	end

	if taskConfig and self.eggDescTxt then
		ClientTextUtils.setText(self.eggDescTxt, pg.getFormatText(pg.getLocalizationText(taskConfig.taskDes), progress, target))
	end

	pg.global.setRedDot(RedDotConst.RedDotPath.EVENT_AREA_ACTIVITY_PET_REWARD, self.eggUButton, taskState == ActivityConst.TaskState.Finihed_CanRecv, RedDotConst.RedDotStyle.REWARD)

	local qualityIdx = 4

	self.qualityUImage.url = AddressDataConst["FILTER_EVENT_RATING" .. qualityIdx]

	if self.formItemUButton then
		LuaUIUtils.renderFormItem(self.formItemUButton, templateId)
		ClientTextUtils.setText(self.formItemTxt, LuaUIUtils.getPetFormName(templateId))
	end

	if self.elementUButton then
		local _, names = LuaUIUtils.getElementInfo(pData.elementType)

		LuaUIUtils.setElementButtonNew(self.elementUButton, names[1].element, true, templateId)
	end
end

return AreaActivityComponent
