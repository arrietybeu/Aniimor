-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseComponent\\HpUIComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("HpUIComponent")
local ClientAbilityUtils = require("Utils.ClientAbilityUtils")
local AttributeConst = require("Common.Const.AttributeConst")
local SysConfigData = require("Data.sys_config_data")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local Utils = require("Common.Utils.Utils")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local UIConst = require("Const.UIConst")
local MessageName = require("Const.MessageName")
local Const = require("Common.Const.Const")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local ClientConst = require("Const.ClientConst")
local EventConst = require("Const.EventConst")
local TimerManager = require("Core.Timer.TimerManager")
local ClientTextUtils = require("Utils.ClientTextUtils")
local AbilityConst = require("Common.Const.AbilityConst")
local Class = require("Core.Framework.Class")
local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local HpUIComponent = Class.LightClass("HpUIComponent", HudBaseComponent)
local LuaUIUtils = require("Utils.LuaUIUtils")
local BuffUIUtils = require("Utils.BuffUIUtils")
local pg = pg
local ClientUtils = require("Utils.ClientUtils")
local PetData = require("Data.pet_data")
local PetPrototypeData = require("Data.pet_prototype_data")
local GameStringCfgData = require("Data.gamestring_config_data")
local BossRushUtils = require("Utils.BossRushUtils")
local FUSE_STATE = "FuseState"

HpUIComponent.messages = {
	[MessageName.MODULE_ENABLE_CHANGED] = {
		"onModuleEnableChanged",
		true
	},
	[MessageName.MAIN_PLAYER_HP_CHANGE] = {
		"refreshPlayerHp",
		true
	},
	[MessageName.MAIN_PLAYER_EP_CHANGE] = {
		"refreshPlayerEp",
		true
	},
	[MessageName.PLAYER_COMBAT_STATUS_UPDATE] = {
		"onPlayerCombatStatusUpdate",
		true
	},
	[MessageName.PET_HP_CHANGE] = {
		"refreshPossessHp",
		true
	},
	[MessageName.BREAK_POINT_CHANGE] = {
		"refreshEntityBp",
		true
	},
	[MessageName.ON_SPECIAL_TEMPORARY_EP_CHANGED] = {
		"onSpecialTemporaryEpChanged",
		true
	},
	[MessageName.ROGUE_EXTRA_TEMP_PET_STATE_CHANGE] = {
		"onExtraTempPetStateChange",
		true
	},
	[MessageName.ON_CONTROL_ENT] = {
		"onControlEntity",
		true
	},
	[MessageName.COMBAT_PET_TEMPLATE_CHANGE] = {
		"onCombatPetChange",
		true
	},
	[MessageName.COMBAT_PET_CHANGED] = {
		"onCombatPetChange",
		true
	},
	[MessageName.CUR_COMBAT_PET_CHANGED] = {
		"onCurCombatPetChange",
		true
	},
	[MessageName.BUFF_CHANGE] = {
		"onBuffChange",
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
	[MessageName.PREPARE_PETS_UPDATE] = {
		"refreshStatusVisible",
		true
	},
	[MessageName.SHIELD_CHANGE] = {
		"refreshShieldPoint",
		true
	},
	[MessageName.SHIELD_BREAK] = {
		"onShieldBreak",
		true
	},
	[MessageName.ENTER_LIFE_ALIVE] = {
		"refreshStatus",
		true
	},
	[MessageName.APPEAR_FROM_TOPLOGO_BUFF] = {
		"onAppearFromTopLogoBuff",
		true
	},
	[MessageName.CATCH_MODE_CHANGE_UI] = {
		"onCatchModeChange",
		true
	},
	[MessageName.CHARACTER_STATE_CHANGED] = {
		"onCharacterStateChanged",
		true
	},
	[MessageName.QUICK_ENTER_CONTROL_MODE] = {
		"onQuickEnterControlMode",
		true
	},
	[MessageName.ROGUE_COMBAT_DATA_CHANGE] = {
		"onRogueCombatDataChange",
		true
	},
	[MessageName.DUNGEON_TEAMMATEVIEW_CHANGE] = {
		"onTeammateViewChange",
		true
	},
	[MessageName.INTERACT_GESTURE_STATE_CHANGE] = {
		"onInteractGestureStateChanged",
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
	[MessageName.ENTER_SEAMLESS] = {
		"onEnterSeamless",
		true
	},
	[MessageName.EXIT_SEAMLESS] = {
		"onExitSeamless",
		true
	},
	[MessageName.PLAYER_ONTELEPORT] = {
		"onPlayerOnTeleport",
		true
	},
	[MessageName.GRAB_EGG_STRUGGLE_STATE_CHANGED] = {
		"refreshStatusVisible",
		true
	},
	[MessageName.ENTER_LIFE_FALLEN] = {
		"onCombatPetChange",
		true
	}
}

local QuickLinkState = {
	RUNNING = 3,
	WAIT = 2,
	NONE = 1,
	BAN_LINK = 4
}

function HpUIComponent:onPossessedChange()
	if self.uWidget then
		self:refreshPossessedState()
	end
end

function HpUIComponent:findObjects()
	self.statusVisibleInfo = {}
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.rootComponent = self.objectReference:GetRefValue("rootComponent")
	self.myHp = self.objectReference:GetRefValue("myHp")
	self.myHpText = self.objectReference:GetRefValue("myHpText")
	self.myShield = self.objectReference:GetRefValue("myShield")
	self.panelAnimation = self.objectReference:GetRefValue("panelAnimation")
	self.changeBossHpUContainer = self.objectReference:GetRefValue("changeBossHpUContainer")
	self.buffUList = self.objectReference:GetRefValue("buffUList")
	self.ecsBuffUList = self.buffUList
	self.breakUHealthbar = self.objectReference:GetRefValue("breakUHealthbar")
	self.breakUCountDown = self.objectReference:GetRefValue("breakUCountDown")
	self.bloodUComponent = self.objectReference:GetRefValue("bloodUComponent")
	self.layoutBoxUWidget = self.objectReference:GetRefValue("layoutBoxUWidget")
	self.epListUList = self.objectReference:GetRefValue("epListUList")
	self.fuseKey = self.objectReference:GetRefValue("keyUWidget")
	self.fuseText = self.objectReference:GetRefValue("fuseText")
	self.normalUWidget = self.objectReference:GetRefValue("normalUWidget")
	self.breakCountDown = self.objectReference:GetRefValue("breakUCountDown")
	self.vxCountdownAnimation = self.objectReference:GetRefValue("vxCountdownAnimation")
	self.breakCountDownBarBreak = self.objectReference:GetRefValue("barBreakUHealthbar")
	self.topLogoBuffUButton = self.objectReference:GetRefValue("topLogoBuffUButton")
	self.petTip = self.objectReference:GetRefValue("petTip")

	self:m_resetShieldBarUI()
end

function HpUIComponent:isHomeLand()
	return pg.me and pg.me.space and pg.me.space.isHomeland and pg.me.space:isHomeland()
end

function HpUIComponent:onControlChanged(controlPet)
	self:refreshControlState(pg.me, controlPet)
	self:refreshFuseText(controlPet)
end

function HpUIComponent:refreshControlState(player, controlPet)
	local isControllingEgg = player:isControllingEgg()
	local curPetEntity = player:getCurPetEntity()
	local isControllingState = curPetEntity ~= nil or isControllingEgg
	local showHp = isControllingState or player:FALLEN_ST()

	if self.rootComponent and self.rootComponentVisible ~= showHp then
		self.rootComponentVisible = showHp

		LuaUIUtils.setUIVisible(self.rootComponent, showHp)
	end

	local epListVisible = isControllingState and not pg.me:EXTRA_TEMP_PET_ST()

	self:setEpListVisible(epListVisible)

	if showHp and self.layoutBoxUWidget then
		self:refreshFuseBtnVisible()
	end
end

function HpUIComponent:setEpListVisible(visible)
	if not self.epListUList or self.epListVisible == visible then
		return
	end

	self.epListVisible = visible

	LuaUIUtils.setUIVisible(self.epListUList, visible)
end

function HpUIComponent:refreshPossessedState()
	if not self.uWidget then
		return
	end

	local pawn = pg.pawn
	local isControllingEgg = pg.me:isControllingEgg()

	if Utils.isPlayer(pawn) and not isControllingEgg then
		self:refreshFuseText(false)
	else
		self:refreshFuseText(true)
	end
end

function HpUIComponent:refreshFuseText(isControllingPet)
	if isControllingPet then
		ClientTextUtils.setText(self.fuseText, pg.getGameString("UNLINK"))
	else
		ClientTextUtils.setText(self.fuseText, pg.getGameString("LINK"))
	end
end

function HpUIComponent:initView()
	self.oneBallEpValue = SysConfigData.EP_VALUE_PER_BALL or 1
	self.epBalls = {}
	self.specialTempEpBalls = {}
	self.finalEpBalls = {}
	self.dirtyEpIndex = {}
	self.specialTempEpBallBuffData = {}
	self.visibleData = self.visibleData or {}

	function self.buffUList.luaRenderItem(button, index, data)
		BuffUIUtils.setBuffInfo(button, data)
	end

	function self.buffUList.luaClick(button, data)
		local info = data

		info.targetRect = button
		info.autoVer = true

		pg.global.ui:open(UIConst.UI_ID_COMMON_BUFF_INFO_TIP, info)
	end

	self:setKeyBinding()

	if self.epListUList then
		function self.epListUList.luaRenderItem(button, index, data)
			button:TryChangePage("state", data.state)

			button:GetChild("Progress"):GetComponent("UImage").fillAmount = data.progress
		end
	end

	self:refreshPossessedState()
	self:refreshStatusVisible()
	self:refreshStatus()

	if Utils.isPlayer(pg.pawn) then
		self:onControlChanged(false)
	else
		self:onControlChanged(true)
	end

	self.buffDisappearHintTimer = {}

	self:tryConsumeQuickEnterControlMode()
end

function HpUIComponent:onDestroy()
	if self.refreshStatusTimer then
		TimerManager.removeTimer(self.refreshStatusTimer)

		self.refreshStatusTimer = nil
	end

	if self.buffDisappearHintTimer ~= nil then
		for _, timerId in pairs(self.buffDisappearHintTimer) do
			TimerManager.removeTimer(timerId)
		end

		self.buffDisappearHintTimer = nil
	end

	HudBaseComponent.onDestroy(self)

	self.curBuffList = nil
	self.curEcsBuffList = nil
	self.epBalls = nil
	self.specialTempEpBalls = nil
	self.finalEpBalls = nil
	self.dirtyEpIndex = nil
	self.lastNormalBallCount = nil
	self.lastTempBallCount = nil
end

function HpUIComponent:initFuseState()
	local pawn = pg.pawn

	if Utils.isPlayer(pawn) and self.panelAnimation and self.canSwitch then
		UIUtils.PlayAnimation(self.panelAnimation, "VX_Node_HUD_HP_PC_PetToPeople")
	end
end

function HpUIComponent:onCombatPetChange()
	self:refreshControlState(pg.me, false)
	self:refreshStatusVisible()
	self:refreshStatus(true)
end

function HpUIComponent:onCurCombatPetChange(msg)
	local player = pg.me

	if not player then
		return
	end

	if not pg.me.inTeammateView then
		return
	end

	if pg.me.id == msg.uid then
		return
	end

	if pg.me.inTeammateView then
		for id, info in pairs(pg.me:getCurTeamInfo().membersInfo) do
			if info.entityId ~= pg.me.id then
				player = pg.getEntity(info.entityId)
			end
		end
	end

	if not player then
		return
	end

	self:refreshControlState(player)

	local showStatusEntity = self:getCurShowStatusEntity()

	if msg and showStatusEntity and msg.newPetId ~= showStatusEntity.id then
		self:refreshStatusVisible()
		self:refreshStatus(true)
	end
end

function HpUIComponent:setKeyBinding()
	local switchPetBinding = KeyBindingPro.GetOrAddKeyBindingByName(self.transform.gameObject, "switchPet")
	local hotKeyContent = self.fuseKey:GetComponent("HotKeyContent")

	hotKeyContent:SetHotKeyPaths("Hud/SwitchPet")

	switchPetBinding.isVirtual = true
	switchPetBinding.actionPath = "Hud/SwitchPet"
	switchPetBinding.priority = 10

	function switchPetBinding.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:shapeShifting()
		end
	end
end

function HpUIComponent:shapeShifting()
	if not ClientUtils.checkLinkedCondition() then
		return
	end

	if self.quickLinkState == QuickLinkState.WAIT then
		self:confirmQuickLink()
	elseif self.quickLinkState == QuickLinkState.RUNNING then
		if self.canSwitch then
			local ret = self:performSwitchPet()

			if ret then
				self:exitQuickLinkRunningAnim()

				self.quickLinkState = QuickLinkState.NONE
			end
		end
	elseif self.canSwitch then
		self:performSwitchPet()
	end
end

function HpUIComponent:performSwitchPet()
	if pg.me:isControllingEgg() then
		if not pg.me:SWITCH_ANIM_ST() and not pg.me:EGG_BE_CARRIED_ST() then
			pg.me:serverMsg("RPC_CS_UncontrolEgg")
		end

		return false
	end

	if pg.game.controller:isInControlMainPlayer() and not pg.me:checkCanControlPet(true) then
		return false
	end

	if self:switchControlPet(Const.CLIENT_SWITCH_REASON.ManualSwitch) then
		return true
	else
		return false
	end
end

function HpUIComponent:confirmQuickLink()
	local petId = self.quickLinkByPetId

	self.quickLinkByPetId = nil

	pg.me:requestQuickLinkPet(petId, function(result)
		self.quickLinkState = result and QuickLinkState.RUNNING or QuickLinkState.NONE

		self:hideQuickLinkPromptAnim(result)
	end)
end

function HpUIComponent:triggerSwitchEffect()
	self.uWidget:InvokeCallback(CS.XGUI.EInvokeTime.User1)
end

function HpUIComponent:switchControlPet(clientSwitchReason)
	clientSwitchReason = clientSwitchReason or Const.CLIENT_SWITCH_REASON.Default

	if pg.me:isInCatchMode() then
		return false
	end

	if not pg.me:isControllingPet() then
		return pg.me:requestSwitchToPet(clientSwitchReason)
	else
		return pg.me:requestSwitchToPlayer(clientSwitchReason)
	end
end

function HpUIComponent:triggerSwitchFailedEffect()
	return
end

function HpUIComponent:onInputGamepadControlModeChange()
	return
end

function HpUIComponent:refreshStatusVisible(forceRefreshFuse)
	local canSwitch, visible = ClientUtils.computeFuseSwitchState()

	if canSwitch == nil then
		return
	end

	self.canSwitch = canSwitch

	self:refreshCanCombine()
	self:refreshFuseBtnVisible(forceRefreshFuse)

	if not visible then
		self.breakState = nil
	end
end

function HpUIComponent:getCurShowStatusEntity()
	local player = pg.me

	if not player then
		return nil
	end

	if player.inTeammateView then
		for id, info in pairs(pg.me:getCurTeamInfo().membersInfo) do
			if info.entityId ~= pg.me.id then
				player = pg.getEntity(info.entityId)
			end
		end
	end

	local showStatusEntity = player:getCurPetEntity() or pg.pawn
	local isSupportMode = Utils.isSpaceSpecialBattleMode(player.space)

	if isSupportMode then
		if not player:FALLEN_ST() then
			showStatusEntity = player.petPrepareList[1] and pg.getEntity(player.petPrepareList[1])
		else
			showStatusEntity = player
		end
	elseif player:isControllingPet() then
		showStatusEntity = player.getControllingPet and player:getControllingPet() or player:getCurPetEntity()
		showStatusEntity = showStatusEntity or pg.pawn
	elseif player:isControllingEgg() then
		showStatusEntity = player.petPrepareList[1] and pg.getEntity(player.petPrepareList[1])
	end

	return showStatusEntity
end

function HpUIComponent:refreshStatus(needReset)
	if not self.myHp then
		return
	end

	local showStatusEntity = self:getCurShowStatusEntity()

	if not showStatusEntity then
		return
	end

	self:refreshShieldPoint(showStatusEntity)
	self:refreshHp(showStatusEntity, nil, needReset)
	self:refreshEp(showStatusEntity)
	self:refreshBuff(showStatusEntity)
	self:refreshBp({
		entity = showStatusEntity
	})
end

function HpUIComponent:refreshCanCombine()
	if not self.rootComponent then
		return
	end

	local player = pg.me

	if player.inTeammateView then
		for id, info in pairs(pg.me:getCurTeamInfo().membersInfo) do
			if info.entityId ~= pg.me.id then
				player = pg.getEntity(info.entityId)
			end
		end
	end

	if not pg.game:checkModuleEnable(ClientConst.ModuleKey.PetLink) then
		self.rootComponent:TryChangePage("canCombine", 2)

		return
	end

	if pg.game.social.interactGestureComponent:checkInteractGesturePlaying() then
		self.rootComponent:TryChangePage("canCombine", 1)

		return
	end

	local canCombine = self.canSwitch and player:checkPetControlUnlock()

	self.rootComponent:TryChangePage("canCombine", canCombine and 0 or 1)
end

function HpUIComponent:refreshMobileStatus()
	return
end

function HpUIComponent:refreshShieldPoint(pawn)
	if pawn and not pawn.isMainPlayer and not pawn.isMainPet then
		return
	end

	pawn = pawn or self:getCurShowStatusEntity()

	if self.delayHideShiedTimer then
		TimerManager.removeTimer(self.delayHideShiedTimer)

		self.delayHideShiedTimer = nil
	end

	LuaUIUtils.setShieldBar(pawn, self.myShield, self.myShield, true, self.rootComponent)
end

function HpUIComponent:onShieldBreak(entity)
	if not entity then
		return
	end

	local pawn = self:getCurShowStatusEntity() or pg.pawn

	if pawn and entity and pawn.id == entity.id then
		if self.maskUWidget then
			self.maskUWidget:InvokeCallback(CS.XGUI.EInvokeTime.Custom2)

			if self.delayHideShiedTimer then
				TimerManager.removeTimer(self.delayHideShiedTimer)

				self.delayHideShiedTimer = nil
			end

			self.delayHideShiedTimer = TimerManager.addTimer(1, function()
				self.delayHideShiedTimer = nil

				self.maskUWidget:SetActive(false)
			end)
		elseif self.myShield then
			self.rootComponent:TryChangePage("shield", 0)

			if self.delayHideShiedTimer then
				TimerManager.removeTimer(self.delayHideShiedTimer)

				self.delayHideShiedTimer = nil
			end

			self.delayHideShiedTimer = TimerManager.addTimer(1, function()
				self.delayHideShiedTimer = nil

				self.myShield:SetActive(false)
			end)
		end
	end
end

function HpUIComponent:m_resetShieldBarUI()
	if not self.m_resetedShieldBarUI then
		if self.maskUWidget then
			self.maskUWidget:SetActive(false)
		elseif self.myShield then
			self.myShield:SetActive(false)
		end

		self.m_resetedShieldBarUI = true
	end
end

function HpUIComponent:refreshHp(entity, withProgress, needReset)
	entity = entity or pg.me:getCurPetEntity()

	if entity then
		local isFallen = entity:FALLEN_ST()
		local player = pg.me

		if not isFallen and player and Utils.isSpaceSpecialBattleMode(player.space) then
			entity = player.petPrepareList[1] and pg.getEntity(player.petPrepareList[1])

			if not entity then
				return
			end
		end

		local curHp = entity.curHp
		local maxHp = entity.maxHp
		local hpBar = self.myHp

		if isFallen then
			self.rootComponent:TryChangePage("BloodType", 1)
			ClientTextUtils.setText(self.myHpText, "")
		else
			self.rootComponent:TryChangePage("BloodType", 0)
			ClientTextUtils.setText(self.myHpText, string.format("%s/%s", ClientAbilityUtils.getAttributeStr(AttributeConst.hp_cur, curHp), ClientAbilityUtils.getAttributeStr(AttributeConst.hp_cur, maxHp)))
		end

		hpBar.maxHp = maxHp

		if withProgress then
			hpBar:ProgressHp(curHp)
		elseif needReset then
			hpBar:ResetHp(curHp)
		else
			hpBar.hp = curHp
		end
	end
end

function HpUIComponent:refreshEp(pawn)
	pawn = pawn or pg.pawn

	local curEp = pawn.actorCombatAttribute:getEp()
	local maxEp = pawn.actorCombatAttribute:getMaxEp()
	local curTempEp = pawn.actorCombatAttribute:getTempEp()
	local maxTempEp = pawn.actorCombatAttribute:getMaxTempEp()

	curEp = curEp - curTempEp
	maxEp = maxEp - maxTempEp

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		-- block empty
	end

	table.clear(self.dirtyEpIndex)
	table.clear(self.finalEpBalls)

	local normalCount = self:refreshEpBallData(self.epBalls, curEp, maxEp, self.finalEpBalls, self.dirtyEpIndex, 0)

	self:refreshEpBallData(self.specialTempEpBalls, curTempEp, maxTempEp, self.finalEpBalls, self.dirtyEpIndex, normalCount)

	local tempCount = #self.finalEpBalls - normalCount

	if self.epListUList then
		if normalCount ~= self.lastNormalBallCount or tempCount ~= self.lastTempBallCount then
			self.epListUList:SetList(self.finalEpBalls)

			self.lastNormalBallCount = normalCount
			self.lastTempBallCount = tempCount
		else
			for i = 1, #self.dirtyEpIndex do
				self.epListUList:RefreshElement(self.dirtyEpIndex[i])
			end
		end
	end
end

function HpUIComponent:refreshEpBoss()
	if pg.me:EXTRA_TEMP_PET_ST() then
		local curEp = pg.me.rogueCombatData[AbilityConst.ROGUE_BATTLE_DATA_KEY.SKILL_EP] or 0
		local maxEp = pg.me.rogueCombatData[AbilityConst.ROGUE_BATTLE_DATA_KEY.SKILL_EP_MAX] or 100

		if self.changeBossHpUContainer.content == nil then
			self.changeBossHpUContainer:SetActive(true)
			self.changeBossHpUContainer:LoadDefaultUrlManually(function()
				self:refreshEpBoss()
			end)

			return
		end

		LuaUIUtils.setUIVisible(self.changeBossHpUContainer, true)

		self.changeBossHpUContainer.content.maxHp = maxEp

		if SysConfigData.RogueTransformBarColorDiv ~= nil then
			local radio = curEp

			if radio <= SysConfigData.RogueTransformBarColorDiv then
				self.changeBossHpUContainer.content:TryChangePage("State", 1)
			else
				self.changeBossHpUContainer.content:TryChangePage("State", 0)
			end
		end

		self.changeBossHpUContainer.content:ProgressHp(curEp)

		if self.bossEp == nil or self.bossEp <= 0 then
			self.bossEp = 1
		end

		if SysConfigData.RogueTransformBarColorDiv == nil then
			return
		end

		local threshold = self.bossEp - curEp

		if threshold <= SysConfigData.RogueTransformBarColorDiv then
			return
		end

		self.changeBossHpUContainer.content:SetFxLockInfo(true, self.bossEp / maxEp, 2.5, Const.DoTweenEaseType.InExpo, nil, nil)
		self.changeBossHpUContainer.content:SetFxLockInfo(false, self:getBarHpFxLockInfoFillVal(curEp, maxEp), 0.75, Const.DoTweenEaseType.InExpo, nil, function()
			self.bossEp = curEp
		end)
	else
		LuaUIUtils.setUIVisible(self.changeBossHpUContainer, false)
	end
end

function HpUIComponent:onRogueCombatDataChange(param)
	if param and (param.key == AbilityConst.ROGUE_BATTLE_DATA_KEY.SKILL_EP or param.key == AbilityConst.ROGUE_BATTLE_DATA_KEY.SKILL_EP_MAX) then
		self:refreshEpBoss()
	end
end

function HpUIComponent:getBarHpFxLockInfoFillVal(curEp, maxEp)
	return math.clamp(curEp / (maxEp - 0.01), 0, 1)
end

function HpUIComponent:refreshEpBallData(epBallList, curEp, maxEp, resultList, dirtyIndex, indexOffset)
	local ballCount = 1
	local maxBallCount = math.ceil(maxEp / self.oneBallEpValue)

	while ballCount <= maxBallCount do
		if epBallList[ballCount] == nil then
			epBallList[ballCount] = {
				state = 0,
				tIndex = 0
			}
		end

		local ball = epBallList[ballCount]
		local newState = curEp >= ballCount * self.oneBallEpValue and 0 or 1
		local newProgress = math.clamp(curEp / self.oneBallEpValue + 1 - ballCount, 0, 1)

		if dirtyIndex and (ball.state ~= newState or ball.progress ~= newProgress) then
			dirtyIndex[#dirtyIndex + 1] = indexOffset + ballCount - 1
		end

		ball.state = newState
		ball.progress = newProgress

		table.insert(resultList, ball)

		ballCount = ballCount + 1
	end

	while maxBallCount < #epBallList do
		table.remove(epBallList, #epBallList)
	end

	return maxBallCount
end

function HpUIComponent:refreshBuff(pawn)
	if not self.buffUList then
		return
	end

	pawn = pawn or pg.me and pg.me:getCurPetEntity() or pg.pawn
	self.curBuffPawn = pawn

	local buffList = BuffUIUtils.getUIBuffList(pawn, SysConfigData.selfStatusBuffCount or 6)

	self.buffUList:SetList(buffList)

	self.curBuffList = buffList

	LuaUIUtils.setUIVisible(self.buffUList, #buffList > 0)
end

function HpUIComponent:refreshEcsBuff()
	local me = pg.me

	if not me or not me.beControlled then
		return
	end

	local buffList = BuffUIUtils.getUIBuffList(me, SysConfigData.selfStatusBuffCount or 6)

	LuaUIUtils.setUIVisible(self.buffUList, true)
	self.buffUList:SetList(buffList)
end

function HpUIComponent:checkShowBreakBar()
	if not pg.me or not pg.me.space then
		return false
	end

	if pg.me.space:isNpcDuel() then
		return pg.me:isInCombat() or pg.me:isControllingPet() or Utils.isPet(pg.pawn)
	end

	return pg.me.space:isPvpEnv() and pg.me:isInCombat()
end

function HpUIComponent:isShowingPetStatusEntity(entity)
	return pg.me and (pg.me:isControllingPet() or pg.me:isControllingEgg() or Utils.isPet(entity) or Utils.isPet(pg.pawn))
end

function HpUIComponent:refreshBp(data)
	local entity = data.entity
	local deltaBp = data.deltaBp
	local info = Utils.getEntityBreakInfo(entity)

	if not self.view then
		return
	end

	local showBreakBar = self:checkShowBreakBar() and self:isShowingPetStatusEntity(entity)

	if showBreakBar then
		self.breakUHealthbar:SetActive(true)
	else
		self:refreshBuff()

		self.breakState = nil

		self.breakUHealthbar:SetActive(false)

		return
	end

	if info and info.inBreakStatus then
		pg.game.audio:triggerEvent("ui_sfx_parmon_break")
		self.rootComponent:TryChangePage("Break", 1)

		if info.breakBuffFreezeTime ~= 0 then
			self.breakCountDown:SetActive(true)
			self.breakCountDown:Play(math.max(info.breakEndTime - info.breakBuffFreezeTime), 0.01)
			self.breakCountDown:Stop()

			self.breakState = UIConst.BLOOD_BREAK_STATE.STATE_BREAK
			self.breakCountDownBarBreak.hp = 0
		else
			self:setBp(0, 0, info.maxBp)

			local now = pg.me:getGameTime()

			if ToBool(info.breakRecoverEndTime) then
				self.breakCountDown:SetActive(false)

				if self.breakState ~= UIConst.BLOOD_BREAK_STATE.STATE_BREAK_RECOVER then
					self.vxCountdownAnimation:Play("VX_Node_HUD_HP_BOSS_Break_Loop_Disappear")
				end

				self.breakState = UIConst.BLOOD_BREAK_STATE.STATE_BREAK_RECOVER

				local startTime = info.breakRecoverEndTime - info.breakRecoverTime
				local curVale = math.max(0.01, now - startTime)

				self:setBp(0, 0, info.breakRecoverTime)

				if info.breakRecoverFreezeTime == 0 then
					self.breakCountDown:Play(curVale, math.max(info.breakRecoverTime, 0.01))
				else
					self.breakCountDown:Play(math.max(info.breakRecoverEndTime - info.breakRecoverFreezeTime, 0.01), math.max(info.breakRecoverTime, 0.01))
					self.breakCountDown:Stop()
				end
			else
				self.breakCountDown:SetActive(true)

				if self.breakState ~= UIConst.BLOOD_BREAK_STATE.STATE_BREAK then
					self.vxCountdownAnimation:Play("VX_Node_HUD_HP_BOSS_Break_Loop")
				end

				self:setBp(0, 0, info.breakTime)
				self.breakCountDown:Play(math.min(info.breakTime, info.breakEndTime - now))

				self.breakState = UIConst.BLOOD_BREAK_STATE.STATE_BREAK
				self.breakCountDownBarBreak.hp = 0
			end
		end
	else
		if self.breakState then
			self.breakState = nil

			self.vxCountdownAnimation:Play("VX_Node_HUD_HP_BOSS_Break_Recover")
			TimerManager.addTimer(1, function()
				if NotNil(self.vxCountdownAnimation) then
					self.breakCountDown:Stop()
					self.rootComponent:TryChangePage("Break", 0)
					self:setBp(info.curBp, deltaBp, info.maxBp)

					self.breakState = nil
				end
			end)

			return
		else
			self:setBp(info.curBp, 0, info.maxBp)
		end

		self.breakCountDown:Stop()

		self.breakState = nil
	end
end

function HpUIComponent:setBp(curValue, deltaValue, maxValue)
	curValue = maxValue - curValue
	self.breakUHealthbar.maxHp = maxValue

	self.breakUHealthbar:ProgressHp(curValue)
	self:refreshBreakState(curValue, maxValue)
end

function HpUIComponent:refreshBreakState(curValue, maxValue)
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

function HpUIComponent:refreshBreakShake(deltaValue, maxValue)
	local config = SysConfigData.BREAK_VIBRATION_CUTOFF
	local cutoffLower = config[1] < config[2] and config[1] or config[2]
	local cutoffUpper = config[1] < config[2] and config[2] or config[1]

	deltaValue = deltaValue or 0

	local percent = deltaValue / maxValue

	if cutoffLower <= percent and percent < cutoffUpper then
		self.bloodUComponent:InvokeCallback(CS.XGUI.EInvokeTime.User1)
	elseif cutoffUpper <= percent then
		self.bloodUComponent:InvokeCallback(CS.XGUI.EInvokeTime.User2)
	end
end

function HpUIComponent:onCatchModeChange(enable)
	self:refreshStatusVisible()

	if not enable and Utils.isPlayer(pg.pawn) and self.panelAnimation and self.canSwitch then
		UIUtils.PlayAnimation(self.panelAnimation, "VX_Node_HUD_HP_PC_PetToPeople")
	end
end

function HpUIComponent:onCharacterStateChanged()
	self:refreshStatusVisible()
end

function HpUIComponent:onTeammateViewChange()
	if pg.me.inTeammateView then
		for id, info in pairs(pg.me:getCurTeamInfo().membersInfo) do
			if info.entityId ~= pg.me.id then
				local player = pg.getEntity(info.entityId)
				local isControllingPet = player:isControllingPet()

				self:refreshControlState(player, isControllingPet)
				self:refreshStatusAfterStateSettled()
			end
		end
	else
		local isControllingPet = pg.me:isControllingPet()

		self:refreshControlState(pg.me, isControllingPet)
		self:refreshStatusAfterStateSettled()
	end
end

function HpUIComponent:onSpecialTemporaryEpChanged(data)
	if data.enable then
		local delayTime = data.fadeTime
		local interval = data.fadeInterval

		self.specialTempEpBallBuffData[data.buffInsId] = TimerManager.addTimer(delayTime, function()
			local tempEpBall = self:getUnMarkedEpBalls(data.epCount)

			if self.specialTempEpBallBuffData[data.buffInsId] then
				TimerManager.removeTimer(self.specialTempEpBallBuffData[data.buffInsId])
			end

			self.specialTempEpBallBuffData[data.buffInsId] = TimerManager.addRepeatTimer(interval, function()
				for _, epBall in ipairs(tempEpBall) do
					if NotNil(epBall) then
						epBall.renderOpacity = 1 - epBall.renderOpacity
					end
				end
			end)
		end)
	elseif self.specialTempEpBallBuffData[data.buffInsId] then
		TimerManager.removeTimer(self.specialTempEpBallBuffData[data.buffInsId])

		self.specialTempEpBallBuffData[data.buffInsId] = nil
	end
end

function HpUIComponent:getUnMarkedEpBalls(count)
	local ret = {}
	local cnt = 0

	if self.epListUList then
		local allEpBalls = self.epListUList:GetAllButtons()

		for i = allEpBalls.Length - 1, 0, -1 do
			local data = self.epListUList:GetData(i)

			if not data.dirtyMark then
				data.dirtyMark = true

				local epBall = allEpBalls[i]

				self.epListUList:SetElement(i, data)
				table.insert(ret, epBall)

				cnt = cnt + 1
			end

			if count <= cnt then
				break
			end
		end
	end

	return ret
end

function HpUIComponent:setFuseBtnVisible(key, visible)
	if not self.visibleData then
		return
	end

	if not visible then
		self.visibleData[key] = false
	else
		self.visibleData[key] = nil
	end

	self:refreshFuseBtnVisible()
end

function HpUIComponent:refreshFuseBtnVisible(forceRefreshFuse)
	local visible = true

	if pg.me:isThrowItem() or pg.me:isInCatchMode() or pg.me:FALLEN_ST() then
		visible = false
	end

	if not Utils.tableIsEmptyOrNil(self.visibleData) then
		visible = false
	end

	if pg.space and (pg.space:isNpcDuel() or pg.space:isDittoSpace() or BossRushUtils.isInBossRushBattleLevel()) then
		visible = false
	end

	local fuseBtnVisible = visible and self.canSwitch

	if self.fuseBtnVisible ~= fuseBtnVisible or forceRefreshFuse then
		self.fuseBtnVisible = fuseBtnVisible

		LuaUIUtils.setUIVisible(self.layoutBoxUWidget, fuseBtnVisible)
		LuaUIUtils.setUIVisible(self.possessedBtn, fuseBtnVisible)
	end
end

function HpUIComponent:showEmoji(petIdx, emojiName)
	return
end

function HpUIComponent:refreshExploreBtnState()
	self:refreshStatusVisible()
end

function HpUIComponent:onAppearFromTopLogoBuff(info)
	if pg.game.controller:isInControlEnt() then
		local showStatusEntity = self:getCurShowStatusEntity()

		self.showStatusEntity = showStatusEntity

		BuffUIUtils.doAppearFromTopLogoBuff(info, self, "showStatusEntity")
	end
end

function HpUIComponent:onModuleEnableChanged(changeInfo)
	local moduleKey = changeInfo.moduleKey or ""
	local enable = changeInfo.enable

	if moduleKey == ClientConst.ModuleKey.PetLink then
		self:refreshStatusVisible()
	end
end

function HpUIComponent:refreshPlayerHp()
	if pg.me:FALLEN_ST() then
		self:refreshHp(pg.me, true)
	end
end

function HpUIComponent:refreshPlayerEp()
	local player = pg.me

	if pg.game.controller:isInControlEnt() or self:getCurShowStatusEntity() ~= nil or pg.global.ui:runPlatformByMobile() then
		self:refreshEp()
	end
end

function HpUIComponent:onPlayerCombatStatusUpdate(state)
	self:refreshStatusAfterStateSettled()

	if state == Const.COMBAT_STATUS_NORMAL then
		if self.quickLinkState == QuickLinkState.BAN_LINK then
			self.quickLinkState = QuickLinkState.NONE
		end
	elseif state == Const.COMBAT_STATUS_IN_COMBAT and self.quickLinkState == QuickLinkState.WAIT then
		self:killQuickLinkOnCombatAnim()

		self.quickLinkState = QuickLinkState.BAN_LINK
	end
end

function HpUIComponent:onControlStateChanged(info)
	if info and pg.me and info.playerId ~= pg.me.uid then
		return
	end

	if pg.me then
		self:onControlChanged(pg.me:isControllingPet())
	end
end

function HpUIComponent:refreshStatusAfterStateSettled()
	self:refreshStatusVisible()
	self:refreshStatus()
end

function HpUIComponent:refreshPossessHp(petIdx, ov, nv)
	local player = pg.me

	if petIdx < 0 or petIdx == player.curIndex then
		self:refreshHp(nil, true)

		local curPet = player:getCurPetEntity()

		if curPet then
			curPet.eventEmitter:emit(EventConst.TOPLOGO_HEALTH_POINT, ov, nv)
		end
	elseif player.space and player.space.supportPetMode == Const.SpaceSupportPetMode.RealControl then
		local mainCombatPet = pg.me.petPrepareList[1] and pg.getEntity(pg.me.petPrepareList[1])

		self:refreshHp(mainCombatPet, true)
	elseif player:isControllingEgg() then
		local mainCombatPet = pg.me.petPrepareList[1] and pg.getEntity(pg.me.petPrepareList[1]) or pg.me

		self:refreshHp(mainCombatPet, true)
	end
end

function HpUIComponent:refreshEntityBp(data)
	if data.entity.id == pg.pawn.id then
		self:refreshBp(data)
	end
end

function HpUIComponent:onExtraTempPetStateChange()
	if not pg.me:EXTRA_TEMP_PET_ST() then
		self:setEpListVisible(true)
		LuaUIUtils.setUIVisible(self.changeBossHpUContainer, false)
	else
		if not self.changeBossHpUContainer.content then
			self.changeBossHpUContainer:SetActive(true)
			self.changeBossHpUContainer:LoadDefaultUrlManually(function()
				self:refreshEpBoss()
			end)
		else
			self:refreshEpBoss()
		end

		self:setEpListVisible(false)
		LuaUIUtils.setUIVisible(self.changeBossHpUContainer, true)
	end
end

function HpUIComponent:onControlEntity(switchInfo)
	self:onPossessedChange()

	local petEnt = switchInfo.targetEnt

	if petEnt then
		self:onControlChanged(true)
	else
		self:onControlChanged(false)
	end

	self:refreshStatusVisible()
	self:refreshStatus(true)
end

function HpUIComponent:onBuffChange(info)
	local buffPawn = self.curBuffPawn or pg.me and pg.me:getCurPetEntity()

	if not buffPawn then
		return
	end

	local entId = info and info.entId

	if entId == buffPawn.id or info and info.isTeamBuff then
		self:refreshBuff(buffPawn)
	end
end

function HpUIComponent:m_isAffectedByBuffMsg(info)
	if not info or not self.curBuffPawn then
		return false
	end

	return info.entId == self.curBuffPawn.id or info.isTeamBuff
end

function HpUIComponent:m_addBuffToList(uiList, buffList, buffData, pawn, maxCount)
	local buffInfo = BuffUIUtils._addBuffInfo(buffData, pawn, {})

	if not buffInfo then
		return nil, 0
	end

	local idx = BuffUIUtils.computeInsertIndex(buffList, buffInfo, maxCount)

	if idx <= 0 then
		return nil, 0
	end

	if maxCount and maxCount <= #buffList then
		BuffUIUtils.tryRemoveBuff(uiList, buffList, #buffList)
	end

	BuffUIUtils.tryInsertBuff(uiList, buffList, idx, buffInfo)

	return buffInfo, idx
end

function HpUIComponent:m_tryBackfillBuff(maxCount)
	local pawn = self.curBuffPawn

	if not pawn then
		return
	end

	local latestBuffList = BuffUIUtils.getUIBuffList(pawn, maxCount)

	for _, buffInfo in ipairs(latestBuffList) do
		if BuffUIUtils.findBuffIndex(self.curBuffList, buffInfo.instanceId) <= 0 then
			local idx = BuffUIUtils.computeInsertIndex(self.curBuffList, buffInfo, maxCount)

			if idx <= 0 then
				return
			end

			BuffUIUtils.tryInsertBuff(self.buffUList, self.curBuffList, idx, buffInfo)

			local should, delayTime, instanceId = BuffUIUtils.rescheduleDisappearHint(self, buffInfo)

			if should then
				self.buffDisappearHintTimer[instanceId] = TimerManager.addTimer(delayTime, function()
					BuffUIUtils.invokeDisappearHintFx(self.buffUList, self.curBuffList, instanceId)
				end)
			end

			return
		end
	end
end

function HpUIComponent:onBuffAdd(info)
	if not self.buffUList then
		return
	end

	if not self:m_isAffectedByBuffMsg(info) then
		return
	end

	local buffData = info.newBuffData

	if not buffData then
		return
	end

	local pawn = self.curBuffPawn or pg.me and pg.me:getCurPetEntity() or pg.pawn

	self.curBuffList = self.curBuffList or {}

	local buffInfo, idx = self:m_addBuffToList(self.buffUList, self.curBuffList, buffData, pawn, SysConfigData.selfStatusBuffCount or 6)

	if idx > 0 then
		LuaUIUtils.setUIVisible(self.buffUList, true)

		local should, delayTime, instanceId = BuffUIUtils.scheduleDisappearHint(self, buffInfo)

		if should then
			self.buffDisappearHintTimer[instanceId] = TimerManager.addTimer(delayTime, function()
				BuffUIUtils.invokeDisappearHintFx(self.buffUList, self.curBuffList, instanceId)
			end)
		end
	end
end

function HpUIComponent:onBuffRemove(info)
	if not self.buffUList then
		return
	end

	if not self:m_isAffectedByBuffMsg(info) then
		return
	end

	local instanceId = info.buffInsId

	if not instanceId then
		return
	end

	BuffUIUtils.clearBuffDisappearHintTimer(self, instanceId)

	if self.curBuffList then
		local idx = BuffUIUtils.findBuffIndex(self.curBuffList, instanceId)

		if idx > 0 then
			local maxCount = SysConfigData.selfStatusBuffCount or 6
			local needBackfill = maxCount <= #self.curBuffList

			BuffUIUtils.tryRemoveBuff(self.buffUList, self.curBuffList, idx)

			if needBackfill then
				self:m_tryBackfillBuff(maxCount)
			end

			LuaUIUtils.setUIVisible(self.buffUList, #self.curBuffList > 0)
		end
	end
end

function HpUIComponent:onBuffExpiredTimeChange(info)
	if not self:m_isAffectedByBuffMsg(info) then
		return
	end

	if self.curBuffList then
		local buffInfo = BuffUIUtils.updateBuffExpiredTime(self.buffUList, self.curBuffList, info)

		if buffInfo then
			local should, delayTime, instanceId = BuffUIUtils.rescheduleDisappearHint(self, buffInfo)

			if should then
				self.buffDisappearHintTimer[instanceId] = TimerManager.addTimer(delayTime, function()
					BuffUIUtils.invokeDisappearHintFx(self.buffUList, self.curBuffList, instanceId)
				end)
			end

			return
		end
	end
end

function HpUIComponent:onBuffLayerChange(info)
	if not self.curBuffPawn then
		return
	end

	if not self.curBuffList then
		return
	end

	local entId = info.entId

	if entId == self.curBuffPawn.id or info.isTeamBuff then
		BuffUIUtils.applyLayerChange(self.buffUList, self.curBuffList, info)
	end
end

function HpUIComponent:onQuickEnterControlMode(data)
	if self._visible == false then
		return
	end

	if pg.me then
		pg.me:clearPendingQuickEnter()
	end

	if self.quickLinkState == QuickLinkState.WAIT or self.quickLinkState == QuickLinkState.BAN_LINK then
		return
	end

	local petInfo = data.petInfo

	if petInfo == nil then
		return
	end

	local templateId = petInfo.templateId

	if templateId == nil or templateId == 0 then
		return
	end

	self.petTip:SetUrlWithCallback("$UI_Node_BtnPetTip.prefab", function(content)
		local objectReference = content.transform:GetComponent("ObjectReference")
		local progress = objectReference:GetRefValue("progress")
		local icon = objectReference:GetRefValue("icon")
		local text1 = objectReference:GetRefValue("text1")
		local text2 = objectReference:GetRefValue("text2")
		local petData = PetData[templateId]
		local prototypeData = PetPrototypeData[petInfo.petPrototypeId]
		local btnIcon = LuaUIUtils.getPetIcon(prototypeData.iconName, LuaUIUtils.PET_ICON)
		local countDownTime = SysConfigData.PetConjunctionCountdownTime or 15

		icon.url = btnIcon

		ClientTextUtils.setText(text1, pg.getLocalizationText(GameStringCfgData.PET_UNKNOWDIALOGUE_TEXT4.desc))
		ClientTextUtils.setText(text2, pg.getLocalizationText(petData.petLanAlert))
		self:showQuickLinkPromptAnim({
			oc = objectReference
		})

		progress.value = 1

		progress:ProgressToValue(0, function()
			if self.quickLinkState ~= QuickLinkState.RUNNING then
				self:cancelQuickLinkOnTimeoutAnim()

				self.quickLinkState = QuickLinkState.NONE
			end
		end, countDownTime)

		local audioName = string.format("VOX_Combat_Parmon_%d_Appear", petData.resId)

		pg.game.audio:triggerEvent(audioName)

		self.quickLinkState = QuickLinkState.WAIT
		self.quickLinkByPetId = petInfo.id
	end)
end

function HpUIComponent:tryConsumeQuickEnterControlMode()
	self.quickLinkState = QuickLinkState.NONE

	if not pg.me then
		return
	end

	local data = pg.me:consumePendingQuickEnter()

	if data then
		self:onQuickEnterControlMode(data)
	end
end

function HpUIComponent:hideQuickLinkPromptAnim(result)
	self:killQuickLinkProcessAnim()

	if result then
		self.rootComponent:TryChangePage(FUSE_STATE, 1)
	else
		self:killQuickLinkPetTipAnim()
	end
end

function HpUIComponent:exitQuickLinkRunningAnim()
	self.rootComponent:TryChangePage(FUSE_STATE, 1)
end

function HpUIComponent:showQuickLinkPromptAnim(info)
	local keyHotKey = info.oc:GetRefValue("keyHotKey")

	keyHotKey:SetHotKeyPaths("Hud/SwitchPet")
	self.rootComponent:TryChangePage(FUSE_STATE, 2)
end

function HpUIComponent:cancelQuickLinkOnTimeoutAnim()
	self:killQuickLinkPetTipAnim()
end

function HpUIComponent:killQuickLinkOnCombatAnim()
	self:killQuickLinkProcessAnim()
	self:killQuickLinkPetTipAnim()
end

function HpUIComponent:killQuickLinkProcess()
	if self.quickLinkState == QuickLinkState.WAIT then
		self:killQuickLinkOnCombatAnim()

		self.quickLinkState = QuickLinkState.NONE
	end
end

function HpUIComponent:killQuickLinkPetTipAnim()
	local showStatusEntity = self:getCurShowStatusEntity()

	if showStatusEntity ~= nil then
		self.rootComponent:TryChangePage(FUSE_STATE, 1)
	else
		self.rootComponent:TryChangePage(FUSE_STATE, 0)
	end
end

function HpUIComponent:killQuickLinkProcessAnim()
	if self.petTip.content then
		local objectReference = self.petTip.content.transform:GetComponent("ObjectReference")
		local progress = objectReference:GetRefValue("progress")

		progress:KillProcessAnim()
	end
end

function HpUIComponent:onSceneLoaded()
	self:killQuickLinkProcess()
	self:refreshControlState(pg.me)
	self:refreshPossessedState()
end

function HpUIComponent:onSceneUnload()
	self:killQuickLinkProcess()
	self:refreshControlState(pg.me)
	self:refreshPossessedState()
end

function HpUIComponent:onEnterSeamless()
	self:killQuickLinkProcess()
	self:refreshControlState(pg.me)
	self:refreshPossessedState()
end

function HpUIComponent:onExitSeamless()
	self:killQuickLinkProcess()
	self:refreshControlState(pg.me)
	self:refreshPossessedState()
end

function HpUIComponent:onPlayerOnTeleport()
	self:killQuickLinkProcess()
end

function HpUIComponent:onInteractGestureStateChanged()
	self:setFuseBtnVisible("interactGesture", not pg.game.social.interactGestureComponent:checkInteractGesturePlaying())
	self:refreshCanCombine()
end

function HpUIComponent:playShowAnim()
	return
end

function HpUIComponent:playHideAnim()
	return
end

return HpUIComponent
