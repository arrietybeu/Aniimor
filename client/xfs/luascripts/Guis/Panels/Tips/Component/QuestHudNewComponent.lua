-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Component\\QuestHudNewComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Time = require("Core.Common.Time")
local Class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local Queue = require("Core.Framework.Queue")
local ClientTextUtils = require("Utils.ClientTextUtils")
local QuestUtils = require("GameApp.Quest.QuestUtils")
local QuestConst = require("Common.Const.QuestConst")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local BaseTipComponent = require("Guis.Panels.Tips.Component.BaseTipComponent")
local TipVisibilityHelper = require("Guis.Panels.Tips.Component.TipVisibilityHelper")
local HideReason = TipVisibilityHelper.HideReason
local QuestHudNewComponent = Class.LightClass("QuestHudNewComponent", BaseTipComponent)
local logger = LoggerManager.getLogger("QuestHudNewComponent")
local Const = require("Common.Const.Const")
local RedDotConst = require("Const.RedDotConst")
local SysConfigData = require("Data.sys_config_data")
local ItemSourceData = require("Data.item_source_data")
local CommonSwitch = require("Common.CommonSwitch")
local ClientUtils = require("Utils.ClientUtils")
local MessageName = require("Const.MessageName")
local QuestCommonUtils = require("Common.Utils.QuestCommonUtils")

QuestHudNewComponent.messages = {
	[MessageName.ON_PLAYER_ENTER_SPACE] = {
		"onEnterSpace",
		true
	},
	[MessageName.UI_ON_VISIBLE_CHANGE] = {
		"onUIVisibleChanged",
		true
	},
	[MessageName.QUEST_ON_TRACK_REACH] = {
		"onQuestTrackReach",
		true
	},
	[MessageName.MAIN_PLAYER_CATCH_MODE_CHANGE] = {
		"onCatchModeChanged",
		true
	},
	[MessageName.QUEST_ON_TRACE_CHANGE] = {
		"onQuestTraceChanged",
		true
	},
	[MessageName.FIRST_ENTER_TEAM] = {
		"onTeamChanged",
		true
	},
	[MessageName.LEAVE_TEAM] = {
		"onTeamChanged",
		true
	}
}

local questTracingShowTimeSpan = 1.2
local questObjcvShowTimeSpan = 1
local questObjcvFinedTimeSpan = 1.2
local questUntracingShowTimeSpan = 5
local curtainQuestShowTimeSpan = 1.2
local NEED_SWITCH_GROW_QUEST_ID = {}
local NEED_SWITCH_LEVEL_UP_QUEST_IDS = {}
local NEED_SWITCH_STORY_QUEST_IDS = {}
local NEED_SWITCH_STORY_QUEST_CONDITION = 10000
local NEED_SWITCH_STORY_QUEST_TIME = 1000
local LONG_PRESS_TIME = 0.25
local LONG_PRESS_DURATION = 0.55
local questObjcvStateTimeSpan = 0.45

local function getLongPressProgress(pressTime)
	return math.min(math.max((pressTime - LONG_PRESS_TIME) / (LONG_PRESS_DURATION - LONG_PRESS_TIME), 0), 1)
end

local GROW_REWARD_PENDING_TIMEOUT = 5
local GROW_TRACE_WAIT_INTERVAL = 0.2
local GROW_TRACE_WAIT_TIMEOUT = 2

function QuestHudNewComponent:findObjects()
	local container = self.transform:GetComponent("UContainer")

	self:initData()

	self.isVisible = true

	container:LoadDefaultUrlManually(function(widget)
		self:initObjectRef(widget)
		self:afterInitObjectRef()
	end)
end

function QuestHudNewComponent:initObjectRef(content)
	self.objectReference = content:GetComponent("ObjectReference")

	local questComs = self:getQuestComs(self.objectReference)

	self.rootUComponent = questComs.questHUDNewUComponent

	self:initQuestTabRefs(questComs)
	self:initQuestDetailsRefs(questComs)
	self:initAddonRefs(questComs)
	self:initProgressPressRef()

	self.tipsMainUButton = questComs.tipsMainUButton
	self.tipsBranchUButton = questComs.tipsBranchUButton
	self.tipsQuestUButton = questComs.tipsQuestUButton
end

function QuestHudNewComponent:initQuestTabRefs(questComs)
	self.questTabStateObjectReference = self:getQuestTabStateItemComs(questComs.questTabStateObjectReference)
	self.questTabStateUComponent = self.questTabStateObjectReference.rootUComponent
	self.questTabTextNameUSDFText = self.questTabStateObjectReference.textNameUSDFText

	local questTabObjectReference = self:getQuestTabComs(questComs.questTabObjectReference)

	self.pageList = questTabObjectReference.listUList
	self.switchPageKey = questTabObjectReference.keyHotKeyContent
	self.switchPageObjectReference = self.switchPageKey.transform:GetComponent("ObjectReference")
end

function QuestHudNewComponent:initQuestDetailsRefs(questComs)
	local mainDetailsObjectReference = self:getQuestDetailsItemComs(questComs.mainDetailsObjectReference)

	self.storyTracingList = mainDetailsObjectReference.questListUList
	self.clickStoryHintUButton = mainDetailsObjectReference.clickHintBtnUButton
	self.curtainQuestButton = mainDetailsObjectReference.questTitleUComponent

	local branchDetailsObjectReference = self:getQuestDetailsItemComs(questComs.branchDetailsObjectReference)

	self.growTracingList = branchDetailsObjectReference.questListUList
	self.clickGrowHintUButton = branchDetailsObjectReference.clickHintBtnUButton
	self.growTitleQuestButton = branchDetailsObjectReference.questTitleUComponent

	local questDetailsObjectReference = self:getQuestDetailsItemComs(questComs.questDetailsObjectReference)

	self.questTracingList = questDetailsObjectReference.questListUList
	self.clickQuestHintUButton = questDetailsObjectReference.clickHintBtnUButton
	self.questTitleQuestButton = questDetailsObjectReference.questTitleUComponent
end

function QuestHudNewComponent:initAddonRefs(questComs)
	self.questTabStateItemComs = self:getQuestTabStateItemComs(questComs.addonTabStateObjectReference)
	self.questAddTabStateUComponent = self.questTabStateItemComs.rootUComponent
	self.questAddTextNameUSDFText = self.questTabStateItemComs.textNameUSDFText
	self.questTabItemComs = self:getQuestTabComs(questComs.addonTabObjectReference)

	local questDetailsItemComs = self:getQuestDetailsItemComs(questComs.addonDetailsObjectReference)

	self.untracingQuestList = questDetailsItemComs.questListUList
	self.untraceBtnUButton = questDetailsItemComs.clickHintBtnUButton
	self.unTrackPopUButton = questDetailsItemComs.questTitleUComponent

	local unTrackTabObjectReference = self:getQuestTabComs(questComs.addonTabObjectReference)

	self.unTrackPageList = unTrackTabObjectReference.listUList
end

function QuestHudNewComponent:initProgressPressRef()
	self.progressPresss = {}
	self.aiProgressPresss = {}
	self.keyProgressPressUContainer = self.switchPageObjectReference:GetRefValue("progressPressContainerUContainer")

	self.keyProgressPressUContainer:SetActive(true)

	if self.keyProgressPressUContainer then
		self.keyProgressPressUContainer:LoadDefaultUrlManually(function()
			self.keyProgressPressComponent = self.keyProgressPressUContainer.content

			self.keyProgressPressComponent:ProgressToValue(0, nil, 0)
			table.insert(self.progressPresss, self.keyProgressPressComponent)

			if pg.game.input:isUsingGamepad() then
				self.keyProgressPressComponent.gameObject:SetActiveEx(true)
			else
				self.keyProgressPressComponent.gameObject:SetActiveEx(false)
			end
		end)
	end
end

local cachesDirty = false
local questComs = {}

function QuestHudNewComponent:getQuestComs(btn)
	if questComs[btn] == nil then
		local coms = {}
		local oRe = btn:GetComponent("ObjectReference")

		coms.questHUDNewUComponent = oRe:GetRefValue("questHUDNewUComponent")
		coms.questTabStateObjectReference = oRe:GetRefValue("questTabStateObjectReference")
		coms.questTabObjectReference = oRe:GetRefValue("questTabObjectReference")
		coms.mainDetailsObjectReference = oRe:GetRefValue("mainDetailsObjectReference")
		coms.tipsMainUButton = oRe:GetRefValue("tipsMainUButton")
		coms.branchDetailsObjectReference = oRe:GetRefValue("branchDetailsObjectReference")
		coms.tipsBranchUButton = oRe:GetRefValue("tipsBranchUButton")
		coms.questDetailsObjectReference = oRe:GetRefValue("questDetailsObjectReference")
		coms.tipsQuestUButton = oRe:GetRefValue("questTipsBranchUButton")
		coms.addonTabStateObjectReference = oRe:GetRefValue("addonTabStateObjectReference")
		coms.addonTabObjectReference = oRe:GetRefValue("addonTabObjectReference")
		coms.addonDetailsObjectReference = oRe:GetRefValue("addonDetailsObjectReference")
		questComs[btn] = coms
		cachesDirty = true
	end

	return questComs[btn]
end

local questTabStateItemComs = {}

function QuestHudNewComponent:getQuestTabStateItemComs(btn)
	if questTabStateItemComs[btn] == nil then
		local coms = {}
		local oRe = btn:GetComponent("ObjectReference")

		coms.rootUComponent = oRe:GetRefValue("rootUComponent")
		coms.panelAnimation = oRe:GetRefValue("panelAnimation")
		coms.textNameUSDFText = oRe:GetRefValue("textNameUSDFText")
		questTabStateItemComs[btn] = coms
	end

	return questTabStateItemComs[btn]
end

local questTabItemComs = {}

function QuestHudNewComponent:getQuestTabComs(btn)
	if questTabItemComs[btn] == nil then
		local coms = {}
		local oRe = btn:GetComponent("ObjectReference")

		coms.rootTabAnimation = oRe:GetRefValue("rootTabAnimation")
		coms.listUList = oRe:GetRefValue("listUList")
		coms.keyObjectReference = oRe:GetRefValue("keyObjectReference")
		coms.keyHotKeyContent = oRe:GetRefValue("keyHotKeyContent")
		questTabItemComs[btn] = coms
		cachesDirty = true
	end

	return questTabItemComs[btn]
end

local questIconComs = {}

function QuestHudNewComponent:getQuestIconComs(btn)
	if questIconComs[btn] == nil then
		local coms = {}
		local oRe = btn:GetComponent("ObjectReference")

		coms.btn = btn
		coms.iconAnimation = oRe:GetRefValue("iconAnimation")
		coms.iconUImage = oRe:GetRefValue("iconUImage")
		coms.playIconUImage = oRe:GetRefValue("playIconUImage")
		coms.iconSelUImage = oRe:GetRefValue("iconSelUImage")
		coms.line = oRe:GetRefValue("lineUWidget")
		questIconComs[btn] = coms
		cachesDirty = true
	end

	return questIconComs[btn]
end

local questDetailsItemComs = {}

function QuestHudNewComponent:getQuestDetailsItemComs(btn)
	if questDetailsItemComs[btn] == nil then
		local coms = {}
		local oRe = btn:GetComponent("ObjectReference")

		coms.rootUComponent = oRe:GetRefValue("rootObj")
		coms.questListUList = oRe:GetRefValue("questListUList")
		coms.clickHintBtnUButton = oRe:GetRefValue("clickHintBtnUButton")
		coms.questTitleUComponent = oRe:GetRefValue("questTitleUComponent")
		questDetailsItemComs[btn] = coms
	end

	return questDetailsItemComs[btn]
end

local questTitleNewItemComs = {}

function QuestHudNewComponent:getQuestTitleNewItemComs(btn)
	if questTitleNewItemComs[btn] == nil then
		local coms = {}
		local oRe = btn:GetComponent("ObjectReference")

		coms.btn = btn
		coms.keyHotKeyContent = oRe:GetRefValue("keyHotKeyContent")
		coms.textTitleUSDFText = oRe:GetRefValue("textTitleUSDFText")
		coms.closeTag = oRe:GetRefValue("closeTag")
		coms.btnClickUButton = oRe:GetRefValue("btnClickUButton")
		questTitleNewItemComs[btn] = coms
		cachesDirty = true
	end

	return questTitleNewItemComs[btn]
end

local trackQuestObjcvItemComs = {}

function QuestHudNewComponent:getTrackQuestObjcvItemComs(btn)
	if trackQuestObjcvItemComs[btn] == nil then
		local coms = {}
		local oRe = btn:GetComponent("ObjectReference")

		coms.contentTxt = oRe:GetRefValue("contentTxt")
		coms.btnPhoneUWidget = oRe:GetRefValue("btnPhoneUWidget")
		coms.btnPhoneUButton = oRe:GetRefValue("btnPhoneUButton")
		coms.rootAnimation = oRe:GetRefValue("rootAnimation")
		coms.scheduleUWidget = oRe:GetRefValue("scheduleUWidget")
		coms.progress = oRe:GetRefValue("progressUProgress")
		coms.tagPanelUWidget = oRe:GetRefValue("tagPanelUWidget")
		coms.textUSDFText = oRe:GetRefValue("textUSDFText")
		coms.textLevelUSDFText = oRe:GetRefValue("textLevelUSDFText")
		coms.btnClickUButton = oRe:GetRefValue("btnClickUButton")
		trackQuestObjcvItemComs[btn] = coms
		cachesDirty = true
	end

	return trackQuestObjcvItemComs[btn]
end

local questTipComs = {}

function QuestHudNewComponent:getQuestTipComs(btn)
	if questTipComs[btn] == nil then
		local coms = {}
		local oRe = btn:GetComponent("ObjectReference")

		coms.btnAgreeUButton = oRe:GetRefValue("btnRefuseUButton")
		coms.btnRefuseUButton = oRe:GetRefValue("btnAgreeUButton")
		coms.tipRootButton = oRe:GetRefValue("tipRootButton")
		coms.textUBaseText = oRe:GetRefValue("textUBaseText")
		coms.listKeyUList = oRe:GetRefValue("listKeyUList")
		questTipComs[btn] = coms
		cachesDirty = true
	end

	return questTipComs[btn]
end

local trackQuestHintComs = {}

function QuestHudNewComponent:getTrackQuestHintComs(btn)
	if trackQuestHintComs[btn] == nil then
		local coms = {}
		local oRe = btn:GetComponent("ObjectReference")

		coms.btn = btn
		coms.forbidText = oRe:GetRefValue("forbidText")
		coms.keyHotKeyContent = oRe:GetRefValue("keyHotKeyContent")
		coms.traceText = oRe:GetRefValue("traceText")
		coms.animation = oRe:GetRefValue("animation")
		coms.noDoTipText = oRe:GetRefValue("noDoTipText")
		trackQuestHintComs[btn] = coms
		cachesDirty = true
	end

	return trackQuestHintComs[btn]
end

function QuestHudNewComponent:onModuleEnableChanged(changeInfo)
	self.enableModule = changeInfo.enable

	self:setHideFlag(HideReason.enableModule, not self.enableModule)
end

function QuestHudNewComponent:initData()
	self.preFlagQuest = nil
	self.playCompleteAnim = true
	self.playSpecialGetRewardAnim = true
	self.isAddCurtainAccept = {}
	NEED_SWITCH_GROW_QUEST_ID = SysConfigData.NEED_SWITCH_GROW_QUEST_ID or NEED_SWITCH_GROW_QUEST_ID
	NEED_SWITCH_STORY_QUEST_IDS = SysConfigData.NEED_SWITCH_STORY_QUEST_IDS or NEED_SWITCH_STORY_QUEST_IDS
	NEED_SWITCH_LEVEL_UP_QUEST_IDS = SysConfigData.NEED_SWITCH_LEVEL_UP_QUEST_IDS or NEED_SWITCH_LEVEL_UP_QUEST_IDS
	NEED_SWITCH_STORY_QUEST_CONDITION = SysConfigData.NEED_SWITCH_STORY_QUEST_CONDITION or NEED_SWITCH_STORY_QUEST_CONDITION
	NEED_SWITCH_STORY_QUEST_TIME = SysConfigData.NEED_SWITCH_STORY_QUEST_TIME or NEED_SWITCH_STORY_QUEST_TIME
	self.showTab = self:getValidPageType(pg.game.quest:getCurTab())
	self.curSelIndex = 1
	self.questUntracingQueue = Queue.new(10)
	self.questStoryCurtainQueue = Queue.new(50)
	self.questStoryTracingQueue = Queue.new(50)
	self.questGrowTitleQueue = Queue.new(50)
	self.questGrowTracingQueue = Queue.new(50)
	self.questTaskTitleQueue = Queue.new(50)
	self.questTaskTracingQueue = Queue.new(50)
	self.visibleMap = {}
	self.refreshObjTimer = {}

	self:refreshAIIsInTipState(false)

	self.pressAITipsProgress = 0
	self._objChangeCooldowns = {}
	self._objChangePending = {}
	self._objChangeIdleCount = {}
	self._objChangeLastRendered = {}
	self.trackObjcvDataByPage = {}
	self.trackButtonByPage = {}
	self.trackHintDelayTypeByPage = {}
	self.trackHintDelayTimerByPage = {}
	self.isSwitchTracking = false
	self.playingTitleTip = nil
	self.pendingTitleTip = nil
	self.enableModule = pg.game:checkModuleEnable(ClientConst.ModuleKey.Quest)
	self.hideFlags = {}
	self.priorityFlag = HideReason.priorityBreakQuest

	self:initHideFlag()
end

function QuestHudNewComponent:resetFlag()
	self.clickSwitchCd = false
	self.firstShowUpdate = true
	self.playCompleteAnim = true
	self.playSpecialGetRewardAnim = true
	self.isAddCurtainAccept = {}
	self.playingTitleTip = nil
	self.pendingTitleTip = nil
end

function QuestHudNewComponent:afterInitObjectRef()
	self:bindTracingListRenderItem()
	self:bindSwitchPageKey()
	self:bindTitleForwardAndAiTips()
	self:initShowState()
end

function QuestHudNewComponent:bindTracingListRenderItem()
	function self.storyTracingList.luaRenderItem(objcvBtn, objcvIndex, objcvData)
		self:onRefreshStoryObjectivesItem(objcvBtn, objcvIndex, objcvData)
	end

	function self.growTracingList.luaRenderItem(objcvBtn, objcvIndex, objcvData)
		self:onRefreshGrowObjectivesItem(objcvBtn, objcvIndex, objcvData)
	end

	function self.questTracingList.luaRenderItem(objcvBtn, objcvIndex, objcvData)
		self:onRefreshQuestObjectivesItem(objcvBtn, objcvIndex, objcvData)
	end

	function self.pageList.luaRenderItem(button, index, data)
		self:onRefreshPageItem(button, index, data)
	end

	function self.unTrackPageList.luaRenderItem(button, index, data)
		self:onRefreshPageItem(button, index, data)
	end

	function self.untracingQuestList.luaRenderItem(button, index, data)
		self:onRefreshUntracingQuestItem(button, index, data)
	end
end

function QuestHudNewComponent:bindSwitchPageKey()
	local tabBoxUButtonBind = KeyBindingPro.GetOrAddKeyBindingByName(self.switchPageKey.gameObject, "switchPageBind")

	tabBoxUButtonBind.isVirtual = false
	tabBoxUButtonBind.priority = 10
	tabBoxUButtonBind.actionPath = "Hud/SwitchPage"

	function tabBoxUButtonBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			if pg.game.input:isUsingGamepad() then
				self.ctrl:killTimer(self.pressSwitchPageTimer)

				self.pressSwitchPageTimer = nil
				self.pressProgress = 0
				self.pressSwitchPageTimer = self.ctrl:startTimer(function()
					self:inPressing(self.keyProgressPressComponent, true)
				end, 0, true)
			else
				self.ctrl:killTimer(self.pressSwitchPageTimer)

				self.pressSwitchPageTimer = nil
				self.pressProgress = 0
				self.pressSwitchPageTimer = self.ctrl:startTimer(function()
					self:inPressing(self.keyProgressPressComponent, true, true)
				end, 0, true)
			end
		elseif inputInfo.phase == "Canceled" then
			if pg.game.input:isUsingGamepad() then
				self:endPress()

				self.pressProgress = 0
			else
				self:endPress()

				if self.pressProgress <= LONG_PRESS_TIME then
					self:clickSwitchPageByIndex()
				elseif self.keyProgressPressComponent.value >= 1 then
					self:onTabBoxLongPress()
				end

				self.pressProgress = 0
			end
		end

		return true
	end

	self.switchPageKey:SetHotKeyPaths("Hud/SwitchPage")
end

function QuestHudNewComponent:bindTitleForwardAndAiTips()
	self:bindTitleClickForward(self.curtainQuestButton, "clickStoryHintUButton")
	self:bindTitleClickForward(self.growTitleQuestButton, "clickGrowHintUButton")
	self:bindTitleClickForward(self.questTitleQuestButton, "clickQuestHintUButton")
	self:bindTitleClickForward(self.unTrackPopUButton, "untraceBtnUButton")
	self:aiTipBtn(self.tipsQuestUButton)

	function self.rootUComponent.luaTryChangePage(controllerName, pageIndex, lastPageIndex)
		if controllerName == "Tips" then
			self:onTipsPageChanged(pageIndex, lastPageIndex)
		end
	end
end

function QuestHudNewComponent:initShowState()
	self:clearRunningList()
	self:showQuest()
	self:refreshCheckShowState()
	self:onUpdate()
	self:setFirstShowUpdate(true)

	if self.keyProgressPressComponent ~= nil then
		self.keyProgressPressComponent.gameObject:SetActiveEx(pg.game.input:isUsingGamepad())
		self.keyProgressPressComponent:ProgressToValue(0, nil, 0)
	end

	self:refreshSwitchKeyVisible()
end

function QuestHudNewComponent:bindTitleClickForward(titleBtn, hintButtonField)
	if not titleBtn then
		return
	end

	local titleComs = self:getQuestTitleNewItemComs(titleBtn)

	if not titleComs then
		return
	end

	self:setupHintForward(titleComs.btnClickUButton, function()
		return self[hintButtonField]
	end)
end

function QuestHudNewComponent:bindObjectiveClickForward(objcvBtn, hintButtonField)
	local objectComs = self:getTrackQuestObjcvItemComs(objcvBtn)

	if not objectComs then
		return
	end

	self:setupHintForward(objectComs.btnClickUButton, function()
		return self[hintButtonField]
	end)
end

function QuestHudNewComponent:setupHintForward(forwardButton, getHintButton)
	if not forwardButton then
		return
	end

	function forwardButton.luaClick()
		if not pg.global.ui.uiMgr:CheckIsMobileInteract() then
			return
		end

		local hintButton = getHintButton()

		if not hintButton or not NotNil(hintButton) or not hintButton.gameObject.activeSelf then
			return
		end

		if hintButton.luaClick and hintButton.OnClickSimulate then
			hintButton:OnClickSimulate()
		end
	end
end

function QuestHudNewComponent:aiTipBtn(aitipBtn)
	local coms = self:getQuestTipComs(aitipBtn)

	if not coms then
		return
	end

	function coms.btnAgreeUButton.luaClick()
		self:onClickTipBtn(true)
	end

	function coms.btnRefuseUButton.luaClick()
		self:onClickTipBtn(false)
	end

	function coms.listKeyUList.luaRenderItem(button, objcvIndex, data)
		self:onRenderAiTipsKeyItem(coms, button, objcvIndex, data)
	end

	local tipsKeyList = self:getTipsListKeyList()

	coms.listKeyUList:SetList(tipsKeyList)
	ClientTextUtils.setText(coms.textUBaseText, pg.getGameString("QUEST_AI_TRACK_TIPS_TEXT"))
end

function QuestHudNewComponent:onRenderAiTipsKeyItem(coms, button, objcvIndex, data)
	local oRe = button:GetComponent("ObjectReference")
	local keyBinding = button:GetComponent("KeyBindingPro")
	local keyHotKeyContent = oRe:GetRefValue("keyHotKeyContent")
	local btnTipsUText = oRe:GetRefValue("btnTipsUText")
	local progressPressContainerUContainer = oRe:GetRefValue("progressPressContainerUContainer")

	if keyHotKeyContent and btnTipsUText then
		keyHotKeyContent:SetHotKeyPaths(data.path)
		ClientTextUtils.setText(btnTipsUText, data.text)
	end

	if keyBinding then
		keyBinding.actionPath = data.path
		keyBinding.priority = 11

		if objcvIndex == 0 then
			self:bindAiTipsCloseKeyTrigger(keyBinding, coms, data, progressPressContainerUContainer)
		else
			function keyBinding.luaTrigger(inputInfo)
				if inputInfo.phase == "Performed" then
					self:onClickTipBtn(true)
				end
			end
		end
	end
end

function QuestHudNewComponent:bindAiTipsCloseKeyTrigger(keyBinding, coms, data, progressPressContainerUContainer)
	function keyBinding.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			if pg.game.input:isUsingGamepad() then
				self:startPressAITips(coms)
			end
		elseif inputInfo.phase == "Canceled" then
			if pg.game.input:isUsingGamepad() then
				if self.pressAITipsProgress <= LONG_PRESS_TIME then
					pg.game.input:triggerWaitAction(inputInfo.inputControl, {
						data.path
					})
				end

				self:endPressAITips(coms)
			else
				self:onClickTipBtn(false)
			end
		end

		return false
	end

	if progressPressContainerUContainer then
		progressPressContainerUContainer:SetActive(true)
		progressPressContainerUContainer:LoadDefaultUrlManually(function()
			coms.aiKeyProgressPressComponent = progressPressContainerUContainer.content

			coms.aiKeyProgressPressComponent:ProgressToValue(0, nil, 0)
			self:registerAITipsProgress(coms.aiKeyProgressPressComponent)
			self:refreshAITipsProgressActive()
		end)
	end
end

function QuestHudNewComponent:startPressAITips(coms)
	self:endPress()
	self.ctrl:killTimer(self.pressAITipsTimer)

	self.pressAITipsTimer = nil
	self.pressAITipsProgress = 0
	self.pressAITipsTimer = self.ctrl:startTimer(function()
		if not pg.game.input:isUsingGamepad() then
			self:endPressAITips(coms)

			return
		end

		self.pressAITipsProgress = self.pressAITipsProgress + Time.unscaledDeltaTime

		if coms.aiKeyProgressPressComponent then
			if self.pressAITipsProgress > LONG_PRESS_TIME then
				coms.aiKeyProgressPressComponent.gameObject:SetActiveEx(true)
				coms.aiKeyProgressPressComponent:ProgressToValue(getLongPressProgress(self.pressAITipsProgress), nil, 0)
			end

			if self.pressAITipsProgress >= LONG_PRESS_DURATION then
				self:onClickTipBtn(false)
				self:endPressAITips(coms)
			end
		end
	end, 0, true)
end

function QuestHudNewComponent:getTipsListKeyList()
	return {
		{
			path = "Hud/TrackCloseSpecial",
			text = pg.getGameString("QUEST_UNTRACK_TIPS_TEXT")
		},
		{
			path = "Hud/TrackOpenSpecial",
			text = pg.getGameString("QUEST_TRACK_TIPS_TEXT")
		}
	}
end

function QuestHudNewComponent:clickSwitchPageBtn(pageType)
	if not self.clickSwitchCd then
		self.clickSwitchCd = true

		self:startTimer(function()
			self.clickSwitchCd = false
		end, 0.5)

		self.clickSwitchPage = true
		self.showTab = pageType

		self:onRefreshTracingTabPage()
		self:refreshAIIsInTipState(false)

		if self.rootUComponent then
			self.rootUComponent:TryChangePage("tips", 0)
		end

		pg.game.quest:removeAllQuestPathfinding()
	end
end

function QuestHudNewComponent:onRefreshTracingTabPage(noPlayVX)
	local flagQuest = self.visibleMap.visible and self.visibleMap.questVisible

	if flagQuest then
		QuestUtils.switchHudPageType(self.showTab, not noPlayVX)

		local questId = QuestUtils.getPageTraceQuestId(self.showTab)

		if not self:isGrowTab() then
			pg.game.quest:setCurSelectQuestId(questId)
		end

		self.playCompleteAnim = true

		self:refreshPageTabList()
		self:onSwitchPageTab()
		self:refreshQuestTitleByTab(questId)
		self:switchRefreshTraceList()
	end
end

function QuestHudNewComponent:onSwitchPageTab()
	if self.rootUComponent then
		local pageIndex = self.showTab - 1

		self.rootUComponent:TryChangePage("TaskTab", pageIndex)
		self.rootUComponent:TryChangePage("TrackType", 0)
	end
end

function QuestHudNewComponent:isGrowTab()
	return self.showTab == QuestConst.QUEST_HUD_PAGE_TYPE.GROW
end

function QuestHudNewComponent:isStoryTab()
	return self.showTab == QuestConst.QUEST_HUD_PAGE_TYPE.STORY
end

function QuestHudNewComponent:isQuestTab()
	return self.showTab == QuestConst.QUEST_HUD_PAGE_TYPE.QUEST
end

function QuestHudNewComponent:setShowState(state)
	self.visibleMap.visible = state
end

function QuestHudNewComponent:checkIsRunning()
	return TipVisibilityHelper.checkIsRunning(self)
end

function QuestHudNewComponent:clearRunningList(force)
	if force then
		self:clearAllCaches()
	end
end

function QuestHudNewComponent:showQuest()
	self.visibleMap.questVisible = true

	self:onBaseVisibleChanged()
end

function QuestHudNewComponent:isShowingCurtainQuest()
	return self.visibleMap.visible and self.visibleMap.questVisible
end

function QuestHudNewComponent:playCompleteAnimFlag(flag)
	self.playCompleteAnim = flag
end

function QuestHudNewComponent:canRefreshOnVisibleChanged()
	return self.playCompleteAnim or not self.mainInterrupt
end

function QuestHudNewComponent:getValidPageType(pageType)
	for _, v in ipairs(QuestUtils.getTabPageList()) do
		if v.pageType == pageType then
			return pageType
		end
	end

	return QuestConst.QUEST_HUD_PAGE_TYPE.STORY
end

function QuestHudNewComponent:setFirstShowUpdate(flag)
	self.firstShowUpdate = flag

	local isSwitch = self.clickSwitchPage

	if flag and isSwitch then
		self.clickSwitchPage = false
	end

	self.showTab = self:getValidPageType(pg.game.quest:getCurTab())
	self.curSelIndex = QuestUtils.getIndexByPage(self.showTab)

	if self.isInTip and not self:isQuestTab() then
		self:refreshAIIsInTipState(false)
	end

	if self.rootUComponent then
		self.rootUComponent:TryChangePage("QuestState", 2)
	end

	self:onSwitchPageTab()
	self:refreshPageTabList()
end

function QuestHudNewComponent:backToHome()
	self:resetFlag()
	QuestUtils.switchHudPageType(QuestConst.QUEST_HUD_PAGE_TYPE.STORY)

	self.showTab = QuestConst.QUEST_HUD_PAGE_TYPE.STORY

	self:refreshAIIsInTipState(false)
end

function QuestHudNewComponent:checkShowState()
	local me = pg.me

	if me == nil then
		return false
	end

	if not self.isVisible then
		return false
	end

	if not pg.global.ui:checkUIShow(UIConst.UI_ID_HUD_V2) then
		return false
	end

	return true
end

function QuestHudNewComponent:onUpdate()
	if self.objectReference == nil then
		return
	end

	if not self:updateHudVisibleFlag() then
		return
	end

	if self.preFlagQuest == false then
		return
	end

	self:refreshTracingAndTips()
end

function QuestHudNewComponent:updateHudVisibleFlag()
	local hudVisible = pg.global.ui:checkUIShow(UIConst.UI_ID_HUD_V2)

	self:setHideFlag(HideReason.hudVisible, not hudVisible)

	local inScreenTransition = self:refreshScreenTransitionFlag()

	return hudVisible and not inScreenTransition
end

function QuestHudNewComponent:refreshScreenTransitionFlag()
	local inScreenTransition = TipVisibilityHelper.checkInScreenTransition()

	self:setHideFlag(HideReason.screenTransition, inScreenTransition)

	return inScreenTransition
end

function QuestHudNewComponent:refreshTracingAndTips()
	self:checkShowActiveTracingQuest()
	self:checkAITipState(self.preFlagQuest)
	self:checkShowStoryTitleQuest()
	self:checkShowGrowTitleQuest()
	self:checkShowQuestTitleQuest()
	self:checkShowUntracingQuest()
end

function QuestHudNewComponent:hideQuest()
	self.visibleMap.questVisible = false

	self:onBaseVisibleChanged()
end

function QuestHudNewComponent:tryResetQuestState(questId)
	self:resetFlag()
	self:clearInterruptState()

	if QuestUtils.isQuestOfQuestType(QuestUtils.getTracingStoryQuestId(), QuestConst.QUEST_TYPE.HOMELAND) and not self:isGrowTab() then
		self.showTab = QuestConst.QUEST_HUD_PAGE_TYPE.STORY
	end

	self:onRefreshTracingTabPage(true)
end

function QuestHudNewComponent:switchRefreshTraceList()
	if self:isStoryTab() then
		self:onShowStoryTracingQuest()
	elseif self:isGrowTab() then
		self:onShowGrowTracingQuest()
	elseif self:isQuestTab() then
		self:onShowQuestTracingQuest()
	end
end

function QuestHudNewComponent:checkAITipState(flagQuest)
	if not flagQuest then
		return
	end

	if not self:isCheckAITipState() and not self.isInTip and not self.isSwitchTracking and self:isQuestTab() and not ClientUtils.checkCondition(NEED_SWITCH_STORY_QUEST_CONDITION) and not pg.space:isHomeland() then
		self:refreshAIIsInTipState(true)
	end
end

function QuestHudNewComponent:refreshAIIsInTipState(flag)
	self.isInTip = flag

	self:refreshAITipShowTime()
	self:switchAITipState()
end

function QuestHudNewComponent:refreshAITipShowTime()
	self.markShowNoMainQuestTime = Time.realtimeSinceStartup
end

function QuestHudNewComponent:isCheckAITipState()
	if self.markShowNoMainQuestTime == nil then
		return false
	end

	return Time.realtimeSinceStartup - self.markShowNoMainQuestTime < NEED_SWITCH_STORY_QUEST_TIME
end

function QuestHudNewComponent:refreshSwitchKeyVisible()
	local flagQuest = self.visibleMap.visible and self.visibleMap.questVisible

	if not self.rootUComponent or not flagQuest then
		return
	end

	local ret, page = self.rootUComponent:TryGetCurrentPage("tips")
	local isMobile = pg.global.ui.uiMgr:CheckIsMobileInteract()
	local tabCount = #QuestUtils.getTabPageList()

	if isMobile or tabCount <= 1 then
		self.switchPageKey.gameObject:SetActiveEx(false)
	elseif page == 1 and pg.game.input:isUsingGamepad() then
		self.switchPageKey.gameObject:SetActiveEx(false)
	else
		self.switchPageKey.gameObject:SetActiveEx(true)
	end

	self:setProgressZero()
end

function QuestHudNewComponent:switchAITipState()
	local flagQuest = self.visibleMap.visible and self.visibleMap.questVisible

	if not self.rootUComponent or not flagQuest then
		return
	end

	if not self:isQuestTab() then
		self.isInTip = false
	end

	self.rootUComponent:TryChangePage("Tips", self.isInTip and 1 or 0)

	if self.isInTip then
		self._preAITipGrowVisible = self.clickGrowHintUButton and self.clickGrowHintUButton.gameObject.activeSelf
		self._preAITipQuestVisible = self.clickQuestHintUButton and self.clickQuestHintUButton.gameObject.activeSelf
		self._preAITipStoryVisible = self.clickStoryHintUButton and self.clickStoryHintUButton.gameObject.activeSelf

		pg.me:setSideQuestAiTip(true)
		self:showClickHindBtnByTab(false)
	else
		if self._preAITipGrowVisible then
			self:showGrowClickHindBtn(true)
		end

		if self._preAITipQuestVisible then
			self:showQuestClickHindBtn(true)
		end

		if self._preAITipStoryVisible then
			self:showStoryClickHindBtn(true)
		end
	end
end

function QuestHudNewComponent:onTipsPageChanged(pageIndex, lastPageIndex)
	self:refreshSwitchKeyVisible()
end

function QuestHudNewComponent:onClickTipBtn(isYes)
	self:refreshAIIsInTipState(false)

	if isYes then
		self:clickSwitchPageBtn(QuestConst.QUEST_HUD_PAGE_TYPE.STORY)
	end

	self.rootUComponent:TryChangePage("Tips", self.isInTip and 1 or 0)
end

function QuestHudNewComponent:onQuestStateChange(data)
	self:processQuestStateChange(data)
end

function QuestHudNewComponent:processQuestStateChange(data)
	local questData = QuestUtils.getQuestData(data.questId)

	if questData == nil then
		return
	end

	local questConfig = QuestUtils.getQuestConfig(data.questId)

	if questConfig == nil then
		return
	end

	local isVisible = QuestUtils.isQuestVisible(data.questId)

	if not isVisible then
		return
	end

	local isTracing = QuestUtils.isQuestTracing(data.questId)
	local isRootQuestTracing = QuestUtils.isRootQuestTracing(data.questId)
	local isCurtain = QuestUtils.isCurtainQuest(data.questId)
	local isClueQuest = QuestUtils.isQuestOfClueQuestType(data.questId)

	if questData.state == QuestConst.QUEST_STATE.UNRECEIVE then
		self:handleQuestUnReceive(data, questData, isTracing, isRootQuestTracing)
	elseif questData.state == QuestConst.QUEST_STATE.RECEIVED then
		self:handleQuestReceived(questData, questConfig, isTracing, isRootQuestTracing, isCurtain, isClueQuest, data)
	elseif questData.state == QuestConst.QUEST_STATE.COMPLETED then
		self:handleQuestCompleted(questData, questConfig, isCurtain, data)
	elseif questData.state == QuestConst.QUEST_STATE.SUBMITED then
		self:handleQuestSubmitted(questConfig, isTracing, isRootQuestTracing, isCurtain, data)
	elseif questData.state == QuestConst.QUEST_STATE.CLOSE then
		self:handleQuestClosed(questData, questConfig, isTracing, isRootQuestTracing, isCurtain, data)
	end
end

function QuestHudNewComponent:handleQuestUnReceive(data, questData, isTracing, isRootQuestTracing)
	local shouldRefreshRootQuest = isRootQuestTracing and (QuestUtils.isSubQuestManualClaimable(data.questId) or QuestUtils.isInQuestBlackList(data.questId))

	if isTracing or shouldRefreshRootQuest then
		local data1 = {
			isObjAdd = true,
			questId = data.questId,
			questData = questData
		}

		self:enQueueToTraceByPageType(data.questId, data1)
		self:refreshAIIsInTipState(false)
	end
end

function QuestHudNewComponent:enQueueToTraceByPageType(questId, data1)
	local pageType = QuestUtils.getPageType(questId)

	if QuestConst.QUEST_HUD_PAGE_TYPE.GROW == pageType then
		if self:isGrowTab() then
			if data1.refreshAll then
				data1.func = self.onShowGrowTracingQuest
				data1.owner = self
			end

			self:enQueueSafe(self.questGrowTracingQueue, data1)
		end
	elseif QuestConst.QUEST_HUD_PAGE_TYPE.QUEST == pageType then
		if self:isQuestTab() then
			if data1.refreshAll then
				data1.func = self.onShowQuestTracingQuest
				data1.owner = self
			end

			self:enQueueSafe(self.questTaskTracingQueue, data1)
		end
	elseif QuestConst.QUEST_HUD_PAGE_TYPE.STORY == pageType and self:isStoryTab() then
		if data1.refreshAll then
			data1.func = self.onShowStoryTracingQuest
			data1.owner = self
		end

		self:enQueueSafe(self.questStoryTracingQueue, data1)
	end
end

function QuestHudNewComponent:handleQuestReceived(questData, questConfig, isTracing, isRootQuestTracing, isCurtain, isClueQuest, data)
	if isTracing or isRootQuestTracing then
		local data1 = {
			isObjAdd = true,
			questId = data.questId,
			questData = questData
		}
		local pageType = QuestUtils.getPageType(data.questId)

		if QuestConst.QUEST_HUD_PAGE_TYPE.QUEST == pageType and self.pageList and pg.global.ui:checkUIShow(UIConst.UI_ID_HUD_V2) then
			self.pageList:SetList(QuestUtils.getTabPageList())
		end

		self:handleQuestReceivedByPage(questData, questConfig, data, data1, pageType, isCurtain)
		self:refreshAIIsInTipState(false)
	elseif isCurtain and not isClueQuest then
		local data2 = {
			playInterruptAnim = true,
			questId = data.questId,
			questData = QuestUtils.getQuestData(data.questId)
		}

		self:enQueueSafe(self.questUntracingQueue, data2)
	end
end

function QuestHudNewComponent:handleQuestReceivedByPage(questData, questConfig, data, data1, pageType, isCurtain)
	if QuestConst.QUEST_HUD_PAGE_TYPE.GROW == pageType then
		if self:isGrowTab() then
			if not QuestUtils.isParentQuest(data.questId) and not self.isHaveCanGetReward and QuestUtils.isSpecialTrainMainQuest(data.questId) then
				local data2 = {
					playSpecialTrainAnim = true,
					questId = data.questId,
					owner = self
				}

				self:enQueueSafe(self.questGrowTitleQueue, data2)

				self.playSpecialGetRewardAnim = false

				self:startTimer(function()
					self.playSpecialGetRewardAnim = true
				end, questObjcvFinedTimeSpan - 0.2)
			end

			if not self.isHaveCanGetReward and QuestUtils.isSpecialTrainMainQuest(data.questId) and questConfig.objectivesIDs ~= nil then
				data1.func = self.onShowGrowTracingQuest
				data1.owner = self

				self:enQueueSafe(self.questGrowTracingQueue, data1)
			end
		end
	elseif QuestConst.QUEST_HUD_PAGE_TYPE.QUEST == pageType then
		if self:isQuestTab() then
			if questConfig.objectivesIDs ~= nil and not isCurtain then
				self:enQueueSafe(self.questTaskTracingQueue, data1)
			end

			if isCurtain and (not self.isAddCurtainAccept[data.questId] or self.isAddCurtainAccept[data.questId] == nil) then
				self.isAddCurtainAccept[data.questId] = true

				local data2 = {
					playCurtainAcceptAnim = true,
					questId = data.questId,
					owner = self
				}

				self:enQueueSafe(self.questTaskTitleQueue, data2)
			end
		end
	elseif QuestConst.QUEST_HUD_PAGE_TYPE.STORY == pageType and self:isStoryTab() then
		if questConfig.objectivesIDs ~= nil and not isCurtain then
			self:enQueueSafe(self.questStoryTracingQueue, data1)
		end

		if isCurtain and not self.isAddCurtainAccept[data.questId] then
			self.isAddCurtainAccept[data.questId] = true

			local data2 = {
				playCurtainAcceptAnim = true,
				questId = data.questId,
				owner = self
			}

			self:enQueueSafe(self.questStoryCurtainQueue, data2)
		end
	end
end

function QuestHudNewComponent:enQueueCurtainInterruptFinish(questId, isCurtain, isFinish)
	if isCurtain and not QuestUtils.isQuestOfClueQuestType(questId) then
		local data = {
			playInterruptFinishAnim = true,
			questId = questId,
			questData = QuestUtils.getQuestData(questId),
			isFinishInterrupt = isFinish
		}

		self:enQueueSafe(self.questUntracingQueue, data)

		self.playCompleteAnim = false
	end
end

function QuestHudNewComponent:handleQuestSubmitted(questConfig, isTracing, isRootQuestTracing, isCurtain, data)
	if isTracing or isRootQuestTracing then
		local pageType = QuestUtils.getPageType(data.questId)

		if QuestConst.QUEST_HUD_PAGE_TYPE.GROW == pageType then
			self:handleQuestSubmittedGrow(data)
		elseif QuestConst.QUEST_HUD_PAGE_TYPE.QUEST == pageType then
			self:handleQuestSubmittedQuest(questConfig, data, isCurtain)
		elseif QuestConst.QUEST_HUD_PAGE_TYPE.STORY == pageType then
			self:handleQuestSubmittedStory(questConfig, data, isCurtain)
		end
	else
		self:enQueueCurtainInterruptFinish(data.questId, isCurtain, true)
	end

	pg.game.quest:removeAllQuestPathfinding()
end

function QuestHudNewComponent:isGrowRewardTrackLocked()
	return self.growPendingRewardQuestId ~= nil or self.growRewardTrackTimerId ~= nil or self.growTraceWaitTimerId ~= nil
end

function QuestHudNewComponent:markGrowRewardPending(questId)
	self:killTimer(self.growPendingRewardTimerId)

	self.growPendingRewardQuestId = questId
	self.growPendingRewardTimerId = self:startTimer(function()
		self:clearGrowRewardPending()
	end, GROW_REWARD_PENDING_TIMEOUT)
end

function QuestHudNewComponent:clearGrowRewardPending()
	self:killTimer(self.growPendingRewardTimerId)

	self.growPendingRewardTimerId = nil
	self.growPendingRewardQuestId = nil
end

function QuestHudNewComponent:ensureGrowTracingRefresh(questId)
	if questId == nil or questId <= 0 then
		return
	end

	if self.growTraceRefreshQuestId == questId then
		return
	end

	if self:queueContainsQuestId(self.questGrowTracingQueue, questId) then
		return
	end

	local refreshData = {
		refreshAll = true,
		questId = questId,
		func = self.onShowGrowTracingQuest,
		owner = self
	}

	self:enQueueSafe(self.questGrowTracingQueue, refreshData)
end

function QuestHudNewComponent:refreshGrowTracingWhenTraced(target, onNotTraced)
	if target == nil or target <= 0 then
		return
	end

	self:killTimer(self.growTraceWaitTimerId)

	self.growTraceWaitTimerId = nil

	if QuestUtils.getSecondTracingQuestId() == target then
		self:ensureGrowTracingRefresh(target)

		return
	end

	local deadline = Time.realSecondCache + GROW_TRACE_WAIT_TIMEOUT

	self.growTraceWaitTimerId = self:startTimer(function()
		local secTrace = QuestUtils.getSecondTracingQuestId()

		if secTrace == target or Time.realSecondCache >= deadline then
			self:killTimer(self.growTraceWaitTimerId)

			self.growTraceWaitTimerId = nil

			if secTrace == target then
				self:ensureGrowTracingRefresh(target)
			elseif onNotTraced ~= nil then
				onNotTraced()
			else
				self:ensureGrowTracingRefresh(secTrace)
			end
		end
	end, GROW_TRACE_WAIT_INTERVAL, true)
end

function QuestHudNewComponent:refreshGrowChapterItem()
	self.growTraceRefreshQuestId = nil

	if self:queueContainsQuestId(self.questGrowTracingQueue, 0) then
		return
	end

	local refreshData = {
		questId = 0,
		refreshAll = true,
		func = self.onShowGrowChapterItem,
		owner = self
	}

	self:enQueueSafe(self.questGrowTracingQueue, refreshData)
end

function QuestHudNewComponent:onShowGrowChapterItem()
	self:refreshQuestTitleByTab(QuestUtils.getSecondTracingQuestId())
	self:onShowGrowTracingQuest()
end

function QuestHudNewComponent:refreshGrowTracingWhenCleared()
	self:killTimer(self.growTraceWaitTimerId)

	self.growTraceWaitTimerId = nil

	if QuestUtils.getSecondTracingQuestId() <= 0 then
		self:refreshGrowChapterItem()

		return
	end

	local deadline = Time.realSecondCache + GROW_TRACE_WAIT_TIMEOUT

	self.growTraceWaitTimerId = self:startTimer(function()
		if QuestUtils.getSecondTracingQuestId() <= 0 or Time.realSecondCache >= deadline then
			self:killTimer(self.growTraceWaitTimerId)

			self.growTraceWaitTimerId = nil

			self:refreshGrowChapterItem()
		end
	end, GROW_TRACE_WAIT_INTERVAL, true)
end

function QuestHudNewComponent:handleQuestSubmittedGrow(data)
	local isParentQuest = QuestUtils.isParentQuest(data.questId)

	if self:isGrowTab() and not isParentQuest then
		self.isSpecialGetReward = true

		local data1 = {
			isFined = true,
			questId = data.questId,
			func = self.onShowGrowTracingQuest,
			owner = self
		}

		self:enQueueSafe(self.questGrowTracingQueue, data1)
	end

	self:handleGrowMainQuestTrack(data, isParentQuest)
	self:handleGrowBranchQuestTrack(data, isParentQuest)

	if QuestUtils.isQuestOfQuestType(data.questId, QuestConst.QUEST_TYPE.SPECIAL_TRAIN) and QuestUtils.isShowDoublePage() and isParentQuest and QuestUtils.isInStarTitleQuest() then
		local parentQuestId = QuestUtils.getParentQuestId(data.questId)

		if parentQuestId and parentQuestId > 0 and parentQuestId == QuestUtils.getSecondTracingQuestId() then
			self:startTimer(function()
				self:refreshQuestTitleByTab(parentQuestId)
			end, questObjcvFinedTimeSpan)
		end
	end
end

function QuestHudNewComponent:handleGrowMainQuestTrack(data, isParentQuest)
	if self:isGrowRewardTrackLocked() then
		return
	end

	if QuestUtils.isQuestOfQuestType(data.questId, QuestConst.QUEST_TYPE.SPECIAL_TRAIN) and QuestUtils.isShowDoublePage() and not isParentQuest and QuestUtils.isSpecialTrainMainQuest(data.questId) and QuestUtils.isParentSyncFinQuest(data.questId) then
		QuestUtils.manualTrackSecondTracingQuest()
	end
end

function QuestHudNewComponent:handleGrowBranchQuestTrack(data, isParentQuest)
	if self:isGrowRewardTrackLocked() then
		return
	end

	if not isParentQuest and not QuestUtils.isPromotionQuest(data.questId) and not QuestUtils.isSpecialTrainMainQuest(data.questId) then
		if QuestUtils.isInStarTitleQuest() and not QuestUtils.isChapterAdvance() then
			local parentQuestId = QuestUtils.getParentQuestId(data.questId)

			if parentQuestId and parentQuestId > 0 and parentQuestId == QuestUtils.getSecondTracingQuestId() then
				pg.me:traceQuest(parentQuestId, false)
			end
		elseif QuestUtils.isInStarTitleQuest() and QuestUtils.getInStarTitleQuestId() and not QuestUtils.isQuestSubmittedOrFinished(QuestUtils.getInStarTitleQuestId()) then
			if QuestUtils.isChapterAdvance() and QuestUtils.getInStarTitleQuestId() > 0 and QuestUtils.getInStarTitleQuestId() ~= QuestUtils.getSecondTracingQuestId() then
				pg.me:traceQuest(QuestUtils.getInStarTitleQuestId(), true)
			else
				QuestUtils.manualTrackSecondTracingQuest()
			end
		else
			QuestUtils.manualTrackSecondTracingQuest()
		end
	end
end

function QuestHudNewComponent:handleQuestSubmittedQuest(questConfig, data, isCurtain)
	if self:isQuestTab() and questConfig.objectivesIDs ~= nil and not isCurtain then
		local data1 = {
			isFined = true,
			questId = data.questId,
			func = self.onShowQuestTracingQuest,
			owner = self
		}

		self:enQueueSafe(self.questTaskTracingQueue, data1)
	end

	if isCurtain then
		local data1 = {
			refreshAll = true,
			questId = data.questId,
			func = self.onShowQuestTracingQuest,
			owner = self
		}

		self:enQueueSafe(self.questTaskTracingQueue, data1)
		self:enQueueCurtainInterruptFinish(data.questId, isCurtain, true)
	end
end

function QuestHudNewComponent:handleQuestSubmittedStory(questConfig, data, isCurtain)
	if self:isStoryTab() and questConfig.objectivesIDs ~= nil and not isCurtain then
		local data1 = {
			isFined = true,
			questId = data.questId,
			func = self.onShowStoryTracingQuest,
			owner = self
		}

		self:enQueueSafe(self.questStoryTracingQueue, data1)
	end

	self:enQueueCurtainInterruptFinish(data.questId, isCurtain, true)
end

function QuestHudNewComponent:handleQuestClosed(questData, questConfig, isTracing, isRootQuestTracing, isCurtain, data)
	if isTracing or isRootQuestTracing then
		local data1 = {
			isObjClose = true,
			questId = data.questId,
			questData = questData
		}
		local pageType = QuestUtils.getPageType(data.questId)

		if QuestConst.QUEST_HUD_PAGE_TYPE.GROW == pageType then
			if self:isGrowTab() and questConfig.objectivesIDs ~= nil then
				self:enQueueSafe(self.questGrowTracingQueue, data1)
			end
		elseif QuestConst.QUEST_HUD_PAGE_TYPE.QUEST == pageType then
			if self:isQuestTab() and questConfig.objectivesIDs ~= nil and not isCurtain then
				self:enQueueSafe(self.questTaskTracingQueue, data1)
			end
		elseif QuestConst.QUEST_HUD_PAGE_TYPE.STORY == pageType and self:isStoryTab() and questConfig.objectivesIDs ~= nil and not isCurtain then
			self:enQueueSafe(self.questStoryTracingQueue, data1)
		end
	end
end

function QuestHudNewComponent:handleQuestCompleted(questData, questConfig, isCurtain, data)
	local pageType = QuestUtils.getPageType(data.questId)
	local isManualCommit = QuestUtils.isQuestManualCommit(data.questId)
	local isMultiObjAndState = QuestUtils.isMultiObjAndState(data.questId, nil)
	local isSpecialTrainQuest = QuestUtils.isQuestOfQuestType(data.questId, QuestConst.QUEST_TYPE.SPECIAL_TRAIN)

	if not isManualCommit and not isMultiObjAndState and not isSpecialTrainQuest then
		return
	end

	if QuestConst.QUEST_HUD_PAGE_TYPE.GROW == pageType then
		if self:isGrowTab() and questConfig.objectivesIDs ~= nil then
			local data1 = {
				refreshAll = true,
				questId = data.questId,
				questData = questData,
				func = self.onShowGrowTracingQuest,
				owner = self
			}

			self:enQueueSafe(self.questGrowTracingQueue, data1)
		end
	elseif QuestConst.QUEST_HUD_PAGE_TYPE.STORY == pageType then
		if self:isStoryTab() and questConfig.objectivesIDs ~= nil and not isCurtain and (isManualCommit or isMultiObjAndState) then
			local data1 = {
				refreshAll = true,
				questId = data.questId,
				questData = questData,
				func = self.onShowStoryTracingQuest,
				owner = self
			}

			self:enQueueSafe(self.questStoryTracingQueue, data1)
		end
	elseif QuestConst.QUEST_HUD_PAGE_TYPE.QUEST == pageType and self:isQuestTab() and questConfig.objectivesIDs ~= nil and not isCurtain and (isManualCommit or isMultiObjAndState) then
		local data1 = {
			refreshAll = true,
			questId = data.questId,
			questData = questData,
			func = self.onShowQuestTracingQuest,
			owner = self
		}

		self:enQueueSafe(self.questTaskTracingQueue, data1)
	end

	pg.game.quest:removeAllQuestPathfinding()
end

function QuestHudNewComponent:onQuestObjectiveChanged(data)
	local cooldownKey = tostring(data.questId) .. "_" .. tostring(data.objectiveId)

	if self.curObjectives ~= nil then
		for i = 1, #self.curObjectives do
			local curObjcv = self.curObjectives[i]

			if curObjcv.questId == data.questId and curObjcv.objId == data.objectiveId then
				curObjcv.objData = QuestUtils.getQuestObjData(data.questId, data.objectiveId)

				local data1 = {
					isObjChange = true,
					questId = data.questId,
					objIndex = i - 1,
					objcvData = curObjcv,
					isObjFined = data.isFined
				}

				self:handleObjectiveChangeWithCooldown(self.storyTracingList, self.curObjectives, data1, cooldownKey)

				return
			end
		end
	end

	if self.curSecObjectives ~= nil then
		for i = 1, #self.curSecObjectives do
			local curObjcv = self.curSecObjectives[i]

			if curObjcv.questId == data.questId and curObjcv.objId == data.objectiveId then
				curObjcv.objData = QuestUtils.getQuestObjData(data.questId, data.objectiveId)

				local isMultiObjAndState = QuestUtils.isMultiObjAndState(curObjcv.questId, curObjcv.objId)
				local data1 = {
					isObjChange = true,
					questId = data.questId,
					objIndex = i - 1,
					objcvData = curObjcv,
					isObjFined = isMultiObjAndState and data.isFined or false,
					hudType = QuestConst.SPECIAL_QUEST_HUD_STATE.QUEST_TRACE
				}

				self:handleObjectiveChangeWithCooldown(self.growTracingList, self.curSecObjectives, data1, cooldownKey)

				return
			end
		end
	end

	if self.curThrObjectives ~= nil then
		for i = 1, #self.curThrObjectives do
			local curObjcv = self.curThrObjectives[i]

			if curObjcv.questId == data.questId and curObjcv.objId == data.objectiveId then
				curObjcv.objData = QuestUtils.getQuestObjData(data.questId, data.objectiveId)

				local data1 = {
					isObjChange = true,
					questId = data.questId,
					objIndex = i - 1,
					objcvData = curObjcv,
					isObjFined = data.isFined
				}

				self:handleObjectiveChangeWithCooldown(self.questTracingList, self.curThrObjectives, data1, cooldownKey)

				return
			end
		end
	end
end

function QuestHudNewComponent:handleObjectiveChangeWithCooldown(list, objectives, data1, cooldownKey)
	local isInCooldown = self._objChangeCooldowns[cooldownKey] ~= nil

	self._objChangeCooldowns[cooldownKey] = data1
	self._objChangeIdleCount[cooldownKey] = 0

	if isInCooldown then
		self._objChangePending[cooldownKey] = true

		self:refreshAIIsInTipState(false)

		return
	end

	self._objChangePending[cooldownKey] = false
	self._objChangeLastRendered[cooldownKey] = {
		isObjFined = data1.isObjFined,
		currentCnt = data1.objcvData.objData.currentCnt
	}

	self:onRefreshTracingQuestObj(list, objectives, data1)

	local objectivesField = list and self:getObjectivesFieldByList(list) or nil

	local function getLiveObjectives()
		return objectivesField and self[objectivesField] or objectives
	end

	local function clearCooldown()
		self._objChangeCooldowns[cooldownKey] = nil
		self._objChangePending[cooldownKey] = nil
		self._objChangeIdleCount[cooldownKey] = nil
		self._objChangeLastRendered[cooldownKey] = nil
	end

	local function onTick()
		if self._objChangePending[cooldownKey] then
			self._objChangePending[cooldownKey] = nil

			local cached = self._objChangeCooldowns[cooldownKey]
			local lastRendered = self._objChangeLastRendered[cooldownKey]
			local liveObjectives = getLiveObjectives()

			if self:resolveObjectiveIndex(liveObjectives, cached) == nil then
				clearCooldown()

				return
			end

			local changed = cached.isObjFined ~= lastRendered.isObjFined or cached.objcvData.objData.currentCnt ~= lastRendered.currentCnt

			if changed then
				self._objChangeLastRendered[cooldownKey] = {
					isObjFined = cached.isObjFined,
					currentCnt = cached.objcvData.objData.currentCnt
				}
				self._objChangeIdleCount[cooldownKey] = 0

				self:onRefreshTracingQuestObj(list, liveObjectives, cached)
				self:startTimer(onTick, questObjcvStateTimeSpan)
			else
				clearCooldown()
			end
		else
			local idle = (self._objChangeIdleCount[cooldownKey] or 0) + 1

			if idle >= 2 then
				clearCooldown()
			else
				self._objChangeIdleCount[cooldownKey] = idle

				self:startTimer(onTick, questObjcvStateTimeSpan)
			end
		end
	end

	self:startTimer(onTick, questObjcvStateTimeSpan)
	self:refreshAIIsInTipState(false)
end

function QuestHudNewComponent:onQuestComActionObjectiveChanged(data)
	local questData = QuestUtils.getQuestData(data.questId)

	if questData == nil then
		return
	end

	local isTracing = QuestUtils.isQuestTracing(data.questId)
	local isRootQuestTracing = QuestUtils.isRootQuestTracing(data.questId)

	if isTracing or isRootQuestTracing then
		local questConfig = QuestUtils.getQuestConfig(data.questId)

		if questConfig and questConfig.objectivesIDs ~= nil then
			local data1 = {
				refreshAll = true,
				questId = data.questId,
				newQuestId = data.questId,
				questData = questData,
				func = self.onShowStoryTracingQuest,
				owner = self
			}

			self:enQueueSafe(self.questStoryTracingQueue, data1)
		end
	end
end

function QuestHudNewComponent:onQuestTraceChange(data)
	if data.type == QuestConst.QUEST_TRACE_TYPE.STORY then
		self:onQuestTraceChangeStory(data)
	elseif data.type == QuestConst.QUEST_TRACE_TYPE.QUEST then
		self:onQuestTraceChangeQuest(data)
	elseif data.type == QuestConst.QUEST_TRACE_TYPE.SEC then
		self:onQuestTraceChangeSec(data)
	end
end

function QuestHudNewComponent:onQuestTraceChangeStory(data)
	self.isSwitchTracking = false

	local questData = data.questData

	if questData == nil then
		local emptyData = {
			questId = 0,
			isSwitchTrack = true,
			refreshAll = true,
			func = self.onShowStoryTracingQuest,
			owner = self
		}

		self:enQueueSafe(self.questStoryTracingQueue, emptyData)

		return
	end

	local questId = questData.configId
	local isCurtain = QuestUtils.isCurtainQuest(questId)

	if questData.state == QuestConst.QUEST_STATE.RECEIVED and isCurtain and self:isStoryTab() and not self.isAddCurtainAccept[questId] and not self:queueContainsQuestId(self.questStoryCurtainQueue, questId) and QuestUtils.getTracingStoryQuestId() == questId then
		self.isAddCurtainAccept[questId] = true

		local data1

		if pg.game.quest:getHideTransitionAni() then
			pg.game.quest:setHideTransitionAni(false)

			data1 = {
				refreshAll = true,
				questId = questId,
				owner = self
			}
		else
			data1 = {
				playCurtainAcceptAnim = true,
				questId = questId,
				owner = self
			}
		end

		self:enQueueSafe(self.questStoryCurtainQueue, data1)
	end

	local data1 = {
		isSwitchTrack = true,
		refreshAll = true,
		questId = questId,
		func = self.onShowStoryTracingQuest,
		owner = self
	}

	self:enQueueSafe(self.questStoryTracingQueue, data1)
end

function QuestHudNewComponent:onQuestTraceChangeQuest(data)
	self.isSwitchTracking = false

	local isCurtain = QuestUtils.isCurtainQuest(data.questData.configId)

	if data.questData.state == QuestConst.QUEST_STATE.RECEIVED and isCurtain and self:isQuestTab() and (not self.isAddCurtainAccept[data.questData.configId] or self.isAddCurtainAccept[data.questData.configId] == nil) and not self:queueContainsQuestId(self.questTaskTitleQueue, data.questData.configId) and QuestUtils.getTracingQuestId() == data.questData.configId then
		self.isAddCurtainAccept[data.questData.configId] = true

		local data1

		if pg.game.quest:getHideTransitionAni() then
			pg.game.quest:setHideTransitionAni(false)

			data1 = {
				refreshAll = true,
				questId = data.questData.configId,
				owner = self
			}
		else
			data1 = {
				playCurtainAcceptAnim = true,
				questId = data.questData.configId,
				owner = self
			}
		end

		self:enQueueSafe(self.questTaskTitleQueue, data1)
	end

	local data1 = {
		isSwitchTrack = true,
		refreshAll = true,
		questId = data.questData.configId,
		func = self.onShowQuestTracingQuest,
		owner = self
	}

	self:enQueueSafe(self.questTaskTracingQueue, data1)
end

function QuestHudNewComponent:onQuestTraceChangeSec(data)
	if self.isSpecialGetReward and data.isNew and not self:queueContainsQuestId(self.questGrowTitleQueue, data.questData.configId) and QuestUtils.getTracingStoryQuestId() == data.questData.configId then
		self.isSpecialGetReward = false

		local data1

		if pg.game.quest:getHideTransitionAni() then
			pg.game.quest:setHideTransitionAni(false)

			data1 = {
				refreshAll = true,
				questId = data.questData.configId,
				owner = self
			}
		else
			data1 = {
				playCurtainAcceptAnim = true,
				questId = data.questData.configId,
				owner = self
			}
		end

		self:enQueueSafe(self.questGrowTitleQueue, data1)

		self.playSpecialGetRewardAnim = false

		self:startTimer(function()
			self.playSpecialGetRewardAnim = true
		end, questObjcvFinedTimeSpan)
	end

	if data.isNew and QuestUtils.isParentQuest(data.questData.configId) then
		self.growTraceRefreshQuestId = data.questData.configId

		self:startTimer(function()
			self.markGrowObjAsNew = true

			local data = {
				refreshAll = true,
				questId = data.questData.configId,
				func = self.onShowGrowTracingQuest,
				owner = self
			}

			self:enQueueSafe(self.questGrowTracingQueue, data)

			self.growTraceRefreshQuestId = nil
		end, questObjcvFinedTimeSpan)

		if self.growPendingRewardQuestId == nil then
			self.isHaveCanGetReward = false
		end
	end
end

function QuestHudNewComponent:queueContainsQuestId(queue, questId)
	if queue:isEmpty() then
		return false
	end

	local size = queue:size()
	local index = queue.head + 1

	for i = 1, size do
		if index > queue.capacity then
			index = 1
		end

		local item = queue.queue[index]

		if item and item.questId == questId then
			return true
		end

		index = index + 1
	end

	return false
end

function QuestHudNewComponent:onQuestRunStateChanged(data)
	local questData = QuestUtils.getQuestData(data.questId)

	if questData == nil then
		return
	end

	local isTracing = QuestUtils.isQuestTracing(data.questId)
	local isRootQuestTracing = QuestUtils.isRootQuestTracing(data.questId)
	local isVisible = QuestUtils.isQuestVisible(data.questId)

	if not isTracing and not isVisible then
		return
	end

	if isTracing or isRootQuestTracing then
		local data1 = {
			refreshAll = true,
			questId = data.questId,
			questData = questData
		}

		self:enQueueToTraceByPageType(data.questId, data1)
	end
end

function QuestHudNewComponent:checkShowStoryTitleQuest()
	if self.questStoryCurtainQueue:isEmpty() or self:isShowingCurtainTitleQuest() then
		return
	end

	if not self.questUntracingQueue:isEmpty() then
		return
	end

	if not self.ctrl:checkUIVisible() then
		return
	end

	if not self.playCompleteAnim then
		return
	end

	local data = self.questStoryCurtainQueue:deQueue()

	self.curtainQuestShowTime = Time.realtimeSinceStartup

	if data then
		self.isAddCurtainAccept[data.questId] = false

		self:setQuestTitleName(self.curtainQuestButton, data.questId, data, {
			isCurtain = true
		})
		self:markPlayingTitleTip(self.questStoryCurtainQueue, "curtainQuestShowTime", data)
	end
end

function QuestHudNewComponent:isShowingCurtainTitleQuest()
	if self.curtainQuestShowTime == nil then
		return false
	end

	return Time.realtimeSinceStartup - self.curtainQuestShowTime < curtainQuestShowTimeSpan
end

function QuestHudNewComponent:setQuestTitleName(titleBtn, questId, data, config)
	config = config or {}

	local isCurtain = config.isCurtain or false
	local taskType

	if questId and questId > 0 then
		taskType = QuestUtils.getCurSideQuestShowType(questId)
	end

	local titleParams = {
		titleBtn = titleBtn,
		questId = questId,
		taskType = taskType and taskType.taskType or QuestUtils.getPageDefaultType(),
		getNameFunc = function()
			if not questId or questId == 0 then
				return QuestUtils.getEmptyTracingTitle(self.showTab)
			end

			return QuestUtils.getCurtainQuestName(questId)
		end,
		pathsFunc = function()
			return self:isGrowTab() and LuaUIUtils.getFuncActionPath(Const.FUNCTION_IDS.SPECIALTRAIN) or LuaUIUtils.getFuncActionPath(Const.FUNCTION_IDS.QUEST)
		end,
		supportInterruptFinishAnim = isCurtain or false
	}

	self:setTitleNameCommon(titleParams, data)
end

function QuestHudNewComponent:setSpecialTitleName(titleBtn, questId, data)
	local taskType = QuestConst.QUEST_TYPE.SPECIAL_TRAIN - 1
	local name

	if data and data.hudType and data.hudType ~= 0 then
		name = data.title
	else
		name = QuestUtils.getSpecialTrainQuestTitleName(questId)
	end

	if not name or name == "" then
		if not questId or questId == 0 then
			name = QuestUtils.getEmptyTracingTitle(QuestConst.QUEST_HUD_PAGE_TYPE.GROW)
		else
			name = QuestUtils.getCurChapterPromoteHudTitle()
		end
	end

	local titleParams = {
		supportInterruptFinishAnim = false,
		supportSpecialTrainAnim = true,
		titleBtn = titleBtn,
		questId = questId,
		taskType = taskType,
		getNameFunc = function()
			return name
		end,
		pathsFunc = function()
			return "Hud/OpenSpecialTrain"
		end
	}

	self:setTitleNameCommon(titleParams, data)
end

function QuestHudNewComponent:checkShowTracingQuest(force)
	self:checkShowTracingQuestCommon(QuestConst.QUEST_HUD_PAGE_TYPE.STORY, force, self.questStoryTracingQueue, "markShowQuestTime", self.storyTracingList, self.curObjectives, self._titleFuncShowTracing, self.onShowStoryTracingQuest, questTracingShowTimeSpan)
end

function QuestHudNewComponent:_titleFuncShowTracing(data)
	self:setQuestTitleName(self.curtainQuestButton, QuestUtils.getTracingStoryQuestId(), data, {
		isCurtain = true
	})
end

function QuestHudNewComponent:isShowingTracingQuest()
	return self:isShowingTracingQuestCommon("markShowQuestTime", questTracingShowTimeSpan)
end

function QuestHudNewComponent:_titleFuncGrowTitle(data)
	self:setSpecialTitleName(self.growTitleQuestButton, data.questId, data)
end

function QuestHudNewComponent:checkShowGrowTitleQuest()
	self:checkShowTitleQuestCommon(self.questGrowTitleQueue, "growCurtainQuestShowTime", true, true, self._titleFuncGrowTitle)
end

function QuestHudNewComponent:isShowingGrowTitleQuest()
	return self:isShowingTitleQuestCommon("growCurtainQuestShowTime")
end

function QuestHudNewComponent:checkShowGrowTracingQuest(force)
	self:checkShowTracingQuestCommon(QuestConst.QUEST_HUD_PAGE_TYPE.GROW, force, self.questGrowTracingQueue, "markShowSecondQuestTime", self.growTracingList, self.curSecObjectives, self._titleFuncGrowTracing, self.onShowGrowTracingQuest, questTracingShowTimeSpan + 0.2)
end

function QuestHudNewComponent:_titleFuncGrowTracing(data)
	self:setSpecialTitleName(self.growTitleQuestButton, QuestUtils.getSecondTracingQuestId(), data)
end

function QuestHudNewComponent:isShowingGrowTracingQuest()
	return self:isShowingTracingQuestCommon("markShowSecondQuestTime", questTracingShowTimeSpan + 0.2)
end

function QuestHudNewComponent:_titleFuncQuestTitle(data)
	self:setQuestTitleName(self.questTitleQuestButton, data.questId, data)
end

function QuestHudNewComponent:checkShowQuestTitleQuest()
	self:checkShowTitleQuestCommon(self.questTaskTitleQueue, "questTitleQuestShowTime", true, false, self._titleFuncQuestTitle)
end

function QuestHudNewComponent:isShowingQuestTitleQuest()
	return self:isShowingTitleQuestCommon("questTitleQuestShowTime")
end

function QuestHudNewComponent:checkShowQuestTracingQuest(force)
	self:checkShowTracingQuestCommon(QuestConst.QUEST_HUD_PAGE_TYPE.QUEST, force, self.questTaskTracingQueue, "markShowThirdQuestTime", self.questTracingList, self.curThrObjectives, self._titleFuncShowQuestTracing, self.onShowQuestTracingQuest, questTracingShowTimeSpan + 0.2)
end

function QuestHudNewComponent:_titleFuncShowQuestTracing(data)
	self:setQuestTitleName(self.questTitleQuestButton, QuestUtils.getPageTraceQuestId(QuestConst.QUEST_HUD_PAGE_TYPE.QUEST), data)
end

function QuestHudNewComponent:isShowingQuestTracingQuest()
	return self:isShowingTracingQuestCommon("markShowThirdQuestTime", questTracingShowTimeSpan + 0.2)
end

function QuestHudNewComponent:removeSubmittedObjectivesBeforeAdd(itemComs, objectives, newQuestId)
	local submittedObjectives = {}

	for i = #objectives, 1, -1 do
		local objective = objectives[i]
		local questState = objective.questId and QuestCommonUtils.getQuestState(pg.me, objective.questId) or nil
		local isQuestSubmitted = questState == QuestConst.QUEST_STATE.SUBMITED or questState == QuestConst.QUEST_STATE.CLOSE

		if objective.questId ~= newQuestId and isQuestSubmitted then
			submittedObjectives[#submittedObjectives + 1] = {
				isFined = true,
				questId = objective.questId,
				objId = objective.objId
			}
		end
	end

	for i = 1, #submittedObjectives do
		self:removeQuestObjective(itemComs, objectives, submittedObjectives[i])
	end
end

function QuestHudNewComponent:resolveObjectiveIndex(objectives, data)
	if objectives == nil or data == nil then
		return nil
	end

	local objId = data.objId

	if objId == nil and data.objcvData ~= nil then
		objId = data.objcvData.objId
	end

	for i = 1, #objectives do
		local objData = objectives[i]

		if objData ~= nil and objData.questId == data.questId and (objId == nil or objData.objId == objId) then
			return i - 1
		end
	end

	return nil
end

function QuestHudNewComponent:onRefreshTracingQuestObj(itemComs, objectives, data)
	if data.refreshAll and data.func then
		data.func(data.owner)
	elseif data.isObjChange then
		self:onRefreshTracingQuestObjChange(itemComs, objectives, data)
	elseif data.isObjFined then
		self:onRefreshTracingQuestObjFinished(itemComs, objectives, data)
	elseif data.isObjAdd then
		self:onRefreshTracingQuestObjAdd(itemComs, objectives, data)
	else
		self:onRefreshTracingQuestObjClose(itemComs, objectives, data)
	end
end

function QuestHudNewComponent:onRefreshTracingQuestObjChange(itemComs, objectives, data)
	if objectives == nil then
		return
	end

	local objIndex = self:resolveObjectiveIndex(objectives, data)

	if objIndex == nil then
		return
	end

	local objData = objectives[objIndex + 1]

	objData.isObjFined = data.isObjFined

	if data.isObjFined then
		objData.needPlayFinishAnim = true
	else
		objData.isFined = false
	end

	itemComs:RefreshElement(objIndex)
end

function QuestHudNewComponent:onRefreshTracingQuestObjFinished(itemComs, objectives, data)
	if objectives == nil then
		return
	end

	if data.objcvData and data.objcvData.isOr then
		for i = #objectives, 1, -1 do
			local objData = objectives[i]

			if objData.isOr then
				objectives[i].isObjFined = true

				itemComs:RefreshElement(i - 1)
			end
		end
	else
		local objIndex = self:resolveObjectiveIndex(objectives, data)

		if objIndex == nil then
			return
		end

		objectives[objIndex + 1].isObjFined = true

		itemComs:RefreshElement(objIndex)
	end
end

function QuestHudNewComponent:onRefreshTracingQuestObjAdd(itemComs, objectives, data)
	if objectives == nil then
		objectives = {}

		return
	end

	self:removeSubmittedObjectivesBeforeAdd(itemComs, objectives, data.questId)

	local newObjectives = QuestUtils.getReceivedQuestObjectives(data.questId, true)

	for i = 1, #newObjectives do
		local objData = newObjectives[i]

		objData.isNew = true
		objData.questState = QuestCommonUtils.getQuestState(pg.me, objData.questId)

		if not self:isContainsQuest(objectives, objData.questId, objData.objId, objData.questState, itemComs) then
			table.insert(objectives, objData)
			itemComs:AddElement(objData)
		end
	end
end

function QuestHudNewComponent:onRefreshTracingQuestObjClose(itemComs, objectives, data)
	if objectives == nil then
		objectives = {}

		return
	end

	for i = #objectives, 1, -1 do
		local objData = objectives[i]
		local matchSelf = objData.questId ~= nil and objData.questId == data.questId
		local matchParent = QuestUtils.getParentQuestId(objData.questId) == data.questId and data.isFined

		if matchSelf or matchParent then
			if data.objcvData ~= nil then
				objectives[i] = data.objcvData
			end

			if data.isObjClose then
				objectives[i].isObjClose = true
			end

			if data.isFined then
				objectives[i].isObjFined = true
			end

			itemComs:RefreshElement(i - 1)
		end
	end
end

function QuestHudNewComponent:getObjectivesFieldByList(objcvList)
	if objcvList == self.storyTracingList then
		return "curObjectives"
	elseif objcvList == self.questTracingList then
		return "curThrObjectives"
	elseif objcvList == self.growTracingList then
		return "curSecObjectives"
	elseif objcvList == self.untracingQuestList then
		return "curUntracingObjectives"
	end

	return nil
end

function QuestHudNewComponent:getTracingListAndObjectives(pageType)
	if pageType == QuestConst.QUEST_HUD_PAGE_TYPE.STORY then
		return self.storyTracingList, self.curObjectives
	elseif pageType == QuestConst.QUEST_HUD_PAGE_TYPE.GROW then
		return self.growTracingList, self.curSecObjectives
	elseif pageType == QuestConst.QUEST_HUD_PAGE_TYPE.QUEST then
		return self.questTracingList, self.curThrObjectives
	end
end

function QuestHudNewComponent:removeSubmittedQuestObjective(pageType, questId)
	local list, objectives = self:getTracingListAndObjectives(pageType)

	if not objectives then
		return
	end

	self:removeQuestObjective(list, objectives, {
		isFined = true,
		questId = questId
	})
end

function QuestHudNewComponent:removeQuestObjective(objcvList, objectives, data)
	if not data then
		return
	end

	local field = objcvList and self:getObjectivesFieldByList(objcvList) or nil
	local liveObjectives = field and self[field] or objectives

	if not liveObjectives then
		return
	end

	local function isTargetObjective(objective)
		if not objective or not objective.questId then
			return false
		end

		local isTargetQuest = objective.questId == data.questId or data.isFined and QuestUtils.getParentQuestId(objective.questId) == data.questId

		return isTargetQuest and (data.isFined or data.objId == nil or objective.objId == data.objId)
	end

	if objcvList then
		for i = objcvList.itemCount - 1, 0, -1 do
			local objcvListData = objcvList:GetData(i)

			if isTargetObjective(objcvListData) then
				objcvList:RemoveElement(i)
			end
		end
	end

	for i = #liveObjectives, 1, -1 do
		local objective = liveObjectives[i]

		if isTargetObjective(objective) then
			table.remove(liveObjectives, i)
		end
	end
end

function QuestHudNewComponent:onShowStoryTracingQuest(data)
	local params = {
		queue = self.questStoryTracingQueue,
		pageType = QuestConst.QUEST_HUD_PAGE_TYPE.STORY,
		getQuestFunc = function()
			return QuestUtils.getTracingStoryQuestId()
		end,
		refreshFunc = function(refreshData)
			self:onRefreshStoryTracingQuestItem(refreshData)
		end
	}

	self:onShowTracingQuestCommon(params, data)
end

function QuestHudNewComponent:onShowGrowTracingQuest(data)
	local params = {
		queue = self.questGrowTracingQueue,
		pageType = QuestConst.QUEST_HUD_PAGE_TYPE.GROW,
		getQuestFunc = function()
			return QuestUtils.getSecondTracingQuestId()
		end,
		refreshFunc = function(questId)
			self:onRefreshGrowTracingQuestItem(questId)
		end
	}

	self:onShowTracingQuestCommon(params, data)
end

function QuestHudNewComponent:onShowQuestTracingQuest(data)
	local params = {
		queue = self.questTaskTracingQueue,
		pageType = QuestConst.QUEST_HUD_PAGE_TYPE.QUEST,
		getQuestFunc = function()
			return QuestUtils.getTracingQuestId()
		end,
		refreshFunc = function(refreshData)
			self:onRefreshQuestTracingQuestItem(refreshData)
		end
	}

	self:onShowTracingQuestCommon(params, data)
end

function QuestHudNewComponent:onShowTracingQuestCommon(params, data)
	local hasQuestData = data ~= nil and data.questData ~= nil
	local curQuestId

	if hasQuestData then
		self.curQuest = data.questData

		if QuestUtils.isParentQuest(data.questData.configId) then
			self.subQuests = QuestUtils.getAllRecvSubQuests(data.questData.configId)
		else
			self.subQuests = {
				data.questData
			}
		end
	else
		curQuestId = params.getQuestFunc()
	end

	if hasQuestData and data.questData.state == QuestConst.QUEST_STATE.SUBMITED then
		-- block empty
	else
		local refreshData = {
			questData = hasQuestData and data.questData or QuestUtils.getQuestData(curQuestId),
			questState = hasQuestData and data.questData.state or nil,
			newQuestId = data and data.newQuestId or nil
		}

		if params.pageType == QuestConst.QUEST_HUD_PAGE_TYPE.GROW and curQuestId and curQuestId > 0 then
			params.refreshFunc(curQuestId)
		else
			params.refreshFunc(refreshData)
		end
	end
end

function QuestHudNewComponent:refreshQuestTitleByTab(questId)
	if self:isGrowTab() then
		if QuestUtils.isShowSpecialChapterItem() then
			local data = QuestUtils.getSpecialChapterObjectives()

			if data then
				self:setSpecialTitleName(self.growTitleQuestButton, questId, data[1])
			end
		else
			self:setSpecialTitleName(self.growTitleQuestButton, questId)
		end
	elseif self:isStoryTab() then
		self:setQuestTitleName(self.curtainQuestButton, questId, nil, {
			isCurtain = true
		})
	elseif self:isQuestTab() then
		self:setQuestTitleName(self.questTitleQuestButton, questId)
	end
end

function QuestHudNewComponent:enQueueSafe(queue, data)
	if queue:isFull() then
		queue:deQueue()
	end

	queue:enQueue(data)

	if queue == self.questStoryTracingQueue or queue == self.questGrowTracingQueue or queue == self.questTaskTracingQueue then
		self:startTracingQueueUpdate()
	end
end

function QuestHudNewComponent:getActiveTracingQueue()
	if self:isGrowTab() then
		return self.questGrowTracingQueue
	elseif self:isQuestTab() then
		return self.questTaskTracingQueue
	end

	return self.questStoryTracingQueue
end

function QuestHudNewComponent:checkShowActiveTracingQuest()
	if self:isGrowTab() then
		self:checkShowGrowTracingQuest()
	elseif self:isQuestTab() then
		self:checkShowQuestTracingQuest()
	else
		self:checkShowTracingQuest()
	end
end

function QuestHudNewComponent:startTracingQueueUpdate()
	if self.tracingQueueUpdateTimer then
		return
	end

	self.tracingQueueUpdateTimer = self:startTimer(function()
		local activeQueue = self:getActiveTracingQueue()

		if activeQueue:isEmpty() then
			self:killTimer(self.tracingQueueUpdateTimer)

			self.tracingQueueUpdateTimer = nil

			return
		end

		if self.objectReference == nil or not self:isShowingCurtainQuest() then
			return
		end

		self:checkShowActiveTracingQuest()
	end, 0.05, true)
end

function QuestHudNewComponent:setTitleNameCommon(params, data)
	local titleBtn = params.titleBtn
	local questTitleNewItemComs = self:getQuestTitleNewItemComs(titleBtn)

	if params.taskType then
		questTitleNewItemComs.btn:TryChangePage("TaskType", params.taskType)
	end

	if questTitleNewItemComs then
		self:setTitleNameText(params, questTitleNewItemComs, titleBtn)

		if data and data.playCurtainAcceptAnim then
			self.rootUComponent:TryChangePage("QuestState", 3)
		else
			self.rootUComponent:TryChangePage("QuestState", 2)
		end

		self:playTitleStateAnim(params, data, titleBtn)
	end
end

function QuestHudNewComponent:setTitleNameText(params, questTitleNewItemComs, titleBtn)
	local name = params.getNameFunc() or ""

	ClientTextUtils.setText(questTitleNewItemComs.textTitleUSDFText, name)

	if name ~= "" then
		titleBtn:SetActive(true)

		local paths = params.pathsFunc()

		if paths then
			questTitleNewItemComs.keyHotKeyContent:SetHotKeyPaths(paths)
		end

		questTitleNewItemComs.closeTag:SetActive(false)

		if params.questId and QuestUtils.hasCloseCondTimeToken(params.questId) then
			questTitleNewItemComs.closeTag:SetActive(true)
		end
	else
		titleBtn:SetActive(false)
	end
end

function QuestHudNewComponent:playTitleStateAnim(params, data, titleBtn)
	if not data then
		return
	end

	if data.playCurtainAcceptAnim then
		self:playTitleAnimCurtainAccept(params, titleBtn)
	elseif data.playCurtainFinishAnim then
		self:playTitleAnimCurtainFinish(params, titleBtn)
	elseif data.playSpecialTrainAnim and params.supportSpecialTrainAnim then
		self:playTitleAnimSpecialTrain(params, titleBtn)
	elseif data.playInterruptAnim then
		self:playTitleAnimInterrupt(params)
	elseif data.playInterruptFinishAnim and params.supportInterruptFinishAnim then
		self:playTitleAnimInterruptFinish(params, titleBtn)
	end
end

function QuestHudNewComponent:playTitleAnimCurtainAccept(params, titleBtn)
	curtainQuestShowTimeSpan = 2
	questTracingShowTimeSpan = 2

	self.questTabStateUComponent:TryChangePage("IconType", 1)
	self.questTabStateUComponent:TryChangePage("TaskType", params.taskType)
	ClientTextUtils.setText(self.questTabTextNameUSDFText, pg.getGameString("NEW_QUEST"))
	self.rootUComponent:TryChangePage("QuestState", 1)

	if params.refreshCallback then
		params.refreshCallback()
	end

	self:playTitleAnim("SFX_UI_Event_HUDQuest_SpecialAppearance", titleBtn, questTracingShowTimeSpan, true, nil)
end

function QuestHudNewComponent:playTitleAnimCurtainFinish(params, titleBtn)
	curtainQuestShowTimeSpan = 2
	questTracingShowTimeSpan = 2

	self.questTabStateUComponent:TryChangePage("IconType", 0)
	self.questTabStateUComponent:TryChangePage("TaskType", params.taskType)
	ClientTextUtils.setText(self.questTabTextNameUSDFText, pg.getGameString("DISPATCH_MAP_CONDITION_3"))
	self.rootUComponent:TryChangePage("QuestState", 0)
	self:playTitleAnim("SFX_UI_Event_HUDQuest_OverallCompleted", titleBtn, curtainQuestShowTimeSpan, true, nil)
end

function QuestHudNewComponent:playTitleAnimSpecialTrain(params, titleBtn)
	self.rootUComponent:TryChangePage("QuestStateSpecial", 2)
	self.rootUComponent:TryChangePage("QuestStateSpecial", 1)

	curtainQuestShowTimeSpan = 1.2
	questTracingShowTimeSpan = 1.2

	self:playTitleAnim("SFX_UI_Event_HUDQuest_SpecialAppearance", titleBtn, curtainQuestShowTimeSpan, false, function()
		curtainQuestShowTimeSpan = 1.1
		questTracingShowTimeSpan = 1.1
	end)
end

function QuestHudNewComponent:playTitleAnimInterrupt(params)
	self.questAddTabStateUComponent:TryChangePage("IconType", 1)
	self.questAddTabStateUComponent:TryChangePage("TaskType", params.taskType)
	ClientTextUtils.setText(self.questAddTextNameUSDFText, pg.getGameString("NEW_QUEST"))
	self.rootUComponent:TryChangePage("QuestState", 1)
	pg.game.audio:triggerEvent("SFX_UI_Event_HUDQuest_SpecialAppearance")
end

function QuestHudNewComponent:playTitleAnimInterruptFinish(params, titleBtn)
	curtainQuestShowTimeSpan = 1.2
	questTracingShowTimeSpan = 1.2

	self.questAddTabStateUComponent:TryChangePage("IconType", 0)
	self.questAddTabStateUComponent:TryChangePage("TaskType", params.taskType)
	ClientTextUtils.setText(self.questAddTextNameUSDFText, pg.getGameString("DISPATCH_MAP_CONDITION_3"))
	self.questTabStateUComponent:TryChangePage("IconType", 0)
	ClientTextUtils.setText(self.questTabTextNameUSDFText, pg.getGameString("DISPATCH_MAP_CONDITION_3"))
	self.rootUComponent:TryChangePage("QuestState", 1)
	self:playTitleAnim("SFX_UI_Event_HUDQuest_SpecialAppearance", titleBtn, curtainQuestShowTimeSpan, true, nil)
end

function QuestHudNewComponent:playTitleAnim(audioEvent, titleBtn, delayTime, hasCompleteAnim, onAfterDelay)
	pg.game.audio:triggerEvent(audioEvent)

	if hasCompleteAnim then
		self.titleAnimEndTimerId = self:startTimer(function()
			self.titleAnimEndTimerId = nil

			self.rootUComponent:TryChangePage("TitleState", 2)

			curtainQuestShowTimeSpan = 1.2
			questTracingShowTimeSpan = 1.2
		end, delayTime - 0.1)
	elseif onAfterDelay then
		self:startTimer(function()
			onAfterDelay()
		end, delayTime)
	end
end

function QuestHudNewComponent:setTrackHintCommon(button, hintCom, questId, isStoryTab, isQuestTab)
	local pageType = isStoryTab and QuestConst.QUEST_HUD_PAGE_TYPE.STORY or QuestConst.QUEST_HUD_PAGE_TYPE.QUEST
	local objcvData = self:getTrackObjcvData(pageType)

	if not objcvData then
		self:hideTrackHintButton(pageType, button)

		return
	end

	local ret, page = self.rootUComponent:TryGetCurrentPage("Tips")

	if page and page == 1 then
		return
	end

	local isEmpty = objcvData.isEmptyTracing and (isQuestTab or isStoryTab)

	if not questId or questId <= 0 then
		self:setTrackHintEmptyState(button, hintCom, pageType, isStoryTab, isQuestTab, objcvData, isEmpty)

		return
	end

	local ctx = self:buildTrackHintContext(questId, button, isStoryTab, isQuestTab, objcvData)

	self:showTrackHintByCtx(button, hintCom, pageType, isStoryTab, isQuestTab, ctx, isEmpty)
end

function QuestHudNewComponent:setTrackHintEmptyState(button, hintCom, pageType, isStoryTab, isQuestTab, objcvData, isEmpty)
	if isEmpty then
		self:showTrackHintBtn(isQuestTab, isStoryTab)
		button:TryChangePage("TrackType", 0)
		self:setTrackButton(pageType, button)

		function button.luaClick()
			self:openQuest()
		end

		local text = objcvData.hint or pg.getGameString("QUEST_TRACK_TEXT")

		ClientTextUtils.setText(hintCom.traceText, text)
		self:enableTraceQuestBinding(button, isQuestTab, isStoryTab)
		hintCom.keyHotKeyContent:SetHotKeyPaths("Hud/TrackOpenSpecial")
	else
		self:hideTrackHintButton(pageType, button)
	end
end

function QuestHudNewComponent:showTrackHintByCtx(button, hintCom, pageType, isStoryTab, isQuestTab, ctx, isEmpty)
	local shouldShow = ctx.isShowPathfinding or ctx.isShowPlayDialogue or ctx.isShowSourceBtn or ctx.isQuitTip or ctx.isReDoQuestComplete or ctx.isReceiveNpcTarget or isEmpty or ctx.isTimeTokenRestriction

	if isStoryTab then
		shouldShow = ctx.isShowPathfinding or ctx.isSwitchPageQuest or ctx.isLevelUpQuest or ctx.isShowPlayDialogue or ctx.isShowSourceBtn or ctx.isQuitTip or ctx.isReDoQuestComplete or ctx.isReceiveNpcTarget or ctx.isTimeTokenRestriction
	end

	if not shouldShow then
		if isStoryTab then
			self.traceStoryBinding = nil
		elseif isQuestTab then
			self.traceQuestBinding = nil
		end

		self:hideTrackHintButton(pageType, button)

		return
	end

	self:showTrackHintBtn(isQuestTab, isStoryTab)

	if ctx.isTimeTokenRestriction then
		button:TryChangePage("TrackType", 2)
	elseif ctx.isQuitTip then
		button:TryChangePage("TrackType", 1)
	else
		button:TryChangePage("TrackType", 0)
	end

	LuaUIUtils.setUIViewVisible(hintCom.keyHotKeyContent, not ctx.isQuitTip and not ctx.isTimeTokenRestriction)
	self:setTrackButton(pageType, button)

	function button.luaClick()
		self:handleTrackHintClick(ctx)
	end

	local text = self:getTrackHintText(ctx)

	if ctx.isTimeTokenRestriction then
		ClientTextUtils.setText(hintCom.noDoTipText, text)
	else
		ClientTextUtils.setText(ctx.isQuitTip and hintCom.forbidText or hintCom.traceText, text)
	end

	if not ctx.isTimeTokenRestriction then
		self:enableTraceQuestBinding(button, isQuestTab, isStoryTab)
		hintCom.keyHotKeyContent:SetHotKeyPaths("Hud/TrackOpenSpecial")
	end
end

function QuestHudNewComponent:buildTrackHintContext(questId, button, isStoryTab, isQuestTab, objcvData)
	local isQuitHomeland = QuestUtils.needQuitOtherHomeland(questId)
	local isShowPathfinding, _ = QuestUtils.canQuestShowPathfindingFlag(questId)
	local isShowPlayDialogue, dialogueId = QuestUtils.canShowPlayDialogue(questId)
	local isShowSourceBtn, sourceId = QuestUtils.canTraceItemSource(questId)
	local timeTokenId, timeTokenText

	if QuestUtils.isRunCondNotMet(questId) then
		timeTokenId, timeTokenText = QuestUtils.getRunCondTimeTokenInfo(questId)
	end

	return {
		questId = questId,
		button = button,
		isStoryTab = isStoryTab,
		isQuestTab = isQuestTab,
		isLevelUpQuest = table.contains(NEED_SWITCH_LEVEL_UP_QUEST_IDS, questId),
		isSwitchPageQuest = table.contains(NEED_SWITCH_GROW_QUEST_ID, questId),
		isShowPathfinding = isShowPathfinding,
		isShowPlayDialogue = isShowPlayDialogue,
		dialogueId = dialogueId,
		isShowSourceBtn = isShowSourceBtn,
		sourceId = sourceId,
		isQuitHomeland = isQuitHomeland,
		isQuitTip = QuestUtils.needQuitTeam(questId) or isQuitHomeland or QuestUtils.isInQuestBlackList(questId),
		isReDoQuestComplete = QuestUtils.isReDoQuestComplete(questId),
		isReceiveNpcTarget = objcvData and objcvData.isReceiveNpcTarget,
		isTimeTokenRestriction = timeTokenId ~= nil,
		timeTokenId = timeTokenId,
		timeTokenText = timeTokenText
	}
end

function QuestHudNewComponent:enableTraceQuestBinding(button, isQuestTab, isStoryTab)
	if isQuestTab then
		self.traceQuestBinding = self:addTraceQuestKeyBinding(button)
	elseif isStoryTab then
		self.traceStoryBinding = self:addTraceQuestKeyBinding(button)
	end

	local binding = isQuestTab and self.traceQuestBinding or self.traceStoryBinding

	binding.enabled = true
end

function QuestHudNewComponent:showTrackHintBtn(isQuestTab, isStoryTab)
	if isQuestTab then
		self:showQuestClickHindBtn(true)
	elseif isStoryTab then
		self:showStoryClickHindBtn(true)
	end
end

function QuestHudNewComponent:getTrackHintText(ctx)
	if ctx.isQuitTip then
		if QuestUtils.isInQuestBlackList(ctx.questId) then
			return string.match(pg.getGameString("QUEST_CANNOT_PROGRESS_TARGET_TEXT"), "%%s%s*(.+)")
		end

		return ctx.isQuitHomeland and pg.getGameString("QUEST_CANNOT_DO_IN_OTHER_HOME") or pg.getGameString("QUEST_CANNOT_DO_IN_OTHER_WORLD")
	elseif ctx.isSwitchPageQuest and ctx.isStoryTab then
		return pg.getGameString("QUEST_TRACK_GOTO_SPECIAL_TRAIN")
	elseif ctx.isLevelUpQuest and ctx.isStoryTab then
		return pg.getGameString("QUEST_TRACK_LEVEL_UP")
	elseif ctx.isShowPlayDialogue or ctx.isReDoQuestComplete then
		return pg.getGameString("QUEST_TRACK_PLAY_DIALOGUE")
	elseif ctx.isShowSourceBtn then
		return pg.getLocalizationText(ItemSourceData[ctx.sourceId].buttonTxt) or pg.getGameString("QUEST_TRACK_TEXT")
	elseif ctx.isTimeTokenRestriction then
		return ctx.timeTokenText
	end

	return pg.getGameString("QUEST_TRACK_TEXT")
end

function QuestHudNewComponent:handleTrackHintClick(ctx)
	if ctx.isTimeTokenRestriction then
		return
	elseif ctx.isQuitTip then
		if QuestUtils.isInQuestBlackList(ctx.questId) or QuestCommonUtils.getQuestState(pg.me, ctx.questId) == QuestConst.QUEST_STATE.UNRECEIVE then
			local tipsText = string.match(pg.getGameString("QUEST_CANNOT_PROGRESS_TARGET_TEXT"), "%%s%s*(.+)")

			ClientUtils.showBubbleMessageRaw(tipsText, 3)

			return
		end

		local tipsText = ctx.isQuitHomeland and pg.getGameString("QUEST_CANNOT_DO_IN_OTHER_HOME") or pg.getGameString("QUEST_CANNOT_DO_IN_OTHER_WORLD")

		ClientUtils.showBubbleMessageRaw(tipsText, 3)
	elseif ctx.isReceiveNpcTarget then
		QuestUtils.pathfindingToReceiveNpc(ctx.questId)
	elseif ctx.isReDoQuestComplete then
		local comActionDialogueId = QuestUtils.getComActionObjcvDialogueId(ctx.questId)

		if comActionDialogueId and comActionDialogueId > 0 then
			QuestUtils.tryPlayDialogueGraph(comActionDialogueId, ctx.questId)
		else
			pg.me:reDoQuestCompleteActions(ctx.questId)
		end
	elseif ctx.isSwitchPageQuest and ctx.isStoryTab then
		self:clickSwitchPageBtn(QuestConst.QUEST_HUD_PAGE_TYPE.GROW)
	elseif ctx.isLevelUpQuest and ctx.isStoryTab then
		pg.me:doEventByData({
			"appearHelp",
			{
				209
			}
		})
	elseif not ctx.isShowSourceBtn and ctx.isShowPathfinding then
		if not self.clickCD then
			QuestUtils.addQuestPathingNavEffect(ctx.questId)

			self.clickCD = true

			self:startTimer(function()
				self.clickCD = false
			end, curtainQuestShowTimeSpan)
		end
	elseif ctx.isShowPlayDialogue and ctx.dialogueId and ctx.dialogueId > 0 then
		pg.game.dialogue:playDialogueGraph(ctx.dialogueId)
	elseif ctx.isShowSourceBtn and ctx.sourceId and ctx.sourceId > 0 then
		local data = {
			clueSeekID = ctx.sourceId
		}

		table.merge(data, ItemSourceData[ctx.sourceId])
		LuaUIUtils.clueSeek(data, nil, ctx.button)
	end
end

function QuestHudNewComponent:checkShowTitleQuestCommon(queue, showTimeField, checkUIVisible, checkPlayAnim, titleFunc)
	if queue:isEmpty() or self:isShowingTitleQuestCommon(showTimeField) then
		return
	end

	if not self.questUntracingQueue:isEmpty() then
		return
	end

	if checkUIVisible and not self.ctrl:checkUIVisible() then
		return
	end

	if checkPlayAnim and not self.playSpecialGetRewardAnim then
		return
	end

	if not self.playCompleteAnim then
		return
	end

	local data = queue:deQueue()

	self[showTimeField] = Time.realtimeSinceStartup

	if data then
		titleFunc(self, data)
		self:markPlayingTitleTip(queue, showTimeField, data)
	end
end

function QuestHudNewComponent:isShowingTitleQuestCommon(showTimeField)
	if self[showTimeField] == nil then
		return false
	end

	return Time.realtimeSinceStartup - self[showTimeField] < curtainQuestShowTimeSpan
end

function QuestHudNewComponent:markPlayingTitleTip(queue, showTimeField, data)
	if data == nil or not data.playCurtainAcceptAnim then
		self.playingTitleTip = nil

		return
	end

	self.playingTitleTip = {
		queue = queue,
		showTimeField = showTimeField,
		data = data,
		startTime = Time.realtimeSinceStartup,
		duration = questTracingShowTimeSpan,
		endTimerId = self.titleAnimEndTimerId
	}
end

function QuestHudNewComponent:stashPlayingTitleTip()
	local tip = self.playingTitleTip

	self.playingTitleTip = nil

	if tip == nil then
		return
	end

	if Time.realtimeSinceStartup - tip.startTime >= tip.duration - 0.1 then
		return
	end

	self[tip.showTimeField] = nil
	self.pendingTitleTip = tip
end

function QuestHudNewComponent:tryReplayPendingTitleTip()
	local tip = self.pendingTitleTip

	self.pendingTitleTip = nil

	if tip == nil or tip.data == nil then
		return
	end

	local questId = tip.data.questId

	if questId == nil or questId <= 0 then
		return
	end

	if QuestCommonUtils.getQuestState(pg.me, questId) ~= QuestConst.QUEST_STATE.RECEIVED then
		return
	end

	if not self:isTitleTipQueueOfCurTab(tip.queue) then
		return
	end

	if self:queueContainsQuestId(tip.queue, questId) then
		return
	end

	if tip.endTimerId and self.titleAnimEndTimerId == tip.endTimerId then
		self:killTimer(tip.endTimerId)

		self.titleAnimEndTimerId = nil

		if self.rootUComponent then
			self.rootUComponent:TryChangePage("TitleState", 2)
		end

		curtainQuestShowTimeSpan = 1.2
		questTracingShowTimeSpan = 1.2
	end

	self[tip.showTimeField] = nil

	self:enQueueSafe(tip.queue, tip.data)
end

function QuestHudNewComponent:isTitleTipQueueOfCurTab(queue)
	if queue == self.questStoryCurtainQueue then
		return self:isStoryTab()
	elseif queue == self.questGrowTitleQueue then
		return self:isGrowTab()
	elseif queue == self.questTaskTitleQueue then
		return self:isQuestTab()
	end

	return false
end

function QuestHudNewComponent:checkShowTracingQuestCommon(pageType, force, queue, showTimeField, list, objectives, titleFunc, showFunc, timeSpan)
	if queue:isEmpty() then
		return
	end

	if self:isShowingTracingQuestCommon(showTimeField, timeSpan) and force == nil then
		return
	end

	local data = queue:deQueue()

	self[showTimeField] = Time.realtimeSinceStartup

	if data.isObjFined or data.isFined or data.isObjAdd or data.isObjClose or data.refreshAll or data.isSwitchTrack then
		if data.refreshAll and titleFunc and not QuestUtils.isShowSpecialChapterItem() then
			titleFunc(self, data)
			self.pageList:RefreshList()
		end

		if data.isObjAdd then
			local questState = QuestCommonUtils.getQuestState(pg.me, data.questId)

			if questState == QuestConst.QUEST_STATE.SUBMITED then
				return
			end
		end

		self:onRefreshTracingQuestObj(list, objectives, data)

		if data.isObjAdd then
			local lastData = queue:getFirst()

			if lastData ~= nil and lastData.isObjAdd then
				if pageType == QuestConst.QUEST_HUD_PAGE_TYPE.STORY then
					self:checkShowTracingQuest(true)
				elseif pageType == QuestConst.QUEST_HUD_PAGE_TYPE.GROW then
					self:checkShowGrowTracingQuest(true)
				elseif pageType == QuestConst.QUEST_HUD_PAGE_TYPE.QUEST then
					self:checkShowQuestTracingQuest(true)
				end
			end
		end
	else
		showFunc(self, data)
	end
end

function QuestHudNewComponent:isShowingTracingQuestCommon(showTimeField, timeSpan)
	if self[showTimeField] == nil then
		return false
	end

	return timeSpan > Time.realtimeSinceStartup - self[showTimeField]
end

function QuestHudNewComponent:showClickHindBtnCommon(button, flag, pageType)
	local isGrow = pageType == QuestConst.QUEST_HUD_PAGE_TYPE.GROW

	self:clearTrackHintDelayTimer(pageType)

	if not flag then
		self:setTrackButton(pageType, nil)
	end

	if not isGrow and flag and not self.playCompleteAnim then
		return
	end

	if self:getTrackHintDelayType(pageType) == 3 and flag then
		button:SetActive(false)

		self.trackHintDelayTimerByPage[pageType] = self:startTimer(function()
			self.trackHintDelayTimerByPage[pageType] = nil

			button:SetActive(flag)
			self:setTrackHintDelayType(pageType, 1)
		end, 0.15)
	else
		if flag then
			-- block empty
		end

		button:SetActive(flag)
	end
end

function QuestHudNewComponent:onRefreshTracingQuestItemCommon(data, pageType, objectivesField, listField, hintBtnField)
	if self:isQuestTab() and QuestUtils.getPageTraceQuestId(QuestConst.QUEST_HUD_PAGE_TYPE.QUEST) == 0 then
		self[objectivesField] = QuestUtils.getEmptyTracingText(QuestConst.QUEST_HUD_PAGE_TYPE.QUEST)
	elseif self:isStoryTab() and QuestUtils.getPageTraceQuestId(QuestConst.QUEST_HUD_PAGE_TYPE.STORY) == 0 then
		self[objectivesField] = QuestUtils.getEmptyTracingText(QuestConst.QUEST_HUD_PAGE_TYPE.STORY)
	else
		local questData = data.questData

		if questData == nil then
			return
		end

		local questId = questData.configId
		local questConfig = QuestUtils.getQuestConfig(questId)

		if questConfig == nil then
			return
		end

		local isQuestFined = questData.state == QuestConst.QUEST_STATE.COMPLETED

		if questData and (isQuestFined or questData.isObjFined) then
			self[objectivesField] = QuestUtils.getReceivedQuestObjectives(questData.configId)
		else
			self[objectivesField] = QuestUtils.getReceivedQuestObjectives(questData.configId, false)
		end
	end

	local objectives = self[objectivesField]
	local list = self[listField]

	self:refreshTrackHintList(pageType, list, objectives, self[hintBtnField])
end

function QuestHudNewComponent:onRefreshObjectivesItemCommon(objcvBtn, objcvIndex, objcvData, list, objectives, isGrow)
	if not objcvData then
		return
	end

	local pageType = self:getTrackHintPageTypeByList(list)
	local objectComs = self:getTrackQuestObjcvItemComs(objcvBtn)

	if not objectComs then
		return
	end

	self:bindObjectiveClickForward(objcvBtn, self:getHintButtonFieldByPage(pageType))

	local rootAnim = objectComs.rootAnimation

	if objcvData.isObjClose then
		self:onRefreshObjClose(objcvBtn, objcvData, list, objectives, pageType, rootAnim, isGrow)

		return
	end

	if objcvData.questId == nil or objcvData.questId == 0 then
		self:onRefreshObjEmpty(objcvBtn, rootAnim)

		return
	end

	local isMultiObjAndState = QuestUtils.isMultiObjAndState(objcvData.questId, objcvData.objId)

	if isMultiObjAndState then
		self:onRefreshObjMultiState(objcvBtn, objcvData, rootAnim)
	else
		self:onRefreshObjSingleState(objcvBtn, objcvData, list, objectives, pageType, rootAnim)
	end
end

function QuestHudNewComponent:playObjectiveAnimSequence(rootAnim, animName)
	UIUtils.PlayAnimations(rootAnim, {
		"VX_Node_QuestHUD_Text_In_Reset_2",
		animName
	})
end

function QuestHudNewComponent:onRefreshObjClose(objcvBtn, objcvData, list, objectives, pageType, rootAnim, isGrow)
	self:setTrackHintDelayType(pageType, 2)
	objcvBtn:TryChangePage("QuestType", 0)
	objcvBtn:TryChangePage("QuestState", 1)
	self:playObjectiveAnimSequence(rootAnim, "VX_Node_QuestHUD_Text_Out2")

	if isGrow then
		self:hideTrackHintButton(QuestConst.QUEST_HUD_PAGE_TYPE.GROW, self.clickGrowHintUButton)
	end

	self:startObjFinedRemoveTimer(objcvData, function()
		self:setTrackHintDelayType(pageType, 1)
		objcvBtn:TryChangePage("QuestState", 0)
		UIUtils.PlayAnimation(rootAnim, "VX_Node_QuestHUD_Text_In_Reset_2")
		self:removeQuestObjective(list, objectives, objcvData)
		self:restoreTrackHintToActiveObjcv(list)
	end)
end

function QuestHudNewComponent:onRefreshObjEmpty(objcvBtn, rootAnim)
	objcvBtn:TryChangePage("QuestState", 0)
	UIUtils.PlayAnimation(rootAnim, "VX_Node_QuestHUD_Text_In_Reset_2")
end

function QuestHudNewComponent:onRefreshObjMultiState(objcvBtn, objcvData, rootAnim)
	objcvBtn:TryChangePage("QuestType", 1)

	if objcvData.isFined or objcvData.isObjFined or objcvData.objData and objcvData.objData.isComplete then
		objcvBtn:TryChangePage("QuestState", 1)

		if objcvData.needPlayFinishAnim and objcvData.objData and objcvData.objData.isComplete then
			objcvData.needPlayFinishAnim = nil

			local _, curPage = objcvBtn:TryGetCurrentPage("QuestState")

			if curPage == 1 then
				self:playObjectiveAnimSequence(rootAnim, "VX_Node_QuestHUD_Text_Finish")
			else
				UIUtils.PlayAnimation(rootAnim, "VX_Node_QuestHUD_Text_In_Reset_2")
			end
		else
			UIUtils.PlayAnimation(rootAnim, "VX_Node_QuestHUD_Text_In_Reset_2")
		end
	elseif not objcvData.isFined and not objcvData.hasPlayedNewAnim and objcvData.isNew then
		objcvData.isNew = nil
		objcvData.hasPlayedNewAnim = true

		objcvBtn:TryChangePage("QuestState", 0)
		self:playObjectiveAnimSequence(rootAnim, "VX_Node_QuestHUD_Text_In3")
	else
		objcvBtn:TryChangePage("QuestState", 0)
		UIUtils.PlayAnimation(rootAnim, "VX_Node_QuestHUD_Text_In_Reset_2")
	end
end

function QuestHudNewComponent:onRefreshObjSingleState(objcvBtn, objcvData, list, objectives, pageType, rootAnim)
	objcvBtn:TryChangePage("QuestType", 0)

	if not objcvData.isFined and not objcvData.hasPlayedNewAnim and objcvData.isNew then
		self:setTrackHintDelayType(pageType, 3)

		objcvData.isNew = nil
		objcvData.hasPlayedNewAnim = true

		objcvBtn:TryChangePage("QuestState", 0)
		self:playObjectiveAnimSequence(rootAnim, "VX_Node_QuestHUD_Text_In2")
		LuaUIUtils.setUIViewVisible(objcvBtn.gameObject, true)
	elseif objcvData.isObjFined then
		self:setTrackHintDelayType(pageType, 2)
		objcvBtn:TryChangePage("QuestState", 1)

		if QuestUtils.isQuestManualCommit(objcvData.questId) then
			UIUtils.PlayAnimation(rootAnim, "VX_Node_QuestHUD_Text_In_Reset_2")
		elseif not objcvData.hasPlayedFinishAnim then
			objcvData.hasPlayedFinishAnim = true

			self:playObjectiveAnimSequence(rootAnim, "VX_Node_QuestHUD_Text_Out2")
		end

		if not QuestUtils.isQuestManualCommit(objcvData.questId) then
			self:startObjFinedRemoveTimer(objcvData, function()
				if not self:isObjectiveInList(list, objcvData) then
					return
				end

				self:setTrackHintDelayType(pageType, 1)
				objcvBtn:TryChangePage("QuestState", 0)
				UIUtils.PlayAnimation(rootAnim, "VX_Node_QuestHUD_Text_In_Reset_2")
				self:removeQuestObjective(list, objectives, objcvData)
				self:restoreTrackHintToActiveObjcv(list)
			end)
		end
	else
		objcvBtn:TryChangePage("QuestState", 0)
		UIUtils.PlayAnimation(rootAnim, "VX_Node_QuestHUD_Text_In_Reset_2")
		objcvBtn:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
	end
end

function QuestHudNewComponent:startObjFinedRemoveTimer(objcvData, func)
	local key = tostring(objcvData.questId) .. "|" .. tostring(objcvData.objId)

	self.objFinedRemoveTimerKeys = self.objFinedRemoveTimerKeys or {}

	if self.objFinedRemoveTimerKeys[key] then
		return
	end

	self.objFinedRemoveTimerKeys[key] = true

	self:startTimer(function()
		self.objFinedRemoveTimerKeys[key] = nil

		func()
	end, questObjcvFinedTimeSpan, false)
end

function QuestHudNewComponent:isObjectiveInList(objcvList, data)
	if not objcvList or not data then
		return false
	end

	for i = objcvList.itemCount - 1, 0, -1 do
		local d = objcvList:GetData(i)

		if d and d.questId == data.questId and (data.objId == nil or d.objId == data.objId) then
			return true
		end
	end

	return false
end

function QuestHudNewComponent:restoreTrackHintToActiveObjcv(objcvList)
	if not objcvList then
		return
	end

	local btns = objcvList:GetAllButtons()

	if not btns then
		return
	end

	local objectives = {}

	for i = 0, btns.Length - 1 do
		local objData = objcvList:GetData(i)

		if objData then
			objectives[#objectives + 1] = objData
		end
	end

	local pageType = self:getTrackHintPageTypeByList(objcvList)

	for i = 1, #objectives do
		self:tryApplyTrackHint(objectives, objectives[i], pageType)
	end
end

function QuestHudNewComponent:onRefreshStoryTracingQuestItem(data)
	self:onRefreshTracingQuestItemCommon(data, QuestConst.QUEST_HUD_PAGE_TYPE.STORY, "curObjectives", "storyTracingList", "clickStoryHintUButton")
end

function QuestHudNewComponent:onRefreshGrowTracingQuestItem(questId)
	if QuestUtils.isShowSpecialChapterItem() then
		self.curSecObjectives = QuestUtils.getSpecialChapterObjectives()
	elseif QuestUtils.getSecondTracingQuestId() == 0 then
		self.curSecObjectives = QuestUtils.getEmptyTracingText(QuestConst.QUEST_HUD_PAGE_TYPE.GROW)
	else
		self.curSecObjectives = QuestUtils.getReceivedQuestObjectives(questId)
	end

	if self.markGrowObjAsNew then
		self.markGrowObjAsNew = nil

		for i = 1, #self.curSecObjectives do
			self.curSecObjectives[i].isNew = true
		end
	end

	self:refreshTrackHintList(QuestConst.QUEST_HUD_PAGE_TYPE.GROW, self.growTracingList, self.curSecObjectives, self.clickGrowHintUButton)
end

function QuestHudNewComponent:onRefreshQuestTracingQuestItem(data)
	self:onRefreshTracingQuestItemCommon(data, QuestConst.QUEST_HUD_PAGE_TYPE.QUEST, "curThrObjectives", "questTracingList", "clickQuestHintUButton")
end

function QuestHudNewComponent:onRefreshStoryObjectivesItem(objcvBtn, objcvIndex, objcvData)
	self:onRefreshObjectivesItemCommon(objcvBtn, objcvIndex, objcvData, self.storyTracingList, self.curObjectives, false)

	if objcvData.hudType then
		self:setSpecialObjectiveInfo(objcvBtn, objcvData)
	else
		self:setQuestObjectiveInfo(objcvBtn, objcvIndex, objcvData)
	end

	self:tryApplyTrackHint(self.curObjectives, objcvData, QuestConst.QUEST_HUD_PAGE_TYPE.STORY)

	local id = string.format("%d%d", objcvData.questId or 0, objcvData.objId or 0)

	objcvBtn.name = id
end

function QuestHudNewComponent:onRefreshQuestObjectivesItem(objcvBtn, objcvIndex, objcvData)
	self:onRefreshObjectivesItemCommon(objcvBtn, objcvIndex, objcvData, self.questTracingList, self.curThrObjectives, false)

	if objcvData.hudType then
		self:setSpecialObjectiveInfo(objcvBtn, objcvData)
	else
		self:setQuestObjectiveInfo(objcvBtn, objcvIndex, objcvData)
	end

	self:tryApplyTrackHint(self.curThrObjectives, objcvData, QuestConst.QUEST_HUD_PAGE_TYPE.QUEST)

	local id = string.format("%d%d", objcvData.questId or 0, objcvData.objId or 0)

	objcvBtn.name = id
end

function QuestHudNewComponent:setQuestObjectiveInfo(objcvBtn, objcvIndex, objcvData)
	local objectComs = self:getTrackQuestObjcvItemComs(objcvBtn)

	if not objectComs or not objcvData then
		return
	end

	if objcvData.isReceiveNpcTarget then
		self:setQuestTaskTypePage(objcvBtn, objcvData.questId)
		ClientTextUtils.setText(objectComs.contentTxt, objcvData.objConfig.desc)
		objectComs.scheduleUWidget:SetActive(false)
		objectComs.progress:SetActive(false)
		objectComs.tagPanelUWidget:SetActive(false)

		return
	end

	local questConfig = QuestUtils.getQuestConfig(objcvData.questId)

	if questConfig == nil then
		return
	end

	local targetVal, totalTargetVal = self:getObjectiveDisplayVals(objcvData)
	local desc = self:applyObjectiveDescAndProgress(objcvData, objectComs, targetVal, totalTargetVal)

	if pg.game.setting:getShowDebugId() then
		ClientTextUtils.setText(objectComs.contentTxt, string.format("%d-%d-%s", objcvData.questId, objcvData.objId, desc))
	else
		ClientTextUtils.setText(objectComs.contentTxt, desc)
	end

	self:setQuestPhoneBtn(objectComs, objcvData)
	self:setQuestRecommendTag(objcvBtn, objectComs, objcvData)
end

function QuestHudNewComponent:getObjectiveDisplayVals(objcvData)
	local totalTargetVal = QuestUtils.getQuestObjectiveTargetVal(objcvData.questId, objcvData.objId)
	local targetVal

	if objcvData.isFined or objcvData.objData and objcvData.objData.isComplete then
		targetVal = totalTargetVal
	else
		targetVal = objcvData.objData and objcvData.objData.currentCnt or 0
	end

	return targetVal, totalTargetVal
end

function QuestHudNewComponent:applyObjectiveDescAndProgress(objcvData, objectComs, targetVal, totalTargetVal)
	local desc = ClientTextUtils.getLocalizationText(objcvData.objConfig.desc, targetVal)
	local isCn = ClientConfigAppCountry == "cn"

	if not isCn then
		desc = string.format(" %s", desc)
	end

	if not QuestUtils.isRunCondNotMet(objcvData.questId) then
		local displayType = objcvData.objConfig.displayType or 1

		objectComs.scheduleUWidget:SetActive(displayType == QuestConst.QUEST_OBJCV_DISPLAY_TYPE.SHOW_PROGRESS)

		if displayType == QuestConst.QUEST_OBJCV_DISPLAY_TYPE.SHOW_COUNTING then
			local countingStr = string.format("[%s/%s]", targetVal, totalTargetVal)

			desc = ClientTextUtils.concatByLanguage(desc, countingStr)
		elseif displayType == QuestConst.QUEST_OBJCV_DISPLAY_TYPE.SHOW_PROGRESS then
			objectComs.progress:SetActive(true)

			local progressValue = targetVal / totalTargetVal

			objectComs.progress.value = progressValue
			desc = string.format("%s [%d%%]", desc, progressValue * 100)

			function objectComs.progress.luaValueChanged()
				objectComs.scheduleUWidget:InvokeCallback(CS.XGUI.EInvokeTime.Custom3)
			end
		end
	end

	if objcvData.objConfig.showCanSelect then
		desc = QuestUtils.questObjectiveCanSelect(desc)
	end

	if QuestUtils.isInQuestBlackList(objcvData.questId) then
		desc = string.format(pg.getGameString("QUEST_CANNOT_PROGRESS_TARGET_TEXT"), desc)
	end

	local tipsText = pg.getGameString("QUEST_TRACK_PLAY_DIALOGUE")
	local isComActionNoFinish = QuestUtils.isReDoQuestComplete(objcvData.questId)

	if isComActionNoFinish then
		desc = tipsText
	end

	return desc
end

function QuestHudNewComponent:setQuestPhoneBtn(objectComs, objcvData)
	objectComs.btnPhoneUWidget:SetActive(false)

	local callId = QuestUtils.getQuestCallId(objcvData.questId)

	if callId > 0 then
		objectComs.btnPhoneUWidget:SetActive(true)
		LuaUIUtils.setUIViewVisible(objectComs.btnPhoneUButton, true)

		function objectComs.btnPhoneUButton.luaClick()
			pg.game.dialogue:playDialogueGraph(callId)
		end
	end
end

function QuestHudNewComponent:setQuestTaskTypePage(objcvBtn, questId)
	local taskType = QuestUtils.getCurSideQuestShowType(questId)

	objcvBtn:TryChangePage("TaskType", taskType.taskType)
end

function QuestHudNewComponent:setQuestRecommendTag(objcvBtn, objectComs, objcvData)
	self:setQuestTaskTypePage(objcvBtn, objcvData.questId)
	objectComs.tagPanelUWidget:SetActive(false)

	local recommendLevel = objcvData.objConfig.recommendLv

	if recommendLevel and recommendLevel > 0 then
		local showStyle, isShowInHud = QuestUtils.getObjectRecommendLevelStyle(recommendLevel)

		if isShowInHud and objcvData.showRecommend then
			objectComs.tagPanelUWidget:SetActive(true)
			objcvBtn:TryChangePage("TagType", showStyle)
			ClientTextUtils.setText(objectComs.textUSDFText, string.format(pg.getGameString("QUEST_RECOMMEND_LEVEL_TITLE_TEXT")))
			ClientTextUtils.setText(objectComs.textLevelUSDFText, string.format(pg.getGameString("QUEST_RECOMMEND_LEVEL_HUD_TEXT"), recommendLevel))
		end
	end
end

function QuestHudNewComponent:setSpecialObjectiveInfo(objcvBtn, objcvData)
	local objectComs = self:getTrackQuestObjcvItemComs(objcvBtn)

	if not objectComs or not objcvData then
		return
	end

	ClientTextUtils.setText(objectComs.contentTxt, objcvData.content)
	objectComs.btnPhoneUWidget:SetActive(false)
	objectComs.scheduleUWidget:SetActive(false)

	local taskType = QuestUtils.getPageDefaultType(objcvData.pageType)

	objcvBtn:TryChangePage("TaskType", taskType)
	objcvBtn:TryChangePage("QuestType", 0)
end

function QuestHudNewComponent:onRefreshPageItem(button, index, data)
	local pageCom = self:getQuestIconComs(button)

	if not pageCom then
		return
	end

	self:onRefreshPageItemTaskType(pageCom, data)
	self:onRefreshPageItemState(pageCom, index, data)
	self:onRefreshPageItemClick(pageCom, index, data)
end

function QuestHudNewComponent:onRefreshPageItemTaskType(pageCom, data)
	if data.pageType == QuestConst.QUEST_HUD_PAGE_TYPE.STORY then
		local traceQuestId = data.questId or QuestUtils.getTracingStoryQuestId()
		local taskType = traceQuestId > 0 and QuestUtils.getCurSideQuestShowType(traceQuestId).taskType or QuestConst.QUEST_PAGE_STYLE.YELLOW

		pageCom.btn:TryChangePage("TaskType", taskType)
	elseif data.pageType == QuestConst.QUEST_HUD_PAGE_TYPE.GROW then
		local traceQuestId = data.questId or QuestUtils.getSecondTracingQuestId()
		local taskType = traceQuestId > 0 and QuestUtils.getCurSideQuestShowType(traceQuestId).taskType or QuestConst.QUEST_PAGE_STYLE.PURPLE

		pageCom.btn:TryChangePage("TaskType", taskType)
	elseif data.pageType == QuestConst.QUEST_HUD_PAGE_TYPE.QUEST then
		local traceQuestId = data.questId or QuestUtils.getTracingQuestId()

		if traceQuestId > 0 then
			local taskType = QuestUtils.getCurSideQuestShowType(traceQuestId)

			pageCom.btn:TryChangePage("TaskType", taskType.taskType)
		else
			pageCom.btn:TryChangePage("TaskType", QuestConst.QUEST_PAGE_STYLE.BLUE)
		end
	end
end

function QuestHudNewComponent:onRefreshPageItemState(pageCom, index, data)
	pageCom.btn.isSelected = self.showTab == data.pageType

	local pageTypeList = QuestUtils.getTabPageList()

	pageCom.line:SetActive(index ~= #pageTypeList - 1)

	if pageTypeList and #pageTypeList <= 1 then
		self.switchPageKey.gameObject:SetActiveEx(false)
	end

	if data.questId then
		pageCom.btn.isSelected = true
	end
end

function QuestHudNewComponent:onRefreshPageItemClick(pageCom, index, data)
	function pageCom.btn.luaClick()
		if not self.clickSwitchCd then
			self:clickSwitchPageBtn(data.pageType)

			self.curSelIndex = index + 1
		end
	end

	pageCom.btn.luaLongPress = nil
	pageCom.btn.longPressLoadingEnabled = false

	if pageCom.btn.isSelected and pg.global.ui.uiMgr:CheckIsMobileInteract() then
		pageCom.btn.longPressLoadingEnabled = true

		function pageCom.btn.luaLongPress(time)
			self:onTabBoxLongPress()
		end
	end

	if self.clickSwitchPage then
		pageCom.btn:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
	end
end

function QuestHudNewComponent:onTabBoxLongPress()
	if self:isGrowTab() then
		self:openSpecialTrain()

		return
	end

	local tracingQuestId = QuestUtils.getPageTraceQuestId(self.showTab)

	pg.game.quest:setCurSelectQuestId(tracingQuestId)
	self:openQuest()
end

function QuestHudNewComponent:refreshPageTabList()
	local flagQuest = self.visibleMap.visible and self.visibleMap.questVisible

	if flagQuest then
		self.pageList:RefreshList()
	end
end

function QuestHudNewComponent:resetPageTabList()
	local flagQuest = self.visibleMap.visible and self.visibleMap.questVisible

	if flagQuest and self.pageList and pg.global.ui:checkUIShow(UIConst.UI_ID_HUD_V2) then
		self.pageList:SetList(QuestUtils.getTabPageList())
	end
end

function QuestHudNewComponent:onRefreshGrowObjectivesItem(objcvBtn, objcvIndex, objcvData)
	self:onRefreshObjectivesItemCommon(objcvBtn, objcvIndex, objcvData, self.growTracingList, self.curSecObjectives, true)

	if objcvData.hudType and objcvData.hudType ~= QuestConst.SPECIAL_QUEST_HUD_STATE.CHAPTER_ADVANCE then
		self:setSpecialObjectiveInfo(objcvBtn, objcvData)
	else
		self:setQuestObjectiveInfo(objcvBtn, objcvIndex, objcvData)
	end

	self:tryApplyTrackHint(self.curSecObjectives, objcvData, QuestConst.QUEST_HUD_PAGE_TYPE.GROW)

	if objcvData and objcvData.questId and objcvData.objId then
		local id = string.format("%d%d", objcvData.questId, objcvData.objId)

		objcvBtn.name = id
	end
end

function QuestHudNewComponent:getFirstTraceSourceObjcv(objectives)
	if objectives == nil then
		return nil
	end

	for i = 1, #objectives do
		local objcvData = objectives[i]

		if objcvData and objcvData.questId and QuestUtils.canTraceItemSource(objcvData.questId) then
			return objcvData
		end
	end

	return nil
end

function QuestHudNewComponent:shouldClaimTrackHint(objectives, objcvData)
	local firstSourceObjcv = self:getFirstTraceSourceObjcv(objectives)

	if firstSourceObjcv then
		return objcvData == firstSourceObjcv
	end

	return true
end

function QuestHudNewComponent:getTrackObjcvData(pageType)
	return self.trackObjcvDataByPage and self.trackObjcvDataByPage[pageType]
end

function QuestHudNewComponent:setTrackObjcvData(pageType, objcvData)
	self.trackObjcvDataByPage = self.trackObjcvDataByPage or {}
	self.trackObjcvDataByPage[pageType] = objcvData
end

function QuestHudNewComponent:getTrackButton(pageType)
	return self.trackButtonByPage and self.trackButtonByPage[pageType]
end

function QuestHudNewComponent:setTrackButton(pageType, button)
	self.trackButtonByPage = self.trackButtonByPage or {}
	self.trackButtonByPage[pageType] = button
end

function QuestHudNewComponent:getTrackHintDelayType(pageType)
	return self.trackHintDelayTypeByPage and self.trackHintDelayTypeByPage[pageType] or 1
end

function QuestHudNewComponent:setTrackHintDelayType(pageType, delayType)
	self.trackHintDelayTypeByPage = self.trackHintDelayTypeByPage or {}
	self.trackHintDelayTypeByPage[pageType] = delayType
end

function QuestHudNewComponent:clearTrackHintDelayTimer(pageType)
	self.trackHintDelayTimerByPage = self.trackHintDelayTimerByPage or {}

	local timerId = self.trackHintDelayTimerByPage[pageType]

	if timerId then
		self.ctrl:killTimer(timerId)

		self.trackHintDelayTimerByPage[pageType] = nil
	end
end

function QuestHudNewComponent:hideTrackHintButton(pageType, hintButton)
	self:clearTrackHintDelayTimer(pageType)
	self:setTrackButton(pageType, nil)

	if hintButton then
		hintButton:SetActive(false)
	end
end

function QuestHudNewComponent:resetTrackHintPage(pageType, hintButton)
	self:hideTrackHintButton(pageType, hintButton)
	self:setTrackHintDelayType(pageType, 1)
	self:setTrackObjcvData(pageType, nil)
end

function QuestHudNewComponent:removeStaleQuestObjectives(list, newObjectives)
	local staleObjectives = {}

	for i = 0, list.itemCount - 1 do
		local oldObjective = list:GetData(i)

		if oldObjective then
			local existsInNewList = false

			for j = 1, #newObjectives do
				local newObjective = newObjectives[j]

				if newObjective.questId == oldObjective.questId and newObjective.objId == oldObjective.objId then
					existsInNewList = true

					break
				end
			end

			if not existsInNewList then
				staleObjectives[#staleObjectives + 1] = {
					questId = oldObjective.questId,
					objId = oldObjective.objId
				}
			end
		end
	end

	for i = 1, #staleObjectives do
		self:removeQuestObjective(list, newObjectives, staleObjectives[i])
	end
end

function QuestHudNewComponent:refreshTrackHintList(pageType, list, objectives, hintButton)
	self:resetTrackHintPage(pageType, hintButton)

	local newObjectives = objectives or {}

	self:removeStaleQuestObjectives(list, newObjectives)
	list:SetList(newObjectives)
end

function QuestHudNewComponent:getTrackHintPageTypeByList(objcvList)
	if objcvList == self.storyTracingList then
		return QuestConst.QUEST_HUD_PAGE_TYPE.STORY
	elseif objcvList == self.growTracingList then
		return QuestConst.QUEST_HUD_PAGE_TYPE.GROW
	end

	return QuestConst.QUEST_HUD_PAGE_TYPE.QUEST
end

function QuestHudNewComponent:getHintButtonFieldByPage(pageType)
	if pageType == QuestConst.QUEST_HUD_PAGE_TYPE.STORY then
		return "clickStoryHintUButton"
	elseif pageType == QuestConst.QUEST_HUD_PAGE_TYPE.GROW then
		return "clickGrowHintUButton"
	end

	return "clickQuestHintUButton"
end

function QuestHudNewComponent:tryApplyTrackHint(objectives, objcvData, pageType)
	if self:shouldClaimTrackHint(objectives, objcvData) then
		self:setTrackObjcvData(pageType, objcvData)
		self:setTrackHint(pageType)
	end
end

function QuestHudNewComponent:setTrackHint(pageType)
	pageType = pageType or self.showTab

	if pageType == QuestConst.QUEST_HUD_PAGE_TYPE.QUEST then
		self:setQuestTrackHint()
	elseif pageType == QuestConst.QUEST_HUD_PAGE_TYPE.GROW then
		self:setGrowTrackHint()
	else
		self:setStoryTrackHint()
	end
end

function QuestHudNewComponent:setQuestTrackHint()
	local hintCom = self:getTrackQuestHintComs(self.clickQuestHintUButton)
	local objcvData = self:getTrackObjcvData(QuestConst.QUEST_HUD_PAGE_TYPE.QUEST)
	local questId = objcvData and objcvData.questId

	self:hideTrackHintButton(QuestConst.QUEST_HUD_PAGE_TYPE.QUEST, self.clickQuestHintUButton)

	if self:isQuestTab() then
		self:setTrackHintCommon(self.clickQuestHintUButton, hintCom, questId, false, true)
	end
end

function QuestHudNewComponent:setStoryTrackHint()
	if self:isGrowTab() then
		return
	end

	local hintCom = self:getTrackQuestHintComs(self.clickStoryHintUButton)
	local objcvData = self:getTrackObjcvData(QuestConst.QUEST_HUD_PAGE_TYPE.STORY)
	local questId = objcvData and objcvData.questId

	self:hideTrackHintButton(QuestConst.QUEST_HUD_PAGE_TYPE.STORY, self.clickStoryHintUButton)

	if self:isStoryTab() then
		self:setTrackHintCommon(self.clickStoryHintUButton, hintCom, questId, true, false)
	end
end

function QuestHudNewComponent:setGrowTrackHint()
	local objcvData = self:getTrackObjcvData(QuestConst.QUEST_HUD_PAGE_TYPE.GROW)

	if not objcvData then
		return
	end

	local ret, page = self.rootUComponent:TryGetCurrentPage("Tips")

	if page and page == 1 then
		return
	end

	local questId = objcvData.questId
	local hintCom = self:getTrackQuestHintComs(self.clickGrowHintUButton)

	self:hideTrackHintButton(QuestConst.QUEST_HUD_PAGE_TYPE.GROW, hintCom.btn)
	self:clearGrowTrackRedDot(hintCom.btn)

	if objcvData.isEmptyTracing then
		self:setGrowTrackHintEmpty(hintCom, objcvData)

		return
	end

	local text = ""

	if objcvData.hudType and objcvData.hudType > 0 and objcvData.hudType ~= QuestConst.SPECIAL_QUEST_HUD_STATE.CHAPTER_ADVANCE then
		text = self:setGrowTrackHintChapter(hintCom, objcvData)
	elseif objcvData.hudType and objcvData.hudType > 0 and objcvData.hudType == QuestConst.SPECIAL_QUEST_HUD_STATE.CHAPTER_ADVANCE then
		text = self:setGrowTrackHintAdvance(hintCom, questId)
	elseif not self:isStoryTab() and questId then
		text = self:setGrowTrackHintSecondQuest(hintCom, objcvData, questId)
	end

	ClientTextUtils.setText(hintCom.traceText, text)
	self:setupGrowTraceBinding(hintCom)
end

function QuestHudNewComponent:setGrowTrackHintEmpty(hintCom, objcvData)
	hintCom.btn:TryChangePage("TrackType", 0)
	self:showGrowClickHindBtn(true)
	self:setTrackButton(QuestConst.QUEST_HUD_PAGE_TYPE.GROW, hintCom.btn)
	ClientTextUtils.setText(hintCom.traceText, objcvData.hint or pg.getGameString("QUEST_TRACK_TEXT"))

	function hintCom.btn.luaClick()
		self:openSpecialTrain()
	end

	self:setupGrowTraceBinding(hintCom)
end

function QuestHudNewComponent:setGrowTrackHintChapter(hintCom, objcvData)
	local text = objcvData.hint

	if text and text ~= "" then
		hintCom.btn:TryChangePage("TrackType", 0)
		self:showGrowClickHindBtn(true)
	end

	self:setTrackButton(QuestConst.QUEST_HUD_PAGE_TYPE.GROW, hintCom.btn)

	function hintCom.btn.luaClick()
		if objcvData.hudType == QuestConst.SPECIAL_QUEST_HUD_STATE.CHAPTER_ASSESSMENT then
			local advanceId = QuestUtils.getChapterCourseQuestId(QuestUtils.getCurChapterId())
			local assessmentId = QuestUtils.getAssessmentIdByUpgrade(advanceId)

			pg.game.quest:setCurSelectQuestId(assessmentId)
			self:openQuest()
		else
			self:openSpecialTrain()
		end
	end

	self:setupGrowChapterRedDot(hintCom.btn, objcvData)

	return text
end

function QuestHudNewComponent:setGrowTrackHintAdvance(hintCom, questId)
	local text = ""
	local isShowSourceBtn, sourceId = QuestUtils.canTraceItemSource(questId)
	local isShowPathfinding, _ = QuestUtils.canQuestShowPathfindingFlag(questId)

	if isShowSourceBtn or isShowPathfinding then
		hintCom.btn:TryChangePage("TrackType", 0)
		self:showGrowClickHindBtn(true)
		self:setTrackButton(QuestConst.QUEST_HUD_PAGE_TYPE.GROW, hintCom.btn)

		if isShowPathfinding then
			text = pg.getGameString("QUEST_TRACK_TEXT")

			function hintCom.btn.luaClick()
				if not self.clickCD then
					QuestUtils.addQuestPathingNavEffect(questId)

					self.clickCD = true

					self:startTimer(function()
						self.clickCD = false
					end, curtainQuestShowTimeSpan)
				end
			end
		elseif isShowSourceBtn and sourceId and sourceId > 0 then
			text = pg.getLocalizationText(ItemSourceData[sourceId].buttonTxt) or pg.getGameString("QUEST_TRACK_TEXT")

			function hintCom.btn.luaClick()
				local data = {
					clueSeekID = sourceId
				}

				table.merge(data, ItemSourceData[sourceId])
				LuaUIUtils.clueSeek(data, nil, hintCom.btn)
			end
		end
	end

	return text
end

function QuestHudNewComponent:setGrowTrackHintSecondQuest(hintCom, objcvData, questId)
	local text = ""
	local isSwitchPageQuest = table.contains(NEED_SWITCH_STORY_QUEST_IDS, questId)
	local secondQuestData, questConfig = pg.global.ui.SpecialTrainNew:isCanShowTraceSecondQuestFunc(questId)

	if secondQuestData then
		local canGet = secondQuestData.isCanGetReward or false
		local hasGet = secondQuestData.rewardFlags or false

		if objcvData.isObjFined then
			self:showGrowClickHindBtn(false)
		else
			hintCom.btn:TryChangePage("TrackType", 0)
			self:showGrowClickHindBtn(true)
		end

		if self.growPendingRewardQuestId == nil then
			self.isHaveCanGetReward = false
		end

		self:setTrackButton(QuestConst.QUEST_HUD_PAGE_TYPE.GROW, hintCom.btn)

		function hintCom.btn.luaClick()
			self:onGrowSecondQuestClick(questId, secondQuestData, canGet, hasGet, isSwitchPageQuest)
		end

		text = self:getGrowSecondQuestText(questId, questConfig, canGet, hasGet, isSwitchPageQuest)

		if not QuestUtils.isPromotionQuest(questId) then
			local treePath = string.format(RedDotConst.RedDotPath.SPECIAL_TRAIN_TAB_TREE_ITEM, secondQuestData.taskId or 0)

			self.trackSpecialCanGetRewardTreePath = treePath

			pg.global.setRedDot(treePath, hintCom.btn, canGet and not hasGet, RedDotConst.RedDotStyle.REWARD)
		end
	end

	return text
end

function QuestHudNewComponent:clearGrowTrackRedDot(btn)
	if self.trackSpecialCanGetRewardTreePath then
		pg.global.setRedDot(self.trackSpecialCanGetRewardTreePath, btn, false, RedDotConst.RedDotStyle.REWARD)
	end
end

function QuestHudNewComponent:openSpecialTrain()
	pg.global.ui.hudV2:openSpecialTrain()
end

function QuestHudNewComponent:openQuest()
	pg.global.ui.hudV2:openQuest()
end

function QuestHudNewComponent:setupGrowTraceBinding(hintCom)
	if self.traceGrowBinding == nil then
		self.traceGrowBinding = self:addTraceQuestKeyBinding(hintCom.btn)
	else
		self.traceGrowBinding.enabled = true
	end

	hintCom.keyHotKeyContent:SetHotKeyPaths("Hud/TrackOpenSpecial")
end

function QuestHudNewComponent:setupGrowChapterRedDot(btn, objcvData)
	local chapterStateInfo = QuestUtils.getChapterState(objcvData.chapterId)
	local isCanGetReward = pg.global.ui.SpecialTrainNew.model:isCanGetChapterReward(objcvData.chapterId)
	local showRedDot = not chapterStateInfo.isChapterRewarded and isCanGetReward
	local treePath = string.format("%s%s%s%s", RedDotConst.RedDotPath.SPECIAL_TRAIN_TAB_TREE, objcvData.chapterId, QuestConst.TRAIN_CHAPTER_COURSE_TYPE.COMPULSORY, 1)

	self.trackSpecialCanGetRewardTreePath = treePath

	pg.global.setRedDot(treePath, btn, showRedDot, RedDotConst.RedDotStyle.REWARD)
end

function QuestHudNewComponent:onGrowSecondQuestClick(questId, secondQuestData, canGet, hasGet, isSwitchPageQuest)
	if self.getRewardCD then
		return
	end

	self.getRewardCD = true

	self:startTimer(function()
		self.getRewardCD = false
	end, 0.5)

	self.isHaveCanGetReward = pg.global.ui.SpecialTrainNew.model:getCanGetRewardSpecialTrainQuestIds(questId)

	if QuestUtils.isPromotionQuest(questId) then
		self:openSpecialTrain()
	elseif canGet and not hasGet then
		local questList = pg.global.ui.SpecialTrainNew.model:getSpecialTrainGetRewardList(secondQuestData.taskId)

		self:markGrowRewardPending(questId)
		pg.me:getSpecialTrainEntryReward(questList, QuestConst.SPECIAL_TRAIN_REWARD_SRC_TYPE.HUD, function(ret)
			if self.objectReference == nil then
				return
			end

			if ret then
				self:clickSpecialTranVBtn(questId)
			else
				self:clearGrowRewardPending()
			end
		end)
	elseif isSwitchPageQuest then
		local trackQuestId = pg.global.ui.quest.model:getCanTrackMainChapterQuestId()

		if trackQuestId and trackQuestId > 0 then
			pg.me:traceQuest(trackQuestId, true)
		end

		self:startTimer(function()
			self:clickSwitchPageBtn(QuestConst.QUEST_HUD_PAGE_TYPE.STORY)
		end, 1)
	else
		QuestUtils.openTraceSecondQuestFunc(questId)
	end
end

function QuestHudNewComponent:getGrowSecondQuestText(questId, questConfig, canGet, hasGet, isSwitchPageQuest)
	if QuestUtils.isPromotionQuest(questId) then
		local title, content, hint = QuestUtils.getSpecialTrainHudInfo(QuestConst.SPECIAL_QUEST_HUD_STATE.CHAPTER_ADVANCE, questId)

		return hint
	elseif canGet and not hasGet then
		return pg.getGameString("QUEST_TRACK_GET_REWARD")
	elseif isSwitchPageQuest then
		return pg.getGameString("QUEST_TRACK_GOTO_STORY_QUEST")
	end

	return questConfig and pg.getLocalizationText(questConfig.goToTxt)
end

function QuestHudNewComponent:clickSpecialTranVBtn(questId)
	local parentQuest = QuestUtils.getParentQuestId(questId)

	self:killTimer(self.growRewardTrackTimerId)

	self.growRewardTrackTimerId = self:startTimer(function()
		self.growRewardTrackTimerId = nil

		self:decideGrowTrackAfterReward(questId, parentQuest)
	end, questObjcvFinedTimeSpan)

	self:setFirstShowUpdate(true)
end

function QuestHudNewComponent:decideGrowTrackAfterReward(questId, parentQuest)
	self:clearGrowRewardPending()

	if self.objectReference == nil then
		return
	end

	local nextParent = self:pickGrowTraceableCanGetQuest(questId)

	if nextParent > 0 then
		self.growTraceRefreshQuestId = nil

		if nextParent ~= QuestUtils.getSecondTracingQuestId() then
			pg.me:traceQuest(nextParent, true)
		end

		self:refreshGrowTracingWhenTraced(nextParent, function()
			self:trackGrowRingOrFallback(parentQuest)
		end)

		return
	end

	self:trackGrowRingOrFallback(parentQuest)
end

function QuestHudNewComponent:trackGrowChapterItemIfNeeded()
	if not QuestUtils.isShowSpecialChapterItem(true) then
		return false
	end

	self.growTraceRefreshQuestId = nil

	if QuestUtils.isShowSpecialChapterItem() then
		local curTrace = QuestUtils.getSecondTracingQuestId()

		if curTrace > 0 and curTrace ~= (QuestUtils.getInStarTitleQuestId() or 0) then
			pg.me:traceQuest(curTrace, false)
		end

		self:refreshGrowChapterItem()

		return true
	end

	local curTrace = QuestUtils.getSecondTracingQuestId()

	if curTrace > 0 then
		pg.me:traceQuest(curTrace, false)
	end

	self:refreshGrowTracingWhenCleared()

	return true
end

function QuestHudNewComponent:trackGrowRingOrFallback(parentQuest)
	if self:trackGrowChapterItemIfNeeded() then
		return
	end

	local ringObjectives = parentQuest and parentQuest > 0 and QuestUtils.getReceivedQuestObjectives(parentQuest) or {}

	if #ringObjectives > 0 then
		self:ensureGrowTracingRefresh(parentQuest)

		return
	end

	self:trackGrowFallbackQuest()
end

function QuestHudNewComponent:trackGrowFallbackQuest()
	self.growTraceRefreshQuestId = nil

	local fallbackQuestId = QuestUtils.getSpecialTrainNoRewardQuestId(function(id)
		return self:getGrowTraceableParent(id) > 0
	end)
	local fallbackParent = fallbackQuestId > 0 and self:getGrowTraceableParent(fallbackQuestId) or 0

	if fallbackParent > 0 then
		if fallbackParent ~= QuestUtils.getSecondTracingQuestId() then
			pg.me:traceQuest(fallbackParent, true)
		end

		self:refreshGrowTracingWhenTraced(fallbackParent)
	else
		local fallbackTarget = QuestUtils.manualTrackSecondTracingQuest()

		if fallbackTarget > 0 then
			self:refreshGrowTracingWhenTraced(fallbackTarget)
		else
			self:ensureGrowTracingRefresh(QuestUtils.getSecondTracingQuestId())
		end
	end
end

function QuestHudNewComponent:getGrowTraceableParent(questId)
	if questId == nil or questId <= 0 then
		return 0
	end

	local parentQuest = QuestUtils.getParentQuestId(questId)

	if parentQuest == nil or parentQuest <= 0 then
		return 0
	end

	if QuestUtils.getQuestData(parentQuest) == nil and QuestUtils.getSpecialTrainQuestRewardFlags(questId) then
		return 0
	end

	local objectives = QuestUtils.getReceivedQuestObjectives(parentQuest)

	if objectives == nil or #objectives <= 0 then
		return 0
	end

	return parentQuest
end

function QuestHudNewComponent:pickGrowTraceableCanGetQuest(excludeQuestId)
	local model = pg.global.ui.SpecialTrainNew and pg.global.ui.SpecialTrainNew.model

	if model == nil then
		return 0
	end

	local questIds = model:collectCanGetRewardQuestIds(excludeQuestId, false, true)

	for _, id in ipairs(questIds) do
		local parentQuest = self:getGrowTraceableParent(id)

		if parentQuest > 0 then
			return parentQuest
		end
	end

	return 0
end

function QuestHudNewComponent:showStoryClickHindBtn(flag)
	self:showClickHindBtnCommon(self.clickStoryHintUButton, flag, QuestConst.QUEST_HUD_PAGE_TYPE.STORY)
end

function QuestHudNewComponent:showQuestClickHindBtn(flag)
	self:showClickHindBtnCommon(self.clickQuestHintUButton, flag, QuestConst.QUEST_HUD_PAGE_TYPE.QUEST)
end

function QuestHudNewComponent:showGrowClickHindBtn(flag)
	self:showClickHindBtnCommon(self.clickGrowHintUButton, flag, QuestConst.QUEST_HUD_PAGE_TYPE.GROW)
end

function QuestHudNewComponent:showClickHindBtnByTab(flag)
	if self:isGrowTab() then
		self:showGrowClickHindBtn(flag)
	elseif self:isQuestTab() then
		self:showQuestClickHindBtn(flag)
	elseif self:isStoryTab() then
		self:showStoryClickHindBtn(flag)
	end
end

function QuestHudNewComponent:onSwitchHudShowType(isFinishInterrupt)
	self.mainInterrupt = true

	local duration = isFinishInterrupt and curtainQuestShowTimeSpan or 5

	self.rootUComponent:TryChangePage("Interrupt", self.mainInterrupt and 1 or 0)
	self:killTimer(self.interruptResetTimerId)

	self.interruptResetTimerId = self:startTimer(function()
		self.interruptResetTimerId = nil

		self:resetInterrupt(isFinishInterrupt)
	end, duration)
end

function QuestHudNewComponent:resetInterrupt(isFinishInterrupt)
	self:killTimer(self.interruptResetTimerId)

	self.interruptResetTimerId = nil
	self.mainInterrupt = false

	self:onSwitchPageTab()
	self.rootUComponent:TryChangePage("Interrupt", 0)

	if isFinishInterrupt then
		self.rootUComponent:TryChangePage("QuestState", 2)
	else
		self.rootUComponent:TryChangePage("QuestState", 3)
	end

	self.playCompleteAnim = true

	self:startTimer(function()
		local curTrackQuestId = QuestUtils.getPageTraceQuestId(self.showTab)
		local isEmptyTracing = not curTrackQuestId or curTrackQuestId == 0

		if self:isStoryTab() then
			isEmptyTracing = QuestUtils.isStoryTracingAllFinished()
		end

		if isEmptyTracing or QuestUtils.isCurtainQuest(curTrackQuestId) or QuestUtils.isQuestOfQuestType(curTrackQuestId, QuestConst.QUEST_TYPE.SPECIAL_TRAIN) then
			self:refreshQuestTitleByTab(curTrackQuestId)
		end

		if isEmptyTracing then
			self:switchRefreshTraceList()
		end

		self:setTrackHint()
	end, 0.2)
end

function QuestHudNewComponent:checkShowUntracingQuest()
	if self.questUntracingQueue:isEmpty() or self:isShowingUntracingQuestMsg() then
		return
	end

	self.markShowQuestMsgTime = Time.realtimeSinceStartup

	local data = self.questUntracingQueue:deQueue()

	if data then
		if data and data.isObjFined then
			self.curUntracingObjectives = QuestUtils.getReceivedQuestObjectives(data.questId, false)
		else
			self.curUntracingObjectives = QuestUtils.getReceivedQuestObjectives(data.questId)
		end
	end

	if #self.curUntracingObjectives == 0 then
		self.untracingQuestList:SetList({})
		self.untraceBtnUButton:SetActive(false)
	else
		self.untracingQuestList:SetList(self.curUntracingObjectives)
	end

	self:onSwitchHudShowType(data.isFinishInterrupt)
	self:setQuestTitleName(self.unTrackPopUButton, data.questId, data, {
		isCurtain = true
	})

	local list = QuestUtils.getTabPageListInterrupt(data.questId)

	self.unTrackPageList:SetList(list)
end

function QuestHudNewComponent:isShowingUntracingQuestMsg()
	if self.markShowQuestMsgTime == nil then
		return false
	end

	return Time.realtimeSinceStartup - self.markShowQuestMsgTime < questUntracingShowTimeSpan + 0.1
end

function QuestHudNewComponent:onRefreshUntracingQuestItem(objcvBtn, objcvIndex, objcvData)
	local hintCom = self:getTrackQuestHintComs(self.untraceBtnUButton)

	if objcvData.isFined then
		objcvBtn:TryChangePage("QuestType", 0)
		objcvBtn:TryChangePage("QuestState", 0)
		UIUtils.PlayAnimations(hintCom.rootAnimation, {
			"VX_Node_QuestHUD_Text_In_Reset_2",
			"VX_Node_QuestHUD_Text_Out2"
		})

		local refreshTimerId = self:startTimer(function()
			UIUtils.PlayAnimation(hintCom.rootAnimation, "VX_Node_QuestHUD_Text_In_Reset_2")
			self:removeQuestObjective(self.untracingQuestList, self.curUntracingObjectives, objcvData)
		end, questObjcvFinedTimeSpan, false)
	end

	self:setQuestObjectiveInfo(objcvBtn, objcvIndex, objcvData)
	self:bindObjectiveClickForward(objcvBtn, "untraceBtnUButton")

	if #self.curUntracingObjectives == 0 then
		hintCom.btn:SetActive(false)
	else
		hintCom.btn:SetActive(true)
	end

	function hintCom.btn.luaClick()
		pg.game.quest:removeAllQuestPathfinding()

		local rootQuestId = QuestUtils.getRootQuestId(objcvData.questId)

		pg.me:traceQuest(rootQuestId, true)

		local pageType = QuestUtils.getPageType(rootQuestId)

		QuestUtils.switchHudPageType(pageType, true)

		self.showTab = pageType

		self:refreshPageTabList()
		self:resetInterrupt()
	end

	if self.traceBinding == nil then
		self.traceBinding = self:addTraceQuestKeyBinding(hintCom.btn)

		hintCom.keyHotKeyContent:SetHotKeyPaths("Hud/TrackOpenSpecial")
	else
		self.traceBinding.enabled = true
	end

	objcvBtn.name = tostring(objcvData.questId)
end

function QuestHudNewComponent:addTraceQuestKeyBinding(btn)
	local actionPath = "Hud/TrackOpenSpecial"
	local openSetupBind = KeyBindingPro.GetOrAddKeyBindingByName(btn.transform.gameObject, actionPath)

	openSetupBind.actionPath = actionPath
	openSetupBind.isVirtual = false
	openSetupBind.priority = 999

	function openSetupBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			if pg.game.input:isUsingGamepad() then
				self.ctrl:killTimer(self.pressVTrackTimer)

				self.pressVTrackTimer = nil
				self.pressVTrackProgress = 0
				self.pressVTrackTimer = self.ctrl:startTimer(function()
					self.pressVTrackProgress = self.pressVTrackProgress + Time.unscaledDeltaTime
				end, 0, true)
			end

			pg.game.audio:triggerEvent("SFX_UI_Event_HUDQuest_FocusDirection")
		elseif inputInfo.phase == "Canceled" and pg.game.input:isUsingGamepad() then
			if self.pressVTrackProgress <= LONG_PRESS_TIME then
				local trackButton = self:getTrackButton(self.showTab)

				if trackButton and NotNil(trackButton) then
					trackButton:OnClickSimulate()
				end
			end

			self.pressVTrackProgress = 0
		end

		return false
	end

	return openSetupBind
end

function QuestHudNewComponent:isContainsQuest(objectives, questId, objId, newState, itemComs)
	for i, v in pairs(objectives) do
		if v.questId == questId and v.objId == objId then
			if v.questState and v.questState == newState then
				return true
			else
				table.remove(objectives, i)

				if itemComs then
					itemComs:RemoveElement(i - 1)
				end

				return false
			end
		end
	end

	return false
end

function QuestHudNewComponent:inPressing(keyProgressPressComponent, switchPage, pcLongPress)
	self.pressProgress = self.pressProgress + Time.unscaledDeltaTime

	if self.pressProgress > LONG_PRESS_TIME then
		keyProgressPressComponent:ProgressToValue(getLongPressProgress(self.pressProgress), nil, 0)
		self:setProgressActive(true)
	end

	if keyProgressPressComponent.value >= 1 then
		local ret, page = self.rootUComponent:TryGetCurrentPage("Tips")

		if page <= 0 then
			if self.pressProgress > LONG_PRESS_TIME then
				if pcLongPress then
					self:onTabBoxLongPress()
				else
					self:clickSwitchPageByIndex()
				end
			end

			self:endPress()
		elseif page == 1 then
			self:onClickTipBtn(false)
			self:endPress()
		end

		self:setProgressActive(false)
	end
end

function QuestHudNewComponent:clickSwitchPageByIndex()
	self.playCompleteAnim = true

	if not self.clickSwitchCd then
		if self.curSelIndex >= QuestUtils.getTabPageMaxIndex() then
			self.curSelIndex = 1
		else
			self.curSelIndex = self.curSelIndex + 1
		end

		self:clickSwitchPageBtn(QuestUtils.getPageByIndex(self.curSelIndex))
	end
end

function QuestHudNewComponent:endPress()
	self:setProgressZero()
	self:setProgressActive(false)

	if self.pressSwitchPageTimer == nil then
		return
	end

	self.ctrl:killTimer(self.pressSwitchPageTimer)

	self.pressSwitchPageTimer = nil
end

function QuestHudNewComponent:endPressAITips(coms)
	if self.pressAITipsTimer then
		self.ctrl:killTimer(self.pressAITipsTimer)

		self.pressAITipsTimer = nil
	end

	self.pressAITipsProgress = 0

	if coms and coms.aiKeyProgressPressComponent then
		coms.aiKeyProgressPressComponent:ProgressToValue(0, nil, 0)
	end

	self:refreshAITipsProgressActive()
end

function QuestHudNewComponent:registerAITipsProgress(progress)
	if progress == nil then
		return
	end

	self.aiProgressPresss = self.aiProgressPresss or {}

	for i = 1, #self.aiProgressPresss do
		if self.aiProgressPresss[i] == progress then
			return
		end
	end

	table.insert(self.aiProgressPresss, progress)
end

function QuestHudNewComponent:refreshAITipsProgressActive()
	if self.aiProgressPresss == nil then
		return
	end

	local isGamepad = pg.game.input:isUsingGamepad()

	for i = #self.aiProgressPresss, 1, -1 do
		local progress = self.aiProgressPresss[i]

		if progress == nil or not NotNil(progress) then
			table.remove(self.aiProgressPresss, i)
		elseif isGamepad then
			progress.gameObject:SetActiveEx(true)
		else
			progress:ProgressToValue(0, nil, 0)
			progress.gameObject:SetActiveEx(false)
		end
	end
end

function QuestHudNewComponent:onInputDeviceChanged()
	if self.keyProgressPressComponent then
		self.keyProgressPressComponent.gameObject:SetActiveEx(pg.game.input:isUsingGamepad())
	end

	self:refreshSwitchKeyVisible()
	self:setProgressActive(true)
	self:refreshAITipsProgressActive()
end

function QuestHudNewComponent:setProgressActive(isShow)
	if self.progressPresss == nil then
		return
	end

	for i, v in ipairs(self.progressPresss) do
		local isMobile = pg.global.ui.uiMgr:CheckIsMobileInteract()

		if self.progressPresss and self.progressPresss[i] then
			if self.pressProgress and self.pressProgress > LONG_PRESS_TIME and not isMobile and isShow then
				self.progressPresss[i].gameObject:SetActiveEx(true)
				self.progressPresss[i]:ProgressToValue(getLongPressProgress(self.pressProgress), nil, 0)
			else
				if not pg.game.input:isUsingGamepad() then
					self.progressPresss[i].gameObject:SetActiveEx(false)
				end

				self.progressPresss[i]:ProgressToValue(0, nil, 0)
			end
		end
	end
end

function QuestHudNewComponent:setProgressZero()
	for i, v in ipairs(self.progressPresss) do
		if self.progressPresss and self.progressPresss[i] then
			self.progressPresss[i]:ProgressToValue(0, nil, 0)
		end
	end
end

function QuestHudNewComponent:onTeamChanged()
	local flagQuest = self.visibleMap.visible and self.visibleMap.questVisible

	if flagQuest then
		local delayType = self:getTrackHintDelayType(self.showTab)

		if delayType == 3 or delayType == 1 then
			self:setTrackHint()
		end
	end
end

function QuestHudNewComponent:switchQuestPageType(pageType)
	self.showTab = pageType
	self.curSelIndex = QuestUtils.getIndexByPage(pageType)

	local flagQuest = self.visibleMap.visible and self.visibleMap.questVisible

	if flagQuest then
		self:clickSwitchPageBtn(pageType)
	else
		self.firstShowUpdate = true
	end
end

function QuestHudNewComponent:onSpecialTrainChapterUnlock(chapterId)
	if chapterId < 1 then
		return
	end

	local parentQuestId = pg.global.ui.SpecialTrainNew.model:getCompulsoryPageUnlockTrace(chapterId)

	if parentQuestId and parentQuestId > 0 then
		pg.me:traceQuest(parentQuestId, true)
	end

	local flagQuest = self.visibleMap.visible and self.visibleMap.questVisible

	if flagQuest and not pg.global.ui:checkUIOpen(UIConst.UI_ID_OPEN_SPECIAL_TRAIN_PANEL) and not QuestUtils.isChapterLockState(chapterId) then
		-- block empty
	end
end

function QuestHudNewComponent:enableOrDisableActions(isEnable)
	return
end

function QuestHudNewComponent:clearAllCaches()
	if not cachesDirty then
		return
	end

	cachesDirty = false
	questComs = {}
	questTabStateItemComs = {}
	questTabItemComs = {}
	questIconComs = {}
	questDetailsItemComs = {}
	questTitleNewItemComs = {}
	trackQuestObjcvItemComs = {}
	questTipComs = {}
	trackQuestHintComs = {}
end

function QuestHudNewComponent:clearPlayerReferences()
	self:killAllTimer()

	self.tracingQueueUpdateTimer = nil

	self:clearInterruptState()
	self:releaseQuestLists()
	self:clearQuestQueues()
	self:resetQuestFields()
end

function QuestHudNewComponent:releaseQuestLists()
	local listNames = {
		"storyTracingList",
		"growTracingList",
		"questTracingList",
		"untracingQuestList",
		"pageList",
		"unTrackPageList"
	}

	for _, listName in ipairs(listNames) do
		local list = self[listName]

		if list and not IsNil(list) then
			list:ReleaseItemData()
			list:SetList({})
		end
	end
end

function QuestHudNewComponent:clearQuestQueues()
	local queueNames = {
		"questUntracingQueue",
		"questStoryCurtainQueue",
		"questStoryTracingQueue",
		"questGrowTitleQueue",
		"questGrowTracingQueue",
		"questTaskTitleQueue",
		"questTaskTracingQueue"
	}

	for _, queueName in ipairs(queueNames) do
		local queue = self[queueName]

		if queue then
			queue:clear()
		end
	end
end

function QuestHudNewComponent:resetQuestFields()
	self.curObjectives = nil
	self.curSecObjectives = nil
	self.curThrObjectives = nil
	self.curUntracingObjectives = nil
	self.trackObjcvDataByPage = {}
	self.curQuest = nil
	self.subQuests = nil
	self.growPendingRewardQuestId = nil
	self.growPendingRewardTimerId = nil
	self.growTraceRefreshQuestId = nil
	self.growRewardTrackTimerId = nil
	self.growTraceWaitTimerId = nil
	self.trackButtonByPage = {}
	self.trackHintDelayTypeByPage = {}
	self.trackHintDelayTimerByPage = {}
	self._objChangeCooldowns = {}
	self._objChangePending = {}
	self._objChangeIdleCount = {}
	self._objChangeLastRendered = {}
end

function QuestHudNewComponent:clearInterruptState()
	self:killTimer(self.interruptResetTimerId)

	self.interruptResetTimerId = nil
	self.mainInterrupt = false
	self.playCompleteAnim = true
	self.markShowQuestMsgTime = nil
	self.curUntracingObjectives = nil

	if self.rootUComponent and NotNil(self.rootUComponent) then
		self.rootUComponent:TryChangePage("Interrupt", 0)
		self.rootUComponent:TryChangePage("QuestState", 2)
	end

	if self.untraceBtnUButton and NotNil(self.untraceBtnUButton) then
		self.untraceBtnUButton:SetActive(false)
	end
end

function QuestHudNewComponent:onDestroy()
	self:clearPlayerReferences()
	self:clearAllCaches()
end

function QuestHudNewComponent:onVisibleChange(visible)
	if visible and self.rootUComponent then
		self.rootUComponent:TryChangePage("QuestState", 2)
	end
end

function QuestHudNewComponent:initHideFlag()
	if pg.me == nil or pg.me.space == nil then
		return
	end

	self:onEnterSpace()
	self:onUIVisibleChanged()
	self:onCatchModeChanged()
	self:onQuestTraceChanged()
	self:refreshTargetVisibleState()
end

function QuestHudNewComponent:onEnterSpace()
	if pg.me == nil or pg.me.space == nil then
		return
	end

	local space = pg.me.space

	if space:isRogueEnv() or space:isPvpEnv() or space:isBossRushEnv() or space:isCatchRogue() or space:isGrabEgg() or space:isNpcDuel() or space:isBossDungeon() then
		self:setHideFlag(HideReason.space, true)
	else
		self:setHideFlag(HideReason.space, false)
	end

	if space.isHomeland and space:isHomeland() then
		QuestUtils.switchHudPageType(QuestConst.QUEST_HUD_PAGE_TYPE.QUEST)
		self:clickSwitchPageBtn(QuestConst.QUEST_HUD_PAGE_TYPE.QUEST)
	elseif self.pageList and pg.global.ui:checkUIShow(UIConst.UI_ID_HUD_V2) then
		self.pageList:SetList(QuestUtils.getTabPageList())
	end

	self:refreshCheckShowState()
	self:refreshResidualTraceList()
end

function QuestHudNewComponent:refreshResidualTraceList()
	if self.objectReference == nil then
		return
	end

	if not self.storyTracingList or not self.questTracingList or not self.growTracingList then
		return
	end

	self:switchRefreshTraceList()
end

function QuestHudNewComponent:onUIVisibleChanged()
	local ui = pg.global.ui
	local hudId = UIConst.UI_ID_HUD_V2

	self:setHideFlag(HideReason.hudVisible, not ui:checkUIShow(hudId))

	if ui:checkUIShow(UIConst.UI_ID_TRAINING) or ui:checkUIOpen(UIConst.UI_ID_FRIENDSHIP_UP) or not ui:checkUIShow(hudId) or ui:checkUIShow(UIConst.UI_ID_BOTTOM_DIALOGUE) then
		self:setHideFlag(HideReason.ui, true)
	else
		self:setHideFlag(HideReason.ui, false)
	end

	self:refreshCheckShowState()
end

function QuestHudNewComponent:onCatchModeChanged()
	if pg.me == nil then
		return
	end

	local inCatch = pg.me:isInCatchMode()

	self:setHideFlag(HideReason.catchMode, inCatch)
end

function QuestHudNewComponent:onQuestTraceChanged()
	if pg.me == nil then
		return
	end

	local inCourseScene = CommonSwitch.TARGET and QuestUtils.isInCourseScene()

	self:setHideFlag(HideReason.inCourseScene, inCourseScene)
end

function QuestHudNewComponent:refreshTargetVisibleState()
	local targetVisible = CommonSwitch.TARGET and self.ctrl and self.ctrl.target and self.ctrl.target:checkIsRunning()

	self:setHideFlag(HideReason.target, targetVisible)
end

function QuestHudNewComponent:refreshVisibleMap()
	return TipVisibilityHelper.refresh(self)
end

function QuestHudNewComponent:refreshCheckShowState()
	return TipVisibilityHelper.setHideFlag(self, HideReason.checkShowState, not self:checkShowState())
end

function QuestHudNewComponent:setHideFlag(flag, isEnable)
	return TipVisibilityHelper.setHideFlag(self, flag, isEnable)
end

function QuestHudNewComponent:setIsVisible(visible)
	self.isVisible = visible

	self:setHideFlag(HideReason.isVisible, not visible)
end

function QuestHudNewComponent:onPriorityBreak(isShow, flag)
	self:setHideFlag(flag, isShow)
end

function QuestHudNewComponent:onFullScreenShowChange(isShow)
	self:setHideFlag(HideReason.fullScreenShow, isShow)
end

function QuestHudNewComponent:onQuestTrackReach(data)
	if data and data.questId and data.questId > 0 then
		local state = QuestCommonUtils.getQuestState(pg.me, data.questId)

		if state == QuestConst.QUEST_STATE.COMPLETED then
			local comActionDialogueId = QuestUtils.getComActionObjcvDialogueId(data.questId)

			if comActionDialogueId and comActionDialogueId > 0 then
				pg.me:reDoQuestCompleteActions(data.questId)
			end
		elseif state == QuestConst.QUEST_STATE.UNRECEIVE and self.dialogueQuestTargetsInfo then
			local targetInfo = self.dialogueQuestTargetsInfo[data.questId]

			if targetInfo then
				if targetInfo.scene and targetInfo.markId then
					pg.game.map:removeTempMark(targetInfo.scene, targetInfo.markId)
				end

				self.dialogueQuestTargetsInfo[data.questId] = nil
			end
		end

		local combineId = QuestUtils.getCombinedId(data.questId, QuestConst.QUEST_DEFAULT_OBJ_ID)

		QuestUtils.removeQuestPathingNavEffect(combineId)
	end
end

function QuestHudNewComponent:setForceHideFlag(isHide)
	self:setHideFlag(HideReason.forceHide, isHide)
end

function QuestHudNewComponent:onBaseVisibleChanged(visible)
	if self.objectReference == nil then
		return
	end

	local flagQuest = self.visibleMap.visible and self.visibleMap.questVisible

	if self.preFlagQuest ~= flagQuest then
		LuaUIUtils.setUIViewVisible(self.objectReference.gameObject, flagQuest)
		self.view.quest:SetActive(flagQuest)

		if not flagQuest then
			self:stashPlayingTitleTip()
		end
	end

	if not pg.me then
		self.preFlagQuest = flagQuest

		return
	end

	if self.preFlagQuest ~= flagQuest and self:canRefreshOnVisibleChanged() then
		self:setFirstShowUpdate(true)

		if self.pageList and pg.global.ui:checkUIShow(UIConst.UI_ID_HUD_V2) then
			self.pageList:SetList(QuestUtils.getTabPageList())
			self:refreshSwitchKeyVisible()
		end
	end

	if flagQuest and self.firstShowUpdate then
		self:setFirstShowUpdate(false)
		self:onRefreshTracingTabPage(true)
		self.pageList:SetList(QuestUtils.getTabPageList())
		self:refreshSwitchKeyVisible()
	end

	self.preFlagQuest = flagQuest

	if flagQuest == false then
		return
	end

	self:tryReplayPendingTitleTip()
end

return QuestHudNewComponent
