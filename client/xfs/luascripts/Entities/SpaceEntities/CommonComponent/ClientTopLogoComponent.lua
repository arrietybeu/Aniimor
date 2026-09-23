-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientTopLogoComponent.lua

local Class = require("Core.Framework.Class")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("TopLogo")
local Utils = require("Common.Utils.Utils")
local Bitset = require("Common.Bitset")
local ClientConst = require("Const.ClientConst")
local DialogueConst = require("Const.DialogueConst")
local EventConst = require("Const.EventConst")
local UIConst = require("Const.UIConst")
local TopLogoConst = require("Const.TopLogoConst")
local TopLogoItemTypeDefs = require("Guis.Panels.TopLogo.Node.TopLogoItemTypeDefs")
local TopLogoShell = require("Guis.Panels.TopLogo.Node.TopLogoShell")
local TopLogoPvp2Helper = require("Guis.Panels.TopLogo.TopLogoPvp2Helper")
local lume = require("Core.Common.lume")
local Time = require("Core.Common.Time")
local EntityQuestData = require("Data.Quest.quest_entity_revert_data")
local NpcDialogueData = require("Data.npc_dialogue_data")
local QuestPathfindingData = require("Data.Quest.quest_pathfinding_data")
local QuestUtils = require("GameApp.Quest.QuestUtils")
local QuestConst = require("Common.Const.QuestConst")
local SceneUtils = require("Common.Utils.SceneUtils")
local GlobalData = require("Core.Client.GlobalData")
local CatchRogueBuffData = require("Data.catch_rogue_buff_data")
local LuaTopLogoUtils = require("Utils.LuaTopLogoUtils")
local SysConfigData = require("Data.sys_config_data")
local TimerManager = require("Core.Timer.TimerManager")
local MaxDistance = 99999
local Pvp2OwnerResolveMaxRetries = 10
local SpecialInteract = require("Entities.SpaceEntities.CommonComponent.NpcInteract.SpecialInteract")

local function getDialogueTimelineDuration(dialogueId)
	if dialogueId == nil then
		return 0
	end

	if dialogueId == DialogueConst.CUSTOM_BUBBLE_DIALOGUE_ID then
		return DialogueConst.CUSTOM_BUBBLE_DEFAULT_DURATION or 3
	end

	local dialogGraph = NpcDialogueData[dialogueId] or {}
	local duration = 0
	local index = 1

	while dialogGraph[index] do
		duration = duration + (tonumber(dialogGraph[index].duration) or 3)
		index = index + 1
	end

	return duration
end

local ClientTopLogoComponent = Class.Component("ClientTopLogoComponent")

function ClientTopLogoComponent:ctor()
	self.topLogoData = {}
	self.forbiddenTopLogo = true
	self.enableTopLogo = true
	self.topLogoInit = false
	self.questRefPosIds = {}
	self.topLogoItem = nil
	self.topLogoShell = nil
	self._isControllingEgg = nil
	self._topLogoHasEModel = false
	self._topLogoDeadState = false
	self._topLogoAliveGate = false
	self._topLogoVisibleGate = nil
	self._inTopLogoLod20Range = false
	self._inTopLogoLod40Range = false
	self._topLogoLodTimerRegistered = false
	self._topLogoOtherCompVisiblePolicies = {}
	self._isPvp2Scene = false
	self._entityPvp2Type = nil
	self._pvp2OwnerPlayer = nil
	self._isPvp2EnemyTargetBase = false
	self._isPvp2FriendlyOwnedEntity = false
	self._pvp2OwnerResolveRetries = 0
	self._pvp2RevealExpireTime = 0
	self._pvp2RevealCacheReady = false
	self._pvp2RevealTimer = nil
	self._cachedNameState = nil
	self._forceShowBubble = false
end

function ClientTopLogoComponent:_cacheConfig()
	local configData = self:getConfigData()

	self.overrideNameState = configData and configData.overrideNameState
	self.configMasterName = configData and configData.masterName
	self.configName = configData and configData.name
end

function ClientTopLogoComponent:init()
	self._isRealPuppet = Utils.isPuppet(self)

	if not LuaTopLogoUtils.getIsCreateTopLogo(self._isRealPuppet, self.isGrabEggTransfer) then
		self.forbiddenTopLogo = true
	end

	if self.forbiddenTopLogo then
		return
	end

	self._isPlayer = Utils.isPlayer(self) or Utils.isPlayerGhost(self)
	self._isPet = Utils.isPet(self)
	self._isPuppet = Utils.IsPuppetAll(self)
	self._isStaticNpc = Utils.isStaticNpc(self)
	self._isEnvObj = Utils.isEnvObj(self)
	self._isVehicle = Utils.isVehicle(self)
	self._isMainPlayer = Utils.isMainPlayer(self)
	self._isMasterPlayer = Utils.getMasterPlayer(self)
	self._isStaticNpcWithNpcTopLogo = Utils.isStaticNpcWithNpcTopLogo(self)
	self._isCombatType = Utils.isTopLogoCombat(self)
	self._isVirPetNotNull = Utils.isVirtualPetNotNull(self)

	self:refreshTopLogoVisibleGate()

	self._topLogoHasEModel = self.eModel ~= nil

	self:refreshTopLogoDeadState()
	self:_cacheConfig()
	self:addListener()
end

function ClientTopLogoComponent:start()
	if self.forbiddenTopLogo then
		return
	end

	self.topLogoInit = true

	self:onRobEggControlMsg()
	self:_initPvp2Cache()
	self:updateAttachMap()
	self:ensureTopLogoShell()
	self:restoreCachedTopLogoDemand()

	if self._isMainPlayer then
		self:ensureTopLogoItem("player_hub")
	end

	self:reconcileTopLogoLodTimer()
end

function ClientTopLogoComponent:destroy()
	if not self.topLogoInit then
		return
	end

	self.topLogoInit = false
	self._topLogoPreCombat = nil
	self._forceShowBubble = false

	self:_cancelPvp2RevealTimer()
	self:reconcileTopLogoLodTimer(true)
	self.eventEmitter:removeEventListener(EventConst.TOPLOGO_HEIGHT, self.onHeightMsg)
	self.eventEmitter:removeEventListener(EventConst.ON_CAMOUFLAGE_CHANGE, self.onCamouflageChange)
	self.eventEmitter:removeEventListener(EventConst.TOPLOGO_BUBBLE, self.onBubbleMsg)
	self.eventEmitter:removeEventListener(EventConst.TOPLOGO_BUBBLE_WITH_INFO, self.onBubbleWithInfoMsg)
	self.eventEmitter:removeEventListener(EventConst.TOPLOGO_ALERT, self.onAlertMsg)
	self.eventEmitter:removeEventListener(EventConst.TOPLOGO_DIALOGUE, self.onDialogueMsg)
	self:destroyTopLogoItem()
	self:_finishCachedDialogueDemand()
end

function ClientTopLogoComponent:addListener()
	function self.onHeightMsg()
		self:refreshTopLogoHeight()
	end

	function self.onCamouflageChange()
		self:refreshTopLogoVisibleGate()
	end

	function self.onBubbleMsg(isVisible, emojiName, duration, matchMultiple, forceShow)
		if isVisible then
			self.topLogoData.playingEmojiName = emojiName
			self.topLogoData.playingDuration = duration or 2
			self.topLogoData.playStartTime = Time.realSecondCache
			self.topLogoData.matchMultiple = matchMultiple

			local nextForceShow = forceShow == true and self.allowFarTopLogo ~= true

			if self._forceShowBubble ~= nextForceShow then
				self._forceShowBubble = nextForceShow

				self:reconcileTopLogoLodTimer()
			end

			if self:ensureTopLogoItem("bubble") then
				local topLogoItem = self.topLogoItem
				local bubbleComponent = topLogoItem and topLogoItem:peekToplogoComponent(UIConst.TOPLOGO_COMPONENT.BUBBLE)

				if not bubbleComponent then
					bubbleComponent = topLogoItem and topLogoItem:ensureToplogoComponent(UIConst.TOPLOGO_COMPONENT.BUBBLE, "bubble_event")

					if bubbleComponent then
						bubbleComponent:refreshTopLogoInfo(false)
					end
				end

				self:showTopLogoEx(nil, "bubble")
			end
		else
			self.topLogoData.playingEmojiName = nil
			self.topLogoData.playingDuration = nil
			self.topLogoData.playStartTime = nil
			self.topLogoData.matchMultiple = nil
			self.topLogoData.pendingBubbleInfo = nil

			if self._forceShowBubble then
				self._forceShowBubble = false

				self:reconcileTopLogoLodTimer()
			end
		end
	end

	function self.onBubbleWithInfoMsg(emojiInfo)
		local bubbleComponent = self.topLogoItem and self.topLogoItem:peekToplogoComponent(UIConst.TOPLOGO_COMPONENT.BUBBLE)

		if bubbleComponent then
			return
		end

		self.topLogoData.pendingBubbleInfo = emojiInfo

		if self:ensureTopLogoItem("bubble_info") then
			local topLogoItem = self.topLogoItem

			bubbleComponent = topLogoItem and topLogoItem:ensureToplogoComponent(UIConst.TOPLOGO_COMPONENT.BUBBLE, "bubble_info_event")

			if bubbleComponent then
				bubbleComponent:refreshTopLogoInfo(false)

				self.topLogoData.pendingBubbleInfo = nil
			end

			self:showTopLogoEx(nil, "bubble_info")
		end
	end

	function self.onAlertMsg(visible, markType, timeout)
		if not self._isPet and not self._isPuppet then
			return
		end

		self.topLogoData.alertVisible = visible == true
		self.topLogoData.alertMarkType = markType
		self.topLogoData.alertTimeout = timeout

		if not visible then
			return
		end

		local alertComponent = self.topLogoItem and self.topLogoItem:peekToplogoComponent(UIConst.TOPLOGO_COMPONENT.ALERT)

		if not alertComponent and self:ensureTopLogoItem("alert") then
			local topLogoItem = self.topLogoItem

			alertComponent = topLogoItem and topLogoItem:ensureToplogoComponent(UIConst.TOPLOGO_COMPONENT.ALERT, "alert_event")

			if alertComponent then
				alertComponent:refreshTopLogoInfo(false)
			end

			self:showTopLogoEx(nil, "alert")
		end
	end

	function self.onDialogueMsg(isVisible, dialogueId, dialogueText, finishCallback, forceShowInCombat)
		local previousDialogueMsg = self.topLogoData.DialogueMsg

		if not isVisible and finishCallback == nil and previousDialogueMsg then
			finishCallback = previousDialogueMsg[4]
		end

		local dialogueMsg = {
			isVisible,
			dialogueId,
			dialogueText or "",
			finishCallback,
			forceShowInCombat
		}

		if isVisible then
			dialogueMsg.startTime = Time.realSecondCache
			dialogueMsg.expireAt = dialogueMsg.startTime + getDialogueTimelineDuration(dialogueId)
		end

		self.topLogoData.DialogueMsg = dialogueMsg

		if isVisible then
			if self:ensureToplogoComponent(UIConst.TOPLOGO_COMPONENT.CHAT, "dialogue") then
				self:showTopLogoEx(nil, "dialogue")
			end
		elseif not self.topLogoItem then
			self:_finishCachedDialogueDemand()
		end
	end

	self.eventEmitter:addEventListener(EventConst.TOPLOGO_HEIGHT, self.onHeightMsg)
	self.eventEmitter:addEventListener(EventConst.ON_CAMOUFLAGE_CHANGE, self.onCamouflageChange)
	self.eventEmitter:addEventListener(EventConst.TOPLOGO_BUBBLE, self.onBubbleMsg)
	self.eventEmitter:addEventListener(EventConst.TOPLOGO_BUBBLE_WITH_INFO, self.onBubbleWithInfoMsg)
	self.eventEmitter:addEventListener(EventConst.TOPLOGO_ALERT, self.onAlertMsg)
	self.eventEmitter:addEventListener(EventConst.TOPLOGO_DIALOGUE, self.onDialogueMsg)
end

function ClientTopLogoComponent:clearTimedBubbleDemand(emojiName, playStartTime)
	local topLogoData = self.topLogoData

	if not topLogoData or topLogoData.playingEmojiName ~= emojiName then
		return false
	end

	if topLogoData.playStartTime ~= playStartTime then
		return false
	end

	topLogoData.playingEmojiName = nil
	topLogoData.playingDuration = nil
	topLogoData.playStartTime = nil
	topLogoData.matchMultiple = nil
	topLogoData.pendingBubbleInfo = nil

	if self._forceShowBubble then
		self._forceShowBubble = false

		self:reconcileTopLogoLodTimer()
	end

	return true
end

function ClientTopLogoComponent:_finishCachedDialogueDemand()
	local topLogoData = self.topLogoData
	local dialogueMsg = topLogoData and topLogoData.DialogueMsg

	if not dialogueMsg then
		return
	end

	topLogoData.DialogueMsg = nil

	local finishCallback = dialogueMsg[4]

	dialogueMsg[4] = nil

	if finishCallback then
		finishCallback()
	end
end

function ClientTopLogoComponent:restoreCachedTopLogoDemand()
	local topLogoData = self.topLogoData

	if not topLogoData then
		return
	end

	local dialogueMsg = topLogoData.DialogueMsg

	if dialogueMsg and dialogueMsg[1] == true then
		if dialogueMsg.expireAt and dialogueMsg.expireAt <= Time.realSecondCache then
			self:_finishCachedDialogueDemand()
		elseif self:ensureToplogoComponent(UIConst.TOPLOGO_COMPONENT.CHAT, "dialogue_restore") then
			self:showTopLogoEx(nil, "dialogue")
		end
	end

	local alertVisible = topLogoData.alertVisible

	if alertVisible and self:ensureTopLogoItem("alert") then
		local topLogoItem = self.topLogoItem
		local alertComponent = topLogoItem and topLogoItem:ensureToplogoComponent(UIConst.TOPLOGO_COMPONENT.ALERT, "alert_restore")

		if alertComponent then
			alertComponent:refreshTopLogoInfo(false)
		end

		self:showTopLogoEx(nil, "alert_restore")
	end

	if topLogoData.pendingBubbleInfo and self:ensureTopLogoItem("bubble_info") then
		local topLogoItem = self.topLogoItem
		local bubbleComponent = topLogoItem and topLogoItem:ensureToplogoComponent(UIConst.TOPLOGO_COMPONENT.BUBBLE, "bubble_info_restore")

		if bubbleComponent then
			bubbleComponent:refreshTopLogoInfo(false)

			topLogoData.pendingBubbleInfo = nil
		end

		self:showTopLogoEx(nil, "bubble_info_restore")
	end

	if topLogoData.playingEmojiName == nil then
		return
	end

	local playingDuration = topLogoData.playingDuration
	local playStartTime = topLogoData.playStartTime
	local expired = playingDuration ~= nil and playingDuration ~= -1 and playStartTime ~= nil and playingDuration <= Time.realSecondCache - playStartTime

	if not expired then
		local bubbleComponent = self:ensureToplogoComponent(UIConst.TOPLOGO_COMPONENT.BUBBLE, "bubble_restore")

		if bubbleComponent then
			bubbleComponent:refreshTopLogoInfo(false)
			self:showTopLogoEx(nil, "bubble")
		end

		return
	end

	topLogoData.playingEmojiName = nil
	topLogoData.playingDuration = nil
	topLogoData.playStartTime = nil
	topLogoData.matchMultiple = nil

	if self._forceShowBubble then
		self._forceShowBubble = false

		self:reconcileTopLogoLodTimer()
	end
end

function ClientTopLogoComponent:onRobEggControlMsg()
	local isInControlEgg = ToBool(self.controlEggId)

	self._isControllingEgg = self._isPlayer and isInControlEgg

	self:refreshTopLogoVisibleGate()
end

function ClientTopLogoComponent:_initPvp2Cache()
	if self._isPlayer then
		self._entityPvp2Type = "PLAYER"
	elseif self._isPet then
		self._entityPvp2Type = "PET"
	elseif self._isPuppet then
		self._entityPvp2Type = "PUPPET"
	elseif self.isRobSpaceEgg then
		self._entityPvp2Type = "ROB_EGG"
	else
		self._entityPvp2Type = "OTHER"
	end

	self:_refreshPvp2OwnerCache(true)

	self._isPvp2PetEnt = self._entityPvp2Type == "PET" or self._entityPvp2Type == "PLAYER" and not Utils.isMainPlayer(self)
end

function ClientTopLogoComponent:_resolvePvp2OwnerPlayer()
	local entityType = self._entityPvp2Type

	if entityType == "PLAYER" then
		return self, false
	elseif entityType == "PET" then
		local ownerPlayer = Utils.getMasterPlayer(self)

		return ownerPlayer, ownerPlayer == nil
	elseif entityType == "PUPPET" then
		if self.masterActorId == nil or self.masterActorId <= 0 then
			return nil, false
		end

		local ownerPlayer = Utils.getMasterPlayer(self)

		return ownerPlayer, ownerPlayer == nil
	elseif entityType == "ROB_EGG" then
		if not self:isBeControlled() then
			return nil, false
		end

		local ownerPlayer = Utils.getMasterPlayer(self)

		return ownerPlayer, ownerPlayer == nil
	end

	return self, false
end

function ClientTopLogoComponent:_refreshPvp2OwnerCache(resetRetryBudget)
	local oldOwnerPlayer = self._pvp2OwnerPlayer
	local ownerPlayer, shouldRetry = self:_resolvePvp2OwnerPlayer()

	self._pvp2OwnerPlayer = ownerPlayer
	self._isMasterPlayer = ownerPlayer

	if ownerPlayer ~= nil or not shouldRetry then
		self._pvp2OwnerResolveRetries = 0
	elseif resetRetryBudget then
		self._pvp2OwnerResolveRetries = Pvp2OwnerResolveMaxRetries
	end

	return oldOwnerPlayer ~= ownerPlayer
end

function ClientTopLogoComponent:refreshPvp2TeamCache(resetOwnerRetry)
	if not self._isPvp2Scene then
		return
	end

	local ownerChanged = self:_refreshPvp2OwnerCache(resetOwnerRetry ~= false)
	local ownerPlayer = self._pvp2OwnerPlayer
	local me = pg.me
	local friendly = false

	if ownerPlayer and ownerPlayer.uid and me then
		friendly = ownerPlayer.uid == me.uid or me:isUidTeamMember(ownerPlayer.uid)
	end

	local enemy = self:_calcPvp2EnemyTargetBase()
	local friendlyChanged = friendly ~= self._isPvp2FriendlyOwnedEntity
	local enemyChanged = enemy ~= self._isPvp2EnemyTargetBase

	self._isPvp2FriendlyOwnedEntity = friendly
	self._isPvp2EnemyTargetBase = enemy

	if ownerChanged or friendlyChanged or enemyChanged then
		self._cachedNameState = nil

		self:reconcileTopLogoLodTimer()
	end

	if friendlyChanged then
		self:refreshTopLogoAliveGate()
		self:refreshTopLogoVisibleGate()
	end

	if ownerChanged and self._entityPvp2Type == "ROB_EGG" then
		self:_refreshPvp2RobEggTopLogoType()
	end

	if self.topLogoInit and self:_shouldPrewarmPvp2TopLogoItem() then
		self:ensureTopLogoItem("pvp2")
	end

	return ownerChanged
end

function ClientTopLogoComponent:_retryPvp2OwnerCache()
	local retries = self._pvp2OwnerResolveRetries or 0

	if retries <= 0 then
		return
	end

	self._pvp2OwnerResolveRetries = retries - 1

	self:refreshPvp2TeamCache(false)
end

function ClientTopLogoComponent:_updatePvp2SceneCache()
	self._isPvp2Scene = LuaTopLogoUtils.isPvp2TopLogoScene()

	if not self._isPvp2Scene then
		return
	end

	self:refreshPvp2TeamCache()
	self:_updatePvp2RevealState()
end

function ClientTopLogoComponent:isPvp2FriendlyLinkedPlayerTopLogoPass()
	if not self._isPvp2Scene or not self._isPlayer or self._isMainPlayer or not self._isPvp2FriendlyOwnedEntity or not self.isControllingPet or not self:isControllingPet() then
		return false
	end

	local switchingKey = ClientConst.MODEL_VISIBLE_KEY.SWITCHING

	if not Bitset.getBit(self.modelActiveKeys, switchingKey) then
		return false
	end

	local activeHideKeys = Bitset.getList(self.modelActiveKeys)

	return #activeHideKeys == 1 and not Bitset.any(self.modelVisibleKeys)
end

function ClientTopLogoComponent:refreshTopLogoAliveGate()
	local linkedPlayerPass = self:isPvp2FriendlyLinkedPlayerTopLogoPass()
	local isEntityStateAlive = self._isMainPlayer or (self.active ~= false or linkedPlayerPass) and not self._topLogoDeadState

	self._topLogoAliveGate = self._topLogoHasEModel and self.enableTopLogo and isEntityStateAlive or false
end

function ClientTopLogoComponent:isCurrentPlayerHubHostPass()
	local ctrl = pg.global.ui and pg.global.ui.topLogo

	if ctrl == nil or ctrl.isPawnSwitchTransiting == nil or not ctrl:isPawnSwitchTransiting() then
		return false
	end

	if self._isMainPlayer then
		return true
	end

	return self:isCurrentPlayerHubTopLogo()
end

function ClientTopLogoComponent:refreshTopLogoVisibleGate()
	local oldVisibleGate = self._topLogoVisibleGate
	local linkedPlayerPass = self:isPvp2FriendlyLinkedPlayerTopLogoPass()
	local isEntityModelVisible = self:isCurrentPlayerHubHostPass() or self.active ~= false and self.visible ~= false or linkedPlayerPass
	local visibleGate = isEntityModelVisible and not self.hideTopLogo and not self.isTransparent and not self._isControllingEgg and (not self.isCamouflage or not not self:isCurrentPlayerHubTopLogo())

	self._topLogoVisibleGate = visibleGate

	if oldVisibleGate ~= visibleGate and not visibleGate then
		self:applyTopLogoVisible(false)
	end

	return visibleGate
end

function ClientTopLogoComponent:setTopLogoEModelAlive(alive)
	self._topLogoHasEModel = alive and true or false

	self:refreshTopLogoAliveGate()
end

function ClientTopLogoComponent:setEnableTopLogo(enable)
	self.enableTopLogo = enable

	self:refreshTopLogoAliveGate()
end

function ClientTopLogoComponent:getAttachEntityName()
	local originName = self:_getAttachEntityNameImpl()

	return originName
end

function ClientTopLogoComponent:_getAttachEntityNameImpl()
	if self._isPuppet or self._isStaticNpc or self._isVehicle then
		if self.templateId then
			if self.getName then
				return self:getName() or ""
			else
				return self.configName or ""
			end
		end
	elseif self._isPet then
		local masterEnt = self:getMasterEntity()

		if masterEnt then
			local isControllingPet = masterEnt:isControllingPet()
			local playerName = self:m_getMastEntName(masterEnt.playerName or "", self)

			if isControllingPet and playerName ~= "" then
				return playerName
			end

			local pet = masterEnt:getPetInfo(self.id)

			if pet and pet.customName and pet.customName ~= "" then
				return pet.customName
			end
		end

		local petEnt = pg.getEntity(self.id)

		if petEnt and petEnt.customName and petEnt.customName ~= "" then
			return petEnt.customName
		end

		return self.configName or ""
	elseif self._isPlayer then
		if self:isDeformToEggMan() then
			return self.configName or ""
		else
			return self:m_getMastEntName(self.playerName or "", self)
		end
	elseif Utils.isVirtualEntity(self) then
		return self.templateId and self.configName or ""
	end
end

function ClientTopLogoComponent:m_getMastEntName(mastEntName, ent)
	local playerName = mastEntName or ""

	if pg.space and pg.space:isGrabEgg() and Utils.isEnemy(ent, pg.me) then
		playerName = pg.getGameString("GRAB_EGG_ENEMY_PLAYER")
	end

	return playerName
end

function ClientTopLogoComponent:getTopLogoIcon()
	if self.topLogoData ~= nil and self.topLogoData.petAiTrackingIcon ~= nil then
		return self.topLogoData.petAiTrackingIcon
	end

	if Utils.isPlayerInSpaceCatchRogueDungeon(pg.me) and self._isPuppet then
		local catchRoguePuppetInfo = pg.me:getCatchRoguePuppetInfo(self.staticId)

		if catchRoguePuppetInfo and catchRoguePuppetInfo.addOnId then
			return CatchRogueBuffData[catchRoguePuppetInfo.addOnId] and CatchRogueBuffData[catchRoguePuppetInfo.addOnId].topLogoUi
		end
	end
end

function ClientTopLogoComponent:getTopLogoEnterDistance()
	if self.overrideTopLogoEnterDistance then
		return self.overrideTopLogoEnterDistance
	end

	return UIConst.TopLogoEnterRange
end

function ClientTopLogoComponent:updateAttachMap()
	self.isBeAttached = self.attachMap and next(self.attachMap)
end

function ClientTopLogoComponent:onEnterSpace()
	self:refreshTopLogoDeadState()
	self:initTopLogoQuestInfo()
	self:initTopLogoChatInfo()
	self:onRobEggControlMsg()
	self:checkTopLogoRobEgg()
	self:checkTopLogoRobEggControlled()
	self:_updatePvp2SceneCache()
end

function ClientTopLogoComponent:onEnterCombat()
	self:_syncShellMaxDistance()
	self:_onInCombatChanged(true)
end

function ClientTopLogoComponent:onLeaveCombat()
	self:_syncShellMaxDistance()
	self:_onInCombatChanged(false)
end

function ClientTopLogoComponent:EVENT_ConfigDataChange()
	if self.forbiddenTopLogo then
		return
	end

	self:_cacheConfig()

	self._cachedNameState = nil

	if not self.topLogoItem then
		return
	end

	self:updateNameState()
	self.eventEmitter:emit(EventConst.NPC_SPECIAL_STATE_UPDATE)

	local combat = self:getToplogoComponent(UIConst.TOPLOGO_COMPONENT.COMBAT)

	if combat and combat:checkContainerLoaded() then
		combat:refreshName(true)
		combat:refreshSubName()
	end

	local workState = self:getToplogoComponent(UIConst.TOPLOGO_COMPONENT.WORK_STATE)

	if workState then
		workState:markDirty(EventConst.HOMELAND_WORK_STATE_CHANGED)

		if workState:checkContainerLoaded() then
			workState:refreshTopLogoInfo()
		end
	end
end

function ClientTopLogoComponent:onSkeletonLoaded()
	self:refreshTopLogoHeight(TopLogoConst.GET_TOPLOGO_HEIGHT_ENTRY.ON_SKELETON_LOADED)
end

function ClientTopLogoComponent:EVENT_OnHit(srcActorId, abilityId)
	self.topLogoData.isHitTriggered = true
end

function ClientTopLogoComponent:EVENT_OnEnterInteractRange()
	local comp = self:getToplogoComponent(UIConst.TOPLOGO_COMPONENT.INTERACT_SIGN)

	if comp then
		comp:refreshTopLogoInfo()
	end
end

function ClientTopLogoComponent:EVENT_PerceptibilitySearchEntityChanged()
	if self._isPvp2Scene then
		self:refreshPvp2TeamCache()
	end
end

function ClientTopLogoComponent:isPvp2EnemyRevealTarget()
	return self._isPvp2Scene and self._isPvp2EnemyTargetBase
end

function ClientTopLogoComponent:isPvp2RevealActive()
	return self._pvp2RevealCacheReady and self._pvp2RevealExpireTime > Time.getMillisecond()
end

function ClientTopLogoComponent:canShowPvp2RevealTarget()
	if not self:isPvp2EnemyRevealTarget() then
		return false
	end

	return self:isPvp2RevealActive()
end

function ClientTopLogoComponent:_shouldPrewarmPvp2TopLogoItem()
	return self._isPvp2Scene and (self._isPvp2FriendlyOwnedEntity or self._isPvp2EnemyTargetBase and self:isPvp2RevealActive())
end

function ClientTopLogoComponent:onTopLogoLodRangeChanged(is40MeterRange, isInRange)
	if is40MeterRange then
		self._inTopLogoLod40Range = isInRange == true
	else
		self._inTopLogoLod20Range = isInRange == true
	end

	self:reconcileTopLogoLodTimer()
end

function ClientTopLogoComponent:_requiresLongRangeTopLogoLod()
	if self._isPlayer then
		return true
	end

	if self._isPuppet and self.isInCombat and self:isInCombat() then
		return true
	end

	if self._isPvp2Scene then
		if self._isPvp2FriendlyOwnedEntity then
			return true
		end

		if self._isPvp2EnemyTargetBase and self:isPvp2RevealActive() then
			return true
		end
	end

	local item = self.topLogoItem

	if not item then
		local bootstrapDefinition = self:_getTopLogoBootstrapDefinition()

		if bootstrapDefinition.requiresLongRangeLod then
			return bootstrapDefinition.requiresLongRangeLod(self) == true
		end

		return (bootstrapDefinition.defaultMaxDistance or UIConst.TopLogoEnterRange) > UIConst.TopLogoLodNearRange
	end

	local components = item.components

	if not components or next(components) == nil then
		local enterDistance = self.topLogoEnterDistance or self:getTopLogoEnterDistance()

		return enterDistance ~= nil and enterDistance > UIConst.TopLogoLodNearRange
	end

	local activeComps = item.activeComps

	if not activeComps then
		return false
	end

	for _, comp in pairs(activeComps) do
		local distance = comp.getInitMaxDistance and comp:getInitMaxDistance()

		if distance and distance > UIConst.TopLogoLodNearRange then
			return true
		end
	end

	return false
end

function ClientTopLogoComponent:reconcileTopLogoLodTimer(forceRemove)
	local manager = pg and pg.game and pg.game.topLogo and pg.game.topLogo.lodManager

	if forceRemove then
		self._inTopLogoLod20Range = false
		self._inTopLogoLod40Range = false
		self._topLogoLodTimerRegistered = false

		if manager then
			manager:removeLODTimer(self)
		end

		self:removeTopLogoEx()

		return
	end

	if not manager then
		return
	end

	local shouldRegister = self._isMainPlayer or self._inTopLogoLod20Range or self._inTopLogoLod40Range and self:_requiresLongRangeTopLogoLod() or self._forceShowBubble or self.allowFarTopLogo == true

	shouldRegister = self.topLogoInit and shouldRegister or false

	if shouldRegister == self._topLogoLodTimerRegistered then
		return
	end

	self._topLogoLodTimerRegistered = shouldRegister

	if shouldRegister then
		manager:addLODRepeatTimer(self, ClientTopLogoComponent.tickTopLogo)
	else
		manager:removeLODTimer(self)
		self:removeTopLogoEx()
	end
end

function ClientTopLogoComponent:tickTopLogo(canHardWork)
	if not self.space then
		return
	end

	local distance = MaxDistance

	if not self._isVirPetNotNull and self.eModel and self.topLogoShell then
		local dist = self.topLogoShell:getDistance()

		distance = dist > 0 and dist or 0
	end

	return self:topLogoUpdate(distance, canHardWork)
end

function ClientTopLogoComponent:_getTopLogoBootstrapDefinition()
	return TopLogoItemTypeDefs.bootstrapByType[self.topLogoType] or TopLogoItemTypeDefs.defaultBootstrap
end

function ClientTopLogoComponent:_syncShellBootstrapMaxDistance()
	if not self.topLogoShell then
		return
	end

	local bootstrapDefinition = self:_getTopLogoBootstrapDefinition()
	local newDist = bootstrapDefinition.defaultMaxDistance or UIConst.TopLogoEnterRange

	if newDist ~= self._cachedShellMaxDist then
		self._cachedShellMaxDist = newDist

		self.topLogoShell:setMaxDistance(newDist)
	end
end

function ClientTopLogoComponent:ensureTopLogoShell()
	if self.forbiddenTopLogo or not self.topLogoInit then
		return
	end

	local topLogoCtrl = pg.global.ui and pg.global.ui.topLogo

	if not topLogoCtrl or not topLogoCtrl:checkUIOpen() then
		return
	end

	if self.topLogoShell then
		return self.topLogoShell
	end

	self.topLogoShell = TopLogoShell(self)
	self._cachedShellMaxDist = nil
	self._lastEnableRaycast = nil

	self:refreshTopLogoHeight()
	self:_syncShellBootstrapMaxDistance()

	return self.topLogoShell
end

function ClientTopLogoComponent:ensureTopLogoItem(reason)
	if self.forbiddenTopLogo or not self.topLogoInit then
		return
	end

	local topLogoCtrl = pg.global.ui and pg.global.ui.topLogo

	if not topLogoCtrl or not topLogoCtrl:checkUIOpen() then
		return
	end

	reason = reason or "ensure_component"

	if self.topLogoItem then
		return self.topLogoItem
	end

	local shell = self:ensureTopLogoShell()

	if not shell then
		return
	end

	local itemClass = TopLogoItemTypeDefs.byType[self.topLogoType] or TopLogoItemTypeDefs.defaultClass

	self.topLogoItem = itemClass(self)
	self.topLogoCreated = false

	self.topLogoItem:createLogicComponents()
	pg.game.topLogo:setTopLogoComponentGlobalVisible(self.topLogoItem)

	for visibleKey, componentNames in pairs(self._topLogoOtherCompVisiblePolicies or {}) do
		self.topLogoItem:setOtherCompsVisible(componentNames, visibleKey, false)
	end

	if topLogoCtrl and topLogoCtrl.onTopLogoItemCreated then
		topLogoCtrl:onTopLogoItemCreated(self.topLogoItem)
	end

	self:_notifyPvp2PlayerHubRevealChanged()
	self:refreshTopLogoVisibleGate()
	self:_syncShellMaxDistance()

	return self.topLogoItem
end

function ClientTopLogoComponent:initTopLogoShellMaxDist()
	local components = self.topLogoItem and self.topLogoItem.components

	if components then
		local maxDist = 0

		for _, comp in pairs(components) do
			local d = comp.getInitMaxDistance and comp:getInitMaxDistance()

			if d and maxDist < d then
				maxDist = d
			end
		end

		if maxDist > 0 then
			return maxDist
		end
	end

	return UIConst.TopLogoEnterRange
end

function ClientTopLogoComponent:destroyTopLogoItemOnly()
	self._cachedNameState = nil

	if self.topLogoItem then
		self.topLogoItem:destroy()

		self.topLogoItem = nil
	end

	self.topLogoCreated = false
	self._cachedShellMaxDist = nil

	self:_syncShellBootstrapMaxDistance()
	self:reconcileTopLogoLodTimer()
end

function ClientTopLogoComponent:destroyTopLogoItem()
	self:destroyTopLogoItemOnly()

	if self.topLogoShell then
		self.topLogoShell:destroy()

		self.topLogoShell = nil
	end

	self._cachedShellMaxDist = nil
	self._lastEnableRaycast = nil
end

function ClientTopLogoComponent:refreshTopLogoHeight(entry)
	self.topLogoData.strategy = self:getTopLogoFollowStrategy()
	self.topLogoData.height = self:getTopLogoHeight(self.topLogoData.strategy, entry)
	self.topLogoData.heightToRoot = self:getTopLogoHeightToRoot()

	if self.topLogoItem then
		self.topLogoItem:setTopLogoAttachTrans(self.topLogoItem.partId)
	end

	self:m_refreshMidExtraAnchor()

	if self.topLogoShell then
		self.topLogoShell:setFollowStrategy(self.topLogoData.strategy)
		self.topLogoShell:setWorldOffsetY(self.topLogoData.height or 0)
	end
end

function ClientTopLogoComponent:m_refreshMidExtraAnchor()
	local item = self.topLogoItem

	if not item or not item.topLogoScript or IsNil(item.topLogoScript) then
		return
	end

	local eModel = self.eModel

	if eModel == nil then
		item.topLogoScript:DisableMidExtra()

		return
	end

	item.topLogoScript:SetupMidExtraAnchor(eModel, LuaTopLogoUtils.getAgentToCapsuleCenterY(self))
end

function ClientTopLogoComponent:clearTopLogoState()
	self.topLogoData.showCatchLocked = false
end

function ClientTopLogoComponent:showTopLogo()
	if self.topLogoCreated then
		return
	end

	self:showTopLogoEx(nil, "explicit_show")
end

function ClientTopLogoComponent:removeTopLogoEx()
	self.topLogoCreated = false

	if self.topLogoItem then
		self.topLogoItem:destroyTopLogo()
	end
end

function ClientTopLogoComponent:showTopLogoEx(distance, reason)
	local createDistance = self:_resolveTopLogoCreateDistance(distance)
	local bypassDistance = self.allowFarTopLogo == true or self._forceShowBubble == true or self._isPvp2Scene and self._isPvp2EnemyTargetBase and self:isPvp2RevealActive()

	if not bypassDistance and not self:_isInTopLogoEnterRange() then
		return
	end

	local inEffectiveRange = bypassDistance or self:_isInTopLogoEffectiveCreateRange(createDistance)

	if not inEffectiveRange or not self:checkTopLogoAlive(createDistance) then
		return
	end

	reason = reason or "explicit_show"

	local item = self:ensureTopLogoItem(reason)

	if not item then
		return
	end

	inEffectiveRange = bypassDistance or self:_isInTopLogoEffectiveCreateRange(createDistance)

	if not inEffectiveRange then
		return
	end

	local isNeedCreate = next(item.components) == nil or next(item.activeComps) ~= nil

	if isNeedCreate then
		self.topLogoCreated = true

		item:createTopLogo(function()
			self:applyTopLogoVisible(false)
		end)
	end
end

function ClientTopLogoComponent:_resolveTopLogoEffectiveMaxDistance()
	local item = self.topLogoItem
	local maxDist = item and item.getEffectiveMaxDistance and item:getEffectiveMaxDistance() or 0

	if item and item.components then
		local combat = item.components[UIConst.TOPLOGO_COMPONENT.COMBAT]

		if combat and TopLogoPvp2Helper.isPvp2FriendlyTarget(self) and maxDist < SysConfigData.PUPPET_HEALTH_DISTANCE then
			maxDist = SysConfigData.PUPPET_HEALTH_DISTANCE
		end
	end

	if maxDist and maxDist > 0 then
		return maxDist
	end

	return self.topLogoEnterDistance or self:getTopLogoEnterDistance() or UIConst.TopLogoEnterRange
end

function ClientTopLogoComponent:_isInTopLogoEffectiveCreateRange(distance)
	if self._isMainPlayer then
		return true, self:_resolveTopLogoEffectiveMaxDistance()
	end

	if self._isPvp2Scene and self._isPvp2EnemyTargetBase and self:isPvp2RevealActive() then
		return true, self:_resolveTopLogoEffectiveMaxDistance()
	end

	local effectiveMaxDistance = self:_resolveTopLogoEffectiveMaxDistance()

	if not effectiveMaxDistance or effectiveMaxDistance <= 0 then
		return true, effectiveMaxDistance
	end

	return effectiveMaxDistance >= (distance or 0), effectiveMaxDistance
end

function ClientTopLogoComponent:_resolveTopLogoCreateDistance(distance)
	if distance ~= nil then
		return distance
	end

	if self.topLogoShell then
		local shellDistance = self.topLogoShell:getDistance()

		if shellDistance ~= nil then
			return shellDistance > 0 and shellDistance or 0
		end
	end

	if self.getPlayerDistance and self.eModel then
		local playerDistance = self:getPlayerDistance()

		if playerDistance ~= nil then
			return playerDistance > 0 and playerDistance or 0
		end
	end

	local myPos = pg.me and pg.me.getPosition and pg.me:getPosition()
	local ePos = self.getPosition and self:getPosition()

	if myPos and ePos then
		local dx = ePos[1] - myPos[1]
		local dz = ePos[3] - myPos[3]

		return math.sqrt(dx * dx + dz * dz)
	end

	return 0
end

function ClientTopLogoComponent:_isInTopLogoEnterRange()
	if not self.eModel or not pg.me then
		return false
	end

	local myPos = pg.me.getPosition and pg.me:getPosition()
	local ePos = self.getPosition and self:getPosition()

	if not myPos or not ePos then
		return true
	end

	local dx = ePos[1] - myPos[1]
	local dz = ePos[3] - myPos[3]
	local sqrDist = dx * dx + dz * dz
	local enterDist

	if self._isPvp2Scene then
		enterDist = SysConfigData.PUPPET_HEALTH_DISTANCE
	else
		enterDist = self.topLogoEnterDistance or self:getTopLogoEnterDistance() or 0
	end

	if enterDist <= 0 then
		return true
	end

	return sqrDist < enterDist * enterDist
end

function ClientTopLogoComponent:isCurrentPlayerHubTopLogo()
	local playerHub = self:getToplogoComponent(UIConst.TOPLOGO_COMPONENT.PLAYERHUB)

	if not playerHub or not playerHub.m_isCurrentPawn then
		return false
	end

	return playerHub:m_isCurrentPawn()
end

function ClientTopLogoComponent:applyTopLogoVisible(visible)
	if self.topLogoItem then
		self.topLogoItem:setTopLogoVisible(visible)
	end
end

function ClientTopLogoComponent:checkEnableTopLogoRaycast()
	if Utils.isNotEnableTopLogo(self) then
		return false
	end

	if self.space and self.space:isGrabEgg() and (self._isPlayer or self._isPet or self._isPvp2Scene and self._isPvp2EnemyTargetBase) then
		return true
	end

	local inCombat = self.isInCombat and self:isInCombat()

	if inCombat then
		return false
	end

	return true
end

function ClientTopLogoComponent:refreshTopLogoEnableRaycast()
	local enableRayCast = self:checkEnableTopLogoRaycast()

	if self.topLogoShell and self._lastEnableRaycast ~= enableRayCast then
		self._lastEnableRaycast = enableRayCast

		if enableRayCast then
			self.topLogoShell:enableRaycast()
		else
			self.topLogoShell:disableRaycast()
		end
	end
end

function ClientTopLogoComponent:closeTopLogo()
	self.hideTopLogo = true

	self:refreshTopLogoVisibleGate()
end

function ClientTopLogoComponent:openTopLogo()
	self.hideTopLogo = false

	self:refreshTopLogoVisibleGate()
end

function ClientTopLogoComponent:_calcPvp2EnemyTargetBase()
	if not pg.me then
		return false
	end

	local entityType = self._entityPvp2Type

	if entityType == "PLAYER" or entityType == "PUPPET" then
		return Utils.isEnemy(pg.me, self)
	end

	if entityType == "PET" or entityType == "ROB_EGG" then
		local ownerPlayer = self._pvp2OwnerPlayer

		return ownerPlayer ~= nil and Utils.isEnemy(pg.me, ownerPlayer)
	end

	return false
end

function ClientTopLogoComponent:_updatePvp2RevealState()
	if not self._isPvp2Scene then
		return
	end

	local expire = 0
	local map = pg.me and pg.me.pvp2RevealByTarget

	if map then
		expire = map[self.actorId] or 0
	end

	self._pvp2RevealExpireTime = expire
	self._pvp2RevealCacheReady = true

	self:_schedulePvp2RevealExpireCheck()

	self._cachedNameState = nil

	self:_notifyPvp2PlayerHubRevealChanged()
	self:reconcileTopLogoLodTimer()

	if self.topLogoInit and self:_shouldPrewarmPvp2TopLogoItem() then
		self:ensureTopLogoItem("pvp2")
	end
end

function ClientTopLogoComponent:_notifyPvp2PlayerHubRevealChanged()
	local playerHub = self:getToplogoComponent(UIConst.TOPLOGO_COMPONENT.PLAYERHUB)

	if playerHub and playerHub.notifyPvp2RevealChanged then
		playerHub:notifyPvp2RevealChanged()
	end
end

function ClientTopLogoComponent:_schedulePvp2RevealExpireCheck()
	self:_cancelPvp2RevealTimer()

	if self._pvp2RevealExpireTime > 0 then
		local now = Time.getMillisecond()
		local delay = (self._pvp2RevealExpireTime - now) / 1000

		if delay > 0 and delay < 60 then
			self._pvp2RevealTimer = TimerManager.addTimer(delay, function()
				self._pvp2RevealTimer = nil

				if self.topLogoItem then
					self:updateNameState(self:_resolveTopLogoCreateDistance())
				end

				self:_notifyPvp2PlayerHubRevealChanged()
				self:reconcileTopLogoLodTimer()
			end)
		end
	end
end

function ClientTopLogoComponent:_cancelPvp2RevealTimer()
	if self._pvp2RevealTimer then
		TimerManager.removeTimer(self._pvp2RevealTimer)

		self._pvp2RevealTimer = nil
	end
end

function ClientTopLogoComponent:_refreshPvp2RobEggTopLogoType()
	local controlled = self:isBeControlled() and self._pvp2OwnerPlayer ~= nil
	local targetType = controlled and ClientConst.TopLogoType.RobSpaceEgg or ClientConst.TopLogoType.EnvObj

	if self.topLogoType ~= targetType then
		local hadItem = self.topLogoItem ~= nil

		self.topLogoType = targetType

		if hadItem then
			self:destroyTopLogoItemOnly()
			self:ensureTopLogoItem("type_switch")
		else
			self._cachedShellMaxDist = nil

			self:_syncShellBootstrapMaxDistance()
			self:reconcileTopLogoLodTimer()
		end
	end
end

function ClientTopLogoComponent:checkTopLogoRobEggControlled()
	if not self.isRobSpaceEgg then
		return
	end

	if self._isPvp2Scene then
		self:refreshPvp2TeamCache()
	else
		self:_refreshPvp2OwnerCache(true)
	end

	self:_refreshPvp2RobEggTopLogoType()
	self:_updatePvp2RevealState()
end

function ClientTopLogoComponent:initTopLogoQuestInfo()
	self.questRefPosIds = {}

	if self._isPet then
		return
	end

	local sceneId = self.space and self.space.sceneId or GlobalData.Space.sceneId
	local targetPostionRevertData = SceneUtils.getSceneTargetPositionRevertData(sceneId)

	if targetPostionRevertData == nil then
		return
	end

	if self._isEnvObj then
		local templateId = self.templateId

		if templateId ~= nil and targetPostionRevertData.envObjTemplateIds then
			lume.append(self.questRefPosIds, targetPostionRevertData.envObjTemplateIds[templateId])
		end
	elseif self.getConfigData then
		local petPrototypeId = self:getConfigData().petPrototypeId

		if petPrototypeId ~= nil then
			lume.append(self.questRefPosIds, targetPostionRevertData.petProtoTypeIds[petPrototypeId])
		end
	end

	if self.staticId ~= nil then
		local targetPosIdsByEntId = targetPostionRevertData.entityIds[self.staticId]

		lume.append(self.questRefPosIds, targetPosIdsByEntId)
	end

	self:m_refreshTopLogoQuestComponent()
end

function ClientTopLogoComponent:m_getTopLogoChatInfos()
	if self._isPet or self.staticId == nil then
		return nil
	end

	return QuestUtils.getChatInteractInfosByToplogoStaticId(self.staticId)
end

function ClientTopLogoComponent:initTopLogoChatInfo()
	local chatInfos = self:m_getTopLogoChatInfos()

	if chatInfos == nil then
		return
	end

	self:m_refreshTopLogoQuestComponent()
end

function ClientTopLogoComponent:refreshTopLogoChatInfo()
	local chatInfos = self:m_getTopLogoChatInfos()

	if chatInfos == nil then
		return
	end

	self:m_refreshTopLogoQuestComponent()
end

function ClientTopLogoComponent:m_refreshTopLogoQuestComponent()
	self.topLogoQuestDirtyFlag = true

	local questComponent = self:peekToplogoComponent(UIConst.TOPLOGO_COMPONENT.QUEST)

	if self:hasTopLogoQuestData() then
		questComponent = self:ensureToplogoComponent(UIConst.TOPLOGO_COMPONENT.QUEST, "quest_data")
	end

	if questComponent then
		self.eventEmitter:emit(EventConst.TOPLOGO_QUEST)
	end
end

function ClientTopLogoComponent:hasTopLogoQuestData()
	if self.topLogoQuestDirtyFlag then
		self.topLogoQuestDirtyFlag = false

		self:updateTopLogoQuestInfoCache()
	end

	local cache = self.topLogoQuestInfoCache

	if not cache then
		return false
	end

	return cache.checkVisibleQuests and #cache.checkVisibleQuests > 0 or cache.checkDistanceQuests and #cache.checkDistanceQuests > 0
end

function ClientTopLogoComponent:m_buildTopLogoChatInfo(chatItem, isReturnSimpleInfo)
	local ret = {}

	ret[1] = true
	ret[2] = 0

	if not isReturnSimpleInfo then
		local questInfo = chatItem.questInfo

		ret[3] = questInfo[1]
		ret[4] = questInfo[2]
		ret[5] = questInfo[3]
		ret[6] = questInfo[4]
	end

	ret[TopLogoConst.QUEST_INFO_INTERACT_ID_INDEX] = chatItem.interactId

	return ret
end

function ClientTopLogoComponent:getTopLogoQuestInfo(distance, isReturnSimpleInfo)
	if self.topLogoQuestDirtyFlag then
		self.topLogoQuestDirtyFlag = false

		self:updateTopLogoQuestInfoCache()
	end

	if not self.topLogoQuestInfoCache then
		return {}
	end

	local questInfoCache = self.topLogoQuestInfoCache
	local curSelPage = QuestUtils.getCurSelPage()
	local chatItem

	for _, questItem in ipairs(questInfoCache.checkVisibleQuests) do
		if questItem.isChat then
			if chatItem == nil then
				chatItem = questItem
			end
		else
			local questId = questItem.questId
			local pageType = QuestUtils.getPageType(questId)

			if pageType == QuestConst.QUEST_HUD_PAGE_TYPE.EMPTY or pageType == curSelPage then
				if isReturnSimpleInfo then
					if QuestUtils.isQuestVisible(questId) then
						return {
							true,
							questId
						}
					end
				elseif QuestUtils.isQuestVisible(questId) then
					local questInfo = questItem.questInfo

					return {
						true,
						questId,
						questInfo[1],
						questInfo[2],
						questInfo[3],
						questInfo[4]
					}
				end
			end
		end
	end

	local bestItem, bestPriority = nil, 0

	for _, questItem in ipairs(questInfoCache.checkDistanceQuests) do
		local questId = questItem.questId
		local canShowDistance = questItem.canShowDistance

		if canShowDistance == nil or distance <= canShowDistance then
			local questData = QuestUtils.getQuestData(questId)
			local isBaseShow = QuestUtils.isQuestDataTracing(questData) or QuestUtils.isRootQuestTracing(questId) or QuestUtils.isQuestIconOtherStyleType(questId)

			if isBaseShow then
				local priority = 1
				local pageType = QuestUtils.getPageType(questId)
				local questState = questData and questData.state
				local isOngoing = questState == QuestConst.QUEST_STATE.RECEIVED or questState == QuestConst.QUEST_STATE.COMPLETED

				if pageType == curSelPage and isOngoing then
					priority = 4
				elseif pageType == QuestConst.QUEST_HUD_PAGE_TYPE.EMPTY and isOngoing and QuestUtils.isQuestOfClueQuestType(questId) then
					priority = 3
				elseif pageType == QuestConst.QUEST_HUD_PAGE_TYPE.EMPTY then
					priority = 2
				end

				if bestPriority < priority then
					bestPriority = priority
					bestItem = questItem

					if priority == 4 then
						break
					end
				end
			end
		end
	end

	if bestItem then
		local questInfo = bestItem.questInfo

		return {
			true,
			bestItem.questId,
			questInfo[1],
			questInfo[2],
			questInfo[3],
			questInfo[4]
		}
	end

	if chatItem then
		return self:m_buildTopLogoChatInfo(chatItem, isReturnSimpleInfo)
	end

	return {}
end

function ClientTopLogoComponent:m_isChatInteractActive(chatInfo)
	return SpecialInteract.checkInteractValid(chatInfo.staticId, chatInfo.interactId)
end

function ClientTopLogoComponent:m_appendTopLogoChatInfo(questInfoCache)
	local chatInfos = self:m_getTopLogoChatInfos()

	if chatInfos == nil then
		return
	end

	local chatShowType = QuestUtils.getChatShowType()

	for _, chatInfo in ipairs(chatInfos) do
		if self:m_isChatInteractActive(chatInfo) then
			table.insert(questInfoCache.checkVisibleQuests, {
				questId = 0,
				isChat = true,
				interactId = chatInfo.interactId,
				questInfo = {
					0,
					chatShowType,
					TopLogoConst.CHAT_TOPLOGO_SHOW_NUM_MAX,
					0
				}
			})
		end
	end
end

function ClientTopLogoComponent:updateTopLogoQuestInfoCache()
	self.topLogoQuestInfoCache = self.topLogoQuestInfoCache or {}

	local questInfoCache = self.topLogoQuestInfoCache

	questInfoCache.checkVisibleQuests = {}
	questInfoCache.checkDistanceQuests = {}

	if self.staticId ~= nil then
		local questData = EntityQuestData.staticIds[self.staticId]

		if questData then
			for _, info in pairs(questData) do
				local questId = info.questId

				if QuestUtils.isQuestManualClaimable(questId) or QuestUtils.isQuestManualCommit(questId) then
					local curQuestData = QuestUtils.getQuestData(questId)

					if info.state == nil or curQuestData and info.state == curQuestData.state then
						local taskType = QuestUtils.getCurSideQuestShowType(questId)

						table.insert(questInfoCache.checkVisibleQuests, {
							questId = questId,
							questInfo = {
								0,
								taskType,
								1,
								1
							}
						})
					end
				end
			end
		end
	end

	self:m_appendTopLogoChatInfo(questInfoCache)

	local sceneId = self.space and self.space.sceneId or GlobalData.Space.sceneId
	local targetPostionData = SceneUtils.getSceneTargetPositionData(sceneId)

	if targetPostionData == nil then
		return nil
	end

	local questsInfo
	local count = #self.questRefPosIds

	for i = 1, count do
		local pathfindingId = self.questRefPosIds[i]

		questsInfo = QuestPathfindingData[pathfindingId]

		if questsInfo then
			for k, v in pairs(questsInfo) do
				local questId = k
				local questInfoList = v
				local questData = QuestUtils.getQuestData(questId)
				local questConfig = QuestUtils.getQuestConfig(questId)
				local isShowQuestTracking = QuestUtils.canShowQuestTracking(questId)

				if questData ~= nil and questConfig ~= nil and isShowQuestTracking then
					for i = 1, #questInfoList do
						local info = questInfoList[i]
						local questState = info.state
						local objId = info.objId

						if questData.state == questState and not QuestUtils.isQuestObjFined(questId, objId) then
							local objData = QuestUtils.getQuestDataObjData(questData, objId)
							local targetPosInfo = targetPostionData[pathfindingId]
							local canShowDistance = targetPosInfo.showDistance
							local objectiveConfig = questConfig.objectives[objId]
							local taskType = QuestUtils.getCurSideQuestShowType(questId)

							table.insert(questInfoCache.checkDistanceQuests, {
								questId = questId,
								canShowDistance = canShowDistance,
								questInfo = {
									objData and objData.objId or 0,
									taskType,
									targetPosInfo.showNumMax,
									questState
								}
							})
						end
					end
				end
			end
		end
	end
end

function ClientTopLogoComponent:topLogoUpdate(distance, canHardWork)
	local alive = self:checkTopLogoAlive(distance)

	if not alive then
		if self.topLogoCreated then
			self:removeTopLogoEx()
		end

		return 0
	end

	local visible = self:checkTopLogoVisible(distance)
	local isCreate = 0

	if visible and canHardWork and not self.topLogoCreated then
		self:showTopLogoEx(distance, "lod_visible")

		isCreate = 1
	end

	self:m_executeTopLogoUpdate(alive, visible, distance)

	return isCreate
end

function ClientTopLogoComponent:m_executeTopLogoUpdate(alive, visible, distance)
	if alive then
		self:applyTopLogoVisible(visible)
		self:refreshTopLogoEnableRaycast()

		if visible then
			if self.topLogoItem then
				self:updateNameState(distance)
				self.topLogoItem:updateTopLogoItem(distance)
			end
		elseif self.topLogoItem and self._isPvp2Scene and (self._entityPvp2Type == "PLAYER" or self._entityPvp2Type == "PET" or self._entityPvp2Type == "PUPPET") then
			self:updateNameState(distance)
		end
	end
end

function ClientTopLogoComponent:updateNameState()
	if not self.topLogoItem.switchNameState then
		return
	end

	local newState = self:_calculateNameState()

	if self._cachedNameState == newState then
		return
	end

	self._cachedNameState = newState

	self.topLogoItem:switchNameState(newState)
	self:_syncShellMaxDistance()
end

function ClientTopLogoComponent:_calculateNameState()
	if self.overrideNameState then
		return self.overrideNameState
	end

	if self.forbidCombat then
		return UIConst.NAME_STATE.DIALOGUE
	elseif self._isPvp2Scene and self._isPvp2EnemyTargetBase and not self:isPvp2RevealActive() then
		return UIConst.NAME_STATE.DIALOGUE
	elseif self._isStaticNpcWithNpcTopLogo then
		return UIConst.NAME_STATE.DIALOGUE
	elseif self._isPvp2Scene and self._isPvp2FriendlyOwnedEntity and self._isPvp2PetEnt then
		return UIConst.NAME_STATE.COMBAT
	else
		local isInCombat = self._isPuppet and self.isInCombat and self:isInCombat() or false

		if self._isPuppet and (isInCombat or self.configMasterName) or self._isCombatType or Utils.isEnemy(self, pg.me) then
			return UIConst.NAME_STATE.COMBAT
		else
			return UIConst.NAME_STATE.DIALOGUE
		end
	end
end

function ClientTopLogoComponent:_syncShellMaxDistance()
	if not self.topLogoShell or not self.topLogoItem then
		return
	end

	local newDist = self:_resolveTopLogoEffectiveMaxDistance()

	if newDist ~= self._cachedShellMaxDist then
		self._cachedShellMaxDist = newDist

		self.topLogoShell:setMaxDistance(newDist)
	end

	self:reconcileTopLogoLodTimer()
end

function ClientTopLogoComponent:_onInCombatChanged(isInCombat)
	if self._topLogoPreCombat and isInCombat == self._topLogoPreCombat then
		return
	end

	self._topLogoPreCombat = isInCombat

	self:reconcileTopLogoLodTimer()

	if not self.topLogoItem then
		return
	end

	self._cachedNameState = nil

	if isInCombat then
		self.topLogoItem:onEnterCombat()
	else
		self.topLogoItem:onLeaveCombat()
	end
end

function ClientTopLogoComponent:refreshTopLogoDeadState()
	self._topLogoDeadState = self.isDead and self:isDead() and (not self.isFishingCaptureBoss or not self:isFishingCaptureBoss()) or false

	self:refreshTopLogoAliveGate()
end

function ClientTopLogoComponent:isTopLogoDeadState()
	return self._topLogoDeadState
end

function ClientTopLogoComponent:checkTopLogoAlive(distance)
	if not self._topLogoAliveGate then
		return false
	end

	if self._isMainPlayer then
		return true
	end

	if self._isPvp2Scene and (self._pvp2OwnerResolveRetries or 0) > 0 then
		self:_retryPvp2OwnerCache()
	end

	if self._isPvp2Scene and self._isPvp2EnemyTargetBase and self:isPvp2RevealActive() then
		return true
	end

	if self._isPvp2Scene and self._isPvp2FriendlyOwnedEntity and distance < SysConfigData.PUPPET_HEALTH_DISTANCE then
		return true
	end

	if self._forceShowBubble then
		return true
	end

	local topLogoEnterDistance = self:getTopLogoEnterDistance()
	local fogMaskRadius = pg.me.fogMaskRadius

	if fogMaskRadius and fogMaskRadius > 0 then
		topLogoEnterDistance = fogMaskRadius
	end

	self.topLogoEnterDistance = topLogoEnterDistance

	if self.allowFarTopLogo == true or self._forceShowBubble then
		return true
	end

	if self.topLogoShell then
		if not self.topLogoShell:isInRange() then
			return false
		end

		if distance > UIConst.TopLogoViewportCullMinDist and not self.topLogoShell:isInViewportStable() then
			return false
		end
	end

	if self.topLogoItem and self.topLogoItem:checkCreate() then
		return distance < topLogoEnterDistance + UIConst.TopLogoBorderRange
	else
		return distance < topLogoEnterDistance
	end
end

function ClientTopLogoComponent:checkTopLogoVisible(distance)
	local visibleGate = self._topLogoVisibleGate == nil and self:refreshTopLogoVisibleGate() or self._topLogoVisibleGate

	if not visibleGate then
		return false
	end

	if self.topLogoShell and self.topLogoShell:isBlocked() then
		return false
	end

	local isPvp2FriendlyPass = false
	local isPvp2RevealActive = false
	local isPvp2RevealPass = false
	local pvp2PassDistance = false

	if self._isPvp2Scene then
		isPvp2FriendlyPass = self._isPvp2FriendlyOwnedEntity and distance < SysConfigData.PUPPET_HEALTH_DISTANCE
		isPvp2RevealActive = self:isPvp2RevealActive()
		isPvp2RevealPass = self._isPvp2EnemyTargetBase and isPvp2RevealActive
		pvp2PassDistance = isPvp2FriendlyPass or isPvp2RevealPass
	end

	if self.allowFarTopLogo == true or self._forceShowBubble then
		return true
	end

	if not pvp2PassDistance and self.topLogoEnterDistance and distance > self.topLogoEnterDistance then
		return false
	end

	if self._isPvp2Scene and self._isPvp2EnemyTargetBase and not isPvp2RevealActive then
		return false
	end

	return true
end

function ClientTopLogoComponent:SetEcsWaterTopLogo(wetCount, totalWetCount, percent)
	self.topLogoData.ecsWaterTopLogo = {
		wetCount = wetCount,
		totalWetCount = totalWetCount,
		percent = percent
	}

	local callFriends = self.topLogoItem and self.topLogoItem.components and self.topLogoItem.components[UIConst.TOPLOGO_COMPONENT.CALL_FRIENDS]

	if callFriends then
		callFriends:refreshEcsTopLogoInfo(wetCount, totalWetCount, percent)
	end
end

function ClientTopLogoComponent:checkTopLogoRobEgg()
	if self.className == "MainPlayer" and Utils.isRobEggSceneId(self) then
		self.topLogoType = ClientConst.TopLogoType.Player

		self:ensureTopLogoItem("rob_egg")
	end
end

function ClientTopLogoComponent:peekToplogoComponent(componentName)
	return self.topLogoItem and self.topLogoItem:peekToplogoComponent(componentName)
end

ClientTopLogoComponent.getToplogoComponent = ClientTopLogoComponent.peekToplogoComponent

function ClientTopLogoComponent:peekTopLogoItem()
	return self.topLogoItem
end

function ClientTopLogoComponent:ensureToplogoComponent(componentName, reason)
	reason = reason or "ensure_component"

	local item = self:ensureTopLogoItem(reason)

	return item and item:ensureToplogoComponent(componentName, reason)
end

function ClientTopLogoComponent:executeTopLogoComponentMethod(componentName, methodName, ...)
	local comp = self:peekToplogoComponent(componentName)

	if comp and comp[methodName] then
		comp[methodName](comp, ...)
	end
end

function ClientTopLogoComponent:ensureAndExecuteTplComMethod(componentName, methodName, ...)
	local comp = self:ensureToplogoComponent(componentName)

	if comp and comp[methodName] then
		comp[methodName](comp, ...)
	end
end

function ClientTopLogoComponent:emitEventPreCheckComp(eventName, ...)
	if eventName == EventConst.TOPLOGO_BUBBLE then
		self.eventEmitter:emit(EventConst.TOPLOGO_BUBBLE, ...)
	end
end

function ClientTopLogoComponent:setOtherCompsVisible(componentNames, visibleKey, visible)
	visibleKey = visibleKey or UIConst.TOPLOGO_VISIBLE_KEY.DEFAULT
	self._topLogoOtherCompVisiblePolicies = self._topLogoOtherCompVisiblePolicies or {}

	if visible == true then
		self._topLogoOtherCompVisiblePolicies[visibleKey] = nil
	else
		local componentNamesSnapshot = componentNames

		if type(componentNames) == "table" then
			componentNamesSnapshot = {}

			for componentName, retained in pairs(componentNames) do
				componentNamesSnapshot[componentName] = retained
			end
		end

		self._topLogoOtherCompVisiblePolicies[visibleKey] = componentNamesSnapshot
	end

	if self.topLogoItem and self.topLogoItem.setOtherCompsVisible then
		self.topLogoItem:setOtherCompsVisible(componentNames, visibleKey, visible)
	end
end

return ClientTopLogoComponent
