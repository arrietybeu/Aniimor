-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\TopLogoCtrl.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local TopLogoHelper = require("Guis.Panels.TopLogo.TopLogoHelper")
local Utils = require("Common.Utils.Utils")
local UICtrl = require("Guis.UICtrl")
local Class = require("Core.Framework.Class")
local logger = LoggerManager.getLogger("TopLogoCtrl")
local MessageName = require("Const.MessageName")
local UIConst = require("Const.UIConst")
local TopLogoConst = require("Const.TopLogoConst")
local SysConfigData = require("Data.sys_config_data")
local EventConst = require("Const.EventConst")
local Const = require("Common.Const.Const")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local TopLogoActionStateComponent = require("Guis.Panels.TopLogo.Component.TopLogoActionStateComponent")
local TopLogoTeamSpeechComponent = require("Guis.Panels.TopLogo.Component.TopLogoTeamSpeechComponent")

local function isSamePlayerId(left, right)
	return left ~= nil and right ~= nil and tostring(left) == tostring(right)
end

local function getPlayerNameChangeId(info)
	if type(info) == "table" then
		return info.playerId or info.uid
	end

	return info
end

local TopLogoCtrl = Class.LightClass("TopLogoCtrl", UICtrl)

TopLogoCtrl.messages = {
	[MessageName.UI_ON_SET_VISIBLE_TOPLOGO] = {
		"onSetAllTopLogoVisible",
		true
	},
	[MessageName.UI_ON_SET_TOPLOGO_COMPONENT_VISIBLE] = {
		"onSetTopLogoComponentVisible",
		true
	},
	[MessageName.SCENE_LOADED] = {
		"onSceneLoaded",
		true
	},
	[MessageName.SCENE_UNLOAD] = {
		"onSceneUnloaded",
		true
	},
	[MessageName.PREPARE_PETS_UPDATE] = {
		"onPreparePetsUpdate",
		true
	},
	[MessageName.ON_NEW_KNOW_CHANGED] = {
		"onNewKnowChanged",
		true
	},
	[MessageName.QUEST_ON_TAB_SWITCH] = {
		"onQuestTabSwitch",
		true
	},
	[MessageName.QUEST_ON_RUN_STATE_CHANGE] = {
		"onQuestRunStateChange",
		true
	},
	[MessageName.NPC_DUEL_STATE_CHANGED] = {
		"onNpcDuelStateChanged",
		true
	},
	[MessageName.PLAYER_NAME_CHANGE] = {
		"onPlayerNameChange",
		true
	},
	[MessageName.PLAYER_TITLE_CHANGE] = {
		"onPlayerTitleChange",
		true
	},
	[MessageName.TARGET_PET_BUFF_ON_CHANGE] = {
		"onTargetPetBuffChanged",
		true
	},
	[MessageName.MAIN_PLAYER_HP_CHANGE] = {
		"onPlayerHubHpChange",
		true
	},
	[MessageName.ENDURANCE_STATE_CHANGE] = {
		"onPlayerHubEnduranceChange",
		true
	},
	[MessageName.CHARACTER_STATE_CHANGED] = {
		"onPlayerHubCharacterStateChanged",
		true
	},
	[MessageName.PLAYER_ENDURANCE_CHANGE] = {
		"onPlayerHubMaxEnduranceChange",
		true
	},
	[MessageName.CHECK_ENDURANCE_ENOUGH] = {
		"onPlayerHubCheckEnduranceEnough",
		true
	},
	[MessageName.PLAYER_HUB_LIFE_DEAD] = {
		"onPlayerHubEnterDead",
		true
	},
	[MessageName.ENTER_LIFE_FALLEN] = {
		"onPlayerHubEnterFallen",
		true
	},
	[MessageName.PLAYER_HUB_LIFE_ALIVE] = {
		"onPlayerHubEnterAlive",
		true
	},
	[MessageName.ON_CONTROL_ENT] = {
		"onPawnSwitched",
		true
	},
	[MessageName.PET_EXPLORE_SKILL_VAL_CHANGED] = {
		"onPetExploreSkillValChanged",
		true
	},
	[MessageName.PET_EXPLORE_SKILL_VAL_STATE_CHANGED] = {
		"onPetExploreSkillValStateChanged",
		true
	},
	[MessageName.CONTROL_STATE_CHANGE] = {
		"onTopLogoControlStateChanged",
		true
	},
	[MessageName.CUR_COMBAT_PET_CHANGED] = {
		"onTopLogoControlStateChanged",
		true
	}
}

local PAWN_SWITCH_TRANSITION_FALLBACK = 1
local PAWN_SWITCH_RECONCILE_INTERVAL = 0.2

function TopLogoCtrl:ctor()
	UICtrl.ctor(self)

	self.topLogoHelper = TopLogoHelper.new(self)
	self.topLogoHideConfig = {}
	self.m_visualPawn = nil
	self.m_pawnSwitchTimer = nil
	self.m_pendingSwitchPawn = nil
	self.m_pawnSwitchReconcileTimer = nil
end

function TopLogoCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.topLogoRoot = self.view.transform:Find("TopLogoRoot"):GetComponent("TopLogoRoot")
	self.topLogoUContainerRoot = self.view.transform:Find("PreContainerRoot")

	self:refreshTopLogoConfig()
	pg.global.uiMgr:SetTopLogoRoot(self.topLogoRoot)
	self.topLogoHelper:init(self.view, self.topLogoRoot, {
		preloadTopLogoResIds = TopLogoConst.PreloadTopLogoResIds,
		preloadTopLogoUContainerInfo = TopLogoConst.PreloadTopLogoUContainerInfo
	}, self.topLogoUContainerRoot)
	self:restoreEntTopLogo()

	function self.m_onLanguageChanged()
		self:refreshAllTopLogos("onLanguageChanged")
	end

	pg.global.eventEmitter:addEventListener(EventConst.ON_LANGUAGE_CHANGED, self.m_onLanguageChanged)
end

function TopLogoCtrl:onDestroy()
	self:m_cancelPawnSwitchTimers()

	self.m_pendingSwitchPawn = nil

	if self.m_onLanguageChanged then
		pg.global.eventEmitter:removeEventListener(EventConst.ON_LANGUAGE_CHANGED, self.m_onLanguageChanged)

		self.m_onLanguageChanged = nil
	end

	local entities = pg.getEntities()

	for _, ent in pairs(entities) do
		if ent.destroyTopLogoItem then
			ent:destroyTopLogoItem()
		end
	end

	self.topLogoHelper:destroy()
	pg.global.uiMgr:SetTopLogoRoot(nil)
	UICtrl.onDestroy(self)
end

function TopLogoCtrl:restoreEntTopLogo()
	local entities = pg.getEntities()

	for _, ent in pairs(entities) do
		if ent.forbiddenTopLogo == false then
			ent:ensureTopLogoShell()
			ent:restoreCachedTopLogoDemand()
			ent:reconcileTopLogoLodTimer()
		end
	end

	self:m_prewarmPawnHub(self:getVisualPawn())
end

function TopLogoCtrl:onTopLogoItemCreated(topLogoItem)
	if not topLogoItem or topLogoItem._topLogoCtrlCreatedNotified then
		return
	end

	topLogoItem._topLogoCtrlCreatedNotified = true

	self:m_restorePersistentTopLogoState(topLogoItem)
	self:m_restoreWaterStorage(topLogoItem)

	local entity = topLogoItem.entity
	local ecsWaterTopLogo = entity and entity.topLogoData and entity.topLogoData.ecsWaterTopLogo

	if ecsWaterTopLogo then
		local callFriends = topLogoItem:peekToplogoComponent(UIConst.TOPLOGO_COMPONENT.CALL_FRIENDS)

		if callFriends and callFriends.refreshEcsTopLogoInfo then
			callFriends:refreshEcsTopLogoInfo(ecsWaterTopLogo.wetCount, ecsWaterTopLogo.totalWetCount, ecsWaterTopLogo.percent)
		end
	end
end

function TopLogoCtrl:m_restorePersistentTopLogoState(item)
	local action = item:peekToplogoComponent(UIConst.TOPLOGO_COMPONENT.ACTION_STATE)
	local actionState, multiInteractActionId = TopLogoActionStateComponent.resolveStateFromEntity(item.entity)

	if action then
		if action.actionState ~= actionState or action.multiInteractActionId ~= multiInteractActionId then
			action:restoreStateFromEntity()
		end
	elseif actionState ~= Const.PlayerActionState.None or multiInteractActionId > 0 then
		item:ensureToplogoComponent(UIConst.TOPLOGO_COMPONENT.ACTION_STATE, "action_restore")
	end

	local speech = item:peekToplogoComponent(UIConst.TOPLOGO_COMPONENT.TEAM_SPEECH)

	if TopLogoTeamSpeechComponent.resolveVisibleFromEntity(item.entity) then
		speech = item:ensureToplogoComponent(UIConst.TOPLOGO_COMPONENT.TEAM_SPEECH, "speech_restore")
	end

	if speech then
		speech:restoreStateFromEntity()
	end
end

function TopLogoCtrl:onTopLogoControlStateChanged(data)
	local playerId = data and (data.playerId or data.uid)
	local player = pg.me

	if playerId ~= nil and not isSamePlayerId(player and player.uid, playerId) then
		player = pg.getEntityByUid(playerId)
	end

	if not player then
		return
	end

	local restored = {}

	local function restore(entity)
		if not entity or restored[entity] or not entity.peekTopLogoItem then
			return
		end

		restored[entity] = true

		local item = entity:peekTopLogoItem()

		if item then
			self:m_restorePersistentTopLogoState(item)
		else
			local actionState, multiInteractActionId = TopLogoActionStateComponent.resolveStateFromEntity(entity)

			if actionState ~= Const.PlayerActionState.None or multiInteractActionId > 0 or TopLogoTeamSpeechComponent.resolveVisibleFromEntity(entity) then
				entity:ensureTopLogoItem("control_state_restore")
			end
		end
	end

	if player == pg.me then
		restore(pg.pawn)
	end

	restore(player.getCurPetEntity and player:getCurPetEntity())

	if data and data.newPetId then
		restore(pg.getEntity(data.newPetId))
	end

	restore(player)

	if data and data.oldPetId then
		restore(pg.getEntity(data.oldPetId))
	end

	if player == pg.me then
		restore(data and data.oldPawn)
		restore(data and data.oldVisualPawn)
		restore(self.m_visualPawn)
		restore(self.m_pendingSwitchPawn)
	end
end

function TopLogoCtrl:m_restoreWaterStorage(item)
	local entity = item.entity

	if entity ~= self:getVisualPawn() or not entity.isMainPet then
		return
	end

	if not entity.isFullExploreValue or not entity.isFastRecovery then
		return
	end

	if not AbilityUtils.isShowWaterStorage(entity) or entity:isFullExploreValue() or not entity:isFastRecovery() then
		return
	end

	local component = item:ensureToplogoComponent(UIConst.TOPLOGO_COMPONENT.WATER_STORAGE, "water_restore")

	if component then
		component:onWaterStorageUpdate()
	end
end

function TopLogoCtrl:refreshTopLogoConfig()
	if not self.view then
		return
	end

	if pg.space and pg.space:isHomeland() then
		self.topLogoRoot.sortTopLogo = true
	else
		self.topLogoRoot.sortTopLogo = false
	end
end

function TopLogoCtrl:getTopLogo(globalId)
	return self.topLogoHelper:getTopLogo(globalId)
end

function TopLogoCtrl:refreshAllTopLogos(funcName)
	self.topLogoHelper:refreshAllTopLogos(funcName)
end

function TopLogoCtrl:setTopLogoVisible(key, visible)
	if key then
		if visible then
			self.topLogoHideConfig[key] = nil
		else
			self.topLogoHideConfig[key] = true
		end

		self:refreshTopLogoVisible()
	end
end

function TopLogoCtrl:refreshTopLogoVisible()
	if Utils.tableIsEmptyOrNil(self.topLogoHideConfig) then
		self:show()
	else
		self:hide()
	end
end

function TopLogoCtrl:m_setTopLogoMonoPausedByCtrlVisible(visible)
	if self.topLogoHelper then
		self.topLogoHelper:setTopLogoMonoPaused(not visible)
	end
end

function TopLogoCtrl:setViewVisible(visible)
	UICtrl.setViewVisible(self, visible)
	self:m_setTopLogoMonoPausedByCtrlVisible(visible)
end

function TopLogoCtrl:onVisibleChange(visible)
	UICtrl.onVisibleChange(self, visible)
	self:m_setTopLogoMonoPausedByCtrlVisible(visible)
end

function TopLogoCtrl:onSetAllTopLogoVisible(visible)
	self.topLogoVisible = visible

	self.topLogoHelper:refreshTopLogoVisible()
end

function TopLogoCtrl:onSetTopLogoComponentVisible(param)
	self.topLogoHelper:setTopLogoComponentVisible(param.visibleKey, param.visible, param.targetCompNames)
end

function TopLogoCtrl:onSceneLoaded()
	self:refreshTopLogoConfig()
	self:m_refreshAllIcons()
end

function TopLogoCtrl:onSceneUnloaded()
	return
end

function TopLogoCtrl:onTargetPetBuffChanged()
	self:m_refreshAllIcons()
end

function TopLogoCtrl:m_refreshAllIcons()
	if not self.topLogoHelper or not self.topLogoHelper.topLogos then
		return
	end

	for _, topLogoItem in pairs(self.topLogoHelper.topLogos) do
		local entity = topLogoItem and topLogoItem.entity
		local iconDemand = entity and entity:getTopLogoIcon()
		local icon

		if iconDemand ~= nil then
			icon = topLogoItem:ensureToplogoComponent(UIConst.TOPLOGO_COMPONENT.ICON)
		elseif topLogoItem then
			icon = topLogoItem:peekToplogoComponent(UIConst.TOPLOGO_COMPONENT.ICON)
		end

		if icon and icon.m_refreshIcon then
			icon:m_refreshIcon()
		end
	end
end

function TopLogoCtrl:onPreparePetsUpdate()
	for _, topLogoItem in pairs(self.topLogoHelper.topLogos) do
		local combat = topLogoItem and topLogoItem:getToplogoComponent(UIConst.TOPLOGO_COMPONENT.COMBAT)

		if combat then
			combat:refreshLevelAndThreatState()
		end
	end
end

function TopLogoCtrl:onNewKnowChanged(info)
	for _, topLogoItem in pairs(self.topLogoHelper.topLogos) do
		local combat = topLogoItem and topLogoItem:getToplogoComponent(UIConst.TOPLOGO_COMPONENT.COMBAT)

		if combat and combat:checkContainerLoaded() and info.templateId == topLogoItem.entity.petPrototypeId then
			if combat.onNewKnowChanged then
				combat:onNewKnowChanged()
			else
				combat:refreshName(true)
			end
		end
	end
end

function TopLogoCtrl:onQuestTabSwitch(data)
	for _, topLogoItem in pairs(self.topLogoHelper.topLogos) do
		local quest = topLogoItem and topLogoItem:getToplogoComponent(UIConst.TOPLOGO_COMPONENT.QUEST)

		if quest then
			quest:onQuestTabSwitch(data)
		end
	end
end

function TopLogoCtrl:onQuestRunStateChange(data)
	for _, topLogoItem in pairs(self.topLogoHelper.topLogos) do
		local quest = topLogoItem and topLogoItem:getToplogoComponent(UIConst.TOPLOGO_COMPONENT.QUEST)

		if quest and quest.onQuestRunStateChange then
			quest:onQuestRunStateChange(data)
		end
	end
end

function TopLogoCtrl:onNpcDuelStateChanged(data)
	for _, topLogoItem in pairs(self.topLogoHelper.topLogos) do
		local battleRoom = topLogoItem and topLogoItem:ensureToplogoComponent(UIConst.TOPLOGO_COMPONENT.BATTLE_ROOM, "npc_duel_state")

		if battleRoom then
			battleRoom:onNpcDuelStateChanged(data)
		end
	end
end

function TopLogoCtrl:m_isTopLogoRelatedToPlayer(topLogoItem, playerId)
	if playerId == nil or playerId == "" then
		return true
	end

	local entity = topLogoItem and topLogoItem.entity

	if entity == nil then
		return false
	end

	if isSamePlayerId(entity.uid, playerId) or isSamePlayerId(entity.ownerUid, playerId) or isSamePlayerId(entity.playerUID, playerId) then
		return true
	end

	local masterEnt = entity.getMasterEntity and entity:getMasterEntity() or nil

	return isSamePlayerId(masterEnt and masterEnt.uid, playerId)
end

function TopLogoCtrl:onPlayerNameChange(info)
	local playerId = getPlayerNameChangeId(info)

	for _, topLogoItem in pairs(self.topLogoHelper.topLogos) do
		local combat = self:m_isTopLogoRelatedToPlayer(topLogoItem, playerId) and topLogoItem:getToplogoComponent(UIConst.TOPLOGO_COMPONENT.COMBAT)

		if combat then
			combat:refreshName(true)
			combat:refreshSubName()
		end
	end
end

function TopLogoCtrl:getVisualPawn()
	if self.m_visualPawn then
		return self.m_visualPawn
	end

	return pg.pawn or pg.me
end

function TopLogoCtrl:onPlayerTitleChange()
	for _, topLogoItem in pairs(self.topLogoHelper.topLogos) do
		local combat = topLogoItem and topLogoItem:getToplogoComponent(UIConst.TOPLOGO_COMPONENT.COMBAT)

		if combat and combat.refreshTitleSubNameState then
			combat:refreshTitleSubNameState()
		end
	end
end

function TopLogoCtrl:m_getPlayerHubComponent()
	local pawn = self:getVisualPawn()

	if pawn and pawn.getToplogoComponent then
		return pawn:getToplogoComponent(UIConst.TOPLOGO_COMPONENT.PLAYERHUB)
	end

	return nil
end

function TopLogoCtrl:m_syncOtherPlayerHubPawnStates(currentHub)
	if self.m_lastEnduranceConvergedHub == currentHub then
		return
	end

	local topLogos = self.topLogoHelper and self.topLogoHelper.topLogos

	if not topLogos then
		return
	end

	for _, topLogoItem in pairs(topLogos) do
		local hub = topLogoItem and topLogoItem:getToplogoComponent(UIConst.TOPLOGO_COMPONENT.PLAYERHUB)

		if hub and hub ~= currentHub and hub.syncPawnActiveState then
			hub:syncPawnActiveState()
		end
	end

	self.m_lastEnduranceConvergedHub = currentHub
end

function TopLogoCtrl:onPawnSwitched(data)
	self:m_cancelPawnSwitchTimers()

	local oldPawn = data and data.oldPawn or pg.me
	local oldVisualPawn = self.m_visualPawn or oldPawn
	local isFusing = pg.pawn ~= nil and pg.pawn ~= pg.me

	if isFusing then
		self.m_visualPawn = oldVisualPawn
		self.m_pendingSwitchPawn = pg.pawn

		self:m_prewarmPawnHub(pg.pawn)

		self.m_pawnSwitchTimer = self:startTimer(function()
			self.m_pawnSwitchTimer = nil

			self:m_finishPawnSwitch()
		end, self:m_getPawnSwitchTransition())
		self.m_pawnSwitchReconcileTimer = self:startTimer(function()
			self:m_reconcilePawnSwitchWindow()
		end, PAWN_SWITCH_RECONCILE_INTERVAL, true)

		self:onTopLogoControlStateChanged(data)
		self:onPawnSwitchUpdateExploreSkill(oldVisualPawn)
	else
		self.m_visualPawn = nil
		self.m_pendingSwitchPawn = nil

		self:m_applyPawnSwitch(nil, oldPawn, oldVisualPawn)
	end
end

function TopLogoCtrl:isPawnSwitchTransiting()
	return self.m_pendingSwitchPawn ~= nil
end

function TopLogoCtrl:m_cancelPawnSwitchTimers()
	if self.m_pawnSwitchTimer then
		self:killTimer(self.m_pawnSwitchTimer)

		self.m_pawnSwitchTimer = nil
	end

	if self.m_pawnSwitchReconcileTimer then
		self:killTimer(self.m_pawnSwitchReconcileTimer)

		self.m_pawnSwitchReconcileTimer = nil
	end
end

function TopLogoCtrl:notifyPawnSwitchVisualDone()
	if self.m_pendingSwitchPawn == nil then
		return
	end

	self:m_cancelPawnSwitchTimers()
	self:m_finishPawnSwitch()
end

function TopLogoCtrl:m_finishPawnSwitch()
	self:m_cancelPawnSwitchTimers()

	local oldVisualPawn = self.m_visualPawn

	self.m_visualPawn = nil

	local targetPawn = self.m_pendingSwitchPawn

	self.m_pendingSwitchPawn = nil

	self:m_applyPawnSwitch(targetPawn, oldVisualPawn, oldVisualPawn)
end

function TopLogoCtrl:m_prewarmPawnHub(pawn)
	if pawn == nil or pawn.ensureToplogoComponent == nil then
		return
	end

	local hub = pawn:ensureToplogoComponent(UIConst.TOPLOGO_COMPONENT.PLAYERHUB, "player_hub")

	if pawn.tickTopLogo then
		pawn:tickTopLogo(true)
	end

	if hub and hub.prewarmContainers then
		hub:prewarmContainers()
	end
end

function TopLogoCtrl:m_reconcilePawnSwitchWindow()
	local targetPawn = self.m_pendingSwitchPawn

	if targetPawn == nil then
		self:m_cancelPawnSwitchTimers()

		return
	end

	local me = pg.me
	local inSwitchAnim = me ~= nil and (me.switchEndTime ~= nil or me.inSwitchAnim == true)

	if not inSwitchAnim then
		self:m_finishPawnSwitch()

		return
	end

	self:m_prewarmPawnHub(targetPawn)
end

function TopLogoCtrl:m_getPawnSwitchTransition()
	return math.max(SysConfigData.switchAppearTime or 0, PAWN_SWITCH_TRANSITION_FALLBACK)
end

function TopLogoCtrl:m_applyPawnSwitch(targetPawn, oldPawn, oldVisualPawn)
	targetPawn = targetPawn or pg.pawn

	self:onTopLogoControlStateChanged({
		oldPawn = oldPawn,
		oldVisualPawn = oldVisualPawn
	})

	if targetPawn and targetPawn.refreshTopLogoHeight then
		targetPawn:refreshTopLogoHeight()
	end

	local targetHub = targetPawn and targetPawn.getToplogoComponent and targetPawn:getToplogoComponent(UIConst.TOPLOGO_COMPONENT.PLAYERHUB)

	if targetHub and targetHub.notifyPawnChanged then
		targetHub:notifyPawnChanged()
	end

	local entities = pg.getEntities()

	if entities then
		for _, ent in pairs(entities) do
			if ent and ent.getToplogoComponent then
				local hub = ent:getToplogoComponent(UIConst.TOPLOGO_COMPONENT.PLAYERHUB)

				if hub and hub ~= targetHub and hub.notifyPawnChanged then
					hub:notifyPawnChanged()
				end
			end
		end
	end

	if pg.me and pg.me.tickTopLogo then
		pg.me:tickTopLogo(true)
	end

	if targetPawn and targetPawn ~= pg.me and targetPawn.tickTopLogo then
		targetPawn:tickTopLogo(true)
	end

	self:onPawnSwitchUpdateExploreSkill(oldVisualPawn or oldPawn)
end

function TopLogoCtrl:onPlayerHubHpChange(changeData)
	local hub = self:m_getPlayerHubComponent()

	if hub then
		hub:refreshPlayerHp(changeData)
	end
end

function TopLogoCtrl:onPlayerHubEnduranceChange()
	if self:isPawnSwitchTransiting() then
		return
	end

	local hub = self:m_getPlayerHubComponent()

	self:m_syncOtherPlayerHubPawnStates(hub)

	if hub then
		hub:onEnduranceChange()
	end
end

function TopLogoCtrl:onPlayerHubCharacterStateChanged()
	local hub = self:m_getPlayerHubComponent()

	if hub then
		hub:onCharacterStateChanged()
	end
end

function TopLogoCtrl:onPlayerHubMaxEnduranceChange(info)
	if self:isPawnSwitchTransiting() then
		return
	end

	local hub = self:m_getPlayerHubComponent()

	if hub then
		hub:onPlayerEnduranceChange(info)
	end
end

function TopLogoCtrl:onPlayerHubCheckEnduranceEnough(info)
	if info and info.isEnough == false then
		local hub = self:m_getPlayerHubComponent()

		if hub then
			hub:onEnduranceNotEnough()
		end
	end
end

function TopLogoCtrl:onPlayerHubEnterDead()
	local hub = self:m_getPlayerHubComponent()

	if hub and hub.onPlayerHubLifeUnalive then
		hub:onPlayerHubLifeUnalive()
	end
end

function TopLogoCtrl:onPlayerHubEnterFallen()
	local hub = self:m_getPlayerHubComponent()

	if hub and hub.onPlayerHubLifeUnalive then
		hub:onPlayerHubLifeUnalive()
	end
end

function TopLogoCtrl:onPlayerHubEnterAlive()
	local hub = self:m_getPlayerHubComponent()

	if hub and hub.onPlayerHubLifeAlive then
		hub:onPlayerHubLifeAlive()
	end
end

function TopLogoCtrl:onPetExploreSkillValChanged()
	local com = self:m_getPetWaterStorageComponent(true)

	if com == nil then
		return
	end

	com:onWaterStorageValueUpdate()
end

function TopLogoCtrl:onPetExploreSkillValStateChanged(state)
	local com = self:m_getPetWaterStorageComponent(true)

	if com == nil then
		return
	end

	com:onWaterStorageUpdate(state)
end

function TopLogoCtrl:onPawnSwitchUpdateExploreSkill(oldVisualPawn)
	local pawn = self:getVisualPawn()
	local component = pawn and pawn.getToplogoComponent and pawn:getToplogoComponent(UIConst.TOPLOGO_COMPONENT.WATER_STORAGE)

	if component then
		component:onWaterStorageUpdate()
	elseif pawn and pawn.isMainPet and pawn.isFullExploreValue and pawn.isFastRecovery and AbilityUtils.isShowWaterStorage(pawn) and not pawn:isFullExploreValue() and pawn:isFastRecovery() then
		local item = pawn:peekTopLogoItem()

		if item then
			self:m_restoreWaterStorage(item)
		else
			pawn:ensureTopLogoItem("water_restore")
		end
	end

	if oldVisualPawn and oldVisualPawn ~= pawn and oldVisualPawn.getToplogoComponent then
		local oldComponent = oldVisualPawn:getToplogoComponent(UIConst.TOPLOGO_COMPONENT.WATER_STORAGE)

		if oldComponent then
			oldComponent:onWaterStorageUpdate()
		end
	end
end

function TopLogoCtrl:m_getPetWaterStorageComponent(ensure)
	local pawn = self:getVisualPawn()

	if pawn and pawn.ensureToplogoComponent and ensure then
		return pawn:ensureToplogoComponent(UIConst.TOPLOGO_COMPONENT.WATER_STORAGE, "water_storage")
	end

	if pawn and pawn.getToplogoComponent then
		return pawn:getToplogoComponent(UIConst.TOPLOGO_COMPONENT.WATER_STORAGE)
	end

	return nil
end

return TopLogoCtrl
