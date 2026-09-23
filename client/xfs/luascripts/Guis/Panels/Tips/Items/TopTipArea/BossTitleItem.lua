-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\TopTipArea\\BossTitleItem.lua

local Class = require("Core.Framework.Class")
local BaseQueueItem = require("Guis.Panels.Tips.Items.BaseQueueItem")
local Time = require("Core.Common.Time")
local LuaUIUtils = require("Utils.LuaUIUtils")
local BuffUIUtils = require("Utils.BuffUIUtils")
local UIConst = require("Const.UIConst")
local ECSConst = require("Common.Const.ECSConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local MessageName = require("Const.MessageName")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("BossTitleItem")
local Utils = require("Common.Utils.Utils")
local TimerManager = require("Core.Timer.TimerManager")
local SysConfigData = require("Data.sys_config_data")
local BossRushUtils = require("Utils.BossRushUtils")
local BossTitleTrapInvisibleOwner = require("Utils.BossTitleTrapInvisibleOwner")
local Const = require("Common.Const.Const")
local AttributeConst = require("Common.Const.AttributeConst")
local AbilitySettingGlobalConstData = require("Data.ability_setting_global_const_data")
local DoTweenAnimMgr = DoTweenAnimMgr
local FX_RETRACT_EASE_SINEIN = CS.DG.Tweening.Ease.__CastFrom(2)
local HP_FX_RETRACT_TWEEN_ID = "bossHpFxRetract"
local BREAK_FX_RETRACT_TWEEN_ID = "bossBreakFxRetract"
local BossTitleItem = Class.LightClass("BossTitleItem", BaseQueueItem)
local ToBool = ToBool
local BOSS_TITLE_TRAP_REASON = "trap"
local BOSS_DEAD_HIDE_DURATION = 2.8
local BOSS_DEAD_UI_WHITE_LIST = {
	[UIConst.UI_ID_TIPS] = true,
	[UIConst.UI_ID_DAMAGE_NUMBER] = true
}
local BLOOD_FX_POOL_SIZE = 4
local EP_ATTRIBUTE_IDS = {
	AttributeConst.ep_cur,
	AttributeConst.ep_max_cur,
	AttributeConst.ep_temp_cur,
	AttributeConst.ep_temp_max
}
local UNLOCK_FX_TWEEN_SECOND = 0.3
local BOSS_HP_HUD_BLOOD_VX_TIME_LIMIT = 15
local SHAKE_FXVX_ANI_INVOKE_INDEX = CS.XGUI.EInvokeTime.Custom2
local BLOOD_FXVX_CUSTOM2 = CS.XGUI.EInvokeTime.Custom2
local BLOOD_FXVX_CUSTOM3 = CS.XGUI.EInvokeTime.Custom3
local BLOOD_FXVX_CUSTOM4 = CS.XGUI.EInvokeTime.Custom4
local BLOOD_FXVX_CUSTOM5 = CS.XGUI.EInvokeTime.Custom5
local BLOOD_BREAK_FXVX_ANI_DURATION = 0.2
local BLOOD_BREAK_FXVX_ANI_INVOKE_INDEX = CS.XGUI.EInvokeTime.Custom1
local BREAK_FXVX_USER1 = CS.XGUI.EInvokeTime.User1
local BREAK_FXVX_USER2 = CS.XGUI.EInvokeTime.User2
local BREAK_FXVX_CUSTOM1 = CS.XGUI.EInvokeTime.Custom1
local BREAK_FXVX_CUSTOM6 = CS.XGUI.EInvokeTime.Custom6
local BREAK_FXVX_TWEEN_SECOND = 0.5
local BREAK_FXVX_BIG_DMG_THRESHOLD = 5
local DMG_BREAK_COUNT_DOWN_END_INDEX = CS.XGUI.EInvokeTime.Custom1
local DMG_BREAK_RECOVER_END_INDEX = CS.XGUI.EInvokeTime.Custom2

function BossTitleItem:onInit()
	self.bossTitleUITimers = {}

	self:setMaxLimit(1)

	self.uContainer = self.uWidget
	self.invisibleReason = {}

	self:setVisible(false)

	self.breakState = nil
	self.buffDisappearHintTimer = {}
	self.hpState = self:newHpState()
end

function BossTitleItem:pushData(data)
	if data and data.bossMechanismIconMap then
		self.m_pendingBossMechanismIconMap = data.bossMechanismIconMap
	end

	if self:isQueueEmpty() and not self:isRunning() then
		self:enqueue(data)
	elseif data and data.bossMechanismIconMap then
		self:refreshBossMechanismIcon()
	else
		self:refreshBossTitle()
	end
end

function BossTitleItem:onUpdate()
	self:tryPopupItem()
end

function BossTitleItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	local data = self:dequeue()

	self:addRunItem(data)
	self:initUContainer(data)
end

function BossTitleItem:onClearRunningList(force)
	local data = self:firstRunItem()

	if data then
		self:recycleToast(data, force)
	end
end

function BossTitleItem:initUContainer(data)
	if not self.uContainer:CheckURLLoaded() then
		self.uContainer:LoadDefaultUrlManually(self:guardRunCallback(data, function(loadedItem)
			if IsNil(loadedItem) or self.uContainer.content ~= loadedItem then
				return
			end

			self:renderItem(loadedItem, data)
		end))
	else
		self:renderItem(self.uContainer.content, data)
	end
end

function BossTitleItem:renderItem(item, data)
	self.objectReference = item:GetComponent("ObjectReference")
	self.txtName = self.objectReference:GetRefValue("txtName")
	self.levelTxtName = self.objectReference:GetRefValue("levelTxtName")
	self.barHp = self.objectReference:GetRefValue("barHp")
	self.barShield = self.objectReference:GetRefValue("barShield")
	self.barBreak = self.objectReference:GetRefValue("barBreak")
	self.barBreakCountdown = self.objectReference:GetRefValue("barBreakCountdown")
	self.elementsList = self.objectReference:GetRefValue("elementsList")
	self.listBuff = self.objectReference:GetRefValue("listBuff")
	self.rootComponent = self.objectReference:GetRefValue("rootComponent")
	self.bloodUComponent = self.objectReference:GetRefValue("bloodUComponent")
	self.waringPaopaoUImage = self.objectReference:GetRefValue("waringPaopaoUImage")
	self.battleWarningTransform = self.objectReference:GetRefValue("battleWarningTransform")
	self.nameBossWidget = self.objectReference:GetRefValue("nameBossUWidget")
	self.imgHandleUWidget = self.objectReference:GetRefValue("imgHandleUWidget")
	self.titleUSDFText = self.objectReference:GetRefValue("titleUSDFText")
	self.bloodObjectReference = self.bloodUComponent:GetComponent("ObjectReference")
	self.vxBrokenUWidget = self.bloodObjectReference:GetRefValue("vxBrokenUWidget")
	self.breakingCountDownUCountDown = self.bloodObjectReference:GetRefValue("breakingCountDownUCountDown")
	self.vxCountdownAnimation = self.bloodObjectReference:GetRefValue("vxCountdownAnimation")
	self.breakCountDownBarBreak = self.bloodObjectReference:GetRefValue("breakCountDownBarBreak")
	self.elementToplogoUContainer = self.objectReference:GetRefValue("elementToplogoUContainer")
	self.statusEffectUContainer = self.objectReference:GetRefValue("statusEffectUContainer")
	self.addonBloodUWidget = self.objectReference:GetRefValue("addonBloodUWidget")
	self.bossStageUBaseText = self.objectReference:GetRefValue("bossStageUBaseText")
	self.firstKillUWidget = self.objectReference:GetRefValue("firstKillUWidget")
	self.hpNumUWidget = self.objectReference:GetRefValue("hpNumUWidget")
	self.hpNumUBaseText = self.objectReference:GetRefValue("hpNumUBaseText")
	self.bloodNewRectTransform = self.bloodObjectReference:GetRefValue("bloodNewRectTransform")
	self.fxVXRectTransform = self.bloodObjectReference:GetRefValue("fxVXRectTransform")
	self.epListUList = self.objectReference:GetRefValue("epListUList")
	self.m_allHpWidth = (self.bloodNewRectTransform and self.bloodNewRectTransform.sizeDelta and self.bloodNewRectTransform.sizeDelta.x or 0.1) - 8
	self.m_fxVXRectTSizeY = self.fxVXRectTransform and self.fxVXRectTransform.sizeDelta and self.fxVXRectTransform.sizeDelta.y or 0
	self.dmgBoostUWidget = self.bloodObjectReference:GetRefValue("dmgBoostUWidget")

	self.dmgBoostUWidget:SetActive(true)

	self.dmgBoostUWidget.renderOpacity = 0
	self.breakTxtUSDFText = self.bloodObjectReference:GetRefValue("breakTxtUSDFText")
	self.vXBloodHandleUWidget = self.bloodObjectReference:GetRefValue("vXBloodHandleUWidget")
	self.vXBreakHandleUWidget = self.bloodObjectReference:GetRefValue("vXBreakHandleUWidget")
	self.breakFxVXUImage = self.bloodObjectReference:GetRefValue("breakFxVXRectTransform"):GetComponent("UImage")
	self.m_breakFxVXRectTSizeY = self.breakFxVXUImage.sizeDelta.y or 0
	self.hpUWidget = self.bloodObjectReference:GetRefValue("hpUWidget")
	self.bossPropertyUContainer = self.objectReference:GetRefValue("bossPropertyUContainer")

	ClientTextUtils.setText(self.titleUSDFText, "Lv")
	self.vXBloodHandleUWidget:SetActive(true)

	self.m_isCreated = true

	self.barHp:TryChangePage("NameChar", 2)

	self.elementsList.luaRenderItem = self:guardRunCallback(data, function(button, index, data)
		if data.elementName then
			LuaUIUtils.setElementButtonNew(button, data.elementName)
		end
	end, item)
	self.listBuff.luaRenderItem = self:guardRunCallback(data, function(button, index, data)
		BuffUIUtils.setBuffInfo(button, data)
	end, item)
	self.listBuff.luaClick = self:guardRunCallback(data, function(button, data)
		local info = data

		info.targetRect = button
		info.autoVer = true

		pg.global.ui:open(UIConst.UI_ID_COMMON_BUFF_INFO_TIP, info)
	end, item)
	self.oneBallEpValue = SysConfigData.EP_VALUE_PER_BALL or 1

	if self.epListUList then
		self.epListUList.luaRenderItem = self:guardRunCallback(data, function(button, index, data)
			button:TryChangePage("state", data.state)

			button:GetChild("Progress"):GetComponent("UImage").fillAmount = data.progress
		end, item)
	end

	self:refreshBossTitle()
	self:initBloodFxPool()
	self:resetHpState()
	self:m_resetShieldBarUI()
end

function BossTitleItem:refreshEp(pawn)
	if not self.m_isCreated or not pg.space:isNpcDuel() or not pawn then
		if self.epListUList then
			self.epListUList.gameObject:SetActiveEx(false)
		end

		return
	end

	if not pawn.actorCombatAttribute then
		return
	end

	self.epBalls = self.epBalls or {}
	self.specialTempEpBalls = self.specialTempEpBalls or {}

	local curEp = pawn.actorCombatAttribute:getEp()
	local maxEp = pawn.actorCombatAttribute:getMaxEp()
	local curTempEp = pawn.actorCombatAttribute:getTempEp()
	local maxTempEp = pawn.actorCombatAttribute:getMaxTempEp()

	curEp = curEp - curTempEp
	maxEp = maxEp - maxTempEp

	local finalEpBalls = {}

	self:refreshEpBallData(self.epBalls, curEp, maxEp, finalEpBalls)
	self:refreshEpBallData(self.specialTempEpBalls, curTempEp, maxTempEp, finalEpBalls)

	if self.epListUList then
		self.epListUList:SetList(finalEpBalls)
		self.epListUList.gameObject:SetActiveEx(true)
	end
end

function BossTitleItem:bindEpRefreshNotify(target)
	if self.m_epNotifyTarget == target and self.m_epNotifyInfoList then
		return
	end

	self:unbindEpRefreshNotify()

	if not target or not pg.space:isNpcDuel() then
		return
	end

	local actorCombatAttribute = target.actorCombatAttribute

	if not actorCombatAttribute then
		return
	end

	self.m_epNotifyTarget = target
	self.m_epNotifyInfoList = {}

	self:registerEpRefreshNotify(actorCombatAttribute, target)

	if actorCombatAttribute and actorCombatAttribute.masterActorCombatAttribute then
		self:registerEpRefreshNotify(actorCombatAttribute.masterActorCombatAttribute, target)
	end
end

function BossTitleItem:registerEpRefreshNotify(actorCombatAttribute, target)
	if not actorCombatAttribute then
		return
	end

	for _, notifyInfo in ipairs(self.m_epNotifyInfoList) do
		if notifyInfo.actorCombatAttribute == actorCombatAttribute then
			return
		end
	end

	local notifyIds = {}

	local function refreshFunc()
		if self.m_epNotifyTarget == target and self.curTarget == target then
			self:refreshEp(target)
		end
	end

	for _, attributeId in ipairs(EP_ATTRIBUTE_IDS) do
		notifyIds[#notifyIds + 1] = {
			attributeId = attributeId,
			notifyId = actorCombatAttribute:registerAttributeNotify(attributeId, refreshFunc)
		}
	end

	self.m_epNotifyInfoList[#self.m_epNotifyInfoList + 1] = {
		actorCombatAttribute = actorCombatAttribute,
		notifyIds = notifyIds
	}
end

function BossTitleItem:unbindEpRefreshNotify()
	if not self.m_epNotifyInfoList then
		self.m_epNotifyTarget = nil

		return
	end

	for _, notifyInfo in ipairs(self.m_epNotifyInfoList) do
		local actorCombatAttribute = notifyInfo.actorCombatAttribute

		if actorCombatAttribute then
			for _, notifyData in ipairs(notifyInfo.notifyIds) do
				actorCombatAttribute:unregisterAttributeNotify(notifyData.attributeId, notifyData.notifyId)
			end
		end
	end

	self.m_epNotifyInfoList = nil
	self.m_epNotifyTarget = nil
end

function BossTitleItem:refreshEpBallData(epBallList, curEp, maxEp, resultList)
	local ballCount = 1
	local maxBallCount = math.ceil(maxEp / self.oneBallEpValue)

	while ballCount <= maxBallCount do
		if epBallList[ballCount] == nil then
			epBallList[ballCount] = {
				tIndex = 0,
				state = 0
			}
		end

		epBallList[ballCount].state = curEp >= ballCount * self.oneBallEpValue and 0 or 1
		epBallList[ballCount].progress = math.clamp(curEp / self.oneBallEpValue + 1 - ballCount, 0, 1)

		table.insert(resultList, epBallList[ballCount])

		ballCount = ballCount + 1
	end

	while maxBallCount < #epBallList do
		table.remove(epBallList, #epBallList)
	end
end

function BossTitleItem:setVisibleWithFlags(flag, visible)
	if visible then
		self.invisibleReason[flag] = nil
	else
		self.invisibleReason[flag] = visible
	end

	self:refreshVisible()
end

function BossTitleItem:isContentCreated()
	return self.m_isCreated and NotNil(self.rootComponent)
end

function BossTitleItem:refreshVisible()
	if not Utils.isEmptyTable(self.invisibleReason) then
		self:hideBossTitle()
		self:m_tryLogWarnInvisibleReason()
	elseif self:isContentCreated() and self.curTarget then
		self:showBossTitle()
	elseif self.visible then
		self:setVisible(false)
	end
end

function BossTitleItem:m_tryHideTrapTarget(target)
	if target and BossTitleTrapInvisibleOwner.isTargetHidden(target.actorId) then
		self.invisibleReason.HasTarget = nil
		self.invisibleReason[BOSS_TITLE_TRAP_REASON] = false

		self:refreshVisible()

		return true
	end

	if self.invisibleReason[BOSS_TITLE_TRAP_REASON] ~= nil then
		self.invisibleReason[BOSS_TITLE_TRAP_REASON] = nil
	end

	return false
end

function BossTitleItem:showBossTitle()
	if not self:isContentCreated() then
		return
	end

	if self.visible then
		return
	end

	self:setVisible(true)

	local hudCtrl = pg.global.ui.hudV2

	if hudCtrl and hudCtrl.setMapHudVisible then
		hudCtrl:setMapHudVisible("BossTile", false)
	end

	self.rootComponent:InvokeCallback(CS.XGUI.EInvokeTime.Show)

	self.lastCombatState = nil

	self:refreshCombatState()

	self.combatTimer = self:startTimer(function()
		self:refreshCombatState()
	end, 0.5, true)
end

function BossTitleItem:hideBossTitle()
	self:setVisible(false)

	local hudCtrl = pg.global.ui.hudV2

	if hudCtrl and hudCtrl.setMapHudVisible then
		hudCtrl:setMapHudVisible("BossTile", true)
	end

	if self.curTarget then
		self.curTarget:enableNotifyEcsAmount(false, ECSConst.ECS_AMOUNT_NOTIFY_OWNER.BOSS_TITLE)
	end

	self:resetHpState()
	self:unbindEpRefreshNotify()

	self.curTarget = nil

	facade:SendMessageCommand(MessageName.BOSS_TITLE_COMBAT_STATE_CHANGE, UIConst.BossCombatState.Normal)

	if self.combatTimer then
		self:killTimer(self.combatTimer)
	end

	self:clearRunningList()
end

function BossTitleItem:m_restoreBossDeadTipsEdge()
	self.bossDeadHideTipsTimer = nil

	local tipsCtrl = pg.global.ui.tips

	if tipsCtrl and tipsCtrl.forceHideEdgeTipsAndAreaC then
		tipsCtrl:forceHideEdgeTipsAndAreaC(false)
	end
end

function BossTitleItem:m_hideHudAndTipsEdgeOnBossDead()
	pg.global.ui:hideAllUIByCustomKey(UIConst.UI_HIDE_KEY.BOSS_TITLE_DEAD, BOSS_DEAD_UI_WHITE_LIST, BOSS_DEAD_HIDE_DURATION)

	if self.bossDeadHideTipsTimer then
		self:killTimer(self.bossDeadHideTipsTimer)

		self.bossDeadHideTipsTimer = nil
	end

	local tipsCtrl = pg.global.ui.tips

	if tipsCtrl and tipsCtrl.forceHideEdgeTipsAndAreaC then
		tipsCtrl:forceHideEdgeTipsAndAreaC(true)

		self.bossDeadHideTipsTimer = self:startTimer(function()
			self:m_restoreBossDeadTipsEdge()
		end, BOSS_DEAD_HIDE_DURATION, false)
	end
end

function BossTitleItem:onTargetDeadImmediately(target)
	if not self.curTarget or self.curTarget ~= target then
		return
	end

	if self.onKillPerformTimer ~= nil then
		self:killTimer(self.onKillPerformTimer)

		self.onKillPerformTimer = nil
	end

	if NotNil(self.firstKillUWidget) then
		LuaUIUtils.setUIViewVisible(self.firstKillUWidget, false)
	end

	self:setVisibleWithFlags("HasTarget", false)
end

function BossTitleItem:refreshCombatState()
	local curCombatState

	if pg.space and pg.space:isNpcDuel() then
		curCombatState = UIConst.BossCombatState.InBattle
	else
		curCombatState = LuaUIUtils.getBossTitleCombatState(self.curTarget)
	end

	if curCombatState ~= self.lastCombatState then
		self.lastCombatState = curCombatState

		facade:SendMessageCommand(MessageName.BOSS_TITLE_COMBAT_STATE_CHANGE, curCombatState)

		if curCombatState == UIConst.BossCombatState.Leaving and (self.curTarget.bossAreaEffectTaskId or self.curTarget.bossAreaEffect) then
			curCombatState = UIConst.BossCombatState.InBattle
		end

		if NotNil(self.rootComponent) then
			self.rootComponent:TryChangePage("InBattle", curCombatState)
		end
	end
end

function BossTitleItem:refreshBossTitleWhenSwitchCombat(isEnterCombat, actorId)
	local target = self.curTarget

	if target and target.actorId ~= actorId then
		return
	end

	self.cacheInCombatBossActId = isEnterCombat and actorId or nil

	self:refreshBossTitle()
end

function BossTitleItem:refreshBossTitle()
	local player = pg.me

	if player == nil or player.space == nil then
		return
	end

	if IsNil(self.uContainer.content) then
		return
	end

	local hatredBossEntityList = self:getHatredBossEntityList()
	local isHasValidBoss = #hatredBossEntityList == 1
	local target = isHasValidBoss and hatredBossEntityList[1] or nil
	local preShowCond = target and player:isInCombat()
	local curShowCond = target and target:isInCombat()

	if isHasValidBoss and curShowCond then
		if self:m_tryHideTrapTarget(target) then
			return
		end

		local oldTarget = self.curTarget
		local isSameTarget = target == oldTarget

		if oldTarget and not isSameTarget then
			oldTarget:enableNotifyEcsAmount(false, ECSConst.ECS_AMOUNT_NOTIFY_OWNER.BOSS_TITLE)
		end

		self.curTarget = target

		self.curTarget:enableNotifyEcsAmount(true, ECSConst.ECS_AMOUNT_NOTIFY_OWNER.BOSS_TITLE)
		self:setVisibleWithFlags("HasTarget", true)

		local deferred = self:m_tryPlaySwitchTargetAnimation(oldTarget, target)

		if not deferred then
			self:refreshTargetInfo(isSameTarget)
		end
	elseif self.curTarget and self.curTarget:isDead() then
		if self.onKillPerformTimer == nil then
			self:m_hideHudAndTipsEdgeOnBossDead()
			LuaUIUtils.setUIViewVisible(self.firstKillUWidget, true)
			self.rootComponent:InvokeCallback(CS.XGUI.EInvokeTime.User1)

			self.onKillPerformTimer = self:startTimer(function()
				LuaUIUtils.setUIViewVisible(self.firstKillUWidget, false)
				self:setVisibleWithFlags("HasTarget", false)

				self.onKillPerformTimer = nil
			end, 2.8, false)
		end
	else
		self:refreshBossTitleByLock(player.lockedActorId)
	end
end

function BossTitleItem:getHatredBossEntityList()
	local behatredMap = pg.me:getBehatredMap()
	local hatredBossEntityList = {}

	for actorId, _ in pairs(behatredMap) do
		local entity = pg.getEntityByActorId(actorId)

		if entity ~= nil and (Utils.isLabelBoss(entity.label) or Utils.isLabelElite(entity.label)) then
			hatredBossEntityList[#hatredBossEntityList + 1] = entity
		end
	end

	if pg.space:isNpcDuel() and pg.space:npcDuelDungeonIsReady() then
		local npcDuelCurPet = pg.space:getCurNpcDuelBotPetEntity()

		if npcDuelCurPet then
			hatredBossEntityList[#hatredBossEntityList + 1] = npcDuelCurPet
		end
	end

	return hatredBossEntityList
end

function BossTitleItem:checkIsShowBossTitle(actorId)
	return self.curTarget and self.curTarget.actorId == actorId or false
end

function BossTitleItem:refreshBossTitleByLock(lockedActorId)
	local target

	if not target and lockedActorId and lockedActorId ~= 0 then
		target = pg.getEntityByActorId(lockedActorId)
	end

	local checkValidDist = AbilitySettingGlobalConstData.forceLockDis * 3

	if not target and self.curTarget and pg.game.controller.lockHelper:checkTargetValid(self.curTarget, checkValidDist, true) then
		target = self.curTarget
	end

	local isBossOrElite = target and (Utils.isLabelBoss(target.label) or Utils.isLabelElite(target.label)) or false
	local isBossInCombat = target and target.isInCombat and target:isInCombat() or false

	if isBossOrElite and isBossInCombat then
		if self:m_tryHideTrapTarget(target) then
			return
		end

		local oldTarget = self.curTarget
		local isSameTarget = target == oldTarget

		if oldTarget and not isSameTarget then
			oldTarget:enableNotifyEcsAmount(false, ECSConst.ECS_AMOUNT_NOTIFY_OWNER.BOSS_TITLE)
		end

		self.curTarget = target

		self.curTarget:enableNotifyEcsAmount(true, ECSConst.ECS_AMOUNT_NOTIFY_OWNER.BOSS_TITLE)
		self:setVisibleWithFlags("HasTarget", true)
		self:refreshVisible()

		local deferred = self:m_tryPlaySwitchTargetAnimation(oldTarget, target)

		if not deferred then
			self:refreshTargetInfo(isSameTarget)
		end

		return
	end

	self:setVisibleWithFlags("HasTarget", false)
	self:refreshVisible()
end

function BossTitleItem:refreshTargetInfo(isSameTarget)
	local visible = self.curTarget and self:checkVisibility(self.curTarget.label)

	if visible then
		if not isSameTarget then
			self:initTargetInfo()
			self:resetHpState()
		end

		self.elementsList:SetList(LuaUIUtils.getTargetElementsInfos(self.curTarget.elementTypes))

		local characterInfo = self.curTarget.characterInfo or {}

		self:refreshLevel()
		self:refreshShield(self.curTarget)
		self:refreshHealthPoint(self.curTarget)
		self:refreshBreakBar({
			entity = self.curTarget
		})
		self:refreshBuffs({
			entId = self.curTarget.id
		})
		self:refreshElementInfo()
		self:refreshFreezeHp()
		self:refreshBossStage()
		self:bindEpRefreshNotify(self.curTarget)
		self:refreshEp(self.curTarget)
		self:refreshBossMechanismIcon()
	else
		self:unbindEpRefreshNotify()
		self:refreshVisible()
	end
end

function BossTitleItem:checkVisibility(label)
	if pg.space:isNpcDuel() and pg.space:npcDuelDungeonIsReady() then
		return true
	end

	if label ~= nil then
		return Utils.isLabelBoss(label) or Utils.isLabelElite(label)
	else
		return false
	end
end

function BossTitleItem:refreshBossStage(isInit)
	if not self.m_isCreated then
		return
	end

	if not self.curTarget then
		return
	end

	if not pg.me.space:isBossRushEnv() then
		return
	end

	local newStage = pg.space.levelStage or 0

	if self.lastBossRushStage == newStage then
		return
	end

	self.lastBossRushStage = newStage

	if not isInit and newStage ~= 0 then
		self.rootComponent:InvokeCallback(CS.XGUI.EInvokeTime.User2)
	end

	local totalHpCount = BossRushUtils.getBossTotalHpCount()

	ClientTextUtils.setText(self.hpNumUBaseText, "x", totalHpCount - newStage)
end

function BossTitleItem:getBossTitleStagePos()
	if not self.hpNumUBaseText then
		return
	end

	return self.hpNumUBaseText.transform.position
end

function BossTitleItem:m_clearStatusEffectHideTimer()
	if self.bossTitleUITimers.delayHideStatuesEfxTimer then
		TimerManager.removeTimer(self.bossTitleUITimers.delayHideStatuesEfxTimer)

		self.bossTitleUITimers.delayHideStatuesEfxTimer = nil
	end
end

function BossTitleItem:m_showSpecialStateBuff(specialStateBuff)
	if IsNil(self.statusEffectUContainer) or not specialStateBuff then
		return
	end

	self:m_clearStatusEffectHideTimer()

	self.m_statusEffectLoadReqId = (self.m_statusEffectLoadReqId or 0) + 1

	local reqId = self.m_statusEffectLoadReqId
	local target = self.curTarget
	local container = self.statusEffectUContainer

	local function applyStateEffect()
		if self.m_statusEffectLoadReqId ~= reqId then
			return
		end

		if not self.m_isCreated or self.curTarget ~= target or IsNil(container) then
			return
		end

		if not container.content then
			return
		end

		self.curSpecialStateBuff = specialStateBuff

		self.nameBossWidget:SetActive(false)
		BuffUIUtils.setStateEffectBuff(container.content, specialStateBuff)
		container:SetActive(true)
	end

	if container:CheckURLLoaded() then
		applyStateEffect()
	else
		container:LoadDefaultUrlManually(function()
			applyStateEffect()
		end)
	end
end

function BossTitleItem:m_hideSpecialStateBuffWithDelay()
	self.m_statusEffectLoadReqId = (self.m_statusEffectLoadReqId or 0) + 1
	self.curSpecialStateBuff = nil

	if IsNil(self.statusEffectUContainer) or not self.statusEffectUContainer.content then
		return
	end

	self.statusEffectUContainer.content:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
	self:m_clearStatusEffectHideTimer()

	self.bossTitleUITimers.delayHideStatuesEfxTimer = TimerManager.addTimer(0.6, function()
		self.nameBossWidget:SetActive(true)
		self.statusEffectUContainer:SetActive(false)

		self.bossTitleUITimers.delayHideStatuesEfxTimer = nil
	end)
end

function BossTitleItem:refreshBuffs(info)
	if not self.m_isCreated then
		return
	end

	local entId = info.entId

	if self.curTarget and self.curTarget.id == entId then
		local buffData, specialStateBuff = BuffUIUtils.getUIBuffList(self.curTarget, SysConfigData.bossTitleBuffCount or 6)

		BuffUIUtils.filterEcsBuff(buffData)
		self.listBuff:SetList(buffData)

		self.curBuffList = buffData

		if specialStateBuff then
			self:m_showSpecialStateBuff(specialStateBuff)
		else
			self:m_hideSpecialStateBuffWithDelay()
		end

		local should, delayTime, instanceId = BuffUIUtils.checkBuffDisappearHint(self, info and info.newBuffData)

		if should then
			self.buffDisappearHintTimer[instanceId] = TimerManager.addTimer(delayTime, function()
				BuffUIUtils.invokeDisappearHintFx(self.listBuff, self.curBuffList, instanceId)
			end)
		end
	end

	self:refreshEcsAmount(self.curTarget)
end

function BossTitleItem:onBuffAdd(info)
	if not self.m_isCreated or not self.curTarget or not info or self.curTarget.id ~= info.entId then
		return
	end

	local buffData = info.newBuffData

	if not buffData then
		return
	end

	if BuffUIUtils.checkIsElementBuff(buffData.templateId) then
		self:refreshEcsAmount(self.curTarget)

		return
	end

	if not self.curBuffList then
		return
	end

	local buffInfo = BuffUIUtils._addBuffInfo(buffData, self.curTarget, {})

	if buffInfo then
		local maxCount = SysConfigData.bossTitleBuffCount or 6
		local idx = BuffUIUtils.computeInsertIndex(self.curBuffList, buffInfo, maxCount)

		if idx > 0 then
			if maxCount <= #self.curBuffList then
				BuffUIUtils.tryRemoveBuff(self.listBuff, self.curBuffList, #self.curBuffList)
			end

			BuffUIUtils.tryInsertBuff(self.listBuff, self.curBuffList, idx, buffInfo)

			local newSpecial = BuffUIUtils.updateSpecialStateBuff(self.curSpecialStateBuff, buffData, self.curTarget)

			if newSpecial and newSpecial ~= self.curSpecialStateBuff then
				self:m_showSpecialStateBuff(newSpecial)
			end

			local should, delayTime, instanceId = BuffUIUtils.scheduleDisappearHint(self, buffInfo)

			if should then
				self.buffDisappearHintTimer[instanceId] = TimerManager.addTimer(delayTime, function()
					BuffUIUtils.invokeDisappearHintFx(self.listBuff, self.curBuffList, instanceId)
				end)
			end
		end
	end

	self:refreshEcsAmount(self.curTarget)
end

function BossTitleItem:onBuffRemove(info)
	if not self.m_isCreated or not self.curTarget or not info or self.curTarget.id ~= info.entId then
		return
	end

	local instanceId = info.buffInsId

	BuffUIUtils.clearBuffDisappearHintTimer(self, instanceId)

	if self.curBuffList then
		local idx = BuffUIUtils.findBuffIndex(self.curBuffList, instanceId)

		if idx > 0 then
			BuffUIUtils.tryRemoveBuff(self.listBuff, self.curBuffList, idx)
		end
	end

	if self.curSpecialStateBuff and self.curSpecialStateBuff.instanceId == instanceId then
		local newSpecial = BuffUIUtils.computeSpecialStateBuff(self.curBuffList)

		if newSpecial then
			self:m_showSpecialStateBuff(newSpecial)
		else
			self:m_hideSpecialStateBuffWithDelay()
		end
	end

	self:refreshEcsAmount(self.curTarget)
end

function BossTitleItem:onBuffExpiredTimeChange(info)
	if not self.m_isCreated or not self.curTarget or not info or self.curTarget.id ~= info.entId then
		return
	end

	if self.curBuffList then
		local buffInfo = BuffUIUtils.updateBuffExpiredTime(self.listBuff, self.curBuffList, info)

		if buffInfo then
			local should, delayTime, instanceId = BuffUIUtils.rescheduleDisappearHint(self, buffInfo)

			if should then
				self.buffDisappearHintTimer[instanceId] = TimerManager.addTimer(delayTime, function()
					BuffUIUtils.invokeDisappearHintFx(self.listBuff, self.curBuffList, instanceId)
				end)
			end
		end
	end
end

function BossTitleItem:onBuffLayerChange(info)
	local entId = info.entId

	self:refreshEcsAmount(self.curTarget)

	if self.curTarget and self.curTarget.id == entId then
		BuffUIUtils.applyLayerChange(self.listBuff, self.curBuffList, info)
	end
end

function BossTitleItem:initTargetInfo()
	local target = self.curTarget
	local npcInfo = target:getConfigData()
	local shinyName = ""

	if Utils.isLabelShiny(target.label) then
		shinyName = pg.getGameString("SHINY")
	end

	if Utils.isLabelBoss(target.label) then
		local fullName = ClientTextUtils.concatByLanguage(pg.getLocalizationText(shinyName), pg.getLocalizationText(npcInfo.BossShowName or ""))

		ClientTextUtils.setText(self.txtName, fullName)
		self.rootComponent:TryChangePage("Enemy", "Boss")
	elseif Utils.isLabelElite(target.label) then
		local fullName = ClientTextUtils.concatByLanguage(pg.getLocalizationText(shinyName), pg.getLocalizationText(npcInfo.EliteShowName or ""))

		ClientTextUtils.setText(self.txtName, fullName)
		self.rootComponent:TryChangePage("Enemy", "Elite")
	elseif pg.space:isNpcDuel() then
		local fullName = pg.me:npcDuelGetCurPetName()

		ClientTextUtils.setText(self.txtName, fullName)
		self.rootComponent:TryChangePage("Enemy", "Boss")
	else
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("BossTitleCtrl:current target label", target.label)
		end

		self:refreshVisible()
	end

	if target.gender == Const.GENDER_TYPE_MALE then
		self.rootComponent:TryChangePage("Gender", 0)
	elseif target.gender == Const.GENDER_TYPE_FEMALE then
		self.rootComponent:TryChangePage("Gender", 1)
	else
		self.rootComponent:TryChangePage("Gender", 2)
	end

	local multiHpBar = self.curTarget:getConfigData().mutiHpBar or 1
	local showMultiHpBar = multiHpBar > 1 or pg.me.space:isBossRushEnv()

	self.addonBloodUWidget:SetActive(showMultiHpBar)
	self.hpNumUWidget:SetActive(showMultiHpBar)

	if pg.me.space:isBossRushEnv() then
		self:refreshBossStage(true)
	elseif multiHpBar > 1 then
		ClientTextUtils.setText(self.hpNumUBaseText, "x", multiHpBar)
	end

	self:refreshFreezeHp()

	if npcInfo.bossType ~= nil then
		if npcInfo.bossType == 1 then
			self.rootComponent:TryChangePage("BossType", 1)
		elseif npcInfo.bossType == 2 then
			self.rootComponent:TryChangePage("BossType", 2)
		else
			self.rootComponent:TryChangePage("BossType", 0)
		end
	end
end

function BossTitleItem:onEntElementChange(entInfo)
	if not self.m_isCreated then
		return
	end

	local entId = entInfo.entId

	if self.curTarget and self.curTarget.id == entId then
		self:refreshElementInfo()
	end
end

function BossTitleItem:start()
	local visible = self.curTarget and self:checkVisibility(self.curTarget.label)

	self:setVisible(visible)
	self:onStart()
end

function BossTitleItem:refreshElementInfo()
	if not self.m_isCreated then
		return
	end

	if self.curTarget then
		self.elementsList:SetList(LuaUIUtils.getTargetElementsInfos(self.curTarget.elementTypes))
	end
end

function BossTitleItem:refreshLevel()
	if not self.curTarget or not self.levelTxtName then
		return
	end

	local level = self.curTarget.level

	if not level then
		return
	end

	ClientTextUtils.setText(self.levelTxtName, level)
end

function BossTitleItem:refreshBreakBar(data, isIgnoreHpLock)
	if not self.m_isCreated then
		return
	end

	local entity = data.entity or {}
	local deltaBp = data.deltaBp or 0
	local info = Utils.getEntityBreakInfo(entity)

	if self.curTarget and self.curTarget.id ~= entity.id then
		return
	end

	self.isPreInBreak = self.isPreInBreak or false
	self.isCurInBreak = info and info.inBreakStatus

	if self.isCurInBreak then
		pg.game.audio:triggerEvent("ui_sfx_parmon_break")
		self.rootComponent:TryChangePage("Break", 1)

		self.dmgBoostUWidget.renderOpacity = 1

		if self.curTarget then
			self.breakTxtUSDFText.text = string.format("%d%%", (1 + self.curTarget.actorCombatAttribute:getAttribValue(AttributeConst.break_base_dmg_ratio)) * 100)
		end

		if self.imgHandleUWidget then
			self.imgHandleUWidget:SetActive(false)
		end

		if not self.isPreInBreak and not isIgnoreHpLock then
			self:onBreakStarted(entity, isIgnoreHpLock)
		end

		if info.breakBuffFreezeTime ~= 0 then
			self.breakingCountDownUCountDown:SetActive(true)
			self.breakingCountDownUCountDown:Play(math.max(info.breakEndTime - info.breakBuffFreezeTime, 0.01))
			self.breakingCountDownUCountDown:Stop()

			self.breakState = UIConst.BLOOD_BREAK_STATE.STATE_BREAK
			self.breakCountDownBarBreak.hp = 0
		else
			self:setBp(0, 0, info.maxBp)

			local now = pg.me:getGameTime()

			if ToBool(info.breakRecoverEndTime) then
				if self.breakState ~= UIConst.BLOOD_BREAK_STATE.STATE_BREAK_RECOVER then
					self.vxCountdownAnimation:Play("VX_Node_HUD_HP_BOSS_Break_Loop_Disappear")
					self.dmgBoostUWidget:InvokeCallback(DMG_BREAK_COUNT_DOWN_END_INDEX)
				end

				self.breakState = UIConst.BLOOD_BREAK_STATE.STATE_BREAK_RECOVER

				local startTime = info.breakRecoverEndTime - info.breakRecoverTime
				local curVale = math.max(0.01, now - startTime)

				self:setBp(0, 0, info.breakRecoverTime)

				if info.breakRecoverFreezeTime == 0 then
					self.barBreakCountdown:Play(curVale, math.max(info.breakRecoverTime, 0.01))
				else
					self.barBreakCountdown:Play(math.max(info.breakRecoverEndTime - info.breakRecoverFreezeTime, 0.01), math.max(info.breakRecoverTime, 0.01))
					self.breakingCountDownUCountDown:Stop()
				end
			else
				self.breakingCountDownUCountDown:SetActive(true)

				if self.breakState ~= UIConst.BLOOD_BREAK_STATE.STATE_BREAK then
					self.vxCountdownAnimation:Play("VX_Node_HUD_HP_BOSS_Break_Loop")
				end

				self:setBp(0, 0, info.breakTime)

				local countDownTime = math.max(math.min(info.breakTime, info.breakEndTime - now), 0.01)

				self.breakingCountDownUCountDown:Play(countDownTime)

				self.breakState = UIConst.BLOOD_BREAK_STATE.STATE_BREAK
				self.breakCountDownBarBreak.hp = 0
			end
		end
	elseif self.breakState then
		self.breakState = nil

		self.vxCountdownAnimation:Play("VX_Node_HUD_HP_BOSS_Break_Recover")

		if self.hpUWidget then
			self.hpUWidget:SetActive(false)
		end

		self.barBreakCountdown:Stop()

		if self.bossTitleUITimers.m_revertBreakStateTimer then
			TimerManager.removeTimer(self.bossTitleUITimers.m_revertBreakStateTimer)

			self.bossTitleUITimers.m_revertBreakStateTimer = nil
		end

		self.bossTitleUITimers.m_revertBreakStateTimer = TimerManager.addTimer(0.8, function()
			self.bossTitleUITimers.m_revertBreakStateTimer = nil

			self.rootComponent:TryChangePage("Break", 0)

			if self.hpUWidget then
				self.hpUWidget:SetActive(true)
			end
		end)

		self.dmgBoostUWidget:InvokeCallback(DMG_BREAK_RECOVER_END_INDEX)

		if self.imgHandleUWidget then
			self.imgHandleUWidget:SetActive(true)
		end

		self:setBp(info.maxBp - info.curBp, deltaBp, info.maxBp, false)
		self.breakingCountDownUCountDown:SetActive(false)
		self:onBreakEnded(entity, isIgnoreHpLock)
	else
		self.dmgBoostUWidget.renderOpacity = 0

		self.barBreakCountdown:Stop()
		self:setBp(info.maxBp - info.curBp, deltaBp, info.maxBp)

		self.breakState = nil

		self.breakingCountDownUCountDown:SetActive(false)
	end

	self.isPreInBreak = self.isCurInBreak
end

function BossTitleItem:refreshShield(entity)
	if not self.m_isCreated then
		return
	end

	entity = entity or {}

	if self.curTarget and self.curTarget.id ~= entity.id then
		return
	end

	LuaUIUtils.setShieldBar(self.curTarget, nil, self.barShield)
end

function BossTitleItem:onShieldBreak(entity)
	if not self.m_isCreated then
		return
	end

	if self.curTarget and self.curTarget.id ~= entity.id then
		return
	end

	self.barShield:InvokeCallback(CS.XGUI.EInvokeTime.Custom6)

	if self.bossTitleUITimers.delayHideShieldTimer then
		TimerManager.removeTimer(self.bossTitleUITimers.delayHideShieldTimer)

		self.bossTitleUITimers.delayHideShieldTimer = nil
	end

	self.bossTitleUITimers.delayHideShieldTimer = TimerManager.addTimer(1, function()
		self.bossTitleUITimers.delayHideShieldTimer = nil

		self.barShield:SetActive(false)
	end)
end

function BossTitleItem:m_resetShieldBarUI()
	if not self.m_isCreated then
		return
	end

	if not self.m_resetedShieldBarUI then
		self.barShield:SetActive(false)

		self.m_resetedShieldBarUI = true
	end
end

function BossTitleItem:m_tryPlaySwitchTargetAnimation(oldTarget, newTarget)
	if not self.m_isCreated or not self.rootComponent then
		return false
	end

	if oldTarget == nil or oldTarget == newTarget then
		return false
	end

	self.m_isSwitchTargetFadingOut = true

	self.rootComponent:InvokeCallback(CS.XGUI.EInvokeTime.Custom4)

	if self.bossTitleUITimers.m_switchTargetFadeInTimer then
		TimerManager.removeTimer(self.bossTitleUITimers.m_switchTargetFadeInTimer)

		self.bossTitleUITimers.m_switchTargetFadeInTimer = nil
	end

	self.bossTitleUITimers.m_switchTargetFadeInTimer = TimerManager.addTimer(0.13, function()
		self.bossTitleUITimers.m_switchTargetFadeInTimer = nil
		self.m_isSwitchTargetFadingOut = false

		local valid = self.m_isCreated and NotNil(self.rootComponent) and self.curTarget == newTarget

		if valid then
			self:refreshTargetInfo(false)

			if pg.space:isNpcDuel() then
				self.rootComponent:InvokeCallback(CS.XGUI.EInvokeTime.User3)
			else
				self.rootComponent:InvokeCallback(CS.XGUI.EInvokeTime.Custom5)
			end
		end
	end)

	return true
end

function BossTitleItem:getHpDisplayRatio(curHp, maxHp)
	return math.clamp(curHp / (maxHp - 0.01), 0, 1)
end

function BossTitleItem:refreshHpDisplay(entity)
	local state = self.hpState
	local rawCurHp = entity.curHp or 0
	local rawMaxHp = entity.maxHp or 1
	local displayCurHp, displayMaxHp = rawCurHp, rawMaxHp
	local barSize = rawMaxHp
	local configData = entity:getConfigData()
	local multiHpBar = configData.mutiHpBar or 1

	if pg.space:isBossRushEnv() then
		local grade, curValue, maxValue = BossRushUtils.getBossCurHpState(rawCurHp, rawMaxHp)

		state.hideAddonBlood = BossRushUtils.checkIsBossLastHp(rawCurHp, rawMaxHp)
		state.curStage = BossRushUtils.getBossTotalHpCount() - grade + 1
		displayCurHp = curValue
		displayMaxHp = maxValue
		barSize = maxValue
	elseif multiHpBar > 1 then
		local oneHpBar = rawMaxHp / multiHpBar
		local curStage = math.min(math.floor(rawCurHp / oneHpBar) + 1, multiHpBar)

		displayCurHp = rawCurHp % oneHpBar
		displayMaxHp = oneHpBar
		barSize = oneHpBar
		state.curStage = curStage
		state.hideAddonBlood = curStage <= 1
	else
		state.curStage = nil
		state.hideAddonBlood = nil
	end

	state.rawCurHp = rawCurHp
	state.rawMaxHp = rawMaxHp
	state.displayCurHp = displayCurHp
	state.displayMaxHp = displayMaxHp
	state.barSize = barSize > 0 and barSize or 1
	state.curRatio = self:getHpDisplayRatio(displayCurHp, displayMaxHp)
end

function BossTitleItem:applyHpToBar(isFirstSet)
	local state = self.hpState

	if state.hideAddonBlood then
		self.addonBloodUWidget:SetActive(false)
	end

	if state.curStage and self.lastBossStage ~= state.curStage then
		self.lastBossStage = state.curStage

		if state.curStage ~= 0 then
			self.rootComponent:InvokeCallback(CS.XGUI.EInvokeTime.User2)
		end

		ClientTextUtils.setText(self.hpNumUBaseText, "x", state.curStage)
	end

	self.barHp.maxHp = state.displayMaxHp

	if isFirstSet and pg.space:isNpcDuel() then
		self.barHp.hp = state.displayCurHp
	end

	self.barHp.hp = state.displayCurHp
end

function BossTitleItem:refreshHealthPoint(entity)
	if not self.m_isCreated then
		return
	end

	if self.curTarget and self.curTarget.id ~= entity.id then
		return
	end

	local newCurHp = entity and entity.curHp

	if newCurHp ~= nil and self.m_lastSyncedCurHp ~= nil and math.abs(self.m_lastSyncedCurHp - newCurHp) < 0.01 then
		return
	end

	local isFirstSet = self.m_lastSyncedCurHp == nil
	local preRawHp = self.m_lastSyncedCurHp or newCurHp or 0

	self.m_lastSyncedCurHp = newCurHp

	if self.m_isSwitchTargetFadingOut then
		return
	end

	if entity and self.barHp then
		local preStage = self.hpState.curStage

		self:refreshHpDisplay(entity)
		self:applyHpToBar(isFirstSet)
		self:onHpDisplayChanged(preRawHp, preStage)
	else
		self.hpState.curRatio = 0
	end
end

function BossTitleItem:setBp(curValue, deltaValue, maxValue)
	if not self.m_isCreated then
		return
	end

	self.barBreak:SetActive(true)

	curValue = curValue * 100
	deltaValue = deltaValue * 100
	maxValue = maxValue * 100

	local preValue = self.barBreak.hp or curValue

	self.barBreak.maxHp = maxValue
	self.barBreak.hp = curValue

	self:refreshBreakState(curValue, maxValue)
	self:refreshBreakShake(curValue, deltaValue, maxValue)

	if self.isBpInit then
		self.isBpInit = nil
	else
		self:onBreakBarDamage(preValue, curValue, maxValue)
	end
end

function BossTitleItem:refreshBreakState(curValue, maxValue)
	if not self.m_isCreated then
		return
	end

	local config = SysConfigData.BREAK_STATE_CUTOFF
	local cutoffLower = config[1] < config[2] and config[1] or config[2]
	local cutoffUpper = config[1] < config[2] and config[2] or config[1]
	local percent = curValue / maxValue

	if percent >= 0 and percent < cutoffLower then
		self.rootComponent:TryChangePage("BreakState", "Low")
	elseif cutoffLower <= percent and percent < cutoffUpper then
		self.rootComponent:TryChangePage("BreakState", "Middle")
	else
		self.rootComponent:TryChangePage("BreakState", "High")
	end
end

function BossTitleItem:refreshBreakShake(curValue, deltaValue, maxValue)
	if not self.m_isCreated then
		return
	end

	if deltaValue <= 0 or maxValue <= 0 then
		return
	end

	local config = SysConfigData.BREAK_VIBRATION_CUTOFF
	local cutoffLower = config[1] < config[2] and config[1] or config[2]
	local cutoffUpper = config[1] < config[2] and config[2] or config[1]
	local percent = curValue / maxValue

	if percent < cutoffLower then
		self.bloodUComponent:InvokeCallback(BREAK_FXVX_USER2)
	elseif percent < cutoffUpper then
		self.bloodUComponent:InvokeCallback(BREAK_FXVX_USER1)
	end
end

function BossTitleItem:refreshFreezeHp(info)
	if not self.m_isCreated then
		return
	end

	if self.curTarget and self.curTarget:FREEZE_HP_ST() then
		self.bloodUComponent:TryChangePage("PaopaoHit", 1)
	else
		self.bloodUComponent:TryChangePage("PaopaoHit", 0)
	end
end

function BossTitleItem:onFreezeHpHit()
	if self.curTarget and self.curTarget:FREEZE_HP_ST() then
		self.bloodUComponent:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
	end
end

function BossTitleItem:onFreezeHpOutTime(info)
	if not self.m_isCreated then
		return
	end

	local isOutTime = info[1]
	local alpha = info[2]

	if self.curTarget and self.curTarget:FREEZE_HP_ST() then
		self.waringPaopaoUImage.gameObject:SetActiveEx(isOutTime)

		if isOutTime then
			self.waringPaopaoUImage.renderOpacity = alpha or 1
		else
			self.waringPaopaoUImage.renderOpacity = 1
		end
	end
end

function BossTitleItem:onDestroy()
	BaseQueueItem.onDestroy(self)

	if self.curTarget then
		self.curTarget:enableNotifyEcsAmount(false, ECSConst.ECS_AMOUNT_NOTIFY_OWNER.BOSS_TITLE)
	end

	for _, timerId in pairs(self.buffDisappearHintTimer) do
		TimerManager.removeTimer(timerId)
	end

	BuffUIUtils.tryDestroyEleBuffsTimer(self)

	if next(self.bossTitleUITimers) then
		for k, v in pairs(self.bossTitleUITimers) do
			TimerManager.removeTimer(v)

			self.bossTitleUITimers[k] = nil
		end
	end

	self.bossTitleUITimers = {}

	self:destroyBloodFxPool()
	self:unbindEpRefreshNotify()
	self:setVisible(false)

	if NotNil(self.uContainer.content) then
		self.uContainer:DestroyContent()
	end

	self.m_isCreated = false
	self.rootComponent = nil
	self.curBuffList = nil
end

function BossTitleItem:onSetVisible(visible)
	facade:SendMessageCommand(MessageName.BOSS_TITLE_SHOWN_MESSAGE, {
		visible = visible
	})
end

function BossTitleItem:setVisible(visible)
	if not visible then
		self.breakState = nil
	end

	BossTitleItem.super.setVisible(self, visible)
end

function BossTitleItem:refreshEcsAmount(ent)
	if not self.curTarget then
		BuffUIUtils.tryDestroyEleBuffsTimer(self)

		return
	end

	if self.curTarget ~= ent then
		BuffUIUtils.tryDestroyEleBuffsTimer(self)

		return
	end

	self:refreshBossThreatLevel(self.curTarget, not ToBool(self.curTarget:getConfigData().hideBloodLevel))

	if not self.elementToplogoUContainer then
		BuffUIUtils.tryDestroyEleBuffsTimer(self)

		return
	end

	if not self.elementToplogoUContainer:CheckURLLoaded() then
		BuffUIUtils.tryDestroyEleBuffsTimer(self)
		self.elementToplogoUContainer:LoadDefaultUrlManually(function()
			self:refreshEcsAmount(ent)
		end)

		return
	end

	if self.curTarget and self.curTarget.ecsAmountCache and self.curTarget.ecsAmountCache.maxElementType and self.curTarget.ecsAmountCache.maxValue > 0 then
		self.elementToplogoUContainer:SetActiveFastest(true)
		BuffUIUtils.setElementBuff(self.elementToplogoUContainer.content:GetComponent("UButton"), self.curTarget, self)
	else
		self.elementToplogoUContainer:SetActiveFastest(false)
		BuffUIUtils.tryDestroyEleBuffsTimer(self)
	end
end

function BossTitleItem:refreshBossThreatLevel(target, forceVisible)
	if not self.rootComponent or not self.levelTxtName then
		return
	end

	if self.bossTitleUITimers.m_showLeveTxtTimer then
		TimerManager.removeTimer(self.bossTitleUITimers.m_showLeveTxtTimer)

		self.bossTitleUITimers.m_showLeveTxtTimer = nil
	end

	local level = target and target.level

	if not forceVisible or not level then
		LuaUIUtils.setUIViewVisible(self.levelTxtName, false)
		self.rootComponent:TryChangePage("BattleWarning", 0)

		return
	end

	ClientTextUtils.setText(self.levelTxtName, level)
	LuaUIUtils.setUIViewVisible(self.levelTxtName, true)

	local threatState = LuaUIUtils.getThreatLevelState(level)

	self.rootComponent:TryChangePage("Threat", threatState)

	if threatState == "dangerous" then
		self.rootComponent:TryChangePage("BattleWarning", 1)
	elseif threatState == "veryDangerous" then
		self.rootComponent:TryChangePage("BattleWarning", 2)
	else
		self.rootComponent:TryChangePage("BattleWarning", 0)
	end
end

function BossTitleItem:onHpDisplayChanged(preRawHp, preStage)
	local state = self.hpState
	local rawDelta = preRawHp - state.rawCurHp
	local isHpReduced = rawDelta > 0
	local bottomRatio = math.clamp(state.curRatio, 0, 1)
	local anchorRatio = math.clamp(bottomRatio + rawDelta / state.barSize, 0, 1)
	local isBreakHpFx = self.breakState == UIConst.BLOOD_BREAK_STATE.STATE_BREAK or self.breakState == UIConst.BLOOD_BREAK_STATE.STATE_BREAK_RECOVER

	if not isHpReduced then
		return
	end

	local isCrossBar = preStage ~= nil and state.curStage ~= nil and preStage > state.curStage

	if isCrossBar then
		local lastAnchor = (bottomRatio + rawDelta / state.barSize - (preStage - state.curStage)) % 1

		self:accumulateBloodFx(lastAnchor, 0)
		self:retractBloodFx(0, UNLOCK_FX_TWEEN_SECOND)
		self:accumulateBloodFx(1, bottomRatio)
		self.rootComponent:InvokeCallback(SHAKE_FXVX_ANI_INVOKE_INDEX)
	end

	self:accumulateBloodFx(anchorRatio, bottomRatio)

	if isBreakHpFx then
		self.rootComponent:InvokeCallback(BLOOD_FXVX_CUSTOM2)
	else
		self:setUnlockBloodFxDelayTimer()
	end
end

function BossTitleItem:onBreakStarted(entity, isIgnoreHpLock)
	if isIgnoreHpLock then
		return
	end

	self.isBreakingFx = true

	self:refreshHpDisplay(entity)
	self:retractBloodFx(math.clamp(self.hpState.curRatio, 0, 1), UNLOCK_FX_TWEEN_SECOND)
end

function BossTitleItem:onBreakEnded(entity, isIgnoreHpLock)
	self.rootComponent:InvokeCallback(BLOOD_BREAK_FXVX_ANI_INVOKE_INDEX)

	self.isBreakingFx = nil

	if self.bossTitleUITimers.m_unlockBreakFxVxTimer then
		return
	end

	self.bossTitleUITimers.m_unlockBreakFxVxTimer = TimerManager.addTimer(BLOOD_BREAK_FXVX_ANI_DURATION, function()
		self.bossTitleUITimers.m_unlockBreakFxVxTimer = nil

		self:refreshHpDisplay(entity)

		local duration = isIgnoreHpLock and 0 or UNLOCK_FX_TWEEN_SECOND

		self:retractBloodFx(math.clamp(self.hpState.curRatio, 0, 1), duration)
	end)
end

function BossTitleItem:resetHpState()
	self.hpState = self:newHpState()
	self.m_lastSyncedCurHp = nil

	if self.barHp then
		self.barHp:ResetFxLockInfo()
	end

	self:resetAllBloodFx()
	self:resetBreakBarFx()
	self:clearBloodFxUnlockTimer()

	self.isBpInit = true
	self.breakState = nil

	if self.bossTitleUITimers.m_unlockBreakFxVxTimer then
		TimerManager.removeTimer(self.bossTitleUITimers.m_unlockBreakFxVxTimer)

		self.bossTitleUITimers.m_unlockBreakFxVxTimer = nil
	end

	if self.rootComponent then
		self.rootComponent:TryChangePage("Break", 0)
	end

	if self.imgHandleUWidget then
		self.imgHandleUWidget:SetActive(true)
	end
end

function BossTitleItem:newHpState()
	return {
		barSize = 1,
		displayMaxHp = 1,
		displayCurHp = 0,
		rawMaxHp = 1,
		rawCurHp = 0,
		curRatio = 0
	}
end

function BossTitleItem:clearBloodFxUnlockTimer()
	if self.bossTitleUITimers.m_unlockBloodFxVxTimer then
		TimerManager.removeTimer(self.bossTitleUITimers.m_unlockBloodFxVxTimer)

		self.bossTitleUITimers.m_unlockBloodFxVxTimer = nil
	end
end

function BossTitleItem:setUnlockBloodFxDelayTimer()
	self:clearBloodFxUnlockTimer()

	local limitSecond = self:getBloodVxLimitTimeSecond()

	self.bossTitleUITimers.m_unlockBloodFxVxTimer = TimerManager.addTimer(limitSecond, function()
		self.bossTitleUITimers.m_unlockBloodFxVxTimer = nil

		if self.m_bloodFxActive then
			self:retractBloodFx(math.clamp(self.hpState.curRatio, 0, 1), UNLOCK_FX_TWEEN_SECOND)
		end
	end)
end

function BossTitleItem:getBloodVxLimitTimeSecond()
	local limitSecond = SysConfigData.BOSS_HP_HUD_BLOOD_VX_TIME_LIMIT or BOSS_HP_HUD_BLOOD_VX_TIME_LIMIT

	return limitSecond
end

function BossTitleItem:initBloodFxPool()
	if self.m_bloodFxList then
		self:resetAllBloodFx()

		return
	end

	self.m_bloodFxList = {}
	self.m_bloodFxActive = nil
	self.m_bloodFxCursor = 1
	self.m_nextRetractTime = 0

	local originFx = self:newBloodFx(self.fxVXRectTransform)

	table.insert(self.m_bloodFxList, originFx)

	local parent = self.fxVXRectTransform.parent
	local pos = self.fxVXRectTransform.position

	for i = 1, BLOOD_FX_POOL_SIZE - 1 do
		pg.global.resMgr:ResInstantiateAsync(self.fxVXRectTransform.gameObject, function(gameObj)
			if self.m_bloodFxList == nil then
				if NotNil(gameObj) then
					pg.global.resMgr:ResDestroyObject(gameObj)
				end

				return
			end

			local rect = gameObj.transform:GetComponent("RectTransform")
			local fx = self:newBloodFx(rect)

			table.insert(self.m_bloodFxList, fx)
		end, pos, Quaternion.identity, parent)
	end
end

function BossTitleItem:destroyBloodFxPool()
	if self.m_bloodFxList then
		for _, fx in ipairs(self.m_bloodFxList) do
			DoTweenAnimMgr.Kill(fx.rect.gameObject, LuaUIUtils.TweenId(HP_FX_RETRACT_TWEEN_ID), false)
		end

		self.m_bloodFxList = nil
	end

	self.m_bloodFxActive = nil
	self.m_bloodFxCursor = 1
	self.m_nextRetractTime = 0
end

function BossTitleItem:newBloodFx(rect)
	local go = rect.gameObject

	return {
		alive = false,
		topRatio = 0,
		rect = rect,
		go = go,
		uWidget = go:GetComponent("UImage"),
		vxLine = rect:Find("VxLine"),
		vxLine2 = rect:Find("VxLine2")
	}
end

function BossTitleItem:m_applyBloodFxByRatio(fx, topRatio, bottomRatio)
	self:m_applyRectByRatio(fx.rect, self.m_fxVXRectTSizeY, topRatio, bottomRatio)
end

function BossTitleItem:acquireBloodFx(anchorRatio)
	local count = #self.m_bloodFxList

	if (count == 0 or count < self.m_bloodFxCursor) and LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("BossTitleItem: acquireBloodFx error")
	end

	local fx = self.m_bloodFxList[self.m_bloodFxCursor]

	self:resetBloodFx(fx)

	self.m_bloodFxCursor = self.m_bloodFxCursor % count + 1
	fx.topRatio = anchorRatio
	fx.alive = true

	self:mySetActiveFast(fx.rect, true)

	self.m_bloodFxActive = fx

	return fx
end

function BossTitleItem:accumulateBloodFx(anchorRatio, bottomRatio)
	if not self.barHp then
		return
	end

	local fx = self.m_bloodFxActive

	if not self.m_bloodFxActive then
		self:acquireBloodFx(anchorRatio)

		fx = self.m_bloodFxActive

		fx.uWidget:InvokeCallback(BLOOD_FXVX_CUSTOM5)
	end

	self:m_applyBloodFxByRatio(fx, math.clamp(fx.topRatio, 0, 1), math.clamp(bottomRatio, 0, 1))
	self:refreshBloodFxLines(true)
end

function BossTitleItem:retractBloodFx(frozenBottom, duration)
	local fx = self.m_bloodFxActive

	if not fx then
		return
	end

	self.m_bloodFxActive = nil

	fx.uWidget:InvokeCallback(BLOOD_FXVX_CUSTOM4)

	local fromTop = math.clamp(fx.topRatio, 0, 1)
	local bottom = math.clamp(frozenBottom, 0, 1)
	local delay = math.max(0, self.m_nextRetractTime - Time.time)

	self.m_nextRetractTime = math.max(Time.time, self.m_nextRetractTime) + duration

	self:startRetractTween(fx.rect, HP_FX_RETRACT_TWEEN_ID, fromTop, bottom, duration, delay, function(t)
		self:m_applyBloodFxByRatio(fx, t, bottom)
	end, function()
		self:recycleBloodFx(fx)
	end)
	self:refreshBloodFxLines()
end

function BossTitleItem:recycleBloodFx(fx)
	self:resetBloodFx(fx)
	self:refreshBloodFxLines()
end

function BossTitleItem:mySetActiveFast(trans, isActive)
	if isActive then
		trans:SetLocalScaleEx(1, 1, 1)
	else
		trans:SetLocalScaleEx(0, 0, 0)
	end
end

function BossTitleItem:resetBloodFx(fx)
	DoTweenAnimMgr.Kill(fx.rect.gameObject, LuaUIUtils.TweenId(HP_FX_RETRACT_TWEEN_ID), false)

	fx.alive = false
	fx.topRatio = 0

	self:m_applyBloodFxByRatio(fx, 0, 0)
	self:mySetActiveFast(fx.vxLine, false)
	self:mySetActiveFast(fx.vxLine2, false)
	self:mySetActiveFast(fx.rect, false)
end

function BossTitleItem:resetAllBloodFx()
	if not self.m_bloodFxList then
		return
	end

	for _, fx in ipairs(self.m_bloodFxList) do
		self:resetBloodFx(fx)
	end

	self.m_bloodFxActive = nil
	self.m_bloodFxCursor = 1
	self.m_nextRetractTime = 0
end

function BossTitleItem:refreshBloodFxLines(isAttack)
	if isAttack == nil then
		isAttack = false
	end

	local count = #self.m_bloodFxList
	local activeIndex = (self.m_bloodFxCursor - 2) % count + 1

	for i = 1, count do
		local curIndex = (activeIndex - i) % count + 1
		local preIndex = (activeIndex - 1 - i) % count + 1
		local fx = self.m_bloodFxList[curIndex]

		if fx.alive == false then
			return
		else
			fx.uWidget:InvokeCallback(BLOOD_FXVX_CUSTOM3)
		end

		self:mySetActiveFast(fx.vxLine, self.m_bloodFxList[preIndex].alive == false or preIndex == activeIndex)
		self:mySetActiveFast(fx.vxLine2, curIndex == activeIndex)
	end
end

function BossTitleItem:m_applyRectByRatio(rect, sizeY, topRatio, bottomRatio)
	local allWidth = self.m_allHpWidth or 0
	local displayWidth = allWidth * math.clamp(topRatio - bottomRatio, 0, 1)

	rect.sizeDelta = Vector2(displayWidth, sizeY or 0)
	rect.anchoredPosition = Vector2(allWidth * math.clamp(topRatio, 0, 1), rect.anchoredPosition.y)
end

function BossTitleItem:startRetractTween(target, id, fromRatio, toRatio, duration, delay, updateCb, completeCb)
	local tweenId = LuaUIUtils.TweenId(id)

	DoTweenAnimMgr.Kill(target.gameObject, tweenId, false)
	DoTweenAnimMgr.DoFloat(target.gameObject, fromRatio, toRatio, tweenId, duration, delay, FX_RETRACT_EASE_SINEIN, nil, function(t)
		if updateCb then
			updateCb(t)
		end
	end, function()
		if completeCb then
			completeCb()
		end
	end)
end

function BossTitleItem:getBreakBigDmgRatio()
	return (SysConfigData.BREAK_FXVX_BIG_DMG_THRESHOLD or BREAK_FXVX_BIG_DMG_THRESHOLD) / 100
end

function BossTitleItem:onBreakBarDamage(preValue, curValue, maxValue)
	if maxValue <= 0 then
		return
	end

	local delta = preValue - curValue

	if delta <= 0 then
		return
	end

	local topRatio = math.clamp(preValue / maxValue, 0, 1)
	local curRatio = math.clamp(curValue / maxValue, 0, 1)

	self.vXBreakHandleUWidget:SetActiveFastest(true, true)
	self.rootComponent:InvokeCallback(BREAK_FXVX_CUSTOM1)

	if delta / maxValue >= self:getBreakBigDmgRatio() then
		self.rootComponent:InvokeCallback(BREAK_FXVX_CUSTOM6)
	end

	self:startRetractTween(self.breakFxVXUImage, BREAK_FX_RETRACT_TWEEN_ID, topRatio, curRatio, BREAK_FXVX_TWEEN_SECOND, 0, function(t)
		self:m_applyRectByRatio(self.breakFxVXUImage, self.m_breakFxVXRectTSizeY, t, curRatio)
	end, function()
		self.vXBreakHandleUWidget:SetActiveFastest(false)
	end)
end

function BossTitleItem:resetBreakBarFx()
	if IsNil(self.breakFxVXUImage) then
		return
	end

	DoTweenAnimMgr.Kill(self.breakFxVXUImage.gameObject, LuaUIUtils.TweenId(BREAK_FX_RETRACT_TWEEN_ID), false)
	self.vXBreakHandleUWidget:SetActiveFastest(false)
	self:m_applyRectByRatio(self.breakFxVXUImage, self.m_breakFxVXRectTSizeY, 0, 0)
end

function BossTitleItem:m_tryLogWarnInvisibleReason()
	if self.m_preTryLogWarnInvisibleReasonTime and Time.realSecondCache - self.m_preTryLogWarnInvisibleReasonTime <= 3 then
		return
	end

	if not LoggerManager.checkLogger(LoggerConst.WARN) then
		return
	end

	local str = ""

	if not Utils.isEmptyTable(self.invisibleReason) then
		for key, reason in pairs(self.invisibleReason) do
			str = str .. string.format("%s:%s,", tostring(key), tostring(reason))
		end
	end

	if str ~= "" then
		logger:warn("BossTitleItem:m_tryLogWarnInvisibleReason invisibleReason:%s", str)

		self.m_preTryLogWarnInvisibleReasonTime = Time.realSecondCache
	end
end

function BossTitleItem:onUIVisibleToHide()
	self:finished()
end

function BossTitleItem:refreshBossMechanismIcon()
	local map = self.m_pendingBossMechanismIconMap or {}
	local curActorId = self.curTarget and self.curTarget.actorId or nil
	local data = curActorId and map[curActorId] or nil
	local cache = self.m_bmIconDataCache

	if not data then
		if cache then
			self:destroyBossMechanismIcon()

			self.m_bmIconDataCache = nil
		end

		return
	end

	if data.assetId == nil or data.type == nil or data.max == -1 or data.cur == -1 then
		return
	end

	if not cache or cache.actorId ~= data.actorId then
		self.m_bmIconDataCache = {
			stage = false,
			actorId = data.actorId,
			type = data.type
		}

		self:initBossMechanismIcon(data.assetId, data.type, data.max)

		return
	end

	if not self.bmIconInit then
		return
	end

	if cache.type ~= data.type then
		self.bmIconType = data.type
		self.bmIconMax = data.max

		self:applyBossMechanismIconTypeVisibility()
		self:setBossMechanismIconProgress(data.cur, data.max)

		cache.type = data.type
	end

	if cache.cur ~= data.cur then
		self:setBossMechanismIconProgress(data.cur, data.max)

		cache.cur = data.cur
	end

	if data.pendingFlash then
		self:flashBossMechanismIcon()

		data.pendingFlash = false
	end

	if cache.stage ~= data.stage then
		if data.stage then
			self:showBossMechanismIconVX()
		else
			self:hideBossMechanismIconVX()
		end

		cache.stage = data.stage
	end
end

function BossTitleItem:initBossMechanismIcon(assetId, iconType, max)
	self.bmIconType = iconType
	self.bmIconMax = max

	if self.bmIconInit then
		self:destroyBossMechanismIcon()
	end

	self.bossPropertyUContainer:SetUrlWithCallback(assetId, function(content)
		if not content then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("BossTitleItem: Asset %s not exist", assetId)
			end

			return
		end

		local objectReference = content.transform:GetComponent("ObjectReference")

		self.bmIconRootWidget = content
		self.bmIconTxtNum = objectReference:GetRefValue("txtNum")
		self.bmIconSliderUSlider = objectReference:GetRefValue("sliderUSlider")
		self.bmIconVXRefreshUContainer = objectReference:GetRefValue("vXRefreshUContainer")
		self.bmIconInit = true

		self:applyBossMechanismIconTypeVisibility()
		self:refreshBossMechanismIcon()
	end)
end

function BossTitleItem:applyBossMechanismIconTypeVisibility()
	if NotNil(self.bmIconSliderUSlider) then
		self.bmIconSliderUSlider.gameObject:SetActiveEx(self.bmIconType == UIConst.BossMechanismIconType.Slider or self.bmIconType == UIConst.BossMechanismIconType.MinMax)
	end

	if NotNil(self.bmIconTxtNum) then
		self.bmIconTxtNum.gameObject:SetActiveEx(self.bmIconType == UIConst.BossMechanismIconType.MinMax)
	end
end

function BossTitleItem:destroyBossMechanismIcon()
	self.bossPropertyUContainer:DestroyContent()

	self.bmIconRootWidget = nil
	self.bmIconTxtNum = nil
	self.bmIconSliderUSlider = nil
	self.bmIconVXRefreshUContainer = nil
	self.bmIconLastNum = nil
	self.bmIconInit = false
end

function BossTitleItem:showBossMechanismIconVX()
	self.bmIconVXRefreshUContainer.gameObject:SetActiveEx(false)
	self.bmIconVXRefreshUContainer.gameObject:SetActiveEx(true)
	self.bmIconRootWidget:TryChangePage("Stage", 1)
end

function BossTitleItem:hideBossMechanismIconVX()
	self.bmIconVXRefreshUContainer.gameObject:SetActiveEx(false)
	self.bmIconVXRefreshUContainer.gameObject:SetActiveEx(true)
	self.bmIconRootWidget:TryChangePage("Stage", 0)
end

function BossTitleItem:setBossMechanismIconProgress(num, max)
	if self.bmIconType == UIConst.BossMechanismIconType.Slider or self.bmIconType == UIConst.BossMechanismIconType.MinMax then
		self.bmIconSliderUSlider.value = num / max
	end

	if self.bmIconType == UIConst.BossMechanismIconType.MinMax then
		ClientTextUtils.setText(self.bmIconTxtNum, string.format("%s/%s", num, max))
	end

	if self.bmIconLastNum ~= nil and self.bmIconLastNum ~= num and num == 0 then
		self.bmIconVXRefreshUContainer.gameObject:SetActiveEx(false)
		self.bmIconVXRefreshUContainer.gameObject:SetActiveEx(true)
	end

	self.bmIconLastNum = num
end

function BossTitleItem:flashBossMechanismIcon()
	self.bmIconRootWidget:TryChangePage("AddLight", 0)
	self.bmIconRootWidget:TryChangePage("AddLight", 1)
end

function BossTitleItem:onRecycleCleanup(data, target, reason)
	self:setVisible(false)
end

return BossTitleItem
