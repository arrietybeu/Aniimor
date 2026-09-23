-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Component\\CommonTargetComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local BaseTipComponent = require("Guis.Panels.Tips.Component.BaseTipComponent")
local TipVisibilityHelper = require("Guis.Panels.Tips.Component.TipVisibilityHelper")
local HideReason = TipVisibilityHelper.HideReason
local LuaUIUtils = require("Utils.LuaUIUtils")
local QuestUtils = require("GameApp.Quest.QuestUtils")
local Utils = require("Common.Utils.Utils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LevelData = require("Data.level_data")
local UIConst = require("Const.UIConst")
local Time = require("Core.Common.Time")
local AddressDataConst = require("Const.AddressDataConst")
local logger = LoggerManager.getLogger("CommonTargetComponent")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local MessageName = require("Const.MessageName")
local ClientUtils = require("Utils.ClientUtils")
local TargetUtils = require("GameApp.Target.TargetUtils")
local Const = require("Common.Const.Const")
local ItemSourceData = require("Data.item_source_data")
local CommonSwitch = require("Common.CommonSwitch")
local Queue = require("Core.Framework.Queue")
local CustomTriggerData = require("Data.custom_trigger_data")
local SysConfigData = require("Data.sys_config_data")
local DungeonConst = require("Common.Const.DungeonConst")
local CommonTargetComponent = Class.LightClass("CommonTargetComponent", BaseTipComponent)

CommonTargetComponent.messages = {
	[MessageName.PLAYER_INTERACT_RECORD_ADD] = {
		"onInteractRecordAdd",
		true
	},
	[MessageName.PLAYER_INTERACT_RECORD_DELETE] = {
		"onInteractRecordDelete",
		true
	},
	[MessageName.ON_PLAYER_ENTER_SPACE] = {
		"onEnterSpace",
		true
	},
	[MessageName.UI_ON_VISIBLE_CHANGE] = {
		"onUIVisibleChanged",
		true
	},
	[MessageName.MAIN_PLAYER_CATCH_MODE_CHANGE] = {
		"onCatchModeChanged",
		true
	},
	[MessageName.DUNGEON_STATE_CHANGE] = {
		"refreshLeaveCountdown",
		true
	}
}

local targetObjcFinedTimeSpan = 1.1
local targetTracingShowTimeSpan = 1.1
local QUEST_CLICK_HINT_IN_ANI = "VX_Pb_QuestHUD_ClickHint_In"
local QUEST_CLICK_HINT_OUT_ANI = "VX_Pb_QuestHUD_ClickHint_Out"
local TARGET_CHEST_RESET_ANI = "VX_Node_Hud_GameplayTrack_Chest_In"
local ROB_EGG_LEAVE_COUNTDOWN_WARNING_INDEX = 2
local ROB_EGG_LEAVE_COUNTDOWN_WARNING_SECONDS = ((SysConfigData.GRABEGG_REMAIN_EXTRACT_TIME or EMPTY_TABLE)[ROB_EGG_LEAVE_COUNTDOWN_WARNING_INDEX] or 3) * Const.SECONDS_ONE_MINUTE
local ROB_EGG_OPENING_COUNTDOWN_TICK_OFFSET = 0.999
local ROB_EGG_LEAVE_COUNTDOWN_WARNING_COLOR = CS.UnityEngine.Color(1, 0.5843137254901961, 0.5411764705882353, 1)

function CommonTargetComponent:findObjects()
	self.visibleMap = {}
	self.container = self.transform:GetComponent("UContainer")

	self.container:LoadDefaultUrlManually(function(widget)
		self:initObjectRef()
	end)
end

function CommonTargetComponent:initView()
	self.racingTempleSceneId = 2008
	self.showTime = true
	self.targetObjcQueue = Queue.new(50)

	self:tryShowReenterTarget()

	self.hideFlags = {}
	self.priorityFlag = HideReason.priorityBreakTarget

	self:showTarget(TargetUtils.isShowCurTargetSimple())
	self:initHideFlag()
end

function CommonTargetComponent:tryShowReenterTarget()
	local reenterTargetId = TargetUtils.isReenterShowTarget()

	if not reenterTargetId or reenterTargetId <= 0 then
		return
	end

	self.isVisible = true

	self:showTarget(true)

	self.reSetObj = true

	pg.game.target:onShowTarget(reenterTargetId)
end

function CommonTargetComponent:initObjectRef()
	self.content = self.container.content
	self.objectReference = self.container.content:GetComponent("ObjectReference")
	self.txtNumUBaseText = self.objectReference:GetRefValue("txtNumUBaseText")
	self.chestUWidget = self.objectReference:GetRefValue("chestUWidget")
	self.listCatchPetBuffUList = self.objectReference:GetRefValue("listCatchPetBuffUList")
	self.optionalUWidget = self.objectReference:GetRefValue("optionalUWidget")
	self.txtOptionalUBaseText = self.objectReference:GetRefValue("txtOptionalUBaseText")
	self.selectTxtNum = self.objectReference:GetRefValue("selectTxtNum")
	self.buffList = self.objectReference:GetRefValue("buffList")
	self.chestAnimation = self.objectReference:GetRefValue("chestAnimation")
	self.leaveCountdownContainer = self.objectReference:GetRefValue("leaveCountdownContainer")
	self.rootUComponent = self.objectReference:GetRefValue("rootUComponent")
	self.tabStateObjectReference = self.objectReference:GetRefValue("tabStateObjectReference")
	self.tabObjectReference = self.objectReference:GetRefValue("tabObjectReference")
	self.detailsObjectReference = self.objectReference:GetRefValue("detailsObjectReference")

	local targetDetailsObjectReference = self:getQuestDetailsItemComs(self.detailsObjectReference)

	self.listTaskUList = targetDetailsObjectReference.questListUList
	self.btnClickUButton = targetDetailsObjectReference.clickHintBtnUButton

	local trackQuestHintComs = self:getTrackQuestHintComs(self.btnClickUButton)

	self.btnClickUButtonText = trackQuestHintComs.traceText
	self.btnClickAnimation = trackQuestHintComs.animation
	self.keyHotKeyContent = trackQuestHintComs.keyHotKeyContent
	self.questTitleNewItemComs = self:getQuestTitleNewItemComs(targetDetailsObjectReference.questTitleUComponent)
	self.txtTitleUBaseText = self.questTitleNewItemComs.textTitleUSDFText

	local tabComs = self:getQuestTabComs(self.tabObjectReference)

	self.listUList = tabComs.listUList

	function self.listUList.luaRenderItem(button, idx, objcvData)
		self:onRefreshPageItem(button, idx, objcvData)
	end

	function self.listTaskUList.luaRenderItem(button, idx, objcvData)
		self:setTargetObjectiveInfo(button, idx, objcvData)
	end

	function self.buffList.luaRenderItem(button, idx, objcvData)
		self:setTargetObjectiveBuffInfo(button, idx, objcvData)
	end

	self.content:TryChangePage("challengeState", 1)
	self.content:TryChangePage("TrackType", 1)
	self:refreshLeaveCountdown()
end

function CommonTargetComponent:isShowLeaveCountdown()
	local me = pg.me
	local space = me and me.space
	local mainSceneId = space and (space.masterDungeonSceneId or space.sceneId) or 0

	return space ~= nil and space.isGrabEgg ~= nil and space:isGrabEgg() and mainSceneId == Const.ROB_EGG_SCENE_CLIP_ID and (space.status == DungeonConst.STATUS.COUNT_DONW or space.status == DungeonConst.STATUS.PLAYING) and me.observeTargetUid == nil
end

function CommonTargetComponent:getLeaveCountdownUCountDown()
	local container = self.leaveCountdownContainer
	local content = container and container.content

	if IsNil(content) then
		return
	end

	local countDown = content:GetComponent("UCountDown")

	if NotNil(countDown) then
		return countDown
	end

	local objectReference = content:GetComponent("ObjectReference")

	if IsNil(objectReference) then
		return
	end

	countDown = objectReference:GetRefValue("countDownUCountDown")

	if IsNil(countDown) then
		countDown = objectReference:GetRefValue("countDown")
	end

	return countDown
end

function CommonTargetComponent:setLeaveCountdownState(remainTime)
	local countDown = self.leaveCountdownUCountDown

	if IsNil(countDown) then
		return
	end

	local space = pg.me and pg.me.space
	local isWarning = space and space.status == DungeonConst.STATUS.PLAYING and remainTime <= ROB_EGG_LEAVE_COUNTDOWN_WARNING_SECONDS
	local state = isWarning and 2 or 0

	if self.leaveCountdownBaseColor == nil then
		self.leaveCountdownBaseColor = countDown.baseColor
	end

	countDown:TryChangePage("State", state)

	if isWarning then
		countDown.baseColor = ROB_EGG_LEAVE_COUNTDOWN_WARNING_COLOR
	else
		countDown.baseColor = self.leaveCountdownBaseColor
	end
end

function CommonTargetComponent:stopLeaveCountdown()
	local countDown = self.leaveCountdownUCountDown

	if NotNil(countDown) then
		if self.leaveCountdownBaseColor ~= nil then
			countDown.baseColor = self.leaveCountdownBaseColor
		end

		countDown.luaCountDownUpdate = nil
		countDown.luaFinished = nil

		countDown:Stop()
	end

	self.leaveCountdownUCountDown = nil
	self.leaveCountdownBaseColor = nil
end

function CommonTargetComponent:setupLeaveCountdown()
	if not self:isShowLeaveCountdown() then
		return
	end

	local space = pg.me.space
	local endTime = space.status == DungeonConst.STATUS.COUNT_DONW and space.openingCountdownEndTime or space.end_ts
	local remainTime = math.max(0, (endTime or 0) - Time.secondCache)

	if remainTime <= 0 then
		self:stopLeaveCountdown()

		if NotNil(self.leaveCountdownContainer) then
			self.leaveCountdownContainer:SetActive(false)
		end

		return
	end

	local countDown = self:getLeaveCountdownUCountDown()

	if IsNil(countDown) then
		return
	end

	self:stopLeaveCountdown()

	self.leaveCountdownUCountDown = countDown
	countDown.positiveTiming = false

	function countDown.luaCountDownUpdate(time)
		self:setLeaveCountdownState(time or 0)
	end

	function countDown.luaFinished()
		self:setLeaveCountdownState(0)

		if NotNil(self.leaveCountdownContainer) then
			self.leaveCountdownContainer:SetActive(false)
		end
	end

	self:setLeaveCountdownState(remainTime)

	local playTime = remainTime

	if pg.me.space.status == DungeonConst.STATUS.COUNT_DONW then
		playTime = remainTime + ROB_EGG_OPENING_COUNTDOWN_TICK_OFFSET
	end

	countDown:Play(playTime)
end

function CommonTargetComponent:refreshLeaveCountdown()
	local container = self.leaveCountdownContainer

	if IsNil(container) then
		return
	end

	local isShow = self:isShowLeaveCountdown()

	container:SetActive(isShow)

	if not isShow then
		self:stopLeaveCountdown()

		return
	end

	if container:CheckURLLoaded() then
		self:setupLeaveCountdown()

		return
	end

	if self.leaveCountdownLoading then
		return
	end

	self.leaveCountdownLoading = true

	container:LoadDefaultUrlManually(function()
		self.leaveCountdownLoading = nil

		if NotNil(self.leaveCountdownContainer) then
			self:refreshLeaveCountdown()
		end
	end)
end

local questDetailsItemComs = {}

function CommonTargetComponent:getQuestDetailsItemComs(btn)
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

local questTabItemComs = {}

function CommonTargetComponent:getQuestTabComs(btn)
	if questTabItemComs[btn] == nil then
		local coms = {}
		local oRe = btn:GetComponent("ObjectReference")

		coms.rootTabAnimation = oRe:GetRefValue("rootTabAnimation")
		coms.listUList = oRe:GetRefValue("listUList")
		coms.keyObjectReference = oRe:GetRefValue("keyObjectReference")
		coms.keyHotKeyContent = oRe:GetRefValue("keyHotKeyContent")
		questTabItemComs[btn] = coms
	end

	return questTabItemComs[btn]
end

local questTitleNewItemComs = {}

function CommonTargetComponent:getQuestTitleNewItemComs(btn)
	if questTitleNewItemComs[btn] == nil then
		local coms = {}
		local oRe = btn:GetComponent("ObjectReference")

		coms.btn = btn
		coms.keyHotKeyContent = oRe:GetRefValue("keyHotKeyContent")
		coms.textTitleUSDFText = oRe:GetRefValue("textTitleUSDFText")
		questTitleNewItemComs[btn] = coms
	end

	return questTitleNewItemComs[btn]
end

local trackQuestHintComs = {}

function CommonTargetComponent:getTrackQuestHintComs(btn)
	if trackQuestHintComs[btn] == nil then
		local coms = {}
		local oRe = btn:GetComponent("ObjectReference")

		coms.btn = btn
		coms.forbidText = oRe:GetRefValue("forbidText")
		coms.keyHotKeyContent = oRe:GetRefValue("keyHotKeyContent")
		coms.traceText = oRe:GetRefValue("traceText")
		coms.animation = oRe:GetRefValue("animation")
		trackQuestHintComs[btn] = coms
	end

	return trackQuestHintComs[btn]
end

local questIconComs = {}

function CommonTargetComponent:getQuestIconComs(btn)
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
	end

	return questIconComs[btn]
end

function CommonTargetComponent:setTargetObjectiveInfo(button, idx, data)
	local objectReference = button:GetComponent("ObjectReference")
	local contentTxt = objectReference:GetRefValue("contentTxt")
	local btnPhoneUButton = objectReference:GetRefValue("btnPhoneUButton")
	local rootAnimation = objectReference:GetRefValue("rootAnimation")
	local tagPanelUWidget = objectReference:GetRefValue("tagPanelUWidget")

	if not contentTxt or not btnPhoneUButton or not rootAnimation or not tagPanelUWidget then
		return
	end

	if data.targetId == nil then
		return
	end

	local targetVal
	local totalTargetVal = TargetUtils.getConditionTargetValue(data.conditionId, 1)

	if ClientUtils.checkCondition(data.conditionId) or data.isObjFined then
		targetVal = totalTargetVal
	else
		targetVal = pg.me.triggerMap:getConditionFinishCount(data.conditionId, 1) or 0
	end

	local desc = ClientTextUtils.getLocalizationText(data.desc)
	local isCn = ClientConfigAppCountry == "cn"

	if not isCn then
		desc = string.format(" %s", desc)
	end

	local desc1, curValue, totalValue = ""

	if data.addType == Const.HUD_TARGET_ADD_TYPE.CATCH_PETS then
		curValue, totalValue = TargetUtils.getTargetCatchPetCount()
	elseif data.addType == Const.HUD_TARGET_ADD_TYPE.COMMON_CHALLENGE then
		-- block empty
	elseif data.addType == Const.HUD_TARGET_ADD_TYPE.TEMP then
		desc1, curValue, totalValue = pg.game.target:getTopProgress(data.seqid)

		if pg.me.levelItemTargetCount > 0 then
			totalValue = pg.me.levelItemTargetCount
		else
			totalValue = nil
		end
	end

	if data.targetId == Const.HUD_SPECIAL_TARGET_PUPPET_HP and data.conditionId then
		local triggerCfg = CustomTriggerData[data.conditionId]

		if triggerCfg and triggerCfg.condition and triggerCfg.condition[1] and triggerCfg.condition[1][1] == "PUPPET_HP_LE_PERCENT" then
			targetVal = 100 - targetVal
			curValue = curValue and 100 - curValue
		end
	end

	if data.showCounting and data.showCounting > 0 and totalTargetVal then
		totalValue = totalValue and totalValue > 0 and totalValue or totalTargetVal

		if curValue then
			local countingStr = string.format("[%s/%s]", curValue, totalValue)

			desc = ClientTextUtils.concatByLanguage(desc, countingStr)
		else
			local countingStr = string.format("[%s/%s]", targetVal, totalValue)

			desc = ClientTextUtils.concatByLanguage(desc, countingStr)
		end
	end

	if data.showCanSelect then
		desc = QuestUtils.questObjectiveCanSelect(desc)
	end

	if pg.game.setting:getShowDebugId() then
		desc = string.format("%d-%d-%s", data.targetId, data.conditionId, desc)
	end

	ClientTextUtils.setText(contentTxt, desc)

	local showFinishTip = data.showFinishTip and data.showFinishTip > 0

	local function playAnimSequence(animName)
		UIUtils.PlayAnimation(rootAnimation, "VX_Node_QuestHUD_Text_In_Reset_2", function()
			UIUtils.PlayAnimation(rootAnimation, animName)
		end)
	end

	button:TryChangePage("QuestType", 0)

	if showFinishTip and (data.isFined or data.isObjFined) then
		button:TryChangePage("QuestType", 1)
	end

	if data.isFined then
		button:TryChangePage("QuestState", 1)

		local npfa = data.needPlayFinishAnim or data.objcvData and data.objcvData.needPlayFinishAnim

		if showFinishTip then
			local seqid = data.seqid or data.objcvData and data.objcvData.seqid

			if npfa and pg.game.target:tryConsumeFinishAnim(data.targetId, seqid) then
				data.needPlayFinishAnim = nil

				if data.objcvData then
					data.objcvData.needPlayFinishAnim = nil
				end

				playAnimSequence("VX_Node_QuestHUD_Text_Finish")
			end
		else
			if npfa then
				data.needPlayFinishAnim = nil

				playAnimSequence("VX_Node_QuestHUD_Text_Out2")
			end

			self:startTimer(function()
				button:TryChangePage("QuestState", 0)
				UIUtils.PlayAnimation(rootAnimation, "VX_Node_QuestHUD_Text_In_Reset_2")
			end, targetObjcFinedTimeSpan, false)
			UIUtils.PlayAnimation(self.btnClickAnimation, QUEST_CLICK_HINT_OUT_ANI)
		end
	elseif data.isNew or data.objcvData and data.objcvData.isNew then
		playAnimSequence("VX_Node_QuestHUD_Text_In2")
		UIUtils.PlayAnimation(self.btnClickAnimation, QUEST_CLICK_HINT_IN_ANI)
	elseif data.isObjFined or data.objcvData and data.objcvData.isObjFined then
		button:TryChangePage("QuestState", 1)

		if showFinishTip then
			button:TryChangePage("QuestType", 1)

			local npfa = data.needPlayFinishAnim or data.objcvData and data.objcvData.needPlayFinishAnim
			local seqid = data.seqid or data.objcvData and data.objcvData.seqid

			if npfa and pg.game.target:tryConsumeFinishAnim(data.targetId, seqid) then
				data.needPlayFinishAnim = nil

				if data.objcvData then
					data.objcvData.needPlayFinishAnim = nil
				end

				playAnimSequence("VX_Node_QuestHUD_Text_Finish")
			end
		else
			playAnimSequence("VX_Node_QuestHUD_Text_Out2")
			self:startTimer(function()
				self:removeQuestObjective(self.listTaskUList, self.curObjectives, data)
				button:TryChangePage("QuestState", 0)
				UIUtils.PlayAnimation(rootAnimation, "VX_Node_QuestHUD_Text_In_Reset_2")
			end, targetObjcFinedTimeSpan, false)
		end
	else
		button:TryChangePage("QuestState", 0)
	end

	self:setTrackHint(data.targetId)
	btnPhoneUButton:SetActive(false)
	LuaUIUtils.setUIViewVisible(tagPanelUWidget, false)

	if data.desc == nil or data.desc == "" then
		button:SetActive(false)
	else
		button:SetActive(true)
	end

	button:TryChangePage("TaskType", 1)

	local timerId = TargetUtils.getReenterCurTimerId()

	if timerId and timerId > 0 then
		if self._reenterCountDownTimer then
			self:killTimer(self._reenterCountDownTimer)
		end

		self._reenterCountDownTimer = self:startTimer(function()
			self._reenterCountDownTimer = nil

			if timerId == TargetUtils.getReenterCurTimerId() then
				pg.global.ui.tips:refreshCountDownData(timerId, {
					infoText = TargetUtils.getTargetTimerText(timerId)
				})
			end
		end, targetTracingShowTimeSpan)
	end
end

function CommonTargetComponent:setTargetObjectiveBuffInfo(button, idx, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local buffUButton = objectReference:GetRefValue("buffUButton")

	if not iconUImage or not buffUButton then
		return
	end

	iconUImage.url = data.icon

	function buffUButton.luaRenderTooltip(_, component)
		local objectRef = component:GetComponent("ObjectReference")
		local txtName = objectRef:GetRefValue("txtNameUSDFText")

		ClientTextUtils.setText(txtName, data.desc)
	end
end

function CommonTargetComponent:setTrackHint(targetId)
	targetId = targetId or pg.game.target:getTargetId()

	local isTrace, pathfindId = TargetUtils.isShowTraceBtn(targetId)
	local isShowSourceBtn, sourceId = TargetUtils.canTraceItemSource(targetId)
	local isShowResetBtn, _ = TargetUtils.isShowResetBtn(targetId)
	local isTempleScene = TargetUtils.getTargetConfigAddType() == Const.HUD_TARGET_ADD_TYPE.SCENE and pg.global.scene.curScene and pg.global.scene.curScene.getClassType() == "TempleScene"

	if isTempleScene then
		isShowResetBtn = pg.game.target:getRacingStatus() and pg.game.target:getRacingStatus() >= 2
	end

	local isShowFinishRiftBtn = false

	if pg.me and pg.me.isInRiftMode and pg.me:isInRiftMode() then
		isShowFinishRiftBtn = Utils.checkIsSpaceOwner(pg.me)
	end

	if not isTrace and not isShowSourceBtn and not isShowResetBtn and not isShowFinishRiftBtn then
		self.btnClickUButton:SetActive(false)

		return
	end

	self.btnClickUButton:SetActive(true)

	function self.btnClickUButton.luaClick()
		self.btnClickUButton:InvokeCallback(CS.XGUI.EInvokeTime.User1)

		if isShowResetBtn then
			self:onResetClick()
		elseif isShowSourceBtn then
			if sourceId and sourceId > 0 then
				local data = {}

				data.clueSeekID = sourceId

				table.merge(data, ItemSourceData[sourceId])
				LuaUIUtils.clueSeek(data, nil, self.btnClickUButtonText)
			end
		elseif isTrace then
			if not self.clickCD then
				TargetUtils.addTargetPathingNavEffect(targetId)

				self.clickCD = true

				self:startTimer(function()
					self.clickCD = false
				end, 1)
			end
		elseif isShowFinishRiftBtn then
			self:onFinishRiftClick()
		end
	end

	local actionPath = "Hud/TrackOpenSpecial"
	local text = pg.getGameString("QUEST_TRACK_TEXT")

	if isShowResetBtn then
		text = pg.getGameString("TARGET_CAN_RESET_TEXT")
		actionPath = "Hud/ResetPuzzle"
	elseif isShowSourceBtn then
		text = pg.getLocalizationText(ItemSourceData[sourceId].buttonTxt) or text

		if isTempleScene then
			actionPath = "Hud/TempleHelp"
		end
	elseif isShowFinishRiftBtn then
		text = pg.getGameString("Rift_ResetGameplay")
		actionPath = "Hud/ResetRift"
	end

	ClientTextUtils.setText(self.btnClickUButtonText, text)
	self:addTraceQuestKeyBinding(self.btnClickUButton, actionPath)
	self.keyHotKeyContent:SetHotKeyPaths(actionPath)

	local group = TargetUtils.getTargetConfigGroup(targetId)
	local isCourseTarget = group and group >= Const.COURSE_TARGET_GROUP_MIN and group <= Const.COURSE_TARGET_GROUP_MAX

	if isTrace and isCourseTarget and self._lastAutoNaviTargetId ~= targetId then
		self._lastAutoNaviTargetId = targetId

		TargetUtils.addTargetPathingNavEffect(targetId)
	end
end

function CommonTargetComponent:addTraceQuestKeyBinding(btn, actionPath)
	local openSetupBind = KeyBindingPro.GetOrAddKeyBindingByName(btn.transform.gameObject, "TrackHintBtn")

	openSetupBind.actionPath = actionPath
	openSetupBind.isVirtual = false
	openSetupBind.priority = 999

	function openSetupBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			pg.game.audio:triggerEvent("SFX_UI_Event_HUDQuest_FocusDirection")
		end

		return false
	end

	return openSetupBind
end

function CommonTargetComponent:onResetClick()
	if self.isShowCurTarget then
		if TargetUtils.getTargetConfigAddType() == Const.HUD_TARGET_ADD_TYPE.SCENE and pg.global.scene.curScene.getClassType() == "TempleScene" then
			facade:sendMsgToUI(MessageName.RACESAMPLE_PAUSE_TIMER, {})
			ClientUtils.showConfirmRaw(pg.getGameString("PUZZLE_RETRY_TITLE"), pg.getGameString("PUZZLE_TELEPORT_RETRY"), function()
				facade:sendMsgToUI(MessageName.RACESAMPLE_RESTART, {})
				pg.me:resetTarget(pg.game.target:getTargetId())
				LuaUIUtils.commonHideCountDown(pg.game.target:getTargetId())
				pg.game.audio:stopBgmByLevel("RacingBGM")
			end, nil, function()
				facade:sendMsgToUI(MessageName.RACESAMPLE_RESUME_TIMER, {})
			end)
		else
			local challengeData = pg.game.challenge:getCurChallengeInfo()

			if challengeData and challengeData.resetFunc then
				local confirmExtraInfo = {
					pauseGame = true
				}

				pg.global.showConfirmMsgRaw(pg.getGameString("PUZZLE_RETRY_TITLE"), pg.getGameString("PUZZLE_TELEPORT_RETRY"), function()
					challengeData.resetFunc()
					pg.me:resetTarget(pg.game.target:getTargetId())
					pg.game.target:resetTopCurValue()
					LuaUIUtils.commonHideCountDown(pg.game.target:getTargetId())
				end, nil, nil, nil, nil, confirmExtraInfo)
			end
		end
	end
end

function CommonTargetComponent:onFinishRiftClick()
	local title = pg.getGameString("Rift_Title")
	local desc = pg.getGameString("Rift_ConfirmExit")

	pg.global.showConfirmMsgRaw(title, desc, function()
		pg.me:endFissureChallenge()
	end, nil, nil, nil)
end

function CommonTargetComponent:onStageChange(info)
	pg.game.target:setRacingStatus(info.stage)

	if pg.global.scene.curScene and pg.global.scene.curScene.getClassType() == "TempleScene" then
		self:setTrackHint()
	end
end

function CommonTargetComponent:checkIsRunning()
	return TipVisibilityHelper.checkIsRunning(self)
end

function CommonTargetComponent:clearRunningList(force)
	TipVisibilityHelper.clearRunningList(self)

	if self.preFlagTarget ~= false then
		self.preFlagTarget = false

		if NotNil(self.container) then
			self.container:SetActive(false)
		end
	end
end

function CommonTargetComponent:setShowState(state)
	self.visibleMap.visible = state
end

function CommonTargetComponent:backToHome()
	if not pg.game or not pg.game.target then
		return
	end

	self.showTime = true

	pg.game.target:onDelTarget()
	pg.game.target:onTimerClose()
end

function CommonTargetComponent:showTarget(flag)
	self.visibleMap.targetVisible = flag
	self.isShowCurTarget = flag

	self:setHideFlag(HideReason.isShowCurTarget, not self.isShowCurTarget)

	if self.ctrl and self.ctrl.refreshQuestTargetVisibleState then
		self.ctrl:refreshQuestTargetVisibleState()
	end

	self:onBaseVisibleChanged()
end

function CommonTargetComponent:checkShowState()
	local me = pg.me

	if me == nil then
		return false
	end

	if me:isInCatchMode() == true then
		return false
	end

	if not self.isShowCurTarget then
		return false
	end

	if not self.isVisible then
		return false
	end

	return true
end

function CommonTargetComponent:onUpdate()
	if not self:updateHudVisibleFlag() then
		return
	end

	if self.content == nil then
		return
	end

	if self.reSetObj then
		self.reSetObj = false

		facade:sendMsgToUI(MessageName.TARGET_ON_CHANGE, {
			targetId = TargetUtils.isReenterShowTarget(),
			refreshType = Const.HUD_TARGET_CHANGE_TYPE.IN
		})
	end

	if self.preFlagTarget then
		local curTargetId = pg.game.target:getTargetId()

		if self.preTargetId ~= curTargetId then
			self.preTargetId = curTargetId
			self.pendingTargetInfoUpdate = true
		end

		self:checkShowTargetObjc()
	end
end

function CommonTargetComponent:setDelayTime()
	if self:checkIsRunning() then
		if TargetUtils.isDelayTime() then
			if not self.delayTime then
				self.delayTime = Time.realSecondCache + 2

				return
			end

			if Time.realSecondCache < self.delayTime then
				return
			end
		end
	else
		self.delayTime = nil
	end
end

function CommonTargetComponent:onUpdateTargetInfo()
	self.content:TryChangePage("OriginalIconSize", 0)
	self:setTargetIcon()
	self:setTargetTitle()
	self:setChestInfo()

	local curTargetId = pg.game.target:getTargetId()
	local isTrace, _ = TargetUtils.isShowTraceBtn(curTargetId)
	local isShowSourceBtn, sourceId = TargetUtils.canTraceItemSource(curTargetId)

	self.btnClickUButton:SetActive(TargetUtils.isShowResetBtn() or isTrace or isShowSourceBtn)

	if TargetUtils.getTargetConfigAddType() == Const.HUD_TARGET_ADD_TYPE.SCENE and pg.global.scene.curScene and pg.global.scene.curScene.getClassType() == "TempleScene" then
		self.btnClickUButton:SetActive(isShowSourceBtn or pg.game.target:getRacingStatus() and pg.game.target:getRacingStatus() >= 2)
	elseif TargetUtils.getTargetConfigAddType() == Const.HUD_TARGET_ADD_TYPE.COMMON_CHALLENGE then
		local challengeData = pg.game.challenge:getCurChallengeInfo()

		if challengeData and challengeData.resetFunc or TargetUtils.isShowResetBtn() or isTrace or isShowSourceBtn then
			self.btnClickUButton:SetActive(true)
		else
			self.btnClickUButton:SetActive(false)
		end
	end
end

function CommonTargetComponent:setTargetIcon()
	if self.listUList then
		self.listUList:SetList({
			{}
		})
	end
end

function CommonTargetComponent:onRefreshPageItem(button, index, data)
	local pageCom = self:getQuestIconComs(button)

	if not pageCom then
		return
	end

	pageCom.btn.isSelected = true

	local icon = TargetUtils.getTargetIcon()

	pageCom.playIconUImage.url = icon

	pageCom.line:SetActive(false)
end

function CommonTargetComponent:setTargetTitle()
	local title = TargetUtils.getTargetConfigTitle()

	self.questTitleNewItemComs.btn:TryChangePage("TaskType", 1)
	ClientTextUtils.setText(self.txtTitleUBaseText, pg.getLocalizationText(title))
end

function CommonTargetComponent:setChestInfo()
	if not self:checkIsRunning() then
		return
	end

	if not TargetUtils.isShowChest() then
		self.chestUWidget:SetActive(false)

		return
	end

	local curNum, totalNum, chestFinish = TargetUtils.getTargetChestData()

	if chestFinish then
		if self._chestFinish ~= chestFinish then
			self._chestInit = true

			self.chestUWidget:SetActive(true)
			self.chestUWidget:InvokeCallback(CS.XGUI.EInvokeTime.User1)
		end
	else
		self.chestUWidget:SetActive(true)

		if self._chestInit then
			self._chestInit = false

			UIUtils.PlayAnimation(self.chestAnimation, TARGET_CHEST_RESET_ANI)
		end
	end

	self._chestFinish = chestFinish

	ClientTextUtils.setText(self.txtNumUBaseText, string.format("%s/%s", curNum, totalNum))
end

function CommonTargetComponent:checkShowTargetObjc(force)
	if self.targetObjcQueue:isEmpty() then
		return
	end

	local nextData = self.targetObjcQueue:getFirst()

	if not force and self:isShowingTarget() and nextData.refreshType ~= Const.HUD_TARGET_CHANGE_TYPE.IN then
		return
	end

	self.markShowTargetTime = Time.realtimeSinceStartup

	local data = self.targetObjcQueue:deQueue()

	if data.isNew then
		self:refreshTargetItem(data)
	elseif data.isFined or data.isObjFined then
		self:targetObjectiveChange(data)
	else
		self:refreshTargetItem(data)

		self.lastShowObjAdd = false
	end

	if self.targetObjcQueue:isEmpty() and self.pendingTargetInfoUpdate then
		self.pendingTargetInfoUpdate = nil

		self:onUpdateTargetInfo()
	end
end

function CommonTargetComponent:isShowingTarget()
	if self.markShowTargetTime == nil then
		return false
	end

	return Time.realtimeSinceStartup - self.markShowTargetTime < targetTracingShowTimeSpan
end

function CommonTargetComponent:_isSameObjectiveStructure(oldList, newList)
	if oldList == nil or newList == nil then
		return false
	end

	if #oldList ~= #newList then
		return false
	end

	for i = 1, #newList do
		local o, n = oldList[i], newList[i]

		if o == nil or n == nil then
			return false
		end

		if o.targetId ~= n.targetId or o.seqid ~= n.seqid or o.conditionId ~= n.conditionId then
			return false
		end
	end

	return true
end

function CommonTargetComponent:refreshOptionalProgress()
	local needFinishNum, totalNum = TargetUtils.getNeedFinishNum()
	local finishNum = 0
	local targetConfig = TargetUtils.getTargetConfig()
	local expression = targetConfig and targetConfig.conditionExpression

	if needFinishNum and needFinishNum > 0 and expression then
		local finishedTags = {}

		for i = 1, #expression do
			local conditionId = targetConfig["conditionId" .. i]

			if conditionId and conditionId > 0 and conditionId ~= 8 and ClientUtils.checkCondition(conditionId) then
				finishedTags[expression[i]] = true
			end
		end

		for _ in pairs(finishedTags) do
			finishNum = finishNum + 1
		end
	end

	self.optionalUWidget:SetActive(totalNum > 1 and needFinishNum < totalNum)

	if needFinishNum and needFinishNum > 0 then
		ClientTextUtils.setText(self.selectTxtNum, string.format("%s/%s", finishNum, needFinishNum))
	end
end

function CommonTargetComponent:refreshTargetItem(data)
	local newObjectives = TargetUtils.getTargetConditions(nil, nil, data)

	if self:_isSameObjectiveStructure(self.curObjectives, newObjectives) then
		self.curObjectives = newObjectives

		self.listTaskUList:SetActiveQuickly(true)

		for i = 1, #newObjectives do
			self.listTaskUList:RefreshElement(i - 1)
		end

		self:refreshTargetBuffItem()
		self:setTrackHint()
		self:refreshOptionalProgress()

		return
	end

	local allBtns = self.listTaskUList:GetAllButtons()

	for i = 0, allBtns.Length - 1 do
		local btn = allBtns[i]

		btn:InvokeCallback(CS.XGUI.EInvokeTime.Custom2)
	end

	self.listTaskUList:SetActiveQuickly(true)

	self.curObjectives = newObjectives

	self.listTaskUList:SetList(self.curObjectives)
	self:refreshTargetBuffItem()
	self:setTrackHint()
	self:refreshOptionalProgress()
end

function CommonTargetComponent:refreshTargetBuffItem()
	local flagTarget = self.visibleMap.visible and self.visibleMap.targetVisible

	if not flagTarget then
		return
	end

	if TargetUtils.getTargetConfigAddType() ~= Const.HUD_TARGET_ADD_TYPE.CATCH_PETS then
		self.buffList:SetActiveQuickly(false)

		return
	end

	self.buffList:SetActiveQuickly(true)

	self.buffs = TargetUtils.getTargetBuffs()

	self.buffList:SetList(self.buffs)

	local curValue, totalValue = TargetUtils.getTargetCatchPetCount()

	if curValue then
		facade:sendMsgToUI(MessageName.TARGET_ON_CHANGE, {
			seqid = 1,
			targetId = pg.game.target:getTargetId(),
			curValue = curValue,
			refreshType = Const.HUD_TARGET_CHANGE_TYPE.OBJECT_PROGRESS
		})
	end
end

function CommonTargetComponent:onRefreshTracingObj(itemComs, objectives, data)
	if data.refreshAll then
		data.func(data.owner)
	elseif data.isFined then
		if objectives == nil then
			return
		end

		itemComs:RefreshElement(data.objIndex - 1)
		self:refreshOptionalProgress()
	elseif data.isNew then
		self.curObjectives = TargetUtils.getTargetConditions(nil, nil, data)

		self.listTaskUList:SetList(self.curObjectives)
	elseif data.isObjFined then
		if objectives == nil then
			return
		end

		if data.objIndex then
			if objectives[data.objIndex] then
				objectives[data.objIndex].isObjFined = true
			end

			itemComs:RefreshElement(data.objIndex - 1)
		end

		self:refreshOptionalProgress()
	else
		if objectives == nil then
			return
		end

		for i = #objectives, 1, -1 do
			local objData = objectives[i]

			if objData.targetId == data.targetId and objData.seqid == data.objIndex then
				if data.isFined then
					objectives[i].isObjFined = true
				end

				itemComs:RefreshElement(i - 1)
			end
		end

		self:refreshOptionalProgress()
	end
end

function CommonTargetComponent:onTargetObjectChange(data)
	if self.ctrl and self.ctrl.refreshQuestTargetVisibleState then
		self.ctrl:refreshQuestTargetVisibleState()
	end

	local targetData = {
		refreshAll = true,
		targetId = data.targetId,
		func = self.refreshTargetItem,
		owner = self,
		refreshType = data.refreshType
	}

	if data.refreshType == Const.HUD_TARGET_CHANGE_TYPE.IN then
		self.curObjectives = nil

		if NotNil(self.listTaskUList) then
			self.listTaskUList:SetList({
				{}
			})
		end

		targetData.refreshAll = false
		targetData.isNew = true
		self.pendingTargetInfoUpdate = true
		self._lastAutoNaviTargetId = nil
	elseif data.refreshType == Const.HUD_TARGET_CHANGE_TYPE.STAGE then
		targetData.refreshAll = false
		targetData.isNew = true

		pg.game.target:resetTopCurValue()
	elseif data.refreshType == Const.HUD_TARGET_CHANGE_TYPE.OBJECT then
		targetData.subTargetList = data.subTargetList
		targetData.isObjFined = true
		targetData.needPlayFinishAnim = data.needPlayFinishAnim

		self:onTargetObjectiveChanged(data)

		if self.curObjectives ~= nil then
			targetData.needPlayFinishAnim = nil
		end

		pg.game.target:removeAllTargetPathfinding()
	elseif data.refreshType == Const.HUD_TARGET_CHANGE_TYPE.OBJECT_PROGRESS then
		self:onTargetObjectiveChanged(data)
	elseif data.refreshType == Const.HUD_TARGET_CHANGE_TYPE.CLOSE then
		pg.game.target:resetTopCurValue()
		pg.game.target:setRacingStatus(0)

		self._lastAutoNaviTargetId = nil
	end

	if data.refreshType ~= Const.HUD_TARGET_CHANGE_TYPE.OBJECT_PROGRESS and data.refreshType ~= Const.HUD_TARGET_CHANGE_TYPE.CLOSE then
		if self.targetObjcQueue:isFull() then
			self.targetObjcQueue:deQueue()
		end

		self.targetObjcQueue:enQueue(targetData)
	end
end

function CommonTargetComponent:onTargetObjectiveChanged(data)
	if self.curObjectives ~= nil then
		for i = 1, #self.curObjectives do
			local curObjcv = self.curObjectives[i]

			if data.seqid and curObjcv.targetId == data.targetId and curObjcv.seqid == data.seqid then
				curObjcv.curValue = data.curValue
				curObjcv.isNew = nil

				if data.dstValue and data.dstValue > 0 then
					curObjcv.totalValue = data.dstValue
				end

				local data1 = {
					isNew = false,
					targetId = data.targetId,
					objIndex = i,
					objcvData = curObjcv
				}

				self:onRefreshTracingObj(self.listTaskUList, self.curObjectives, data1)
			elseif data.subTargetList and self:isInSubTargetList(data.subTargetList, curObjcv.seqid) then
				local shouldAnim = false

				if data.needPlayFinishAnim and data.needPlayFinishAnim[curObjcv.seqid] then
					curObjcv.needPlayFinishAnim = true
					shouldAnim = true
				end

				local data2 = {
					isObjFined = true,
					targetId = data.targetId,
					objIndex = i,
					objcvData = curObjcv
				}

				self:onRefreshTracingObj(self.listTaskUList, self.curObjectives, data2)

				if shouldAnim then
					curObjcv.needPlayFinishAnim = nil
				end
			end
		end
	end
end

function CommonTargetComponent:targetObjectiveChange(data)
	if self.curObjectives ~= nil then
		for i = 1, #self.curObjectives do
			local curObjcv = self.curObjectives[i]

			if curObjcv.targetId == data.targetId then
				local inThisEvent = true

				if data.isObjFined and data.subTargetList then
					inThisEvent = self:isInSubTargetList(data.subTargetList, curObjcv.seqid)
				end

				if inThisEvent then
					curObjcv.isFined = data.isFined
					curObjcv.isNew = data.isNew
					curObjcv.targetId = data.targetId

					local prevIsObjFined = curObjcv.isObjFined
					local isThisObjFined = data.isObjFined

					if data.isObjFined and data.subTargetList then
						curObjcv.isObjFined = true
						isThisObjFined = true
					else
						curObjcv.isObjFined = data.isObjFined
					end

					local shouldAnim = false

					if data.needPlayFinishAnim and data.needPlayFinishAnim[curObjcv.seqid] and not prevIsObjFined then
						curObjcv.needPlayFinishAnim = true
						shouldAnim = true
					end

					local data1 = {
						targetId = data.targetId,
						objIndex = i,
						objcvData = curObjcv,
						isFined = data.isFined,
						isNew = data.isNew,
						isObjFined = isThisObjFined
					}

					self:onRefreshTracingObj(self.listTaskUList, self.curObjectives, data1)

					if shouldAnim then
						curObjcv.needPlayFinishAnim = nil
					end
				end
			end
		end
	end
end

function CommonTargetComponent:isInSubTargetList(subTargetList, seqid)
	for _, subId in ipairs(subTargetList) do
		if subId == seqid then
			return true
		end
	end

	return false
end

function CommonTargetComponent:removeQuestObjective(objcvList, objectives, data)
	if not objectives or not objcvList then
		return
	end

	local btns = objcvList:GetAllButtons()

	for i = 0, btns.Length - 1 do
		local objcvListData = objcvList:GetData(i)

		if objcvListData and data and objcvListData.seqid == data.seqid then
			for j = 1, #objectives do
				if objectives[j] and objectives[j].seqid == data.seqid and objectives[j].targetId == data.targetId then
					table.remove(objectives, j)
					objcvList:RemoveElement(i)

					break
				end
			end
		end
	end
end

function CommonTargetComponent:resetTargetState()
	pg.game.target:removeAllTargetPathfinding()

	self._lastAutoNaviTargetId = nil
	self.showTime = true
end

function CommonTargetComponent:onDittoStateChange(newState, gamePlay)
	return
end

function CommonTargetComponent:onInteractRecordAdd(info)
	self:setChestInfo()
end

function CommonTargetComponent:onInteractRecordDelete(info)
	self:setChestInfo()
end

function CommonTargetComponent:initHideFlag()
	if pg.me == nil or pg.me.space == nil then
		return
	end

	self:onEnterSpace()
	self:onUIVisibleChanged()
	self:onCatchModeChanged()
end

function CommonTargetComponent:onEnterSpace()
	if pg.me == nil or pg.me.space == nil then
		return
	end

	local me = pg.me

	if me.space:isPvpEnv() then
		self:setHideFlag(HideReason.space, true)
	else
		self:setHideFlag(HideReason.space, false)
	end

	self:tryShowReenterTarget()
	self:refreshLeaveCountdown()
	self:refreshCheckShowState()
end

function CommonTargetComponent:updateHudVisibleFlag()
	local ui = pg.global.ui
	local fullScreen = ui:getFullScreenVisibleState()
	local hudVisible = ui:checkUIShow(UIConst.UI_ID_HUD_V2)
	local inCutscene = ui:checkUIShow(UIConst.UI_ID_SKIP_PANEL) == true

	self:setHideFlag(HideReason.cutscene, inCutscene)

	local hide = not hudVisible or fullScreen or inCutscene

	self:setHideFlag(HideReason.hudVisible, not hudVisible or fullScreen)

	if hide then
		self.visibleMap.visible = false

		if self.preFlagTarget ~= false then
			self.preFlagTarget = false

			if NotNil(self.container) then
				self.container:SetActive(false)
			end
		end
	end

	return not hide
end

function CommonTargetComponent:onUIVisibleChanged()
	local ui = pg.global.ui
	local hudId = UIConst.UI_ID_HUD_V2

	self:updateHudVisibleFlag()

	if not ui:checkUIShow(hudId) or not ui:checkUIShow(UIConst.UI_ID_TIPS) then
		self:setHideFlag(HideReason.ui, true)
	else
		self:setHideFlag(HideReason.ui, false)
	end

	self:refreshCheckShowState()
end

function CommonTargetComponent:onCatchModeChanged()
	if pg.me == nil then
		return
	end

	self:setHideFlag(HideReason.catchMode, pg.me:isInCatchMode())
end

function CommonTargetComponent:refreshVisibleMap()
	return TipVisibilityHelper.refresh(self)
end

function CommonTargetComponent:refreshCheckShowState()
	self.isShowCurTarget = TargetUtils.isShowCurTargetSimple()

	return TipVisibilityHelper.refreshCheckShowState(self)
end

function CommonTargetComponent:setHideFlag(flag, isEnable)
	return TipVisibilityHelper.setHideFlag(self, flag, isEnable)
end

function CommonTargetComponent:setIsVisible(visible)
	self.isVisible = visible

	self:setHideFlag(HideReason.isVisible, not visible)
end

function CommonTargetComponent:onPriorityBreak(isShow, flag)
	self:setHideFlag(flag, isShow)
end

function CommonTargetComponent:onFullScreenShowChange(isShow)
	self:setHideFlag(HideReason.fullScreenShow, isShow)
end

function CommonTargetComponent:onDestroy()
	self:stopLeaveCountdown()

	self.leaveCountdownLoading = nil

	BaseTipComponent:onDestroy(self)

	self.preFlagTarget = nil
	self.preTargetId = nil

	for k in next, questDetailsItemComs do
		questDetailsItemComs[k] = nil
	end

	for k in next, questTabItemComs do
		questTabItemComs[k] = nil
	end

	for k in next, questTitleNewItemComs do
		questTitleNewItemComs[k] = nil
	end

	for k in next, trackQuestHintComs do
		trackQuestHintComs[k] = nil
	end

	for k in next, questIconComs do
		questIconComs[k] = nil
	end
end

function CommonTargetComponent:setForceHideFlag(isHide)
	self:setHideFlag(HideReason.forceHide, isHide)
end

function CommonTargetComponent:onBaseVisibleChanged(visible)
	local flagTarget = self.visibleMap.visible and self.visibleMap.targetVisible

	if self.preFlagTarget ~= flagTarget then
		self.container:SetActive(flagTarget)

		self.preFlagTarget = flagTarget
	end
end

return CommonTargetComponent
