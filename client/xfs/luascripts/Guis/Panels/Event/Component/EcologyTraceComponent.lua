-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Event\\Component\\EcologyTraceComponent.lua

local Class = require("Core.Framework.Class")
local RedDotConst = require("Const.RedDotConst")
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local ClientUtils = require("Utils.ClientUtils")
local AddressDataConst = require("Const.AddressDataConst")
local EventContainerComponent = require("Guis.Panels.Event.Component.EventContainerComponent")
local EcologyTraceComponent = Class.LightClass("EcologyTraceComponent", EventContainerComponent)
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local ItemUtils = require("Common.Utils.ItemUtils")
local SysConfigData = require("Data.sys_config_data")

function EcologyTraceComponent:findObjects()
	if not self:checkContentLoaded() then
		return
	end

	self.objectReference = self.transform:GetChild(0):GetComponent("ObjectReference")
	self.rootUComponent = self.objectReference:GetRefValue("rootUComponent")
	self.displayUComponent = self.objectReference:GetRefValue("displayUComponent")
	self.rewardPreviewUComponent = self.objectReference:GetRefValue("rewardPreviewUComponent")
	self.btnResearchUButton = self.objectReference:GetRefValue("btnResearchUButton")
	self.btnEcologicalUButton = self.objectReference:GetRefValue("btnEcologicalUButton")
	self.countDownSearch = self.objectReference:GetRefValue("countDownSearch")
	self.btnSearchUButton = self.objectReference:GetRefValue("btnSearchUButton")
	self.btnTrackUButton = self.objectReference:GetRefValue("btnTrackUButton")
	self.btnTrackingUButton = self.objectReference:GetRefValue("btnTrackingUButton")
	self.btnWaitingUButton = self.objectReference:GetRefValue("btnWaitingUButton")
	self.card1ObjectReference = self.objectReference:GetRefValue("card1ObjectReference")
	self.card2ObjectReference = self.objectReference:GetRefValue("card2ObjectReference")
	self.imgPetUImage = self.objectReference:GetRefValue("imgPetUImage")
	self.textPetName = self.objectReference:GetRefValue("textPetName")
	self.textPetForm = self.objectReference:GetRefValue("textPetForm")
	self.rootAnim = self.objectReference:GetRefValue("rootAnim")
	self.btnPetDetail = self.objectReference:GetRefValue("btnPetDetail")
	self.btnInfoCostSearch = self.objectReference:GetRefValue("btnInfoCostSearch")
	self.txtCostSearch = self.objectReference:GetRefValue("txtCostSearch")
	self.txtFreeSearch = self.objectReference:GetRefValue("txtFreeSearch")
	self.imgCostSearchIcon = self.objectReference:GetRefValue("imgCostSearchIcon")
	self.txtCostSearchCostNum = self.objectReference:GetRefValue("txtCostSearchCostNum")
	self.txtCurStageTime = self.objectReference:GetRefValue("txtCurStageTime")
	self.eventTitleUContainer = self.objectReference:GetRefValue("eventTitleUContainer")
	self.txtResearchCenter = self.objectReference:GetRefValue("txtResearchCenter")
	self.txtEcological = self.objectReference:GetRefValue("txtEcological")
	self.txtEcologicalTaskNum = self.objectReference:GetRefValue("txtEcologicalTaskNum")
	self.countDownSearch2 = self.objectReference:GetRefValue("countDownSearch2")
	self.txtCountDownInfo = self.objectReference:GetRefValue("txtCountDownInfo")
	self.txtCountDownInfo2 = self.objectReference:GetRefValue("txtCountDownInfo2")
	self.listRewardUList2 = self.objectReference:GetRefValue("listRewardUList2")
end

function EcologyTraceComponent:addListener()
	self.btnInfoCostSearch.enabledTooltip = false

	function self.btnInfoCostSearch.luaClick()
		pg.global.ui.tips:showTextTip(pg.getGameString("ECOLOGICAL_SEARCH_FREE_TIP"))
	end

	function self.btnEcologicalUButton.luaClick()
		pg.global.ui:open(UIConst.UI_Pb_Event_EcologicalSurvey, self.eventId)
	end

	function self.btnResearchUButton.luaClick()
		pg.global.ui:enableVisibleWhitelistForDuration({
			UIConst.UI_ID_EVENT
		})
		pg.global.ui:open(UIConst.UI_Pb_Event_ResearchCenter, self.eventId)
	end

	function self.btnSearchUButton.luaClick()
		self:trySearchEcologyPet()
	end

	function self.btnTrackUButton.luaClick()
		self:trackEcologyPet()
	end

	function self.btnTrackingUButton.luaClick()
		self:trackEcologyPet()
	end

	function self.btnWaitingUButton.luaClick()
		pg.global.ui.tips:showTextTip(pg.getFormatText(pg.getGameString("ECOLOGICAL_SEARCH_TIME"), self.countDownSearch.title.text))
	end

	function self.listRewardUList2.luaRenderItem(button, index, data)
		LuaUIUtils.renderRewardItem(button, data)
	end

	function self.btnPetDetail.luaClick()
		local chosedPetId = ClientActivityUtils.getEcoTracePetId()

		pg.global.ui:open(UIConst.UI_ID_PET_DETAIL, {
			templateId = chosedPetId
		}, function()
			self:InitEnterAnim()
		end)
	end

	ClientTextUtils.setText(self.txtEcological, pg.getGameString("ECOLOGICAL_TASK_TITLE"))
end

function EcologyTraceComponent:refreshPetInfo(curStage)
	local chosePet = self.model:getEcoTracePet()
	local chosedPetId = ClientActivityUtils.getEcoTracePetId()

	if not chosePet or not chosedPetId then
		return
	end

	self.imgPetUImage.url = string.format(AddressDataConst.PET_EVENT_PETSAVE, chosedPetId)

	ClientTextUtils.setText(self.textPetName, pg.getLocalizationText(chosePet.name))
	ClientTextUtils.setText(self.textPetForm, pg.getGameString("ECOLOGICAL_PET_FORM"))
	ClientTextUtils.setText(self.txtCurStageTime, pg.getFormatText(pg.getGameString("ECOLOGICAL_RESARCH_TIME_DESC"), pg.getGameString("ECOLOGICAL_RESARCH_TITLE_" .. curStage)))

	local taskUI = pg.global.ui.eventEcoTraceTask
	local taskModel = taskUI and taskUI.model
	local researchCompleteNum = 0
	local taskCompleteNum, taskMaxCount = 0, 0

	if taskModel then
		researchCompleteNum = taskModel:getResearchCompleteInfo()
		taskCompleteNum, taskMaxCount = taskModel:getTaskCompleteInfo()
	end

	ClientTextUtils.setText(self.txtResearchCenter, pg.getFormatText(pg.getGameString("ECOLOGICAL_RESARCH_NAME"), researchCompleteNum))
	ClientTextUtils.setText(self.txtEcologicalTaskNum, string.format("%d/%d", taskCompleteNum, taskMaxCount))
end

function EcologyTraceComponent:refreshRewardList(showAwardId)
	local rewards = LuaUIUtils.getRewardItemByDropId(showAwardId)

	if rewards and next(rewards) then
		self.listRewardUList2:SetList(rewards)
	end
end

function EcologyTraceComponent:playDefaultEnterAnimation()
	pg.game.audio:triggerEvent("SFX_UI_ImoDiscover_MoveIn")
end

function EcologyTraceComponent:hasTrackTarget(trackInfo, markStaticId)
	return trackInfo and trackInfo.hasTrack and trackInfo.markStaticId == markStaticId or false
end

function EcologyTraceComponent:getSearchButtonType(isSearchEnd, searched, costTime)
	if isSearchEnd and searched and costTime == 0 then
		return 3
	end

	if not isSearchEnd then
		local curCfg = self.model:getCurEcoTraceSearchCfg()
		local markStaticId = curCfg and curCfg.loacte or 0
		local trackInfo = self.model:getTrackInfo(self.eventId, self.eventType)

		return self:hasTrackTarget(trackInfo, markStaticId) and 2 or 1
	end

	return 0
end

function EcologyTraceComponent:refreshSearchCostInfo(ecoCfg, searched)
	local consumeInfo = ecoCfg.consumeItem and ecoCfg.consumeItem[1]

	if not consumeInfo then
		self.costEnough = false

		return
	end

	local costId = consumeInfo[1]
	local costNum = consumeInfo[2]
	local hasCount = ItemUtils.getItemCountById(pg.me, costId)

	self.costEnough = costNum <= hasCount

	local content = "x0"

	if searched then
		if self.costEnough then
			content = string.format("x%d", costNum)
		else
			content = string.format("<style=Item_Lack>x%d</style>", costNum)
		end
	end

	self.imgCostSearchIcon.url = LuaUIUtils.getIconByItemId(costId)

	ClientTextUtils.setText(self.txtCostSearchCostNum, content)
end

function EcologyTraceComponent:refreshSearchInfo(ecoCfg, curStage)
	local activityData = ClientActivityUtils.getEcoTraceActivityData()
	local searched = self.model:getCurEcoTraceSearched()
	local freeTime = activityData and activityData.ecoTraceSearchCnt or 0
	local costTime = activityData and activityData.ecoTraceSearchCostCnt or 0
	local totalTime = freeTime + costTime
	local isSearchEnd = not activityData or activityData.ecoTraceSearchMarkId == 0
	local timeText = pg.getFormatText(pg.getGameString("ECOLOGICAL_SEARCH_LEFT_COUNT"), totalTime, SysConfigData.ECOLOGICAL_PERIOD_CONSUME_COUNT + SysConfigData.ECOLOGICAL_PERIOD_FREE_COUNT)

	ClientTextUtils.setText(self.txtFreeSearch, timeText)
	ClientTextUtils.setText(self.txtCostSearch, timeText)

	self.btnType = self:getSearchButtonType(isSearchEnd, searched, costTime)

	if self.btnType == 0 then
		self:refreshSearchCostInfo(ecoCfg, searched)
	else
		self.costEnough = true
	end

	self.rewardPreviewUComponent:TryChangePage("status", searched and 1 or 0)
	self.rewardPreviewUComponent:TryChangePage("Button", self.btnType)

	local nextSearchTime = ClientActivityUtils.getNextEcoTraceSearchTime()

	self.rootUComponent:TryChangePage("lastCycle", nextSearchTime == 0 and 1 or 0)
	LuaUIUtils.setCountDownTime(self.countDownSearch, nextSearchTime, UIConst.TimeType.Short)
	LuaUIUtils.setCountDownTime(self.countDownSearch2, nextSearchTime, UIConst.TimeType.Short)
	ClientTextUtils.setText(self.txtCountDownInfo, pg.getGameString("ECOLOGICAL_SEARCH_RESET"))
	ClientTextUtils.setText(self.txtCountDownInfo2, pg.getGameString("ECOLOGICAL_SEARCH_RESET"))
end

function EcologyTraceComponent:refreshRedDotState()
	local taskUI = pg.global.ui.eventEcoTraceTask
	local taskModel = taskUI and taskUI.model
	local hasTaskReward = taskModel and taskModel:hasRewardCanGet() or false

	pg.global.setRedDot(RedDotConst.RedDotPath.EVENT_ECO_TRACE_QUEST, self.btnEcologicalUButton, hasTaskReward, RedDotConst.RedDotStyle.REWARD)
	pg.global.setRedDot(RedDotConst.RedDotPath.EVENT_ECO_TRACE_SEARCH, self.btnSearchUButton, ClientActivityUtils.checkEcologySearchPoint(), RedDotConst.RedDotStyle.POINT)
	self:refreshCommonNodeRedDot()
end

function EcologyTraceComponent:refreshPage()
	local ecoCfg = ClientActivityUtils.getEcoTraceActivityCfg()

	if not ecoCfg or not next(ecoCfg) then
		return
	end

	local _, curStage = ClientActivityUtils.getEcoStageInfo()

	self:refreshPetInfo(curStage)
	self:refreshRewardList(ecoCfg.showAwardId)
	self:playDefaultEnterAnimation()
	self:refreshSearchInfo(ecoCfg, curStage)

	local eventTimeCfg = Utils.getEventTimeConfig(self.eventId)

	self:setEventTitle(self.eventTitleUContainer, eventTimeCfg.tabEndDayTime)
	self:refreshRedDotState()
end

function EcologyTraceComponent:playEvent(eventName)
	if not self.eventName or self.eventName ~= eventName then
		self.eventName = eventName

		self.rootUComponent:InvokeCallback(eventName)
	end
end

function EcologyTraceComponent:trySearchEcologyPet()
	if ClientActivityUtils.checkEcoTraceSearchNearEnd(self.eventId) then
		ClientUtils.showConfirmRaw(pg.getGameString("ECOLOGICAL_END_SOON_TIP_TITLE"), pg.getGameString("ECOLOGICAL_END_SOON_TIP"), function()
			self:searchEcologyPet()
		end)

		return
	end

	self:searchEcologyPet()
end

function EcologyTraceComponent:searchEcologyPet()
	if not pg.me.space or not Utils.isSpaceSingleWorld(pg.me.space.spaceType) then
		pg.global.ui.tips:showTextTip(pg.getGameString("ECOLOGICAL_SEARCH_ARK_TIP"))

		return
	end

	if self.model:getCurEcoTraceSearched() then
		local activityData = ClientActivityUtils.getEcoTraceActivityData()

		if activityData and activityData.ecoTraceSearchCostCnt == 0 then
			pg.global.ui.tips:showTextTip(pg.getGameString("ECOLOGICAL_SEARCH_TIME_NOT_ENOUGH"))

			return
		end

		if not self.costEnough then
			pg.global.ui.tips:showTextTip(pg.getGameString("ECOLOGICAL_SEARCH_ITEM_NOT_ENOUGH"))

			return
		end
	end

	pg.me:reqSearchEcoTracePet(self.eventId, function(code, res)
		if code ~= true then
			pg.global.ui.tips:showTextTip(pg.getGameString("ECOLOGICAL_SEARCH_ARK_TIP"))

			return
		end

		self:trackEcologyPet()
	end)
end

function EcologyTraceComponent:trackEcologyPet()
	local curCfg = self.model:getCurEcoTraceSearchCfg()

	if not curCfg then
		return
	end

	local markStaticId = curCfg.loacte
	local trackInfo = self.model:getTrackInfo(self.eventId, self.eventType)

	if self:hasTrackTarget(trackInfo, markStaticId) then
		pg.game.map:manualUnTraceQuestMark(markStaticId)

		return
	end

	self.ctrl:startEventTrack(self.eventId, markStaticId, function()
		pg.game.map:openMapAndLocateMark(3000, Const.MAP_MARK_EcoTrace_Search, markStaticId, true, nil, function()
			self.displayUComponent:TryChangePage("Button", 2)
			pg.global.ui.tips:showTextTip(pg.getGameString("ECOLOGICAL_SEARCH_START_TIP"))
		end, false)
	end)
end

function EcologyTraceComponent:onExitPage()
	EventContainerComponent.onExitPage(self)
end

function EcologyTraceComponent:InitEnterAnim()
	self.firstEnterEvent = true
end

return EcologyTraceComponent
