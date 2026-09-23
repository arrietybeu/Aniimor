-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\TipsCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local UICtrl = require("Guis.UICtrl")
local Class = require("Core.Framework.Class")
local TipsCtrl = Class.LightClass("TipsCtrl", UICtrl)
local Utils = require("Common.Utils.Utils")
local TimeUtils = require("Common.Utils.TimeUtils")
local Time = require("Core.Common.Time")
local Logger = require("Core.Log.LoggerManager").getLogger("TipsCtrl")
local ConfirmUIComponent = require("Guis.Panels.Tips.Component.ConfirmUIComponent")
local EventPopContainerComponent = require("Guis.Panels.Tips.Component.EventPopContainerComponent")
local ActivityPopDispatcher = require("Guis.Panels.Tips.ActivityPopDispatcher")
local InputFieldUIComponent = require("Guis.Panels.Tips.Component.InputFieldUIComponent")
local ItemBatchComponent = require("Guis.Panels.Tips.Component.ItemBatchComponent")
local RestraintUIComponent = require("Guis.Panels.Tips.Component.RestraintUIComponent")
local NpcDuelBuffComponent = require("Guis.Panels.Tips.Component.NpcDuelBuffComponent")
local QuestHudNewComponent = require("Guis.Panels.Tips.Component.QuestHudNewComponent")
local CommonTargetComponent = require("Guis.Panels.Tips.Component.CommonTargetComponent")
local LimitChallengeComponent = require("Guis.Panels.Tips.Component.LimitChallengeComponent")
local TeamMatchTipComponent = require("Guis.Panels.Tips.Component.TeamMatchTipComponent")
local PopupTipComponent = require("Guis.Panels.Tips.Component.PopupTipComponent")
local MarqueeUIComponent = require("Guis.Panels.Tips.Component.MarqueeUIComponent")
local AreaManagementComponent = require("Guis.Panels.Tips.Component.AreaManagementComponent")
local ScreenCaptureShareComponent = require("Guis.Panels.Tips.Component.ScreenCaptureShareComponent")
local TipVisibilityHelper = require("Guis.Panels.Tips.Component.TipVisibilityHelper")
local HideReason = TipVisibilityHelper.HideReason
local PetFirstShowData = require("Data.pet_first_show_data")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local TipAreaConst = require("Guis.Panels.Tips.TipAreaConst")
local ClientConst = require("Const.ClientConst")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("TipsCtrl")
local ClientSwitch = require("Common.ClientSwitch")
local Const = require("Const.Const")
local MessageName = require("Const.MessageName")
local GmToolUtils = require("Utils.GmToolUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local SysNoticeData = require("Data.sys_notice_data")
local UIConst = require("Const.UIConst")
local ClientUtils = require("Utils.ClientUtils")
local NoticeDef = require("Common.NoticeDef")
local PetTraitData = require("Data.pet_trait_data")
local ActivityConst = require("Common.Const.ActivityConst")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local ShopCommodityData = require("Data.shop_commodity_data")
local ItemData = require("Data.item_data")
local HomelandConfigData = require("Data.homeland_config_data")
local ItemDebugData = require("Data.item_debug_data")
local ClientRepo = require("Core.Client.ClientRepo")
local SysConfigData = require("Data.sys_config_data")
local TimerManager = require("Core.Timer.TimerManager")
local EventArkCarnData = require("Data.event_ark_carn_data")
local LevelData = require("Data.level_data")
local MatchConfigData = require("Data.match_data")
local PlayerTitleData = require("Data.player_title_data")
local JoyStickDragRelay = require("Guis.Helper.JoyStickDragRelay")
local ipairs = ipairs
local pairs = pairs

TipsCtrl.TICK_INTERVAL = 0.04

local MULTI_PET_OBTAINS_DELAY_TIME = 1
local SCENE_LOADED_BUBBLE_MESSAGE_DELAY = 0.5
local CUTSCENE_SUSPEND_HIDE_KEYS = {
	[UIConst.UI_HIDE_KEY.PET_EVOLVE] = true
}

TipsCtrl.messages = {
	[MessageName.ON_NOTIFY_ITEM] = {
		"onNotifyItem",
		true
	},
	[MessageName.ON_NOTIFY_ITEM_BATCH] = {
		"onNotifyItemBatch",
		true
	},
	[MessageName.PET_RESEARCH_CHANGE] = {
		"onPetResearchChange",
		true
	},
	[MessageName.PET_ACHIEVE_CHANGE] = {
		"onPetAchieveChange",
		true
	},
	[MessageName.PET_STAGE_UPDATE] = {
		"onPetEvolve",
		true
	},
	[MessageName.PET_FIRST_SHOW] = {
		"onPetFirstShow",
		false
	},
	[MessageName.SCENE_LOADED] = {
		"onSceneLoaded",
		true
	},
	[MessageName.SCENE_UNLOAD] = {
		"onSceneUnload",
		true
	},
	[MessageName.PLAYER_DESTROY] = {
		"onPlayerDestroyed",
		true
	},
	[MessageName.ON_HIDE_ALL_UI] = {
		"onHideAllUIChanged",
		true
	},
	[MessageName.ON_RESTORE_ALL_UI] = {
		"onRestoreAllUIChanged",
		true
	},
	[MessageName.QUEST_ON_STATE_CHANGE] = {
		"onQuestStateChange",
		true
	},
	[MessageName.QUEST_ON_TRACE_CHANGE] = {
		"onQuestTraceChange",
		true
	},
	[MessageName.QUEST_ON_OBJECTIVE_CHANGED] = {
		"onQuestObjectiveChanged",
		true
	},
	[MessageName.QUEST_ON_COM_ACTION_OBJECTIVE_CHANGED] = {
		"onQuestComActionObjectiveChanged",
		true
	},
	[MessageName.QUEST_ON_RUN_STATE_CHANGE] = {
		"onQuestRunStateChanged",
		true
	},
	[MessageName.TEAM_PUSH_GO_READY_ROOM] = {
		"onGoReadyRoomPush",
		true
	},
	[MessageName.TEAM_ENTER_MEMBER_AGREE_CHANGE] = {
		"onTeamEnterAgreeChanged",
		true
	},
	[MessageName.TARGET_ON_CHANGE] = {
		"onTargetObjectChange",
		true
	},
	[MessageName.TARGET_PET_BUFF_ON_CHANGE] = {
		"refreshTargetBuffItem",
		true
	},
	[MessageName.ITEM_COUNT_MAP_CHANGE] = {
		"refreshTargetProgressItem",
		true
	},
	[MessageName.REFRESH_OPERATION_HINT] = {
		"refreshOperationHint",
		true
	},
	[MessageName.MODULE_ENABLE_CHANGED] = {
		"onModuleEnableChanged",
		true
	},
	[MessageName.DIALOGUE_GRAPH_ON_END] = {
		"onDialogueGraphEnd",
		true
	},
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	},
	[MessageName.UI_AI_HELPER_POP] = {
		"insertAiHelperTip",
		true
	},
	[MessageName.MAIN_PLAYER_PET_ADD] = {
		"onAddPet",
		true
	},
	[MessageName.MAIN_PLAYER_PET_EVOLVE] = {
		"onPetEvolved",
		true
	},
	[MessageName.UPDATE_PROGRESS_DISENGAGE] = {
		"onUpdateProgressDisengage",
		true
	},
	[MessageName.EXIT_PROGRESS_DISENGAGE] = {
		"onExitProgressDisengage",
		true
	},
	[MessageName.PLAYER_EXP_CHANGE] = {
		"event_onPlayerExpChange",
		true
	},
	[MessageName.PLAYER_LEVEL_CHANGE] = {
		"event_onPlayerLvChange",
		true
	},
	[MessageName.PLAYER_STAR_CHANGE] = {
		"event_onPlayerStarChange",
		true
	},
	[MessageName.MONEY_COUNT_CHANGE] = {
		"event_onMoneyNumChange",
		true
	},
	[MessageName.LOCKED_TARGET_CHANGE] = {
		"refreshBossTitle",
		false
	},
	[MessageName.PLAYER_BE_HATRED_LIST_CHANGE] = {
		"refreshBossTitle",
		false
	},
	[MessageName.PLAYER_ONTELEPORT] = {
		"refreshBossTitle",
		false
	},
	[MessageName.ENT_COMBAT_STATUS_CHANGED] = {
		"refreshBossTitleWhenSwitchCombat",
		false
	},
	[MessageName.BUFF_CHANGE] = {
		"refreshBuffs",
		true
	},
	[MessageName.ON_BUFF_ADD] = {
		"onBuffAdd",
		true
	},
	[MessageName.ON_BUFF_REMOVE] = {
		"onBuffRemove",
		true
	},
	[MessageName.ON_BUFF_EXPIRED_TIME_CHANGE] = {
		"onBuffExpiredTimeChange",
		true
	},
	[MessageName.BUFF_LAYER_CHANGE] = {
		"onBuffLayerChange",
		true
	},
	[MessageName.SHIELD_CHANGE] = {
		"refreshShield",
		true
	},
	[MessageName.SHIELD_BREAK] = {
		"onShieldBreak",
		true
	},
	[MessageName.BREAK_POINT_CHANGE] = {
		"refreshBreakBar",
		true
	},
	[MessageName.HEALTH_POINT_CHANGE] = {
		"refreshHealthPoint",
		true
	},
	[MessageName.ENT_ELEMENT_CHANGE] = {
		"onEntElementChange",
		true
	},
	[MessageName.ON_FREEZE_HP_CHANGED] = {
		"refreshFreezeHp",
		true
	},
	[MessageName.ON_FREEZE_HP_HIT] = {
		"onFreezeHpHit",
		true
	},
	[MessageName.ON_FREEZE_HP_OUT_TIME] = {
		"onFreezeHpOutTime",
		true
	},
	[MessageName.DUNGEON_GOAL_REFRESH] = {
		"onDungeonGoalRefresh",
		true
	},
	[MessageName.SHOP_ON_BUY_ITEMS] = {
		"onBuyItems",
		true
	},
	[MessageName.ON_HIT_WHEN_FULL_SCREEN_UI_SHOW] = {
		"onHitWhenFullScreenShow",
		true
	},
	[MessageName.BOSS_MECHANISM_ICON_INIT_CLIENT] = {
		"onBossMechanismIconInitClient",
		true
	},
	[MessageName.BOSS_MECHANISM_ICON_DESTROY] = {
		"onBossMechanismIconDestroy",
		true
	},
	[MessageName.BOSS_MECHANISM_ICON_SHOW_VX] = {
		"onBossMechanismIconShowVX",
		true
	},
	[MessageName.BOSS_MECHANISM_ICON_HIDE_VX] = {
		"onBossMechanismIconHideVX",
		true
	},
	[MessageName.BOSS_MECHANISM_ICON_SYNC_MAX] = {
		"onBossMechanismIconSyncMax",
		true
	},
	[MessageName.BOSS_MECHANISM_ICON_SYNC_PROGRESS] = {
		"onBossMechanismIconSyncProgress",
		true
	},
	[MessageName.BOSS_MECHANISM_ICON_FLASH] = {
		"onBossMechanismIconFlash",
		true
	},
	[MessageName.RACESAMPLE_STAGE_CHANGE] = {
		"onRaceSampleStageChange",
		true
	},
	[MessageName.DITTO_STATE_CHANGE] = {
		"onDittoStateChange",
		true
	},
	[MessageName.UI_ON_VISIBLE_CHANGE] = {
		"onUIVisibleChanged",
		false
	},
	[MessageName.ECS_MAX_AMOUNT_CHANGE] = {
		"onEcsMaxAmountChange",
		true
	},
	[MessageName.BOSS_RUSH_LEVEL_GRADE_CHANGED] = {
		"refreshBossStage",
		true
	},
	[MessageName.SPECIAL_TRAIN_CHAPTER_UNLOCK] = {
		"onSpecialTrainChapterUnlock",
		true
	},
	[MessageName.ON_BADGE_TASK_CHANGED] = {
		"onBadgeTaskChange",
		true
	},
	[MessageName.RECV_MAIL] = {
		"onRecvMail",
		true
	},
	[MessageName.START_CATCH_BOSS] = {
		"onStartCatchBoss",
		true
	},
	[MessageName.SKILL_FREE_AIM] = {
		"onSkillFreeAimChanged",
		true
	}
}

function TipsCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.isModelInfo = {}
	self.pendingCheckList = {}
	self.pendingSceneLoadedBubbleMessageIds = {}
	self.edgePriorities = {}
	self.midLowerPriorities = {}
	self.teamInviteNoticeId = 0
	self.areaManager = AreaManagementComponent.new(self)
	self.screenCaptureShareComponent = ScreenCaptureShareComponent.new(self)
	self.itemBatch = ItemBatchComponent.new(self)
	self.confirm = ConfirmUIComponent.new(self, self.view.confirmRoot)
	self.inputField = InputFieldUIComponent.new(self, self.view.inputField)
	self.event = EventPopContainerComponent.new(self, self.view.eventRoot)
	self.dispatcher = ActivityPopDispatcher.new()
	self.popupTip = PopupTipComponent.new(self)
	self.challenge = LimitChallengeComponent.new(self, self.view.challengeHud, {
		priority = UIConst.UITipPriority.Edge_Challenge
	})
	self.challenge.edgeAreaType = TipAreaConst.EDGE_AREAS.Challenge
	self.quest = QuestHudNewComponent.new(self, self.view.quest, {
		priority = UIConst.UITipPriority.Edge_Quest
	})
	self.quest.edgeAreaType = TipAreaConst.EDGE_AREAS.Quest
	self.target = CommonTargetComponent.new(self, self.view.target, {
		priority = UIConst.UITipPriority.Edge_Challenge
	})
	self.target.edgeAreaType = TipAreaConst.EDGE_AREAS.Target

	table.insert(self.edgePriorities, self.challenge)
	table.insert(self.edgePriorities, self.target)
	table.insert(self.edgePriorities, self.quest)
	table.sort(self.edgePriorities, function(a, b)
		return a.priority > b.priority
	end)

	self.restraint = RestraintUIComponent.new(self, self.view.restraintRoot)
	self.marquee = MarqueeUIComponent.new(self, self.view.marqueeRectTransform)
	self.npcDuelBuff = NpcDuelBuffComponent.new(self, self.view.spaceBuffToastUContainer)

	self:refreshIsModel()
	self:pushAreaManagerData({
		itemKey = "ShortCutKey",
		areaType = TipAreaConst.AREAS.CF
	})
	self:_applyShortCutKeyRedirect()

	local function func()
		if self._onOpenCallced then
			self:update()
		end
	end

	self:startTimer(func, TipsCtrl.TICK_INTERVAL, true)

	local state = pg.game.setting:getGuideLabelState()

	self:switchGuideLabel(1 - state)

	if NotNil(self.view.questAreaUWidget) then
		self.joyStickDragListener = JoyStickDragRelay.attach(self.view.questAreaUWidget.gameObject)
	end
end

function TipsCtrl:showRainbowPetAppear(templateId, duration)
	self:pushAreaManagerData({
		itemKey = "NormalText",
		tIndex = 2,
		areaType = TipAreaConst.AREAS.A3,
		templateId = templateId,
		duration = duration or 2
	})
end

function TipsCtrl:onDestroy()
	JoyStickDragRelay.detach(self.joyStickDragListener)

	self.joyStickDragListener = nil
	self.pendingCheckList = nil

	if self.dispatcher then
		self.dispatcher:clear()

		self.dispatcher = nil
	end

	if self.pendingSceneLoadedBubbleMessageTimerId then
		TimerManager.removeTimer(self.pendingSceneLoadedBubbleMessageTimerId)

		self.pendingSceneLoadedBubbleMessageTimerId = nil
	end

	self.pendingSceneLoadedBubbleMessageIds = nil

	UICtrl.onDestroy(self)

	self._onOpenCallced = nil
	self.confirm = nil
	self.inputField = nil
	self.restraint = nil
	self.quest = nil
	self.challenge = nil
	self.target = nil
	self.itemBatch = nil
	self.event = nil
	self.teamMatchTip = nil
	self.fullScreenShow = nil

	table.clear(self.edgePriorities)
	table.clear(self.midLowerPriorities)
end

function TipsCtrl:onOpen(info)
	self._onOpenCallced = true
end

function TipsCtrl:onShow()
	UICtrl.onShow(self)
	self:resetQuestState()
end

function TipsCtrl:onHide()
	UICtrl.onHide(self)
end

function TipsCtrl:onUIVisibleChanged()
	self:refreshScreenTransitionHide()

	if self.areaManager == nil then
		return
	end

	local hideAreas, forceHideTip, needFullScreenHide = pg.global.ui:getHideTipAreas()

	self.areaManager:onUIVisibleChanged(hideAreas, forceHideTip, needFullScreenHide)
	self:applyEdgePanelHide(hideAreas, forceHideTip, needFullScreenHide)
	self:checkUpdateState()
end

function TipsCtrl:refreshScreenTransitionHide()
	if Utils.tableIsEmptyOrNil(self.edgePriorities) then
		return false
	end

	local inScreenTransition = TipVisibilityHelper.checkInScreenTransition()

	for _, com in ipairs(self.edgePriorities) do
		com:setHideFlag(HideReason.screenTransition, inScreenTransition)
	end

	return inScreenTransition
end

function TipsCtrl:applyEdgePanelHide(hideAreas, forceHideTip, needFullScreenHide)
	local hideQuestArea = hideAreas[TipAreaConst.EDGE_AREAS.QuestArea]

	for _, com in ipairs(self.edgePriorities) do
		if forceHideTip then
			com:setHideFlag(HideReason.panelHide, true)
		elseif needFullScreenHide then
			com:setHideFlag(HideReason.panelHide, true)
		elseif hideQuestArea then
			com:setHideFlag(HideReason.panelHide, true)
		elseif com.edgeAreaType and hideAreas[com.edgeAreaType] then
			com:setHideFlag(HideReason.panelHide, true)
		else
			com:setHideFlag(HideReason.panelHide, false)
		end
	end
end

function TipsCtrl:onRaceSampleStageChange(info)
	if self.challenge then
		self.challenge:onStageChange(info)
	end

	if self.target then
		self.target:onStageChange(info)
	end
end

function TipsCtrl:onGoReadyRoomPush(info)
	if not self.teamMatchTip then
		self.teamMatchTip = TeamMatchTipComponent.new(self)
	end

	self.teamMatchTip:showTeamMatchTip(info.dungeonSceneId)
end

function TipsCtrl:onTeamEnterAgreeChanged(matchReadyTeams)
	if not self.teamMatchTip then
		self.teamMatchTip = TeamMatchTipComponent.new(self)
	end

	if matchReadyTeams and next(matchReadyTeams) ~= nil then
		self.teamMatchTip:showTeamMatchTip()
	else
		self.teamMatchTip:closeTeamMatchTip()
	end
end

function TipsCtrl:update()
	if not self:checkUIVisible() then
		return
	end

	self:preUpdate()
	self:onUpdate()
end

function TipsCtrl:checkUpdateState()
	local customModalRun = self:checkCustomModalMutPanel()
	local fullPanelRun = pg.global.ui:getModalPanelShowState() or pg.global.ui:checkHasPendingDestroyFullPanel() or pg.global.ui:checkHasWaitingShowFullPanel()
	local oldFullScreenShow = self.fullScreenShow

	self.fullScreenShow = customModalRun or fullPanelRun

	if self.fullScreenShow ~= oldFullScreenShow then
		self:onFullScreenShowChange(self.fullScreenShow)

		return
	end
end

function TipsCtrl:onStartOpenLoadingUI(panelId)
	if self.fullScreenShow ~= true then
		self.fullScreenShow = true

		self:onFullScreenShowChange(self.fullScreenShow)
	end

	self.areaManager:onStartOpenLoadingUI(panelId)
end

function TipsCtrl:insertAiHelperTip(info)
	self:showAIHelperTips(info)
end

function TipsCtrl:onModuleEnableChanged(changeInfo)
	local moduleKey = changeInfo.moduleKey or ""
	local enable = changeInfo.enable

	if moduleKey == ClientConst.ModuleKey.Quest then
		self.quest:onModuleEnableChanged(changeInfo)
	end
end

function TipsCtrl:switchGuideLabel(pageId)
	if self.view then
		self.view.rootComponent:TryChangePage("guideLabel", pageId)
	end
end

function TipsCtrl:preUpdate()
	self:checkMidLowerInfo(self.fullScreenShow)
end

function TipsCtrl:fadeOut()
	if self.view then
		self.view.widget:InvokeCallback(CS.XGUI.EInvokeTime.Hide)
	end
end

function TipsCtrl:fadeIn()
	if self.view then
		self.view.widget:InvokeCallback(CS.XGUI.EInvokeTime.Show)
	end
end

function TipsCtrl:checkMidLowerInfo(mutWithInfoLayer)
	if mutWithInfoLayer then
		self:clearMidLower(UIConst.UITipPriority.Tip_Max)

		return false
	end

	if pg.global.ui:checkUIShow(UIConst.UI_ID_GUIDE_PANEL) then
		self:clearMidLower(UIConst.UITipPriority.Tip_Max)

		return false
	end

	local breakPriority = -1

	for _, v in ipairs(self.midLowerPriorities) do
		local priority = v.priority or 0

		if priority < breakPriority then
			break
		end

		if v and (v:preUpdate() or v:checkIsRunning()) then
			breakPriority = priority
		end
	end

	if breakPriority == -1 then
		return false
	end

	self:clearMidLower(breakPriority)

	return true
end

function TipsCtrl:checkUpdateEdgeInfo(mutWithInfoLayer)
	if mutWithInfoLayer or self:checkCustomEdgeMutTip() then
		self:clearEdgeTips(UIConst.UITipPriority.Tip_Max)

		return
	end
end

function TipsCtrl:onUpdate()
	self:updatePendingChecks()
	self:refreshScreenTransitionHide()

	for _, v in ipairs(self.edgePriorities) do
		v:onUpdate()
	end

	for _, v in ipairs(self.midLowerPriorities) do
		v:onUpdate()
	end
end

function TipsCtrl:updatePendingChecks()
	for i = #self.pendingCheckList, 1, -1 do
		local isFinished = self.pendingCheckList[i]()

		if isFinished then
			table.remove(self.pendingCheckList, i)
		end
	end
end

function TipsCtrl:addPendingCheck(checkFunc)
	self.pendingCheckList[#self.pendingCheckList + 1] = checkFunc
end

function TipsCtrl:removePendingCheck(checkFunc)
	for i = #self.pendingCheckList, 1, -1 do
		if self.pendingCheckList[i] == checkFunc then
			table.remove(self.pendingCheckList, i)

			return
		end
	end
end

function TipsCtrl:checkCustomModalMutPanel()
	if pg.game.evolution:isInEvolution() then
		self:onClearAllRunningTip()

		return true
	end

	if pg.global.ui:checkUIShow(UIConst.UI_ID_PET_LEVEL_UP) then
		self:clearEdgeTips(UIConst.UITipPriority.Tip_Max)

		return true
	end

	if pg.global.ui.firstPetShow:checkUIVisible() then
		self:clearEdgeTips(UIConst.UITipPriority.Tip_Max)

		return true
	end

	if pg.global.ui:checkUIShow(UIConst.UI_ID_FUNC_MENU_UNLOCK) then
		self:onClearAllRunningTip()

		return true
	end

	return false
end

function TipsCtrl:checkCustomMidMutTip()
	return false
end

function TipsCtrl:checkCustomEdgeMutTip()
	return false
end

function TipsCtrl:onFullScreenShowChange(isShow)
	for _, v in ipairs(self.edgePriorities) do
		v:onFullScreenShowChange(isShow)
	end
end

function TipsCtrl:onEdgeTipPriorityChange(priority, isShow, flag)
	if priority < 0 then
		return
	end

	for _, v in ipairs(self.edgePriorities) do
		if priority > v.priority then
			v:onPriorityBreak(isShow, flag)
		end
	end
end

function TipsCtrl:clearEdgeTips(priority, ignoreMap, clearQueue)
	if priority < 0 then
		return
	end

	for _, v in ipairs(self.edgePriorities) do
		if priority > v.priority and (ignoreMap == nil or not ignoreMap[v.priority]) then
			v:clearRunningList(true)
		end

		if clearQueue then
			v:clearQueueList()
		end
	end
end

function TipsCtrl:clearMidLower(priority, ignoreList)
	if priority < 0 then
		return
	end

	for _, v in ipairs(self.midLowerPriorities) do
		if priority > v.priority and (ignoreList == nil or not table.contains(ignoreList, v.priority)) then
			v:clearRunningList(true)
		end
	end
end

function TipsCtrl:onClearAllRunningTip()
	self:clearEdgeTips(UIConst.UITipPriority.Tip_Max)
	self:clearMidLower(UIConst.UITipPriority.Tip_Max)
end

function TipsCtrl:onClearAllTips()
	self:clearEdgeTips(UIConst.UITipPriority.Tip_Max, nil, true)
	self:clearMidLower(UIConst.UITipPriority.Tip_Max)
end

function TipsCtrl:hideAllAreasWithFlag(flag, ignoreAreas)
	if self.areaManager == nil then
		return
	end

	if flag == nil then
		flag = TipAreaConst.UITipAreaFlag.AreaFlag_Default
	end

	self.areaManager:hideAreaWithFlag(flag, ignoreAreas)
	self:setEdgeVisible(false)
end

function TipsCtrl:showAllAreasWithFlag(flag)
	if flag == nil then
		flag = TipAreaConst.UITipAreaFlag.AreaFlag_Default
	end

	if self.areaManager == nil then
		return
	end

	self.areaManager:showAreaWithFlag(flag)
	self:setEdgeVisible(true)
end

function TipsCtrl:hideOtherAreasExcept(exceptAreaType)
	if self.areaManager == nil then
		return
	end

	self:setEdgeVisible(false)
	self.areaManager:hideAreaWithFlag(TipAreaConst.UITipAreaFlag.AreaFlag_SeasonOpenTip, {
		exceptAreaType
	})

	if exceptAreaType ~= TipAreaConst.AREAS.CF then
		self.areaManager:setAreaItemVisibleWithFlag(TipAreaConst.AREAS.CF, "ShortCutKey", TipAreaConst.UITipAreaFlag.AreaFlag_SeasonOpenTip, false)
	end
end

function TipsCtrl:restoreAllAreas()
	if self.areaManager ~= nil then
		self.areaManager:showAreaWithFlag(TipAreaConst.UITipAreaFlag.AreaFlag_SeasonOpenTip)
		self.areaManager:setAreaItemVisibleWithFlag(TipAreaConst.AREAS.CF, "ShortCutKey", TipAreaConst.UITipAreaFlag.AreaFlag_SeasonOpenTip, true)
	end

	self:setEdgeVisible(true)
end

function TipsCtrl:setEdgeVisible(flag)
	if Utils.tableIsEmptyOrNil(self.edgePriorities) then
		return
	end

	for _, com in pairs(self.edgePriorities) do
		if com and com.setIsVisible then
			com:setIsVisible(flag)
		end
	end
end

function TipsCtrl:setTipsVisibleByLevel(reasonKey, visible)
	reasonKey = reasonKey or "Default"
	self.levelTipsVisibleInfo = self.levelTipsVisibleInfo or {}

	if visible then
		self.levelTipsVisibleInfo[reasonKey] = nil
	else
		self.levelTipsVisibleInfo[reasonKey] = false
	end

	if Utils.tableIsEmptyOrNil(self.levelTipsVisibleInfo) then
		self:showAllAreasWithFlag(TipAreaConst.UITipAreaFlag.AreaFlag_Level)
	else
		self:hideAllAreasWithFlag(TipAreaConst.UITipAreaFlag.AreaFlag_Level)
	end
end

function TipsCtrl:changePage(page)
	if IsNil(self.view) then
		return
	end

	self.view.rootComponent:TryChangePage("Synopsis", page)

	if pg.game.input:isUsingGamepad() and pg.me:isInCatchMode() then
		-- block empty
	end
end

function TipsCtrl:componentSetIsModel(key, isModel)
	if isModel then
		self.isModelInfo[key] = true
	else
		self.isModelInfo[key] = nil
	end

	self:refreshIsModel()
end

function TipsCtrl:checkUIShowVirtualMouseCursor()
	if self:checkUseGamepadModel() then
		return false
	else
		return TipsCtrl.super.checkUIShowVirtualMouseCursor(self)
	end
end

function TipsCtrl:checkComponentInModel()
	if not Utils.tableIsEmptyOrNil(self.isModelInfo) then
		return true
	end

	return false
end

function TipsCtrl:refreshIsModel()
	if self:checkComponentInModel() then
		self:setIsModel(true)
	else
		self:setIsModel(false)
	end

	pg.global.ui:refreshLockCursor()
end

function TipsCtrl:switchHelpShow()
	self.view:switchHelpShow()
end

function TipsCtrl:checkCanPushItem()
	if ClientSwitch.ClosePopupInfoTip then
		return false
	end

	return true
end

function TipsCtrl:pushAreaManagerData(data)
	if not self:checkCanPushItem() then
		return false
	end

	if self.areaManager == nil then
		return false
	end

	self:exitAfk(data)
	self.areaManager:pushData2Area(data)

	return true
end

function TipsCtrl:exitAfk(data)
	if data.itemKey == "TeamInvite" and pg.me.actionState ~= Const.PlayerActionState.AFK then
		pg.global.inputMgr:ForceSetInputTick()
	end
end

function TipsCtrl:showBossCatchWarning(remainTime, title, subTitle)
	if not remainTime or remainTime <= 0 then
		return
	end

	self:pushAreaManagerData({
		itemKey = "BossCatchWarning",
		areaType = TipAreaConst.AREAS.A1,
		duration = remainTime,
		title = title,
		subTitle = subTitle
	})
end

function TipsCtrl:hideBossCatchWarning()
	if self.areaManager == nil then
		return
	end

	self.areaManager:hideAreaItemById(TipAreaConst.AREAS.A1, "BossCatchWarning")
end

function TipsCtrl:showBossCatchTips(text)
	self:pushAreaManagerData({
		itemKey = "BossCatchTips",
		areaType = TipAreaConst.AREAS.A2,
		text = text
	})
end

function TipsCtrl:hideBossCatchTips()
	if self.areaManager == nil then
		return
	end

	self.areaManager:hideAreaItemById(TipAreaConst.AREAS.A2, "BossCatchTips")
end

function TipsCtrl:postAreaManagerData(params)
	if not self:checkCanPushItem() then
		return
	end

	if self.areaManager == nil then
		return
	end

	self.areaManager:postPushData2Area(params)
end

function TipsCtrl:showTargetEntityInfo(duration, uniqueId, extraData)
	extraData = extraData or {}
	extraData.areaType = TipAreaConst.AREAS.TOP
	extraData.itemKey = "TargetEntityInfo"
	extraData.duration = duration
	extraData.uniqueId = uniqueId

	self:pushAreaManagerData(extraData)
end

function TipsCtrl:clearTargetEntityInfo()
	if self.areaManager == nil then
		return
	end

	local item = self.areaManager:getAreaItem(TipAreaConst.AREAS.TOP, "TargetEntityInfo")

	if item then
		item:clearAllData(true)
	end
end

function TipsCtrl:clearAllTips()
	if self.areaManager == nil then
		return
	end

	self.areaManager:clearAllTips()
end

function TipsCtrl:onDialogueGraphStart()
	self.areaManager:hideAreaWithFlag(TipAreaConst.UITipAreaFlag.AreaFlag_DialogueGraph)
end

function TipsCtrl:onDialogueGraphEnd()
	self.areaManager:showAreaWithFlag(TipAreaConst.UITipAreaFlag.AreaFlag_DialogueGraph)
end

function TipsCtrl:showA3AirWallTip(tipId)
	local tipDesc

	if tipId == UIConst.AIR_WALL_TIP_ID.GRAB_EGG_PVP_AIR_WALL then
		if pg.space:checkIsPVPStage() then
			tipDesc = pg.getGameString("GRAB_EGG_TAKE_BOAT_TP_PVP_TIP")
		else
			tipDesc = pg.getGameString("GRAB_EGG_NEED_ACTIVE_PVP_STATE_TIP")
		end
	end

	self:showTextTip(tipDesc, 3)
end

function TipsCtrl:showTextTip(text, duration, iconStyle, outLineDesc, bigIcon, normalIcon, label, isItem, deleteOnSceneUnload, isItemObtain)
	local args = {
		itemKey = "NormalText",
		areaType = TipAreaConst.AREAS.A3,
		desc = text,
		duration = duration,
		outLineDesc = outLineDesc,
		bigIcon = bigIcon,
		normalIcon = normalIcon,
		label = label,
		iconStyle = iconStyle,
		deleteOnSceneUnload = deleteOnSceneUnload,
		isItemObtain = isItemObtain
	}

	self:pushAreaManagerData(args)

	if pg.me and text and not isItem then
		local noticeText = text

		if outLineDesc then
			noticeText = noticeText .. outLineDesc
		end

		pg.game.chat:recvSystemNotice(noticeText)
	end
end

function TipsCtrl:showIconTextTip(text, duration, state, extractionTimePage)
	local args = {
		itemKey = "NormalText",
		iconText = true,
		areaType = TipAreaConst.AREAS.A3,
		desc = text,
		duration = duration,
		state = state,
		extractionTimePage = extractionTimePage
	}

	self:pushAreaManagerData(args)
end

function TipsCtrl:showTextTipByArgs(args)
	args.areaType = TipAreaConst.AREAS.A3
	args.itemKey = "NormalText"

	self:pushAreaManagerData(args)
end

function TipsCtrl:showTextTipById(noticeId, ...)
	if self:handleSpecialNotice(noticeId, ...) then
		return
	end

	local cData = SysNoticeData[noticeId or 0]

	if cData == nil then
		local noticeStr = string.format("notice:%s", NoticeDef.getRepr(noticeId, {
			...
		}))

		if pg.game.setting:getShowDebugId() then
			self:showTextTip(noticeStr, 3, nil)
		end

		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			logger:debug("receive notice, but no config: %s", noticeStr)
		end

		return
	end

	local desc = pg.getLocalizationText(cData.text, ...)
	local data = {
		itemKey = "NormalText",
		areaType = TipAreaConst.AREAS.A3,
		noticeId = noticeId,
		cd = cData.cd,
		stayMin = cData.stayMin or cData.stay,
		desc = desc,
		duration = cData.stay,
		deleteOnSceneUnload = cData.delete
	}

	self:pushAreaManagerData(data)
end

function TipsCtrl:queueBubbleMessageAfterSceneLoaded(noticeId)
	self.pendingSceneLoadedBubbleMessageIds[#self.pendingSceneLoadedBubbleMessageIds + 1] = noticeId
end

function TipsCtrl:handleSpecialNotice(noticeId, ...)
	if noticeId == NoticeDef.TEAM_MSG_PLAYER_DUN_ERROR_NEED_TITLE then
		local playerName = select(1, ...)
		local titleName = select(2, ...)
		local cfg = SysNoticeData[NoticeDef.TEAM_MSG_PLAYER_DUN_ERROR_NEED_TITLE]
		local tip = pg.getLocalizationText(cfg and cfg.text or "")

		tip = string.gsub(tip, "<player>", playerName)
		tip = string.gsub(tip, "<title>", LuaUIUtils.getStarTitleName(titleName, true))

		self:showTextTip(tip)

		return true
	end

	return false
end

function TipsCtrl:hideTextTipById(noticeId)
	if self.areaManager == nil then
		return
	end

	self.areaManager:hideAreaItemById(TipAreaConst.AREAS.A3, "NormalText", noticeId)
end

function TipsCtrl:showConfirm(title, desc, okCb, hideCancel, cancelCb, showNextBtn, nextBtnCb, extraInfo)
	if self.confirm == nil then
		return
	end

	self.confirm:showConfirm(title, desc, okCb, hideCancel, cancelCb, showNextBtn, nextBtnCb, extraInfo)
end

function TipsCtrl:showRestraint(elementName, cb)
	if not self:checkCanPushItem() then
		return
	end

	if self.restraint then
		self.restraint:showRestraint(elementName, cb)
	end
end

function TipsCtrl:showNpcDuelBuff(data)
	if self.npcDuelBuff then
		self.npcDuelBuff:showNpcDuelBuff(data)
	end
end

function TipsCtrl:showMarqueeText(text, duration, speed)
	if self.marquee then
		self.marquee:showMarquee(text, duration, speed)
	end
end

function TipsCtrl:addMarqueeText(text, id, speed)
	if self.marquee then
		id = id or false

		self.marquee:addMarqueeText(text, id, speed)
	end
end

function TipsCtrl:setMarqueeGMVisible(visible)
	if self.marquee then
		self.marquee:setMarqueeGMVisible(visible)
	end
end

function TipsCtrl:clearMarquee()
	if self.marquee then
		self.marquee:clearMarquee()
	end
end

function TipsCtrl:clearMarqueeById(id)
	if self.marquee then
		self.marquee:clearMarqueeById(id)
	end
end

function TipsCtrl:showSkillTreeLvUp(nv)
	if not self:checkCanPushItem() then
		return
	end

	if self.skillUpCmp == nil then
		return
	end

	self.skillUpCmp:checkOpenSkillUpTip(nv)
end

function TipsCtrl:initMapMark()
	self.view:preLoadMapResource(100)
end

function TipsCtrl:showCommonInput(title, cb, cancelCb, extraConfig, loadCb)
	pg.global.ui:open(UIConst.UI_ID_COMMON_TIP_INPUT, {
		title = title,
		cb = cb,
		cancelCb = cancelCb,
		extraConfig = extraConfig,
		loadCb = loadCb
	})
end

function TipsCtrl:showA1Tips(data)
	data.areaType = TipAreaConst.AREAS.A1
	data.itemKey = data.id

	self:pushAreaManagerData(data)
end

function TipsCtrl:showA2Tips(data)
	data.areaType = TipAreaConst.AREAS.A2
	data.itemKey = data.id

	self:pushAreaManagerData(data)
end

function TipsCtrl:hideA1Tips(itemKey, id)
	if self.areaManager == nil then
		return
	end

	self.areaManager:hideAreaItemById(TipAreaConst.AREAS.A1, itemKey, id)
end

function TipsCtrl:hideA2Tips(itemKey, id)
	if self.areaManager == nil then
		return
	end

	self.areaManager:hideAreaItemById(TipAreaConst.AREAS.A2, itemKey, id)
end

function TipsCtrl:isPoiForbidden()
	local space = pg.me and pg.me.space

	if space and type(space.isNpcDuel) == "function" and space:isNpcDuel() then
		return true
	end

	return false
end

function TipsCtrl:showPoi(data)
	if self:isPoiForbidden() then
		return false
	end

	data.areaType = TipAreaConst.AREAS.A1
	data.itemKey = "POIPop"

	return self:pushAreaManagerData(data)
end

function TipsCtrl:showCultivateMapTip(data)
	if self:isPoiForbidden() then
		return false
	end

	data.cultivateState = data.cultivateState or data.state
	data.state = 0
	data.areaType = TipAreaConst.AREAS.A1I
	data.itemKey = "MapTips"

	return self:pushAreaManagerData(data)
end

function TipsCtrl:showCultivateTips(states, data)
	local pushedCount = 0

	for _, cultivateState in ipairs(states or EMPTY_TABLE) do
		local tipData = {}

		for key, value in pairs(data or EMPTY_TABLE) do
			tipData[key] = value
		end

		tipData.cultivateState = cultivateState

		if not self:showCultivateMapTip(tipData) then
			return false
		end

		pushedCount = pushedCount + 1
	end

	return pushedCount > 0
end

function TipsCtrl:hidePoi(uniqueId)
	if self.areaManager == nil then
		return
	end

	self.areaManager:hideAreaItemById(TipAreaConst.AREAS.A1, "POIPop", uniqueId)
end

function TipsCtrl:showPoiArea(data)
	if self:isPoiForbidden() then
		return false
	end

	if self.showPoiAreaCd then
		return
	end

	self.showPoiAreaCd = true

	self:startTimer(function()
		self.showPoiAreaCd = false
	end, 10)

	data.areaType = TipAreaConst.AREAS.A2
	data.itemKey = "POIPopArea"

	self:pushAreaManagerData(data)
end

function TipsCtrl:hidePoiArea(uniqueId)
	self.areaManager:hideAreaItemById(TipAreaConst.AREAS.A2, "POIPopArea", uniqueId)
end

function TipsCtrl:pushPetGot(petInfoList)
	local multi = #petInfoList >= self.model.PET_MULT_COUNT
	local newPets = {}
	local newUnlock = {}

	for _, item in ipairs(petInfoList) do
		local spCode, _ = LuaUIUtils.getPetSpecialAttr(item.id)

		if spCode == LuaUIUtils.SP_CODE.SP_SKILL then
			item.spLabel = pg.getGameString("RARE_SKILL")
		elseif spCode == LuaUIUtils.SP_CODE.SP_FEATURE then
			item.spLabel = pg.getGameString("RARE_FEATURE")
		end

		item.spCode = spCode

		if PetFirstShowData[item.templateId] and (item.isNew or item.isRareNew or item.isMagicNew) then
			newPets[#newPets + 1] = item
		end

		if item.isNew then
			newUnlock[#newUnlock + 1] = item.templateId
		end
	end

	self:pushAreaManagerData({
		areaType = TipAreaConst.AREAS.C,
		itemKey = multi and "MultiPetObtains" or "PetObtain",
		newPets = petInfoList,
		overallDelayTime = multi and MULTI_PET_OBTAINS_DELAY_TIME or nil
	})

	if not ClientUtils.isInDouYinOfflineScene() then
		self:startTimer(function()
			for _, templateId in ipairs(newUnlock) do
				self:tryPushPreResearchItem(templateId)
			end
		end, 2)
	end

	if #newPets > 0 then
		self:showPetFirstGot({
			newPets = newPets
		})
	end
end

function TipsCtrl:showPetFirstGot(data)
	data.areaType = TipAreaConst.AREAS.M
	data.itemKey = "PetFirstShow"

	self:pushAreaManagerData(data)
end

function TipsCtrl:tryPushPreResearchItem(templateId)
	local propertyId = Utils.getBasePetPrototypeId(templateId)
	local petHandbookInfo = pg.me.petHandbookMap[propertyId]
	local player = pg.me

	if petHandbookInfo and petHandbookInfo.traitResearchMap then
		for traitId, researchInfo in petHandbookInfo.traitResearchMap:items() do
			if Const.PET_RESEARCH.STATUS_SHOW == researchInfo.status and researchInfo.isRewarded then
				player:unlockTraitResearch(templateId, traitId)
			end
		end
	end
end

function TipsCtrl:itemPetGot(petInfo)
	if not self:checkCanPushItem() then
		return
	end

	local name = string.format("[%s]", petInfo.name)
	local icon = LuaUIUtils.getPetIcon(petInfo.iconName, LuaUIUtils.PET_ICON, petInfo.label)

	self:showTextTip(pg.getGameString("GOT_PET"), 3, nil, name, nil, icon, false)
end

function TipsCtrl:showPiecesItem(data)
	data.areaType = TipAreaConst.AREAS.M
	data.itemKey = "PreciousProp"

	self:pushAreaManagerData(data)
end

function TipsCtrl:showPiecesItems(items, extraData)
	local valid = 0

	for _, v in ipairs(items) do
		local msg = LuaUIUtils.getSpecialItemInfo(v.itemId, v.itemCount)

		if msg then
			msg.offsetY = extraData.offsetY

			self:showPiecesItem(msg)

			valid = valid + 1
		end
	end

	extraData.waitCount = valid
	extraData.areaType = TipAreaConst.AREAS.M
	extraData.itemKey = "PreciousProp"

	self:postAreaManagerData(extraData)
end

function TipsCtrl:showPropsObtainTips(data)
	data.areaType = TipAreaConst.AREAS.MI
	data.itemKey = "PropsObtain"

	self:pushAreaManagerData(data)
end

function TipsCtrl:showSpecialReplaceItem(data)
	data.areaType = TipAreaConst.AREAS.B
	data.itemKey = "ItemRepeatObtain"

	self:pushAreaManagerData(data)
end

function TipsCtrl:showBadgeItem(data)
	data.areaType = TipAreaConst.AREAS.B
	data.itemKey = "badgeRepeatObtain"

	self:pushAreaManagerData(data)
end

function TipsCtrl:showHelpTips(data)
	data.areaType = TipAreaConst.AREAS.B
	data.itemKey = "HelpTips"

	self:pushAreaManagerData(data)
end

function TipsCtrl:showAIHelperTips(data)
	data.areaType = TipAreaConst.AREAS.BI
	data.itemKey = "AIHelperTips"

	self:pushAreaManagerData(data)
end

function TipsCtrl:hideAIHelperTips(groupId)
	if self.areaManager then
		self.areaManager:hideAreaItemById(TipAreaConst.AREAS.BI, "AIHelperTips", groupId)
	end
end

function TipsCtrl:clearAIHelperTips()
	if not self.areaManager then
		return
	end

	local item = self.areaManager:getAreaItem(TipAreaConst.AREAS.BI, "AIHelperTips")

	if item then
		item:clearAll()
	end
end

function TipsCtrl:showCountDown(duration, uniqueId, extraData)
	extraData = extraData or {}
	extraData.uniqueId = uniqueId
	extraData.areaType = TipAreaConst.AREAS.TOP
	extraData.itemKey = "CountDown"
	extraData.priority = extraData.priority or 0
	extraData.startTime = Time.realSecondCache
	extraData.duration = duration
	extraData.endTime = Time.realSecondCache + duration

	self:pushAreaManagerData(extraData)
end

function TipsCtrl:refreshCountDownData(uniqueId, extraData)
	if self.areaManager == nil then
		return
	end

	self.areaManager:refreshAreaItem(TipAreaConst.AREAS.TOP, "CountDown", uniqueId, extraData)
end

function TipsCtrl:hideCountDown(uniqueId)
	if self.areaManager then
		self.areaManager:hideAreaItemById(TipAreaConst.AREAS.TOP, "CountDown", uniqueId)
	end
end

function TipsCtrl:showTimeViolentCountDown(duration, uniqueId, extraData)
	extraData = extraData or {}
	extraData.uniqueId = uniqueId
	extraData.areaType = TipAreaConst.AREAS.TOP
	extraData.itemKey = "TimeViolent"
	extraData.priority = extraData.priority or 0
	extraData.startTime = Time.realSecondCache
	extraData.duration = duration
	extraData.endTime = Time.realSecondCache + duration

	self:pushAreaManagerData(extraData)
end

function TipsCtrl:refreshTimeViolentCountDownData(uniqueId, extraData)
	self.areaManager:refreshAreaItem(TipAreaConst.AREAS.TOP, "TimeViolent", uniqueId, extraData)
end

function TipsCtrl:hideTimeViolentCountDown(uniqueId)
	if self.areaManager == nil then
		return
	end

	self.areaManager:hideAreaItemById(TipAreaConst.AREAS.TOP, "TimeViolent", uniqueId)
end

function TipsCtrl:onNotifyItem(info)
	if not self:checkCanPushItem() then
		return
	end

	if self.itemBatch == nil then
		return
	end

	self.itemBatch:onNotifyItem(info)
end

function TipsCtrl:onNotifyItemBatch(info)
	if not self:checkCanPushItem() then
		return
	end

	if self.itemBatch == nil then
		return
	end

	self.itemBatch:onNotifyItemBatch(info)
end

function TipsCtrl:pushPropItem(data)
	self:pushPropItemGroup({
		source = data.source,
		batchType = data.batchType,
		items = {
			data
		}
	})
end

function TipsCtrl:pushPropItemGroup(group)
	if group == nil or group.items == nil or #group.items == 0 then
		return
	end

	if group.source == nil then
		for _, data in ipairs(group.items) do
			data.areaType = TipAreaConst.AREAS.C
			data.itemKey = "PropObtain"

			self:pushAreaManagerData(data)
		end

		return
	end

	group.areaType = TipAreaConst.AREAS.C
	group.itemKey = "PropObtain"

	self:pushAreaManagerData(group)
end

function TipsCtrl:beginPropItemStreamBatch(batchId)
	if batchId == nil or not self:checkCanPushItem() or self.areaManager == nil then
		return false
	end

	local item = self.areaManager:getAreaItem(TipAreaConst.AREAS.C, "PropObtain")

	if item == nil or item.beginStreamBatch == nil then
		return false
	end

	return item:beginStreamBatch(batchId) == true
end

function TipsCtrl:appendPropItemStreamBatch(batchId, data)
	if batchId == nil or not Utils.isTable(data) or data.id == nil or not self:checkCanPushItem() or self.areaManager == nil then
		return false
	end

	local item = self.areaManager:getAreaItem(TipAreaConst.AREAS.C, "PropObtain")

	if item == nil or item.appendStreamBatch == nil then
		return false
	end

	return item:appendStreamBatch(batchId, data) == true
end

function TipsCtrl:endPropItemStreamBatch(batchId)
	if batchId == nil or self.areaManager == nil then
		return false
	end

	local item = self.areaManager:getAreaItem(TipAreaConst.AREAS.C, "PropObtain")

	if item == nil or item.endStreamBatch == nil then
		return false
	end

	return item:endStreamBatch(batchId) == true
end

function TipsCtrl:pushQuickUseItem(data)
	data.areaType = TipAreaConst.AREAS.C
	data.itemKey = "QuickUse"

	self:pushAreaManagerData(data)
end

function TipsCtrl:pushFriendOnLineItem(data)
	data.areaType = TipAreaConst.AREAS.C
	data.itemKey = "FriendOnLine"
	data.tIndex = 0

	self:pushAreaManagerData(data)
end

function TipsCtrl:pushLightPropItem(data)
	local overallDelayTime = data.overallDelayTime

	if overallDelayTime and overallDelayTime > 0 then
		data.readyTime = Time.realSecondCache + overallDelayTime
		data.overallDelayTime = nil
	end

	data.areaType = TipAreaConst.AREAS.A1I
	data.itemKey = "ItemObtain"

	self:pushAreaManagerData(data)
end

function TipsCtrl:onPetResearchChange(info)
	info.areaType = TipAreaConst.AREAS.C
	info.itemKey = "PetResearch"
	info.tIndex = 1

	self:pushAreaManagerData(info)
end

function TipsCtrl:onPetAchieveChange(info)
	if pg.space and pg.space:isRogueEnv() then
		return
	end

	info.areaType = TipAreaConst.AREAS.C
	info.itemKey = "PetResearch"
	info.tIndex = 1
	info.isTopic = true

	self:pushAreaManagerData(info)
end

function TipsCtrl:onBadgeTaskChange(info)
	if pg.space and pg.space:isRogueEnv() then
		return
	end

	info.areaType = TipAreaConst.AREAS.C
	info.itemKey = "PetResearch"
	info.tIndex = 1

	self:pushAreaManagerData(info)
end

function TipsCtrl:onPetFirstShow(info)
	self.areaManager:hideAreaItemById(TipAreaConst.AREAS.C, "PetResearch", info.templateId)
end

function TipsCtrl:onPetEvolve(info)
	info.areaType = TipAreaConst.AREAS.C
	info.itemKey = "PetEvolve"

	self:pushAreaManagerData(info)
end

function TipsCtrl:recycleEvolveItem(petId)
	if self.areaManager == nil then
		return
	end

	self.areaManager:hideAreaItemById(TipAreaConst.AREAS.C, "PetEvolve", petId)
end

function TipsCtrl:tryToDelayForLocalizationReplace(data, delay)
	if GmToolUtils.checkMaskState() then
		data.endTime = data.endTime + delay
	end
end

function TipsCtrl:mapAreaUnlockTip(data)
	data.areaType = TipAreaConst.AREAS.A1
	data.itemKey = "MapAreaUnlockTip"

	self:pushAreaManagerData(data)
end

function TipsCtrl:questComplete(data)
	data.areaType = TipAreaConst.AREAS.A1
	data.itemKey = "QuestComplete"

	self:pushAreaManagerData(data)
end

function TipsCtrl:onLanguageChanged()
	self:resetQuestState()
end

function TipsCtrl:onSceneLoaded()
	self:onClearAllTips()
	self:resetQuestState()
	self:refreshHomelandState()
	self:resetChallengeState()
	self:refreshCarnCompletionPrompt()
	self:refreshShortCutKey()
	self.dispatcher:start()

	local pendingNoticeIds = self.pendingSceneLoadedBubbleMessageIds

	if #pendingNoticeIds > 0 then
		if self.pendingSceneLoadedBubbleMessageTimerId then
			TimerManager.removeTimer(self.pendingSceneLoadedBubbleMessageTimerId)
		end

		self.pendingSceneLoadedBubbleMessageTimerId = TimerManager.addTimer(SCENE_LOADED_BUBBLE_MESSAGE_DELAY, function()
			self.pendingSceneLoadedBubbleMessageTimerId = nil

			for _, noticeId in ipairs(pendingNoticeIds) do
				ClientUtils.showBubbleMessage(noticeId)
			end
		end)
	end

	self.pendingSceneLoadedBubbleMessageIds = {}
end

function TipsCtrl:onSceneUnload()
	self.dispatcher:clear()
	self.areaManager:onSceneUnload()
	self:suspendTipsForCutscene(false)
end

function TipsCtrl:onPlayerDestroyed()
	self.dispatcher:resetSession()

	if self.quest then
		self.quest:clearPlayerReferences()
	end

	self:refreshHomelandState()
	self:resetChallengeState()
	self:suspendTipsForCutscene(false)
end

function TipsCtrl:resetQuestState()
	if self.quest == nil or pg.me == nil then
		return
	end

	self.quest:tryResetQuestState()
end

function TipsCtrl:onSpecialTrainChapterUnlock(chapterId)
	if self.quest == nil or pg.me == nil then
		return
	end

	self.quest:onSpecialTrainChapterUnlock(chapterId)
end

function TipsCtrl:playCompleteAnimFlag(flag)
	if self.quest == nil or pg.me == nil then
		return
	end

	self.quest:playCompleteAnimFlag(flag)
end

function TipsCtrl:setQuestRootVisible(visible)
	if self.quest == nil then
		return
	end

	if visible then
		self.quest:showQuest()
	else
		self.quest:hideQuest()
	end
end

function TipsCtrl:setQAreaVisible(visible)
	self.view.questAreaUWidget:SetActiveFastest(visible)
end

function TipsCtrl:onQuestStateChange(data)
	if self.quest == nil then
		return
	end

	self.quest:onQuestStateChange(data)
end

function TipsCtrl:onQuestTraceChange(data)
	if self.quest == nil then
		return
	end

	self.quest:onQuestTraceChange(data)
end

function TipsCtrl:onQuestObjectiveChanged(data)
	if self.quest == nil then
		return
	end

	self.quest:onQuestObjectiveChanged(data)
end

function TipsCtrl:onQuestComActionObjectiveChanged(data)
	if self.quest == nil then
		return
	end

	self.quest:onQuestComActionObjectiveChanged(data)
end

function TipsCtrl:onQuestRunStateChanged(data)
	if self.quest == nil then
		return
	end

	self.quest:onQuestRunStateChanged(data)
end

function TipsCtrl:showQuestChapter(data)
	data.areaType = TipAreaConst.AREAS.M
	data.itemKey = "QuestChapter"

	self:pushAreaManagerData(data)
end

function TipsCtrl:showCurtainQuest(questConfig, state)
	if self.quest == nil then
		return
	end

	self.quest:onRefreshCurtainQuest(questConfig, state)
end

function TipsCtrl:backToHome()
	if self.quest then
		self.quest:backToHome()
	end

	if self.target then
		self.target:backToHome()
	end

	if self.screenCaptureShareComponent then
		self.screenCaptureShareComponent:clear()
	end

	if self.areaManager then
		self.areaManager:clearAllTips()
	end
end

function TipsCtrl:showNpcCallMultiple(data)
	data.areaType = TipAreaConst.AREAS.CI
	data.itemKey = "NpcCall"

	self:pushAreaManagerData(data)
end

function TipsCtrl:setTargetRootVisible(visible)
	if self.target == nil then
		return
	end

	self.target:showTarget(visible)
end

function TipsCtrl:refreshQuestTargetVisibleState()
	if self.quest == nil or self.quest.refreshTargetVisibleState == nil then
		return
	end

	self.quest:refreshTargetVisibleState()
end

function TipsCtrl:refreshTargetBuffItem()
	if self.target == nil then
		return
	end

	self.target:refreshTargetBuffItem()
end

function TipsCtrl:onTargetObjectChange(data)
	if self.target == nil then
		return
	end

	self.target:onTargetObjectChange(data)
end

function TipsCtrl:refreshTargetProgressItem()
	if self.target == nil then
		return
	end

	self.target:refreshTargetBuffItem()
end

function TipsCtrl:resetTargetState()
	if self.target == nil then
		return
	end

	self.target:resetTargetState()
end

function TipsCtrl:onInputDeviceChanged(deviceType)
	self.quest:onInputDeviceChanged()
	self.areaManager:onInputDeviceChanged(deviceType)
end

function TipsCtrl:refreshHotKeyHint(force)
	return
end

function TipsCtrl:refreshOperationHint()
	return
end

function TipsCtrl:addNewNotice(noticeInfo)
	noticeInfo.areaType = TipAreaConst.AREAS.CI
	noticeInfo.itemKey = "TeamInvite"

	self:pushAreaManagerData(noticeInfo)
end

function TipsCtrl:addHudNotice(playerId, playerInfo, noticeMsg, duration, btnYesFunc, btnNoFunc, timeEndFunc, extraParam)
	if extraParam and extraParam.funcName and not pg.me:checkFunctionUnlock(extraParam.funcName) then
		return
	end

	local noticeInfo = {
		noticeId = self.teamInviteNoticeId,
		duration = duration,
		playerId = playerId,
		playerInfo = playerInfo,
		noticeMsg = noticeMsg,
		btnYesFunc = btnYesFunc,
		btnNoFunc = btnNoFunc,
		timeEndFunc = timeEndFunc,
		tIndex = extraParam and extraParam.tIndex and extraParam.tIndex or 0,
		extraParam = extraParam
	}

	if self.playerId2NoticeId == nil then
		self.playerId2NoticeId = {}
	end

	self.playerId2NoticeId[playerId] = self.teamInviteNoticeId
	self.teamInviteNoticeId = self.teamInviteNoticeId + 1

	self:addNewNotice(noticeInfo)
end

function TipsCtrl:removeTeamInviteNoticeByPlayerId(playerId)
	if self.playerId2NoticeId and self.playerId2NoticeId[playerId] then
		pg.global.ui.tips:removeTeamInviteNotice(self.playerId2NoticeId[playerId])

		self.playerId2NoticeId[playerId] = nil
	end
end

function TipsCtrl:removeTeamInviteNotice(noticeId)
	if self.areaManager == nil then
		return
	end

	self.areaManager:hideAreaItemById(TipAreaConst.AREAS.CI, "TeamInvite", noticeId)
end

function TipsCtrl:removeAllNotice()
	if self.areaManager == nil then
		return
	end

	self.areaManager:hideAreaItem(TipAreaConst.AREAS.CI, "TeamInvite")
end

function TipsCtrl:onPvpInvite(data)
	data.areaType = TipAreaConst.AREAS.CI
	data.itemKey = "PvpInvite"

	self:pushAreaManagerData(data)
end

function TipsCtrl:onSetInviteState(data)
	if self.areaManager == nil then
		return
	end

	data.areaType = TipAreaConst.AREAS.TOP

	if data.state == "InviteShow" then
		data.itemKey = "PvpInviteState"

		self:pushAreaManagerData(data)
	elseif data.state == "InviteHide" then
		self.areaManager:hideAreaItem(TipAreaConst.AREAS.TOP, "PvpInviteState")
	elseif data.state == "PrepareShow" then
		data.itemKey = "PvpPreparation"

		self:pushAreaManagerData(data)
	elseif data.state == "PrepareHide" then
		self.areaManager:hideAreaItem(TipAreaConst.AREAS.TOP, "PvpPreparation")
	end
end

function TipsCtrl:isEdgeRunning(ignoreList)
	if Utils.tableIsEmptyOrNil(self.edgePriorities) then
		return false
	end

	for _, com in pairs(self.edgePriorities) do
		if not table.contains(ignoreList, com.priority) then
			local isRunning = com:checkIsRunning()

			if isRunning then
				return true
			end
		end
	end

	return false
end

function TipsCtrl:onAddPet(info)
	self:startTimer(function()
		if not pg.me.enableAutoEquipExplorerPet then
			return
		end

		if not self:checkCanPushItem() then
			return
		end

		local higherClimb, higherGlide, higherSwim = ClientUtils.checkExploreLevel(info.petInfo, pg.me)

		if not higherClimb and not higherGlide and not higherSwim then
			return
		end

		local msg = {
			itemKey = "ExplorePetReplace",
			areaType = TipAreaConst.AREAS.C,
			petId = info.petInfo.id,
			higherClimb = higherClimb,
			higherGlide = higherGlide,
			higherSwim = higherSwim
		}

		self:pushAreaManagerData(msg)
	end, 0.2)
end

function TipsCtrl:onPetEvolved(info)
	self:startTimer(function()
		if not pg.me.enableAutoEquipExplorerPet then
			return
		end

		if not self:checkCanPushItem() then
			return
		end

		local higherClimb, higherGlide, higherSwim = ClientUtils.checkExploreLevel(info.petInfo, pg.me)

		if not higherClimb and not higherGlide and not higherSwim then
			return
		end

		local msg = {
			itemKey = "ExplorePetReplace",
			areaType = TipAreaConst.AREAS.C,
			petId = info.petInfo.id,
			higherClimb = higherClimb,
			higherGlide = higherGlide,
			higherSwim = higherSwim
		}

		self:pushAreaManagerData(msg)
	end, 0.2)
end

function TipsCtrl:onUpdateProgressDisengage(data)
	data.areaType = TipAreaConst.AREAS.A2
	data.itemKey = "OutCombatProgress"

	self:pushAreaManagerData(data)
end

function TipsCtrl:onExitProgressDisengage(progress)
	self.areaManager:hideAreaItemById(TipAreaConst.AREAS.A2, "OutCombatProgress")
end

function TipsCtrl:onHitWhenFullScreenShow()
	self.view.dangerUContainer.gameObject:SetActiveEx(true)

	if self.view.dangerUContainer:CheckURLLoaded() then
		self:triggerFullScreenHitEffect()
	else
		self.view.dangerUContainer:LoadDefaultUrlManually(function()
			self:triggerFullScreenHitEffect()
		end)
	end
end

function TipsCtrl:triggerFullScreenHitEffect()
	if self.triggerFSHitEffectTimer ~= nil then
		return false
	end

	pg.global.showBubbleMessageById(NoticeDef.BE_HIT_ON_FULL_SCREEN_UI_SHOW)
	self.view.dangerUContainer.content:InvokeCallback(CS.XGUI.EInvokeTime.User2)

	self.triggerFSHitEffectTimer = self:startTimer(function()
		self.view.dangerUContainer.gameObject:SetActiveEx(false)
		self:killTimer(self.triggerFSHitEffectTimer)

		self.triggerFSHitEffectTimer = nil
	end, SysConfigData.FULL_SCREEN_HIT_EFFECT_INTERVAL or 1)
end

function TipsCtrl:openStarImprove()
	self:openCommonPopUpTip(LuaUIUtils.getGradeContent(pg.me))
end

function TipsCtrl:openEventRuleDesc(eventDesc, title, onClose, useHyperlinkAnchor)
	local info = {
		title = title or "EVENT_RULE_TITLE",
		useHyperlinkAnchor = useHyperlinkAnchor == true,
		content = {
			info1 = {
				{
					tIndex = 2,
					content = eventDesc
				}
			}
		}
	}

	self:openCommonPopUpTip(info, onClose)
end

function TipsCtrl:openPetManagementReleaseDesc()
	local data = LuaUIUtils.getDescriptionData(5)

	self:componentSetIsModel("PetManagementReleaseDesc", true)
	self:openCommonPopUpTip(data, function()
		self:componentSetIsModel("PetManagementReleaseDesc", false)
	end)
end

function TipsCtrl:openRogueRewardUpDesc()
	local data = LuaUIUtils.getDescriptionData(SysConfigData.mockBattle_UP_RULE)

	self:openCommonPopUpTip(data)
end

function TipsCtrl:openNourishDesc(descId)
	local data = LuaUIUtils.getDescriptionData(descId)

	self:componentSetIsModel("NourishDesc", true)
	self:openCommonPopUpTip(data, function()
		self:componentSetIsModel("NourishDesc", false)
	end)
end

function TipsCtrl:openSchoolGuideDesc(desId)
	local data = LuaUIUtils.getDescriptionData(desId)

	self:openCommonPopUpTip(data)
end

function TipsCtrl:openRogPopTips(desId)
	local data = LuaUIUtils.getDescriptionData(desId)

	self:componentSetIsModel("RogPopTips", true)
	self:openCommonPopUpTip(data, function()
		self:componentSetIsModel("RogPopTips", false)
	end)
end

function TipsCtrl:openCommonPopUpTipById(id)
	local data = LuaUIUtils.getDescriptionData(id)

	self:openCommonPopUpTip(data)
end

function TipsCtrl:openCommonPopUpTip(data, onClose)
	self:componentSetIsModel("PopupTip", true)
	self.popupTip:openPopupTipInfo(data, function()
		self:componentSetIsModel("PopupTip", false)

		if onClose then
			onClose()
		end
	end)
end

function TipsCtrl:event_onPlayerExpChange(info)
	local res = LuaUIUtils.getPlayerInfo()

	res.oldExp = info.oldExp
	res.addExp = info.addExp
	res.oldLevel = info.oldLevel
	res.newLevel = info.newLevel
	res.isLvUp = info.newLevel > info.oldLevel
	res.areaType = TipAreaConst.AREAS.A1I
	res.itemKey = "PlayerExpChanged"
	res.overallDelayTime = 0.2
	res.batch = true

	if pg.space and pg.space:isNpcDuel() then
		res.overallDelayTime = 0

		pg.space:npcDuelExpGetCahce(res)
	else
		self:pushAreaManagerData(res)
	end
end

function TipsCtrl:event_onPlayerLvChange(info)
	return
end

function TipsCtrl:event_onPlayerStarChange()
	local isShowUpstarUI = PlayerTitleData[pg.me.starTitle or 0].isShowUpstarUI

	if isShowUpstarUI == 1 then
		return
	end

	self.popupTip:pushAssessPopTip({
		"2"
	})
end

function TipsCtrl:event_onMoneyNumChange(info)
	return
end

function TipsCtrl:refreshHomelandState()
	if pg.me == nil or pg.me.space == nil then
		self.areaManager:hideAreaItemById(TipAreaConst.AREAS.TOP, "HomeName")

		return
	end

	if pg.me.space:isHomeland() then
		local ownerUid = pg.me.space.ownerUid
		local ownerPlayerName = pg.me.space.ownerPlayerName or ""
		local homelandInfo = {
			itemKey = "HomeName",
			areaType = TipAreaConst.AREAS.TOP,
			name = pg.getFormatText(pg.getGameString("HOMELANE_NAME"), pg.me.space.ownerPlayerName),
			ownerUid = ownerUid,
			ownerPlayerName = ownerPlayerName,
			playerInfo = ownerUid and pg.game.chat and pg.game.chat.getPlayerInfo and pg.game.chat:getPlayerInfo(ownerUid) or nil,
			level = pg.me.space.basicInfo and pg.me.space.basicInfo.level
		}

		self:pushAreaManagerData(homelandInfo)
	else
		self.areaManager:hideAreaItemById(TipAreaConst.AREAS.TOP, "HomeName")
	end
end

function TipsCtrl:showDropHint(strKey, targetPos, duration)
	local dropHintInfo = {
		itemKey = "DropHint",
		areaType = TipAreaConst.AREAS.PA2,
		str = pg.getGameString(strKey),
		progressDuration = duration or 3,
		targetPos = targetPos
	}

	self:pushAreaManagerData(dropHintInfo)
end

function TipsCtrl:hideDropHint()
	if self.areaManager == nil then
		return
	end

	self.areaManager:hideAreaItem(TipAreaConst.AREAS.PA2, "DropHint")
end

function TipsCtrl:tryShowBPCoreReward()
	if not ClientCashShopUtils.canOpenBattlePass() then
		return
	end

	local actData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.BattlePass)
	local phase = actData and actData.activityBase and actData.activityBase.activityPhase

	if not phase then
		return
	end

	local prefsKey = ClientConst.PrefKey.BPCorePop
	local lastShownPhase = pg.global.prefsCacheUtils:getInt(prefsKey, 0)

	if lastShownPhase == phase then
		return
	end

	pg.global.prefsCacheUtils:setInt(prefsKey, phase)
	pg.global.ui:open(UIConst.UI_ID_BP_CORE_REWARD)
end

function TipsCtrl:refreshShortCutKey()
	if not self.areaManager then
		return
	end

	self:_applyShortCutKeyRedirect()

	local com = self.areaManager:getAreaItem(TipAreaConst.AREAS.CF, "ShortCutKey")

	if com then
		com:refreshShortCutKey()
	end
end

function TipsCtrl:_applyShortCutKeyRedirect()
	local targetGo = self.shortCutKeyRedirectTargetGo
	local actionPath = self.shortCutKeyRedirectActionPath

	if targetGo == nil and actionPath == nil then
		return
	end

	if IsNil(targetGo) or string.isNilOrEmpty(actionPath) then
		self:clearShortCutKeyRedirect()

		return
	end

	if not self.areaManager then
		targetGo:SetActiveEx(false)

		return
	end

	local item = self.areaManager:getAreaItem(TipAreaConst.AREAS.CF, "ShortCutKey")

	if item and (IsNil(item.redirectGo) or item.redirectGo ~= targetGo or item.redirectActionPath ~= actionPath) then
		item:bindRedirect(targetGo, actionPath)
	end
end

function TipsCtrl:_clearShortCutKeyRedirectState()
	local targetGo = self.shortCutKeyRedirectTargetGo

	if not IsNil(targetGo) then
		targetGo:SetActiveEx(false)
	end

	self.shortCutKeyRedirectTargetGo = nil
	self.shortCutKeyRedirectActionPath = nil
end

function TipsCtrl:redirectShortCutKey(targetGo, actionPath)
	if IsNil(targetGo) or string.isNilOrEmpty(actionPath) then
		return
	end

	local oldTargetGo = self.shortCutKeyRedirectTargetGo

	if not IsNil(oldTargetGo) and oldTargetGo ~= targetGo then
		oldTargetGo:SetActiveEx(false)
	end

	self.shortCutKeyRedirectTargetGo = targetGo
	self.shortCutKeyRedirectActionPath = actionPath

	self:_applyShortCutKeyRedirect()
end

function TipsCtrl:clearShortCutKeyRedirect()
	self:_clearShortCutKeyRedirectState()

	if not self.areaManager then
		return
	end

	local item = self.areaManager:getAreaItem(TipAreaConst.AREAS.CF, "ShortCutKey")

	if item then
		item:clearRedirect()
	end
end

function TipsCtrl:setShortCurKeyVisible_BigWhiteBall(isShow)
	if self.areaManager == nil then
		return
	end

	local item = self.areaManager:getAreaItem(TipAreaConst.AREAS.CF, "ShortCutKey")

	if item then
		item:setHideFlag(TipAreaConst.TipItemFlag.ItemFlag_BigWhiteBall, not isShow)
	end
end

function TipsCtrl:getBossTitleItem()
	if self.areaManager == nil then
		return nil
	end

	if not self:checkHasBossTitleItem() then
		return nil
	end

	return self.areaManager:getAreaItem(TipAreaConst.AREAS.TOP, "BossTitle")
end

function TipsCtrl:checkHasBossTitleItem()
	if self.areaManager == nil then
		return nil
	end

	return self.areaManager:hasAreaItem(TipAreaConst.AREAS.TOP, "BossTitle")
end

function TipsCtrl:getBossTitleStagePos()
	local component = self:getBossTitleItem()

	if component then
		return component:getBossTitleStagePos()
	end
end

function TipsCtrl:refreshBossTitle()
	if self:checkHasBossTitleItem() or self:checkHatredNeedShowBossTitle() or self:checkNpcDuelShowBossTitle() or self:checkLockTargetShowBossTitle() then
		local info = {
			itemKey = "BossTitle",
			areaType = TipAreaConst.AREAS.TOP
		}

		self:pushAreaManagerData(info)
	end
end

function TipsCtrl:checkHatredNeedShowBossTitle()
	if not pg.me then
		return false
	end

	local target
	local targetCount = 0

	for actorId, _ in pairs(pg.me:getBehatredMap()) do
		local entity = pg.getEntityByActorId(actorId)

		if entity and (Utils.isLabelBoss(entity.label) or Utils.isLabelElite(entity.label)) then
			target = entity
			targetCount = targetCount + 1
		end
	end

	return targetCount == 1 and target:isInCombat()
end

function TipsCtrl:checkNpcDuelShowBossTitle()
	if not pg.me or not pg.space then
		return false
	end

	local isNpcDuel = pg.space:isNpcDuel() and pg.space:npcDuelDungeonIsReady()

	if not isNpcDuel then
		return false
	end

	local npcDuelPet = pg.space:getCurNpcDuelBotPetEntity()

	return npcDuelPet and npcDuelPet:isInCombat()
end

function TipsCtrl:checkLockTargetShowBossTitle()
	if not pg.me then
		return
	end

	local lockedActorId = pg.me.lockedActorId
	local target = lockedActorId and pg.getEntityByActorId(lockedActorId)

	return target and (Utils.isLabelBoss(target.label) or Utils.isLabelElite(target.label)) and target:isInCombat()
end

function TipsCtrl:refreshBossTitleWhenSwitchCombat(data)
	if not data or data.actorId == pg.me.actorId then
		return
	end

	local entity = pg.getEntityByActorId(data.actorId)

	if entity == nil or not Utils.isLabelBoss(entity.label) and not Utils.isLabelElite(entity.label) then
		return
	end

	if data.switch then
		self:refreshBossTitle()

		return
	end

	local component = self:getBossTitleItem()

	if component then
		component:refreshBossTitleWhenSwitchCombat(data.switch, data.actorId)
	end
end

function TipsCtrl:refreshBuffs(info)
	local component = self:getBossTitleItem()

	if component then
		component:refreshBuffs(info)
	end
end

function TipsCtrl:onBuffLayerChange(info)
	local component = self:getBossTitleItem()

	if component then
		component:onBuffLayerChange(info)
	end
end

function TipsCtrl:onBuffAdd(info)
	local component = self:getBossTitleItem()

	if component then
		component:onBuffAdd(info)
	end
end

function TipsCtrl:onBuffRemove(info)
	local component = self:getBossTitleItem()

	if component then
		component:onBuffRemove(info)
	end
end

function TipsCtrl:onBuffExpiredTimeChange(info)
	local component = self:getBossTitleItem()

	if component then
		component:onBuffExpiredTimeChange(info)
	end
end

function TipsCtrl:refreshShield(info)
	local component = self:getBossTitleItem()

	if component then
		component:refreshShield(info)
	end
end

function TipsCtrl:onShieldBreak(info)
	local component = self:getBossTitleItem()

	if component then
		component:onShieldBreak(info)
	end
end

function TipsCtrl:refreshBreakBar(info)
	local component = self:getBossTitleItem()

	if component then
		component:refreshBreakBar(info)
	end
end

function TipsCtrl:refreshHealthPoint(info)
	local component = self:getBossTitleItem()

	if component then
		component:refreshHealthPoint(info)
	end
end

function TipsCtrl:refreshBossStage()
	local component = self:getBossTitleItem()

	if component then
		component:refreshBossStage()
	end
end

function TipsCtrl:onEntElementChange(info)
	local component = self:getBossTitleItem()

	if component then
		component:onEntElementChange(info)
	end
end

function TipsCtrl:refreshFreezeHp(info)
	local component = self:getBossTitleItem()

	if component then
		component:refreshFreezeHp(info)
	end
end

function TipsCtrl:onFreezeHpHit(info)
	local component = self:getBossTitleItem()

	if component then
		component:onFreezeHpHit(info)
	end
end

function TipsCtrl:onFreezeHpOutTime(info)
	local component = self:getBossTitleItem()

	if component then
		component:onFreezeHpOutTime(info)
	end
end

function TipsCtrl:onDungeonGoalRefresh(info)
	local component = self.challenge

	if component then
		component:refreshDungeonGoal(info)
	end
end

function TipsCtrl:resetChallengeState()
	local component = self.challenge

	if component then
		component:resetChallengeState()
	end
end

function TipsCtrl:setBossTitleItemInvisibleReason(flag, visible)
	local component = self:getBossTitleItem()

	if component then
		component:setVisibleWithFlags(flag, visible)
	end
end

function TipsCtrl:pushBossMechanismIconData()
	local component = self:getBossTitleItem()

	if component then
		component:refreshBossMechanismIcon()
	end
end

function TipsCtrl:onBossMechanismIconInitClient(info)
	self.model:initBossMechanismIconClient(info.actorId, info.assetId, info.type, info.needFlash)
	self:pushBossMechanismIconData()
end

function TipsCtrl:onBossMechanismIconSyncMax(info)
	self.model:syncBossMechanismIconMax(info.actorId, info.max)
	self:pushBossMechanismIconData()
end

function TipsCtrl:onBossMechanismIconSyncProgress(info)
	self.model:syncBossMechanismIconProgress(info.actorId, info.progress)
	self:pushBossMechanismIconData()
end

function TipsCtrl:onBossMechanismIconDestroy(info)
	self.model:removeBossMechanismIcon(info.actorId)
	self:pushBossMechanismIconData()
end

function TipsCtrl:onBossMechanismIconShowVX(info)
	self.model:setBossMechanismIconStage(info.actorId, true)
	self:pushBossMechanismIconData()
end

function TipsCtrl:onBossMechanismIconHideVX(info)
	self.model:setBossMechanismIconStage(info.actorId, false)
	self:pushBossMechanismIconData()
end

function TipsCtrl:onBossMechanismIconFlash(info)
	self.model:setBossMechanismIconPendingFlash(info.actorId)
	self:pushBossMechanismIconData()
end

function TipsCtrl:onBuyItems(data)
	local commodityData = ShopCommodityData[data.shopItemId] or {}

	if not commodityData.itemId then
		return
	end

	local itemData = ItemData[commodityData.itemId] or {}
	local isAdvancedBag = 1

	if HomelandConfigData.AdvancedBagShop then
		isAdvancedBag = HomelandConfigData.AdvancedBagShop[commodityData.tag]
	end

	if itemData.isHomeItem == 1 and pg.me.space and pg.me.space.isSelfHomeland and pg.me.space:isSelfHomeland(pg.me) and isAdvancedBag then
		local noticeData = SysNoticeData[NoticeDef.BUY_HOME_ITEM]

		if noticeData then
			pg.global.showBubbleMessageRaw(pg.getLocalizationText(noticeData.text), noticeData.stay)
		end
	end
end

function TipsCtrl:onDittoStateChange(newState, gamePlay)
	local component = self.challenge

	if component then
		component:onDittoStateChange(newState, gamePlay)
	end
end

function TipsCtrl:showCompletionPrompt(data)
	local completionPromptInfo = {
		itemKey = "CompletionPrompt",
		areaType = TipAreaConst.AREAS.B,
		templateId = data.templateId,
		eventId = data.eventId,
		pointNum = data.pointNum
	}

	self:pushAreaManagerData(completionPromptInfo)
end

function TipsCtrl:hideCompletionPrompt()
	self.areaManager:hideAreaItem(TipAreaConst.AREAS.B, "CompletionPrompt")
end

function TipsCtrl:refreshCarnCompletionPrompt()
	if not pg.me then
		return
	end

	local arkcarnCurPhaseId = pg.me.arkcarnCurPhaseId

	if arkcarnCurPhaseId and arkcarnCurPhaseId > 0 then
		local time = TimeUtils.timeToFormatStringSpecial(Time.secondCache)
		local key = pg.me.uid .. "CarnTime" .. time
		local carnValue = pg.global.prefsCacheUtils:getInt(key, 0)
		local stageKey = key .. "Stage"
		local stage3Data = EventArkCarnData[arkcarnCurPhaseId][3]
		local startTime = Utils.getConfigTimeOfArea(stage3Data, "startTime")
		local endTime = Utils.getConfigTimeOfArea(stage3Data, "endTime")

		if carnValue == 0 then
			if pg.me.arkCarnStageState[3] and pg.me.arkCarnStageState[3] == 1 then
				pg.global.prefsCacheUtils:setInt(stageKey, 1)
				self:showCarnCompletionPrompt(pg.getGameString("ARK_CARNIVAL_11"), function()
					pg.me:tryTeleportToScene(stage3Data.petCarnivalId[1], stage3Data.petCarnivalId[2])
				end)
			else
				local remainTime = startTime - Time.secondCache
				local name = LuaUIUtils.getCountDownString(remainTime, UIConst.TimeType.Short, true)

				name = pg.getFormatText(pg.getGameString("ARK_CARNIVAL_10"), name)

				self:showCarnCompletionPrompt(name, function()
					pg.global.ui:open(UIConst.UI_ID_EVENT, {
						id = 10000018,
						tabType = UIConst.EVENT_TAB_TYPE.ACTIVITY
					})
				end)
			end

			pg.global.prefsCacheUtils:setInt(key, 1)
		else
			local stageValue = pg.global.prefsCacheUtils:getInt(stageKey, 0)

			if stageValue == 0 and pg.me.arkCarnStageState[3] and pg.me.arkCarnStageState[3] == 1 then
				pg.global.prefsCacheUtils:setInt(stageKey, 1)
				self:showCarnCompletionPrompt(pg.getGameString("ARK_CARNIVAL_11"), function()
					pg.me:tryTeleportToScene(stage3Data.petCarnivalId[1], stage3Data.petCarnivalId[2])
				end)
			end
		end
	end
end

function TipsCtrl:showCarnCompletionPrompt(name, clickCallback)
	local title = ClientActivityUtils.getEventTitle(ActivityConst.EventType.ArkCarn)
	local completionPromptInfo = {
		itemKey = "CompletionPrompt",
		type = 1,
		areaType = TipAreaConst.AREAS.B,
		overrideTitle = title,
		overrideName = name,
		overrideClick = clickCallback
	}

	self:pushAreaManagerData(completionPromptInfo)
end

function TipsCtrl:hideCarnCompletionPrompt()
	self.areaManager:hideAreaItem(TipAreaConst.AREAS.B, "CompletionPrompt")
end

function TipsCtrl:showNewClueTip(data)
	local clueData = {
		itemKey = "NewClueTips",
		areaType = TipAreaConst.AREAS.BI,
		questId = data.questId,
		callback = data.callback
	}

	self:pushAreaManagerData(clueData)
end

function TipsCtrl:showMutationUnlockTip(itemId)
	local data = {
		itemKey = "GainCrop",
		areaType = TipAreaConst.AREAS.B,
		itemId = itemId
	}

	self:pushAreaManagerData(data)
end

function TipsCtrl:showHomeBookUnlockTip(itemId, duration)
	if type(itemId) ~= "number" then
		return
	end

	self:pushAreaManagerData({
		itemKey = "HomeBookUnlock",
		areaType = TipAreaConst.AREAS.C,
		itemId = itemId,
		duration = duration
	})
end

function TipsCtrl:showCountDownBeat(endTime)
	local data = {
		itemKey = "CountDownBeat",
		areaType = TipAreaConst.AREAS.A1,
		endTime = endTime
	}

	self:pushAreaManagerData(data)
end

function TipsCtrl:hideCountDownBeat()
	if self.areaManager == nil then
		return
	end

	self.areaManager:hideAreaItem(TipAreaConst.AREAS.A1, "CountDownBeat")
end

function TipsCtrl:showControlPanel(endTime, title, direction, startTime)
	local data = {
		itemKey = "ControlPanel",
		areaType = TipAreaConst.AREAS.BI,
		endTime = endTime or Time.realSecondCache + 3,
		title = title,
		direction = direction or 0,
		startTime = startTime
	}

	self:pushAreaManagerData(data)
end

function TipsCtrl:hideControlPanel()
	if self.areaManager then
		self.areaManager:hideAreaItem(TipAreaConst.AREAS.BI, "ControlPanel")
	end
end

function TipsCtrl:onEcsMaxAmountChange(ent)
	local bossTitleItem = self:getBossTitleItem()

	if bossTitleItem and bossTitleItem.visible then
		bossTitleItem:refreshEcsAmount(ent)
	end
end

function TipsCtrl:showHatchEggTip(type, title, desc)
	local data = {
		itemKey = "GrabEggsIncubator",
		areaType = TipAreaConst.AREAS.A1,
		type = type,
		title = title,
		desc = desc
	}

	self:pushAreaManagerData(data)
end

function TipsCtrl:showEggTransferTip(state, title, desc, delay)
	local data = {
		itemKey = "TransferEgg",
		areaType = TipAreaConst.AREAS.A1,
		state = state,
		title = title,
		desc = desc,
		overallDelayTime = delay
	}

	self:pushAreaManagerData(data)
end

function TipsCtrl:onRecvMail(info)
	if info and info.indexDiff and info.indexDiff > 0 then
		local mailList = pg.game.chat.mailList

		for i = 1, info.indexDiff do
			local mail = mailList[i]

			if mail and tonumber(mail.SrcId) == Const.MAIL_ID.SHOPMALL_GIVE_MAIL then
				self:onGiftReceived(mail)

				break
			end
		end
	end

	self:removeClaimedGiftTips()
end

function TipsCtrl:removeClaimedGiftTips()
	local area = self.areaManager:tryGetAreaWithType(TipAreaConst.AREAS.C)

	if not area then
		return
	end

	local item = area:tryGetItem("GiftTips")

	if not item then
		return
	end

	local mailList = pg.game.chat.mailList
	local claimedIds = {}

	for _, mail in ipairs(mailList) do
		if tonumber(mail.SrcId) == Const.MAIL_ID.SHOPMALL_GIVE_MAIL and mail.Params.giftReceived then
			claimedIds[mail.MailId] = true
		end
	end

	for mailId in pairs(claimedIds) do
		item:removeByMailId(mailId)
	end
end

function TipsCtrl:onGiftReceived(mail)
	local data = {
		itemKey = "GiftTips",
		areaType = TipAreaConst.AREAS.C,
		mail = mail
	}
	local giverUid, blessTxt
	local giftItems = {}

	if mail.Params and mail.Params.giftInfo then
		local gifts = mail.Params.giftInfo

		if type(gifts) == "string" then
			gifts = ClientRepo.protoCodec:decode(gifts)
		end

		if gifts.customData then
			giverUid = gifts.customData.giverUid
			blessTxt = gifts.customData.blessTxt
			data.commodityId = gifts.customData.commodityId
			data.rechargeId = gifts.customData.rechargeId
		end

		if gifts.items then
			for itemId, num in pairs(gifts.items) do
				data.id = data.id or itemId
				data.num = data.num or num

				table.insert(giftItems, {
					id = itemId,
					num = num
				})
			end
		end
	end

	if giverUid then
		local playerInfo = pg.game.chat:getPlayerInfo(tostring(giverUid))

		if playerInfo and playerInfo.playerName then
			data.giverName = LuaUIUtils.getPlayerDisplayName(tostring(giverUid), playerInfo.playerName, true)
		end
	end

	data.giverName = data.giverName or mail.SrcName or ""
	data.giverUid = giverUid
	data.blessTxt = blessTxt
	data.giftItems = giftItems

	function data.jumpFunc()
		pg.global.ui:open(UIConst.UI_ID_SHOP_GIFT_RECEIVE, data)
	end

	self:pushAreaManagerData(data)
end

function TipsCtrl:hideGiftTips()
	if self.areaManager == nil then
		return
	end

	self.areaManager:setAreaVisibleWithFlag(TipAreaConst.AREAS.C, TipAreaConst.UITipAreaFlag.AreaFlag_CShow, false)
end

function TipsCtrl:showGiftTips()
	if self.areaManager == nil then
		return
	end

	self.areaManager:setAreaVisibleWithFlag(TipAreaConst.AREAS.C, TipAreaConst.UITipAreaFlag.AreaFlag_CShow, true)
end

function TipsCtrl:pushGMTasks(dataList)
	self.areaManager:parseGMTasks(dataList)
end

function TipsCtrl:hideGMTestInfo()
	self.areaManager:hideTips()
end

function TipsCtrl:showGetEggLimitedTime(extraData)
	extraData = extraData or {}
	extraData.areaType = TipAreaConst.AREAS.TOP
	extraData.itemKey = "GetEggLimitedTime"

	self:pushAreaManagerData(extraData)
end

function TipsCtrl:refreshGetEggLimitedTime(...)
	if self.areaManager == nil then
		return
	end

	self.areaManager:refreshAreaItem(TipAreaConst.AREAS.TOP, "GetEggLimitedTime", ...)
end

function TipsCtrl:showGetEggLimitedTimeWave(waveIndex)
	if self.areaManager == nil then
		return
	end

	local item = self.areaManager:getAreaItem(TipAreaConst.AREAS.TOP, "GetEggLimitedTime")

	if item == nil then
		return
	end

	item:showWaveTip(waveIndex)
end

function TipsCtrl:showGetEggLimitedTimeFinish(extraData)
	if self.areaManager == nil then
		return
	end

	local item = self.areaManager:getAreaItem(TipAreaConst.AREAS.TOP, "GetEggLimitedTime")

	if item ~= nil and item:showFinishTip(extraData) then
		return
	end

	extraData = extraData or {}
	extraData.finishStage = true

	self:showGetEggLimitedTime(extraData)
end

function TipsCtrl:showGetEggLimitedTimeReward(extraData)
	if self.areaManager == nil then
		return
	end

	local item = self.areaManager:getAreaItem(TipAreaConst.AREAS.TOP, "GetEggLimitedTime")

	if item ~= nil and item:showRewardTip() then
		return
	end

	extraData = extraData or {}
	extraData.rewardStage = true

	self:showGetEggLimitedTime(extraData)
end

function TipsCtrl:hideGetEggLimitedTime()
	if self.areaManager == nil then
		return
	end

	self.areaManager:hideAreaItemById(TipAreaConst.AREAS.TOP, "GetEggLimitedTime")
end

function TipsCtrl:showGrabEggWaitingInfo(extraData)
	extraData = extraData or {}
	extraData.areaType = TipAreaConst.AREAS.TOP
	extraData.itemKey = "GrabEggWaitingInfo"
	extraData.tipsTextKey = extraData.tipsTextKey or "GRAB_EGG_LOADING_WAIT"

	self:pushAreaManagerData(extraData)
end

function TipsCtrl:hideGrabEggWaitingInfo()
	if self.areaManager == nil then
		return
	end

	self.areaManager:hideAreaItem(TipAreaConst.AREAS.TOP, "GrabEggWaitingInfo")
end

function TipsCtrl:showCountDownLimitedTime(duration, uniqueId, extraData)
	extraData = extraData or {}
	extraData.uniqueId = uniqueId
	extraData.areaType = TipAreaConst.AREAS.A1
	extraData.itemKey = "CountDownLimitedTime"
	extraData.startTime = Time.secondCache
	extraData.duration = duration
	extraData.endTime = Time.secondCache + (duration or 0)

	self:pushAreaManagerData(extraData)
end

function TipsCtrl:refreshCountDownLimitedTime(uniqueId, extraData)
	if self.areaManager == nil then
		return
	end

	self.areaManager:refreshAreaItem(TipAreaConst.AREAS.A1, "CountDownLimitedTime", uniqueId, extraData)
end

function TipsCtrl:hideCountDownLimitedTime(uniqueId)
	if self.areaManager == nil then
		return
	end

	self.areaManager:hideAreaItemById(TipAreaConst.AREAS.A1, "CountDownLimitedTime", uniqueId)
end

function TipsCtrl:forceHideEdgeTipsAndAreaC(isHide)
	self:_setEdgeTipsAndAreaCHidden(TipAreaConst.UITipAreaFlag.AreaFlag_Force, HideReason.forceHide, isHide, TipAreaConst.EDGE_HIDE_AREA_C_ITEMS)
end

function TipsCtrl:suspendTipsForCutscene(isSuspend)
	isSuspend = isSuspend and true or false

	if self._cutsceneSuspended == true == isSuspend then
		return
	end

	self._cutsceneSuspended = isSuspend

	self:_setEdgeTipsAndAreaCHidden(TipAreaConst.UITipAreaFlag.AreaFlag_Cutscene, HideReason.cutscene, isSuspend, TipAreaConst.CUTSCENE_HIDE_AREA_C_ITEMS)
end

function TipsCtrl:_setEdgeTipsAndAreaCHidden(areaFlag, hideReason, isHide, cAreaItems)
	for _, edgeTip in ipairs(self.edgePriorities or EMPTY_TABLE) do
		edgeTip:setHideFlag(hideReason, isHide)
	end

	local areaShow = not isHide

	if self.areaManager then
		self.areaManager:setAreaVisibleWithFlag(TipAreaConst.AREAS.CI, areaFlag, areaShow)
		self.areaManager:setAreaVisibleWithFlag(TipAreaConst.AREAS.CF, areaFlag, areaShow)

		for _, itemKey in ipairs(cAreaItems or EMPTY_TABLE) do
			self.areaManager:setAreaItemVisibleWithFlag(TipAreaConst.AREAS.C, itemKey, areaFlag, areaShow)
		end
	end
end

function TipsCtrl:onHideAllUIChanged(info)
	if info == nil or not CUTSCENE_SUSPEND_HIDE_KEYS[info.key] then
		return
	end

	self:suspendTipsForCutscene(true)
end

function TipsCtrl:onRestoreAllUIChanged(info)
	if info == nil or not CUTSCENE_SUSPEND_HIDE_KEYS[info.key] then
		return
	end

	self:suspendTipsForCutscene(false)
end

function TipsCtrl:onStartCatchBoss()
	local bossMechanismTips = self.areaManager:getAreaItem(TipAreaConst.AREAS.A2, "BossMechanismTips")

	if bossMechanismTips then
		bossMechanismTips:clearAllData(true)
	end

	local bossMechanismProgress = self.areaManager:getAreaItem(TipAreaConst.AREAS.A2, "BossMechanismProgress")

	if bossMechanismProgress then
		bossMechanismProgress:clearAllData(true)
	end
end

function TipsCtrl:onSkillFreeAimChanged(enable)
	if not self.areaManager then
		return
	end

	local com = self.areaManager:getAreaItem(TipAreaConst.AREAS.CF, "ShortCutKey")

	if com then
		com:setHideFlag(TipAreaConst.TipItemFlag.ItemFlag_SkillFreeAim, enable)
	end
end

function TipsCtrl:showBattleRoomMechanismTips(text, duration)
	self:pushAreaManagerData({
		itemKey = "BattleRoomMechanismTips",
		areaType = TipAreaConst.AREAS.A2,
		text = text,
		duration = duration or 3
	})
end

function TipsCtrl:hideBattleRoomMechanismTips()
	if self.areaManager == nil then
		return
	end

	self.areaManager:hideAreaItem(TipAreaConst.AREAS.A2, "BattleRoomMechanismTips")
end

function TipsCtrl:clearAllBossMechanismTips()
	if self.areaManager == nil then
		return
	end

	local bossMechanismTips = self.areaManager:getAreaItem(TipAreaConst.AREAS.A2, "BossMechanismTips")

	if bossMechanismTips then
		bossMechanismTips:clearAllData(true)
	end
end

return TipsCtrl
