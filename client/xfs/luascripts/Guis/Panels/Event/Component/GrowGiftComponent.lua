-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Event\\Component\\GrowGiftComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("GrowGiftComponent")
local Class = require("Core.Framework.Class")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local EventContainerComponent = require("Guis.Panels.Event.Component.EventContainerComponent")
local Utils = require("Common.Utils.Utils")
local UIConst = require("Const.UIConst")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local NoticeDef = require("Common.NoticeDef")
local RedDotConst = require("Const.RedDotConst")
local ClientConst = require("Const.ClientConst")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local EventGrowthGiftData = require("Data.event_growth_gitf_data")
local ActivateTasksData = require("Data.activate_tasks_data")
local PetPrototypeData = require("Data.pet_prototype_data")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local GrowthGiftSelectModel = require("Guis.Panels.GrowthGiftSelect.GrowthGiftSelectModel")
local GrowGiftComponent = Class.LightClass("GrowGiftComponent", EventContainerComponent)

GrowGiftComponent.BtnGetState = {
	NotSelected = 2,
	CanReceive = 1,
	NotMeetCond = 0,
	Received = 3
}
GrowGiftComponent.CardStatus = {
	NotSelected = 0,
	Selected = 1,
	Received = 2
}

function GrowGiftComponent:findObjects()
	if not self:checkContentLoaded() then
		return
	end

	local objectReference = self.transform:GetChild(0):GetComponent("ObjectReference")

	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.eventTitleUContainer = objectReference:GetRefValue("eventTitleUContainer")
	self.btnGetUComponent = objectReference:GetRefValue("btnGetUComponent")
	self.cardUComponent = objectReference:GetRefValue("cardUComponent")
	self.btnSwitch = objectReference:GetRefValue("btnSwitch")
	self.txtSelect = objectReference:GetRefValue("txtSelect")
	self.btnSwitch2 = objectReference:GetRefValue("btnSwitch2")
	self.imgPetIcon = objectReference:GetRefValue("imgPetIcon")
	self.txtPetName = objectReference:GetRefValue("txtPetName")
	self.imgFormIcon = objectReference:GetRefValue("imgFormIcon")
	self.txtForm = objectReference:GetRefValue("txtForm")
	self.txtCurSwitch = objectReference:GetRefValue("txtCurSwitch")
	self.txtGetCondition = objectReference:GetRefValue("txtGetCondition")
	self.txtGetEgg = objectReference:GetRefValue("txtGetEgg")
	self.txtGetEgg2 = objectReference:GetRefValue("txtGetEgg2")
	self.txtGot = objectReference:GetRefValue("txtGot")
	self.btnGet1 = objectReference:GetRefValue("btnGet1")
	self.btnGet2 = objectReference:GetRefValue("btnGet2")
	self.btnCollect = objectReference:GetRefValue("btnCollect")
	self.curProgress = objectReference:GetRefValue("curProgress")
	self.collectCount = objectReference:GetRefValue("collectCount")
	self.listRewardUList = objectReference:GetRefValue("listRewardUList")
	self.txtCollected = objectReference:GetRefValue("txtCollected")
	self.txtViewCollection = objectReference:GetRefValue("txtViewCollection")
end

function GrowGiftComponent:addListener()
	ClientTextUtils.setText(self.txtSelect, pg.getGameString("PRISMANA_GIFTS_SELECT_REWARD"))
	ClientTextUtils.setText(self.txtCurSwitch, pg.getGameString("PRISMANA_GIFTS_CURRENT_SELECTION"))
	ClientTextUtils.setText(self.txtGetCondition, pg.getGameString("PRISMANA_GIFTS_PROMPTTEXT"))
	ClientTextUtils.setText(self.txtGetEgg, pg.getGameString("PRISMANA_GIFTS_UNLOCK_REWARD"))
	ClientTextUtils.setText(self.txtGetEgg2, pg.getGameString("PRISMANA_GIFTS_CLAIM_REWARD"))
	ClientTextUtils.setText(self.txtGot, pg.getGameString("PRISMANA_GIFTS_CLAIMED"))

	function self.btnSwitch.luaClick()
		self:openPetSelect()
	end

	function self.btnSwitch2.luaClick()
		self:openPetSelect()
	end

	function self.btnGet1.luaClick()
		self:onClickReceive()
	end

	function self.btnGet2.luaClick()
		self:onClickReceive()
	end

	function self.btnCollect.luaClick()
		self:openPetCollection()
	end

	function self.listRewardUList.luaRenderItem(button, index, data)
		self:onRenderCollectRewardItem(button, index, data)
	end
end

function GrowGiftComponent:getBtnGetState()
	local actData = self:getActData()

	if actData and actData.receivedPetFlag == 1 then
		return GrowGiftComponent.BtnGetState.Received
	end

	if not self:isReceiveCondMeet() then
		return GrowGiftComponent.BtnGetState.NotMeetCond
	end

	local selectedDropId = actData and actData.selectedPetId or 0

	if selectedDropId == 0 then
		return GrowGiftComponent.BtnGetState.NotSelected
	end

	return GrowGiftComponent.BtnGetState.CanReceive
end

function GrowGiftComponent:getCardStatus()
	local actData = self:getActData()

	if actData and actData.receivedPetFlag == 1 then
		return GrowGiftComponent.CardStatus.Received
	end

	local selectedDropId = actData and actData.selectedPetId or 0

	return selectedDropId == 0 and GrowGiftComponent.CardStatus.NotSelected or GrowGiftComponent.CardStatus.Selected
end

function GrowGiftComponent:getActData()
	local actData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.GrowthGift)

	return actData
end

function GrowGiftComponent:getSelectedRewardPetId()
	local actData = self:getActData()
	local selectedDropId = actData and actData.selectedPetId or 0

	return GrowthGiftSelectModel.getRewardPetIdByDropId(selectedDropId) or 0
end

function GrowGiftComponent:isReceiveCondMeet()
	local actCfg = EventGrowthGiftData[self.eventPhase]
	local condId = actCfg and actCfg.canReceiveCond or 0

	if condId == 0 then
		return true
	end

	if not pg.me or not pg.me.triggerMap then
		return false
	end

	return pg.me.triggerMap:isCompleteOrMeetCondition(condId)
end

function GrowGiftComponent:openPetSelect()
	pg.global.ui:open(UIConst.UI_ID_GROW_GIFT_SELECT, {
		eventId = self.eventId
	})
end

function GrowGiftComponent:openPetCollection()
	pg.global.ui:open(UIConst.UI_ID_GROW_GIFT_SELECT, {
		collectionMode = true,
		eventId = self.eventId
	})
end

function GrowGiftComponent:getCollectTaskInfoList()
	local activateTaskCfg = ActivateTasksData[self.eventId]
	local taskGroupId = activateTaskCfg and activateTaskCfg.foreverTaskGroup and activateTaskCfg.foreverTaskGroup[1]

	return ClientActivityUtils.getTaskInfoList(taskGroupId, true)
end

function GrowGiftComponent:buildCollectRewardList()
	local actData = self:getActData()
	local curProgress = actData and actData.collectSocre or 0
	local triggerMap = pg.me and pg.me.triggerMap
	local rewardList = {}
	local previousTargetNum = 0

	for _, taskInfo in ipairs(self:getCollectTaskInfoList()) do
		local targetNum = triggerMap and triggerMap:getConditionTargetCount(taskInfo.taskCondition, 1) or 0
		local segmentTargetNum = targetNum - previousTargetNum
		local segmentProgress = segmentTargetNum > 0 and math.min(math.max((curProgress - previousTargetNum) / segmentTargetNum, 0), 1) or 0
		local rewardState = ClientConst.RewardState.NotAchieved

		if taskInfo.taskState == ActivityConst.TaskState.Finihed_CanRecv then
			rewardState = ClientConst.RewardState.ReadyToClaim
		elseif taskInfo.taskState == ActivityConst.TaskState.Received or taskInfo.taskState == ActivityConst.TaskState.Received_SendMail then
			rewardState = ClientConst.RewardState.Claimed
		end

		local taskId = taskInfo.taskId
		local rewardData = {
			taskId = taskId,
			targetNum = targetNum,
			progress = segmentProgress,
			dropId = taskInfo.taskAward,
			state = rewardState
		}

		if rewardState == ClientConst.RewardState.ReadyToClaim then
			function rewardData.extraFunc()
				pg.me:reqActReceiveTaskReward(taskId, self.eventId)
			end
		end

		rewardList[#rewardList + 1] = rewardData
		previousTargetNum = targetNum
	end

	return rewardList
end

function GrowGiftComponent:onRenderCollectRewardItem(button, index, data)
	ClientActivityUtils.onRenderRewardProgressItem(button, index, data)

	local treePath = string.format(RedDotConst.RedDotPath.EVENT_GROW_GIFT_COLLECT_REWARD_ITEM, self.eventId, data.taskId)

	pg.global.setRedDot(treePath, button, data.state == ClientConst.RewardState.ReadyToClaim, RedDotConst.RedDotStyle.REWARD)
end

function GrowGiftComponent:onClickReceive()
	local state = self:getBtnGetState()

	if state == GrowGiftComponent.BtnGetState.NotMeetCond then
		pg.global.showBubbleMessageById(NoticeDef.ACT_GROWTH_GIFT_RECV_NOT_CONDITION)

		return
	end

	if state == GrowGiftComponent.BtnGetState.NotSelected then
		pg.global.showBubbleMessageById(NoticeDef.ACT_GROWTH_GIFT_NOT_SELECT_EGG)

		return
	end

	if state == GrowGiftComponent.BtnGetState.Received then
		return
	end

	local rewardPetId = self:getSelectedRewardPetId()
	local protoData = PetPrototypeData[rewardPetId]
	local petName = protoData and pg.getLocalizationText(protoData.name) or ""

	pg.global.ui:open(UIConst.UI_ID_COMMON_USE_CONFIRM, {
		hideCurrency = true,
		muteCheckEnough = true,
		title = pg.getGameString("PRISMANA_GIFTS_CONFIRM"),
		tipTop = pg.getFormatText(pg.getGameString("PRISMANA_GIFTS_CONFIRMTEXT"), petName),
		confirmCb = function()
			pg.me:reqGrowthGiftReceiveEgg(self.eventId)
		end
	})
end

function GrowGiftComponent:refreshRedDotState()
	local actData = self:getActData()
	local isCollectStage = actData and actData.receivedPetFlag == 1
	local showSelectRedDot = not isCollectStage and actData and (actData.selectedPetId or 0) == 0
	local showReceiveRedDot = not isCollectStage and self:getBtnGetState() == GrowGiftComponent.BtnGetState.CanReceive

	pg.global.setRedDot(RedDotConst.RedDotPath.EVENT_GROW_GIFT_SELECT, self.btnSwitch, showSelectRedDot, RedDotConst.RedDotStyle.POINT)
	pg.global.setRedDot(RedDotConst.RedDotPath.EVENT_GROW_GIFT_REWARD, self.btnGet1, showReceiveRedDot, RedDotConst.RedDotStyle.REWARD)
	self:refreshCommonNodeRedDot()
end

function GrowGiftComponent:refreshPage()
	local actData = self:getActData()
	local isCollectStage = actData and actData.receivedPetFlag == 1
	local eventTimeCfg = Utils.getEventTimeConfig(self.eventId)
	local actCfg = EventGrowthGiftData[self.eventPhase]
	local collectTitle = isCollectStage and actCfg and actCfg.eventTitle and pg.getLocalizationText(actCfg.eventTitle) or nil
	local collectDesc = isCollectStage and actCfg and actCfg.eventDesc and pg.getLocalizationText(actCfg.eventDesc) or nil

	self:setEventTitle(self.eventTitleUContainer, eventTimeCfg and eventTimeCfg.tabEndDayTime, collectTitle, nil, nil, collectDesc)
	self.rootUComponent:TryChangePage("Stage", isCollectStage and 1 or 0)

	if isCollectStage then
		local collectScore = actData.collectSocre or 0

		ClientTextUtils.setText(self.curProgress, collectScore)
		ClientTextUtils.setText(self.collectCount, collectScore)
		ClientTextUtils.setText(self.txtCollected, pg.getGameString("PRISMANA_GIFTS_COLLECTED"))
		ClientTextUtils.setText(self.txtViewCollection, pg.getGameString("PRISMANA_GIFTS_VIEW_COLLECTION"))
		self.listRewardUList:SetList(self:buildCollectRewardList())
	else
		self.btnGetUComponent:TryChangePage("Btn", self:getBtnGetState())
		self.cardUComponent:TryChangePage("Status", self:getCardStatus())
		self:refreshSelectedPet()
	end

	self:refreshRedDotState()
end

function GrowGiftComponent:refreshSelectedPet()
	local rewardPetId = self:getSelectedRewardPetId()

	if rewardPetId == 0 then
		if self.imgPetIcon then
			self.imgPetIcon.url = ""
		end

		ClientTextUtils.setText(self.txtPetName, "")

		if self.imgFormIcon then
			self.imgFormIcon.url = ""
		end

		ClientTextUtils.setText(self.txtForm, "")

		return
	end

	local petCfg = PetPrototypeData[rewardPetId]

	if self.imgPetIcon then
		local petIcon = petCfg and petCfg.iconName and LuaUIUtils.getPetIcon(petCfg.iconName, LuaUIUtils.PET_ICON) or ""

		self.imgPetIcon.url = petIcon
	end

	ClientTextUtils.setText(self.txtPetName, petCfg and pg.getLocalizationText(petCfg.name) or "")

	if self.imgFormIcon then
		self.imgFormIcon.url = PetResearchUtils.getPetFormIconSmall(rewardPetId)
	end

	ClientTextUtils.setText(self.txtForm, LuaUIUtils.getPetFormName(rewardPetId))
end

function GrowGiftComponent:onExitPage()
	EventContainerComponent.onExitPage(self)
end

return GrowGiftComponent
