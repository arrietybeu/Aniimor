-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\TopTipArea\\BossTitleItemV2.lua

local Class = require("Core.Framework.Class")
local BaseQueueItem = require("Guis.Panels.Tips.Items.BaseQueueItem")
local Time = require("Core.Common.Time")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local ECSConst = require("Common.Const.ECSConst")
local EventConst = require("Common.Const.EventConst")
local MessageName = require("Const.MessageName")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("BossTitleItemV2")
local Utils = require("Common.Utils.Utils")
local TimerManager = require("Core.Timer.TimerManager")
local BossTitleTrapInvisibleOwner = require("Utils.BossTitleTrapInvisibleOwner")
local AbilitySettingGlobalConstData = require("Data.ability_setting_global_const_data")
local BossBaseInfoComp = require("Guis.Panels.Tips.Items.TopTipArea.BossBaseInfoComp")
local BossBuffComp = require("Guis.Panels.Tips.Items.TopTipArea.BossBuffComp")
local BossBloodFxComp = require("Guis.Panels.Tips.Items.TopTipArea.BossBloodFxComp")
local BossShieldComp = require("Guis.Panels.Tips.Items.TopTipArea.BossShieldComp")
local BossFreezeHpComp = require("Guis.Panels.Tips.Items.TopTipArea.BossFreezeHpComp")
local BossMechanismIconComp = require("Guis.Panels.Tips.Items.TopTipArea.BossMechanismIconComp")
local BossHpComp = require("Guis.Panels.Tips.Items.TopTipArea.BossHpComp")
local BossBreakComp = require("Guis.Panels.Tips.Items.TopTipArea.BossBreakComp")
local BossTitleItemV2 = Class.LightClass("BossTitleItemV2", BaseQueueItem)
local BOSS_TITLE_TRAP_REASON = "trap"
local BOSS_DEAD_HIDE_DURATION = 2.8
local BOSS_DEAD_UI_WHITE_LIST = {
	[UIConst.UI_ID_TIPS] = true,
	[UIConst.UI_ID_DAMAGE_NUMBER] = true
}

function BossTitleItemV2:onInit()
	self.bossTitleUITimers = {}

	self:setMaxLimit(1)

	self.uContainer = self.uWidget
	self.invisibleReason = {}

	self:setVisible(false)

	self.breakState = nil
	self.baseInfo = BossBaseInfoComp(self)
	self.buff = BossBuffComp(self)
	self.hp = BossHpComp(self)
	self.hpState = self.hp:newHpState()
	self.bloodFx = BossBloodFxComp(self)
	self.shield = BossShieldComp(self)
	self.freezeHp = BossFreezeHpComp(self)
	self.mechanismIcon = BossMechanismIconComp(self)
	self.breakComp = BossBreakComp(self)

	function self.onNpcDuelMasterBuffAdd(info)
		self:m_forwardNpcDuelBuffEvent("onBuffAdd", info)
	end

	function self.onNpcDuelMasterBuffRemove(info)
		self:m_forwardNpcDuelBuffEvent("onBuffRemove", info)
	end

	function self.onNpcDuelMasterBuffExpiredTimeChange(info)
		self:m_forwardNpcDuelBuffEvent("onBuffExpiredTimeChange", info)
	end

	function self.onNpcDuelMasterBuffLayerChange(info)
		self:m_forwardNpcDuelBuffEvent("onBuffLayerChange", info)
	end
end

function BossTitleItemV2:pushData(data)
	if self:isQueueEmpty() and not self:isRunning() then
		self:enqueue(data)
	else
		self:refreshBossTitle()
	end
end

function BossTitleItemV2:onUpdate()
	self:tryPopupItem()
end

function BossTitleItemV2:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	local data = self:dequeue()

	self:addRunItem(data)
	self:initUContainer(data)
end

function BossTitleItemV2:onClearRunningList(force)
	local data = self:firstRunItem()

	if data then
		self:recycleToast(data, force)
	end
end

function BossTitleItemV2:initUContainer(data)
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

function BossTitleItemV2:renderItem(item, data)
	if self:isContentCreated() then
		self:refreshBossTitle()

		return
	end

	local objectReference = item:GetComponent("ObjectReference")

	self.rootComponent = objectReference:GetRefValue("rootComponent")
	self.firstKillUContainer = objectReference:GetRefValue("firstKillUContainer")

	local bloodUComponent = objectReference:GetRefValue("bloodUComponent")
	local bloodObjectReference = bloodUComponent:GetComponent("ObjectReference")

	self.baseInfo:onBind(objectReference)
	self.buff:onBind(objectReference)
	self.hp:onBind(objectReference)
	self.bloodFx:onBind(bloodObjectReference)
	self.shield:onBind(objectReference)
	self.freezeHp:onBind(objectReference)
	self.mechanismIcon:onBind(objectReference)
	self.breakComp:onBind(objectReference, bloodObjectReference)

	self.m_isCreated = true

	self.bloodFx:init()
	self:resetHpState()
	self:m_resetShieldBarUI()
	self:refreshBossTitle()
end

function BossTitleItemV2:getEpComp()
	if not self.ep and pg.space and pg.space:isNpcDuel() then
		local BossEpComp = require("Guis.Panels.Tips.Items.TopTipArea.BossEpComp")

		self.ep = BossEpComp(self)

		self.ep:onBind(self.uContainer.content:GetComponent("ObjectReference"))
	end

	return self.ep
end

function BossTitleItemV2:refreshEp(pawn)
	local ep = self:getEpComp()

	if ep then
		ep:refresh(pawn)
	end
end

function BossTitleItemV2:bindEpRefreshNotify(target)
	local ep = self:getEpComp()

	if ep then
		ep:bindNotify(target)
	end
end

function BossTitleItemV2:unbindEpRefreshNotify()
	if self.ep then
		self.ep:unbindNotify()
	end
end

function BossTitleItemV2:setVisibleWithFlags(flag, visible)
	if visible then
		self.invisibleReason[flag] = nil
	else
		self.invisibleReason[flag] = visible
	end

	self:refreshVisible()
end

function BossTitleItemV2:isContentCreated()
	return self.m_isCreated and NotNil(self.rootComponent)
end

function BossTitleItemV2:refreshVisible()
	if not Utils.isEmptyTable(self.invisibleReason) then
		self:hideBossTitle()
		self:m_tryLogWarnInvisibleReason()
	elseif self:isContentCreated() and self.curTarget then
		self:showBossTitle()
	elseif self.visible then
		self:setVisible(false)
	end
end

function BossTitleItemV2:m_tryHideTrapTarget(target)
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

function BossTitleItemV2:showBossTitle()
	if not self:isContentCreated() then
		return
	end

	if self.visible then
		return
	end

	if not pg.me or pg.me.isLeavingSpace then
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
		if not pg.me or pg.me.isLeavingSpace then
			return
		end

		self:refreshCombatState()
	end, 0.5, true)
end

function BossTitleItemV2:hideBossTitle()
	local needResetTargetState = self.visible or self.curTarget ~= nil

	self:setVisible(false)

	local hudCtrl = pg.global.ui.hudV2

	if hudCtrl and hudCtrl.setMapHudVisible then
		hudCtrl:setMapHudVisible("BossTile", true)
	end

	if self.curTarget then
		self.curTarget:enableNotifyEcsAmount(false, ECSConst.ECS_AMOUNT_NOTIFY_OWNER.BOSS_TITLE)
	end

	self:m_unbindNpcDuelBuffNotify()

	if needResetTargetState then
		self:resetTargetState()
	end

	self.curTarget = nil

	facade:SendMessageCommand(MessageName.BOSS_TITLE_COMBAT_STATE_CHANGE, UIConst.BossCombatState.Normal)

	if self.combatTimer then
		self:killTimer(self.combatTimer)

		self.combatTimer = nil
	end

	self:clearRunningList()
end

function BossTitleItemV2:m_restoreBossDeadTipsEdge()
	self.bossDeadHideTipsTimer = nil

	local tipsCtrl = pg.global.ui.tips

	if tipsCtrl and tipsCtrl.forceHideEdgeTipsAndAreaC then
		tipsCtrl:forceHideEdgeTipsAndAreaC(false)
	end
end

function BossTitleItemV2:m_hideHudAndTipsEdgeOnBossDead()
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

function BossTitleItemV2:onTargetDeadImmediately(target)
	if not self.curTarget or self.curTarget ~= target then
		return
	end

	if self.onKillPerformTimer ~= nil then
		self:killTimer(self.onKillPerformTimer)

		self.onKillPerformTimer = nil
	end

	if NotNil(self.firstKillUContainer) then
		LuaUIUtils.setUIViewVisible(self.firstKillUContainer, false)
	end

	self:setVisibleWithFlags("HasTarget", false)
end

function BossTitleItemV2:refreshCombatState()
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

function BossTitleItemV2:refreshBossTitleWhenSwitchCombat(isEnterCombat, actorId)
	local target = self.curTarget

	if target and target.actorId ~= actorId then
		return
	end

	self.cacheInCombatBossActId = isEnterCombat and actorId or nil

	self:refreshBossTitle()
end

function BossTitleItemV2:m_isNpcDuelTarget(target)
	if not target or not pg.space or not pg.space:isNpcDuel() or not pg.space:npcDuelDungeonIsReady() then
		return false
	end

	if pg.space.npcDuelDungeonIsEnding and pg.space:npcDuelDungeonIsEnding() then
		return false
	end

	local npcDuelPet = pg.space:getCurNpcDuelBotPetEntity()

	return npcDuelPet == target and not target:isDead()
end

function BossTitleItemV2:refreshBossTitle()
	local player = pg.me

	if player == nil or player.isLeavingSpace or player.space == nil then
		return
	end

	if IsNil(self.uContainer.content) then
		return
	end

	local hatredBossEntityList = self:getHatredBossEntityList()
	local isHasValidBoss = #hatredBossEntityList == 1
	local target = isHasValidBoss and hatredBossEntityList[1] or nil
	local curShowCond = target and target:isInCombat()

	if isHasValidBoss and curShowCond then
		self:m_acquireTarget(target)
	elseif self.curTarget and self.curTarget:isDead() then
		if self.onKillPerformTimer == nil then
			self:m_hideHudAndTipsEdgeOnBossDead()
			LuaUIUtils.setUIViewVisible(self.firstKillUContainer, true)

			if not self.firstKillUContainer:CheckURLLoaded() then
				self.firstKillUContainer:LoadDefaultUrlManually(function()
					return
				end)
			end

			self.rootComponent:InvokeCallback(CS.XGUI.EInvokeTime.User1)

			self.onKillPerformTimer = self:startTimer(function()
				LuaUIUtils.setUIViewVisible(self.firstKillUContainer, false)
				self:setVisibleWithFlags("HasTarget", false)

				self.onKillPerformTimer = nil
			end, 2.8, false)
		end
	else
		self:refreshBossTitleByLock(player.lockedActorId)
	end
end

function BossTitleItemV2:getHatredBossEntityList()
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

function BossTitleItemV2:checkIsShowBossTitle(actorId)
	return self.curTarget and self.curTarget.actorId == actorId or false
end

function BossTitleItemV2:getTargetId()
	return self.curTarget and self.curTarget.id or nil
end

function BossTitleItemV2:setBossNameVisible(visible)
	self.baseInfo:setVisible(visible)
end

function BossTitleItemV2:isBossNameHidden()
	return self.baseInfo:isHidden()
end

function BossTitleItemV2:refreshBossTitleByLock(lockedActorId)
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

	if (isBossOrElite or self:m_isNpcDuelTarget(target)) and isBossInCombat then
		self:m_acquireTarget(target)

		return
	end

	self:setVisibleWithFlags("HasTarget", false)
end

function BossTitleItemV2:m_acquireTarget(target)
	if self:m_tryHideTrapTarget(target) then
		return false
	end

	local oldTarget = self.curTarget
	local isSameTarget = target == oldTarget

	if oldTarget and not isSameTarget then
		oldTarget:enableNotifyEcsAmount(false, ECSConst.ECS_AMOUNT_NOTIFY_OWNER.BOSS_TITLE)
	end

	self.curTarget = target

	self:m_bindNpcDuelBuffNotify(target)
	self.curTarget:enableNotifyEcsAmount(true, ECSConst.ECS_AMOUNT_NOTIFY_OWNER.BOSS_TITLE)
	self:setVisibleWithFlags("HasTarget", true)

	local deferred = self:m_tryPlaySwitchTargetAnimation(oldTarget, target)

	if not deferred then
		self:refreshTargetInfo(isSameTarget)
	end

	return true
end

function BossTitleItemV2:refreshTargetInfo(isSameTarget)
	local visible = self.curTarget and self:checkVisibility(self.curTarget.label)

	if visible then
		if not isSameTarget then
			self:resetTargetState()
			self:initTargetInfo()
		end

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

function BossTitleItemV2:checkVisibility(label)
	if pg.space:isNpcDuel() and pg.space:npcDuelDungeonIsReady() then
		return true
	end

	if label ~= nil then
		return Utils.isLabelBoss(label) or Utils.isLabelElite(label)
	else
		return false
	end
end

function BossTitleItemV2:refreshBossStage(isInit)
	self.hp:refreshBossStage(isInit)
end

function BossTitleItemV2:getBossTitleStagePos()
	return self.hp:getStagePos()
end

function BossTitleItemV2:m_showSpecialStateBuff(specialStateBuff)
	self.baseInfo:showSpecialStateBuff(specialStateBuff)
end

function BossTitleItemV2:m_hideSpecialStateBuffWithDelay()
	self.baseInfo:hideSpecialStateBuffWithDelay()
end

function BossTitleItemV2:refreshBuffs(info)
	self.buff:refreshBuffs(info)
end

function BossTitleItemV2:m_forwardNpcDuelBuffEvent(handlerName, info)
	local target = self.npcDuelBuffNotifyTarget

	if not info or not info.isTeamBuff or target ~= self.curTarget then
		return
	end

	local forwardedInfo = {}

	for key, value in pairs(info) do
		forwardedInfo[key] = value
	end

	forwardedInfo.entId = target.id

	self.buff[handlerName](self.buff, forwardedInfo)
end

function BossTitleItemV2:m_bindNpcDuelBuffNotify(target)
	if self.npcDuelBuffNotifyTarget == target then
		return
	end

	self:m_unbindNpcDuelBuffNotify()

	if not self:m_isNpcDuelTarget(target) or not target.eventEmitter then
		return
	end

	local master = target.getMasterEntity and target:getMasterEntity()

	if not master or not master.eventEmitter then
		return
	end

	self.npcDuelBuffNotifyTarget = target
	self.npcDuelBuffNotifySource = master

	master.eventEmitter:addEventListener(EventConst.ON_BUFF_ADD, self.onNpcDuelMasterBuffAdd)
	master.eventEmitter:addEventListener(EventConst.ON_BUFF_REMOVE, self.onNpcDuelMasterBuffRemove)
	master.eventEmitter:addEventListener(EventConst.ON_BUFF_EXPIRED_TIME_CHANGE, self.onNpcDuelMasterBuffExpiredTimeChange)
	master.eventEmitter:addEventListener(EventConst.BUFF_LAYER_CHANGE, self.onNpcDuelMasterBuffLayerChange)
end

function BossTitleItemV2:m_unbindNpcDuelBuffNotify()
	local source = self.npcDuelBuffNotifySource

	self.npcDuelBuffNotifyTarget = nil
	self.npcDuelBuffNotifySource = nil

	if not source or not source.eventEmitter then
		return
	end

	source.eventEmitter:removeEventListener(EventConst.ON_BUFF_ADD, self.onNpcDuelMasterBuffAdd)
	source.eventEmitter:removeEventListener(EventConst.ON_BUFF_REMOVE, self.onNpcDuelMasterBuffRemove)
	source.eventEmitter:removeEventListener(EventConst.ON_BUFF_EXPIRED_TIME_CHANGE, self.onNpcDuelMasterBuffExpiredTimeChange)
	source.eventEmitter:removeEventListener(EventConst.BUFF_LAYER_CHANGE, self.onNpcDuelMasterBuffLayerChange)
end

function BossTitleItemV2:onBuffAdd(info)
	self.buff:onBuffAdd(info)
end

function BossTitleItemV2:onBuffRemove(info)
	self.buff:onBuffRemove(info)
end

function BossTitleItemV2:onBuffExpiredTimeChange(info)
	self.buff:onBuffExpiredTimeChange(info)
end

function BossTitleItemV2:onBuffLayerChange(info)
	self.buff:onBuffLayerChange(info)
end

function BossTitleItemV2:initTargetInfo()
	self.baseInfo:initTargetInfo()
	self.hp:initTargetInfo()
	self:refreshFreezeHp()
end

function BossTitleItemV2:onEntElementChange(entInfo)
	self.baseInfo:onEntElementChange(entInfo)
end

function BossTitleItemV2:start()
	local visible = self.curTarget and self:checkVisibility(self.curTarget.label)

	self:setVisible(visible)
	self:onStart()
end

function BossTitleItemV2:refreshElementInfo()
	self.baseInfo:refreshElementInfo()
end

function BossTitleItemV2:refreshLevel()
	self.baseInfo:refreshLevel()
end

function BossTitleItemV2:refreshBreakBar(data, isIgnoreHpLock)
	self.breakComp:refreshBreakBar(data, isIgnoreHpLock)
end

function BossTitleItemV2:refreshShield(entity)
	self.shield:refresh(entity)
end

function BossTitleItemV2:onShieldBreak(entity)
	self.shield:onBreak(entity)
end

function BossTitleItemV2:m_resetShieldBarUI()
	self.shield:resetUI()
end

function BossTitleItemV2:m_tryPlaySwitchTargetAnimation(oldTarget, newTarget)
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

function BossTitleItemV2:getHpDisplayRatio(curHp, maxHp)
	return self.hp:getHpDisplayRatio(curHp, maxHp)
end

function BossTitleItemV2:refreshHpDisplay(entity)
	self.hp:refreshHpDisplay(entity)
end

function BossTitleItemV2:applyHpToBar(isFirstSet)
	self.hp:applyHpToBar(isFirstSet)
end

function BossTitleItemV2:refreshHealthPoint(entity)
	self.hp:refreshHealthPoint(entity)
end

function BossTitleItemV2:setBp(curValue, deltaValue, maxValue)
	self.breakComp:setBp(curValue, deltaValue, maxValue)
end

function BossTitleItemV2:refreshBreakState(curValue, maxValue)
	self.breakComp:refreshBreakState(curValue, maxValue)
end

function BossTitleItemV2:refreshBreakShake(curValue, deltaValue, maxValue)
	self.breakComp:refreshBreakShake(curValue, deltaValue, maxValue)
end

function BossTitleItemV2:refreshFreezeHp(info)
	self.freezeHp:refresh(info)
end

function BossTitleItemV2:onFreezeHpHit()
	self.freezeHp:onHit()
end

function BossTitleItemV2:onFreezeHpOutTime(info)
	self.freezeHp:onOutTime(info)
end

function BossTitleItemV2:onDestroy()
	BaseQueueItem.onDestroy(self)
	self:m_unbindNpcDuelBuffNotify()

	if self.curTarget then
		self.curTarget:enableNotifyEcsAmount(false, ECSConst.ECS_AMOUNT_NOTIFY_OWNER.BOSS_TITLE)
	end

	if self.combatTimer then
		self:killTimer(self.combatTimer)

		self.combatTimer = nil
	end

	if self.onKillPerformTimer then
		self:killTimer(self.onKillPerformTimer)

		self.onKillPerformTimer = nil
	end

	if self.bossDeadHideTipsTimer then
		self:killTimer(self.bossDeadHideTipsTimer)
		self:m_restoreBossDeadTipsEdge()
	end

	self.buff:destroy()
	self.baseInfo:destroy()

	if next(self.bossTitleUITimers) then
		for k, v in pairs(self.bossTitleUITimers) do
			TimerManager.removeTimer(v)

			self.bossTitleUITimers[k] = nil
		end
	end

	self.bossTitleUITimers = {}

	self.hp:destroy()
	self.bloodFx:destroy()
	self.shield:destroy()
	self.breakComp:destroy()
	self.freezeHp:destroy()
	self.mechanismIcon:destroy(true)

	if self.ep then
		self.ep:destroy()

		self.ep = nil
	end

	self:setVisible(false)

	if NotNil(self.uContainer.content) then
		self.uContainer:DestroyContent()
	end

	self.m_isCreated = false
	self.rootComponent = nil
	self.curTarget = nil
end

function BossTitleItemV2:onSetVisible(visible)
	facade:SendMessageCommand(MessageName.BOSS_TITLE_SHOWN_MESSAGE, {
		visible = visible
	})
end

function BossTitleItemV2:setVisible(visible)
	if not visible then
		self.breakState = nil
	end

	BossTitleItemV2.super.setVisible(self, visible)
end

function BossTitleItemV2:refreshEcsAmount(ent)
	self.buff:refreshEcsAmount(ent)
end

function BossTitleItemV2:refreshBossThreatLevel(target, forceVisible)
	self.baseInfo:refreshBossThreatLevel(target, forceVisible)
end

function BossTitleItemV2:resetHpState()
	self.hp:reset()
	self.bloodFx:reset()
	self.breakComp:reset()
end

function BossTitleItemV2:resetTargetState()
	self.baseInfo:reset()
	self.buff:reset()
	self.shield:reset()
	self.freezeHp:reset()
	self:resetHpState()

	if self.ep then
		self.ep:reset()
	end
end

function BossTitleItemV2:getBreakBigDmgRatio()
	return self.breakComp:getBreakBigDmgRatio()
end

function BossTitleItemV2:onBreakBarDamage(preValue, curValue, maxValue)
	self.breakComp:onBreakBarDamage(preValue, curValue, maxValue)
end

function BossTitleItemV2:resetBreakBarFx()
	self.breakComp:resetBreakBarFx()
end

function BossTitleItemV2:m_tryLogWarnInvisibleReason()
	if self.m_preTryLogWarnInvisibleReasonTime and Time.secondCache - self.m_preTryLogWarnInvisibleReasonTime <= 3 then
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
		logger:warn("BossTitleItemV2:m_tryLogWarnInvisibleReason invisibleReason:%s", str)

		self.m_preTryLogWarnInvisibleReasonTime = Time.secondCache
	end
end

function BossTitleItemV2:onUIVisibleToHide()
	self:finished()
end

function BossTitleItemV2:refreshBossMechanismIcon()
	self.mechanismIcon:setPendingMap(pg.global.ui.tips.model:getBossMechanismIconMap())
	self.mechanismIcon:refresh()
end

function BossTitleItemV2:onRecycleCleanup(data, target, reason)
	self:setVisible(false)
end

return BossTitleItemV2
