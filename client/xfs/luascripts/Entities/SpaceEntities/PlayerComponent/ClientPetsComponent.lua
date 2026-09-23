-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientPetsComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local LoggerManager = require("Core.Log.LoggerManager")
local IDManager = require("Core.Common.IDManager")
local AttributeConst = require("Common.Const.AttributeConst")
local DialogueConst = require("Const.DialogueConst")
local MessageName = require("Const.MessageName")
local Const = require("Common.Const.Const")
local EventConst = require("Const.EventConst")
local PetSwitchAnim = require("GameApp.PetSwitch.PetSwitchAnim")
local PetData = require("Data.pet_data")
local PetEvolveData = require("Data.pet_evolve_data")
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local ClientConst = require("Const.ClientConst")
local PetFertilityConst = require("Const.PetFertilityConst")
local ClientUtils = require("Utils.ClientUtils")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local PetFriendTradeTextUtils = require("Utils.PetFriendTradeTextUtils")
local Utils = require("Common.Utils.Utils")
local EModelUtils = require("Entities.Utils.EModelUtils")
local AbilityConst = require("Common.Const.AbilityConst")
local AiConst = require("Common.Const.AiConst")
local NoticeDef = require("Common.NoticeDef")
local Time = require("Core.Common.Time")
local UIConst = require("Const.UIConst")
local ConflictTypes = require("Common.ConflictTypes")
local AIUtils = require("Common.Utils.AIUtils")
local ItemData = require("Data.item_data")
local SandboxConst = require("Common.Const.SandboxConst")
local Bitset = require("Common.Bitset")
local SysConfigData = require("Data.sys_config_data")
local ClientAbilityUtils = require("Utils.ClientAbilityUtils")
local PetBehaviorConfigData = require("Data.pet_behavior_config_data")
local PetBehaviorLevelData = require("Data.pet_behavior_level_data")
local CTRPool = require("Common.AICt.CTRPool")
local EffectConst = require("Const.EffectConst")
local Lume = require("Core.Common.lume")
local ClientPetsComponent = class.Component("ClientPetsComponent")

function ClientPetsComponent:applyPetSelectTransmogScheme(petId, scheme)
	local petEnt = pg.getEntity(petId)

	if petEnt and petEnt.applyTransmogScheme then
		petEnt:applyTransmogScheme(scheme)
	end
end

local PET_TAG_ANIM_RECORD_MASKS = {
	Const.PET_LABEL_MASK.SHINY,
	Const.PET_LABEL_MASK.BOSS,
	Const.PET_LABEL_MASK.ELITE,
	Const.PET_LABEL_MASK.MAGIC
}

local function getPetEvolveRecordKey(templateId, branchId)
	return "evo" .. templateId .. "_" .. branchId
end

local function getPetTagAnimRecordKey(petId, labelMask)
	return "pet_tag_anim_" .. petId .. "_" .. labelMask
end

function ClientPetsComponent:ctor()
	self.switchPetCD = 0
	self.switchPetEndCDs = {}

	for index = 1, Const.PET_PREPARE_NUM_LIMIT do
		self.switchPetEndCDs[index] = 0
	end

	self.petCommandMode = AiConst.PET_COMMAND_MODE.Normal
	self.clientExploreEntId = nil
	self.clientExploreCancelEntId = nil
	self.petHideKeys = {}
	self.commandPetAI = {}
	self.curExploreRequestId = nil
	self._innerExploreRequestId = 0
	self._petVariantFriendUidMap = {}
	self.clientSocialBossHatredMap = {}
end

function ClientPetsComponent:getPetActivityDispatching(petInfo)
	if not petInfo or not petInfo.id or not self.petActivityDispatchingMap then
		return 0
	end

	return self.petActivityDispatchingMap[petInfo.id] or 0
end

function ClientPetsComponent:isPetActivityDispatching(petInfo)
	return self:getPetActivityDispatching(petInfo) > 0
end

function ClientPetsComponent:hasPetGoldAdveRewarded(petId)
	if string.isNilOrEmpty(petId) or not self.petGoldAdveRewardedMap then
		return false
	end

	return self.petGoldAdveRewardedMap[petId] == true
end

function ClientPetsComponent:getPetExchangeTs(petInfo)
	if not petInfo or not petInfo.id or not self.petExchangeTsMap then
		return 0
	end

	return self.petExchangeTsMap[petInfo.id] or 0
end

function ClientPetsComponent:getPetExchangeFromUid(petInfo)
	if not petInfo or not petInfo.id or not self.petExchangeFromUidMap then
		return ""
	end

	return self.petExchangeFromUidMap[petInfo.id] or ""
end

function ClientPetsComponent:getPetGiveFromUid(petInfo)
	if not petInfo or not petInfo.id or not self.petGiveFromUidMap then
		return ""
	end

	return self.petGiveFromUidMap[petInfo.id] or ""
end

function ClientPetsComponent:getPetVariantIdsByFriendUid(friendUid)
	return self.petVariantFriendMap[tostring(friendUid)] or EMPTY_TABLE
end

function ClientPetsComponent:refreshPetVariantFriendUidMap(friendPetIdsMap)
	local petFriendUidMap = {}

	if friendPetIdsMap == nil then
		self._petVariantFriendUidMap = petFriendUidMap

		return
	end

	for friendUid, petIds in pairs(friendPetIdsMap) do
		for _, petId in ipairs(petIds) do
			assert(petFriendUidMap[petId] == nil, string.format("duplicate petVariantFriendMap petId=%s", petId))

			petFriendUidMap[petId] = friendUid
		end
	end

	self._petVariantFriendUidMap = petFriendUidMap
end

function ClientPetsComponent:on_petVariantFriendMap_changed(_, newValue)
	self:refreshPetVariantFriendUidMap(newValue)
end

local PET_VARIANT_TIPS_RECORD_KEY = "petVarianted"

function ClientPetsComponent:setPetVariantTipsShown(shown)
	self:setRedDotRecord(Const.CLIENT_KEY.FRIEND, PET_VARIANT_TIPS_RECORD_KEY, shown)
end

function ClientPetsComponent:getPetVariantTipsShown()
	return self:getRedDotRecord(Const.CLIENT_KEY.FRIEND, PET_VARIANT_TIPS_RECORD_KEY, false)
end

function ClientPetsComponent:getPetVariantFriendUid(petId)
	return self._petVariantFriendUidMap[tostring(petId)] or ""
end

function ClientPetsComponent:getPetVariantTime(petId)
	return self.petVariantTsMap[tostring(petId)] or 0
end

function ClientPetsComponent:getPetOriginFlag(petInfo)
	if not petInfo or not petInfo.id or not self.petOriginFlagMap then
		return 0
	end

	return self.petOriginFlagMap[petInfo.id] or 0
end

function ClientPetsComponent:start()
	if not self.petSwitchAnim then
		self.petSwitchAnim = PetSwitchAnim.new()
	end

	if self.isMainPlayer and self.inExploreState then
		self:cancelSwitchToExploreEnt()
	end

	if not self.isMainPlayer and self.exploreAbilityIndex and self.exploreAbilityIndex > 0 then
		self.clientExploreEntId = self.petExploreList[self.exploreAbilityIndex]
	end

	self:refreshEntityManagerCurPet()
	self:refreshHasUltimatePetInPrepareList()

	if self.isMainPlayer then
		if not self.checkExploreStateTimer then
			self.checkExploreStateTimer = self:addRepeatTimer(1, function()
				self:checkAndResendExploreRequest()
			end)
		end

		self:refreshPetVariantFriendUidMap(self.petVariantFriendMap)
	end
end

function ClientPetsComponent:refreshHasUltimatePetInPrepareList(prepareList)
	if not self.isMainPlayer then
		return
	end

	self.hasUltimatePetInPrepareList = false
	prepareList = prepareList or self.petPrepareList

	if prepareList then
		for _, petId in ipairs(prepareList) do
			local petInfo = self.pets and self.pets[petId]
			local abilityInfo = petInfo and petInfo.curAbilityMap and petInfo.curAbilityMap[AbilityConst.ULTIMATE_ABILITY]

			if abilityInfo then
				self.hasUltimatePetInPrepareList = true

				return
			end
		end
	end
end

function ClientPetsComponent:preDestroy()
	if self.petSwitchAnim then
		self.petSwitchAnim:destroy()

		self.petSwitchAnim = nil
	end

	self:stopPetExchangeEffects()
end

function ClientPetsComponent:destroy()
	self:clearPendingQuickEnter()

	if self.isMainPlayer then
		appFacade.entityManager:SetCurCombatPetId(nil)
	end

	if self.checkExploreStateTimer then
		self:removeTimer(self.checkExploreStateTimer)

		self.checkExploreStateTimer = nil
	end
end

function ClientPetsComponent:clearPendingQuickEnter()
	if self.pendingQuickEnterTimer then
		self:removeTimer(self.pendingQuickEnterTimer)

		self.pendingQuickEnterTimer = nil
	end

	self.pendingQuickEnterData = nil
end

function ClientPetsComponent:cachePendingQuickEnter(data, duration)
	self:clearPendingQuickEnter()

	self.pendingQuickEnterData = data
	self.pendingQuickEnterTimer = self:addTimer(duration or 15, function()
		self:clearPendingQuickEnter()
	end)
end

function ClientPetsComponent:consumePendingQuickEnter()
	local data = self.pendingQuickEnterData

	self:clearPendingQuickEnter()

	return data
end

function ClientPetsComponent:stopPetExchangeEffects()
	if self.petExchangeHandEffectId then
		self:stopEffectById(self.petExchangeHandEffectId)

		self.petExchangeHandEffectId = nil
	end

	if self.petExchangeLinkEffectId then
		self:stopEffectById(self.petExchangeLinkEffectId)

		self.petExchangeLinkEffectId = nil
	end
end

function ClientPetsComponent:getPets()
	if self.petTeamType ~= Const.PET_TEAM_TYPE_DEFAULT then
		return self.tempPets
	else
		return self.pets
	end
end

function ClientPetsComponent:getFirstOrDefaultPetId()
	if not string.isNilOrEmpty(self.curCombatPetId) then
		return self.curCombatPetId
	end

	local pets = self:getPets()
	local petId, _ = table.firstOrDefault(pets)

	return petId
end

function ClientPetsComponent:getAvatarFirstOrDefaultPetId()
	if not string.isNilOrEmpty(self.curCombatPetId) then
		return self.curCombatPetId
	end

	local petBoxMap = self.petBoxMap

	if not petBoxMap then
		return nil
	end

	for _, boxInfo in petBoxMap:items() do
		for _, petId in boxInfo:items() do
			if string.notNilOrEmpty(petId) then
				return petId
			end
		end
	end

	return nil
end

function ClientPetsComponent:getPetIdByAbilityIndex(abilityIndex)
	return self.petExploreList[abilityIndex]
end

function ClientPetsComponent:getPetInfo(id, forceDefault)
	local petInfo

	if Utils.isPlayerInSpaceCatchRogueDungeon(self) then
		if self.petTeamType ~= Const.PET_TEAM_TYPE_DEFAULT and self.tempPets and self.tempPets[id] then
			petInfo = self.tempPets[id]
		elseif self.pets and self.pets[id] then
			petInfo = self.pets[id]
		end
	elseif self.petTeamType ~= Const.PET_TEAM_TYPE_DEFAULT and not forceDefault then
		petInfo = self.tempPets and self.tempPets[id]
	else
		petInfo = self.pets and self.pets[id]
	end

	if petInfo == nil and self.previewPetInfoList then
		petInfo = self:getNpcDuelPreviewPetInfo(id)
	end

	return petInfo
end

function ClientPetsComponent:getSpecificAbilityPetId(abilityIndex)
	local petId

	if not string.isNilOrEmpty(self.petExploreList[abilityIndex]) then
		petId = self.petExploreList[abilityIndex]
	end

	return petId
end

function ClientPetsComponent:switchToPetByIndex(index, showMsg, appearAbilityId)
	if pg.me and pg.me.invasionInputDisabled then
		return
	end

	local inputEvent = Const.EVENT_PET_DEFAULT
	local curPetEntity = self:getCurPetEntity()

	if curPetEntity and curPetEntity.id == self.petPrepareList[index] and appearAbilityId == nil then
		return
	end

	local curPetState = curPetEntity and curPetEntity.characterState or CharacterStateConst.NONE
	local result = self:checkSwitchPet(index, showMsg, inputEvent)

	if result and self:checkCanSwitchPetWithEnoughSpace(index, curPetEntity) then
		self:serverMsg("RPC_CS_ShowPet", index, curPetState, appearAbilityId or 0)
		self:forbidUltimateForAWhile(0.2)
	elseif pg.me.inExploreState or CharacterStateConst.isExploreState(pg.pawn.characterState) or CharacterStateConst.isChildOfState(pg.pawn.characterState, CharacterStateConst.FLYING) then
		facade:SendMessageCommand(MessageName.SWITCH_PET_BLOCK_BY_EXPLORE_ST)
	end
end

function ClientPetsComponent:checkCanSwitchPetWithEnoughSpace(index, curPetEntity)
	if not self:isPrepareListEmpty() and curPetEntity then
		local id = self.petPrepareList[index]

		if self.curCombatPetId ~= id then
			local nextPetEntity = pg.getEntity(id)

			return self:checkCanSwitchToTargetWithEnoughSpace(nextPetEntity, curPetEntity, true)
		end
	end

	return true
end

function ClientPetsComponent:isInPreparesList(entity)
	if not entity then
		return false
	end

	for _, id in ipairs(self.petPrepareList) do
		if entity.id == id then
			return true
		end
	end

	return false
end

function ClientPetsComponent:checkCanSwitchToTargetWithEnoughSpace(targetEntity, curEntity, showMsg)
	local ret = false

	if targetEntity and curEntity then
		if curEntity:BURROW_ST() and targetEntity:getTemplateData().canBurrow then
			ret = curEntity.eModel:MoveOverlapWithIgnoreLayers(Const.COMPONENT_MOTION, curEntity:getPositionAgentPosition(), curEntity:getPositionAgentRotation())
		else
			ret = targetEntity.eModel:MoveOverlapWithIgnoreLayers(Const.COMPONENT_MOTION, curEntity:getPositionAgentPosition(), curEntity:getPositionAgentRotation())
		end
	end

	if ret and showMsg then
		pg.global.showBubbleMessageById(NoticeDef.CANNOT_SWITCH_BY_INSUFFICIENT_SPACE)
	end

	return not ret
end

function ClientPetsComponent:checkCanControlPetWithEnoughSpaceByTemplateId(targetTemplateId)
	local ret = false
	local targetTemplateData = targetTemplateId and PetData[targetTemplateId]

	if self:isControllingPet() and targetTemplateData then
		local radius, height, centerOffset = Utils.getPetCapsuleDataByTemplateId(targetTemplateId)

		if radius and height and centerOffset then
			local targetPetScale = Utils.getPetInControlConfigScaleByTemplateId(targetTemplateId)
			local curEntity = pg.pawn

			if curEntity:BURROW_ST() and targetTemplateData.canBurrow then
				ret = curEntity.eModel:MoveOverlapWithIgnoreLayers(Const.COMPONENT_MOTION, curEntity:getPositionAgentPosition(), curEntity:getPositionAgentRotation())
			else
				ret = curEntity.eModel:MoveOverlapByCapsuleParam(Const.COMPONENT_MOTION, radius, height, centerOffset, targetPetScale, true)
			end

			if ret then
				pg.global.showBubbleMessageById(NoticeDef.CANNOT_SWITCH_BY_INSUFFICIENT_SPACE)
			end
		end
	end

	return not ret
end

function ClientPetsComponent:checkCanExploreSwitch()
	return
end

function ClientPetsComponent:requestSwitchToPlayer(clientSwitchReason, excludeStates, callback)
	if not self.isMainPlayer then
		return false
	end

	if not self:isControllingPet() then
		return false
	end

	if self.isInSwitchFlying then
		return false
	end

	local curPetEnt = self:getCurPetEntity()

	if curPetEnt and curPetEnt.onVehicleActorId and curPetEnt.onVehicleActorId ~= 0 and clientSwitchReason ~= Const.CLIENT_SWITCH_REASON.Vehicle then
		pg.global.showBubbleMessage(NoticeDef.VEHICLE_EXIT_LINK_FORBID)

		return false
	end

	self.switchPlayerCallback = nil

	if curPetEnt:checkBeStopControlPet(excludeStates) and self:checkStopControlPet(excludeStates) and self:checkCanSwitchToTargetWithEnoughSpace(self, curPetEnt, true) then
		self.switchPlayerCallback = callback
		self.switchPlayerCallbackTime = Time.realSecondCache

		self:serverMsg("RPC_CS_StopControll", clientSwitchReason)

		return true
	end

	return false
end

function ClientPetsComponent:requestSwitchToPet(clientSwitchReason, excludeStates)
	if not self.isMainPlayer then
		return false
	end

	pg.game.social:checkAndStopHornAnimation()

	local isInCarryEgg = self:CARRY_EGG_ST()

	if self:checkControlPet(excludeStates) then
		local petEntity = self:getCurPetEntity()
		local canControlPet = false

		if petEntity then
			canControlPet = petEntity:checkBeControlPet() and (self:isInCombat() or self:checkCanSwitchToTargetWithEnoughSpace(petEntity, self, true))
		elseif isInCarryEgg then
			canControlPet = true
		end

		if canControlPet then
			pg.game.controller.nextSkillAction:clearNextSkillCache()
			self:serverMsg("RPC_CS_StartControll", clientSwitchReason)

			return true
		end
	end

	return false
end

function ClientPetsComponent:requestQuickLinkPet(petId, callback)
	local function done(ok)
		if callback then
			callback(ok)
		end

		return ok
	end

	if not self.isMainPlayer then
		return done(false)
	end

	if not self.pets or not self.pets[petId] then
		return done(false)
	end

	if self.actorBuff:hasTag(AbilityConst.BUFF_TAG_FORBIDDEN_SWITCH_PET) then
		return done(false)
	end

	local excludeStates = {
		CONTROLLING_PET_ST = true
	}

	if not self:checkControlPet(excludeStates) then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			self.logger:error("[快速联结] : 状态冲突表检测不通过，禁止快速联结！！")
		end

		return done(false)
	end

	pg.game.social:checkAndStopHornAnimation()
	pg.game.controller.nextSkillAction:clearNextSkillCache()

	local petPrepareList = pg.me.petPrepareList
	local index = Lume.find(petPrepareList, petId)

	if not index then
		index = #petPrepareList + 1
		index = math.clamp(index, 1, 4)
	end

	local inputEvent = Const.EVENT_PET_DEFAULT
	local curPetEntity = self:getCurPetEntity()
	local result = self:checkSwitchPet(index, true, inputEvent)

	if result and self:checkCanSwitchPetWithEnoughSpace(index, curPetEntity) then
		pg.me:serverMsg("RPC_CS_QuickBattlePet", petId, index, function(v)
			done(v)
		end)
		self:forbidUltimateForAWhile(0.2)
	elseif pg.me.inExploreState or CharacterStateConst.isExploreState(pg.pawn.characterState) or CharacterStateConst.isChildOfState(pg.pawn.characterState, CharacterStateConst.FLYING) then
		facade:SendMessageCommand(MessageName.SWITCH_PET_BLOCK_BY_EXPLORE_ST)
		done(false)
	end
end

function ClientPetsComponent:checkAndResendExploreRequest()
	if self.curExploreRequestId ~= nil and Time.realSecondCache - self.sendExploreRequestTime > 2 then
		self.sendExploreRequestTime = Time.realSecondCache

		if LoggerManager.checkLogger(LoggerConst.INFO) then
			self.logger:info("resendExploreRequest")
		end

		self.exploreReqeustCallback()
	end
end

function ClientPetsComponent:genExploreRequestId()
	self._innerExploreRequestId = self._innerExploreRequestId + 1

	return self._innerExploreRequestId
end

function ClientPetsComponent:switchToExplorePet(abilityIndex, explorePetId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("switchToExplorePet")
	end

	if self.forceControl then
		return false
	end

	local petEntity = pg.getEntity(explorePetId)

	if not petEntity or petEntity:isDead() then
		return false
	end

	if not self:checkExploreControlPet(false, true) then
		return false
	end

	local oldPetId

	if self:isControllingPet() then
		local curPetEnt = self:getCurPetEntity()

		if curPetEnt and not curPetEnt:checkExploreBeControlPet(false, true) then
			return false
		end

		oldPetId = curPetEnt and curPetEnt.id
	end

	self.exploreSwitchFlag = true
	self.clientExploreEntId = explorePetId
	self.clientExploreCancelEntId = nil

	self:cancelAbility()
	self:refreshVisible()
	self:refreshCombatPetsVisible()
	self:refreshExplorePetsVisible()
	petEntity:calcAndRefreshModelScale()

	if pg.pawn ~= petEntity then
		self:playSwitchToExplorePetAnim(Const.EVENT_CLIENT_PRE_EXPLORE, petEntity, pg.pawn == pg.me)
	end

	self:dispatchControlStateChange(oldPetId, petEntity.id)
	self:sendSwitchControlRequest(abilityIndex)
	self:switchToPet(Const.EVENT_CLIENT_PRE_EXPLORE, petEntity)

	self.exploreSwitchFlag = nil

	return true
end

function ClientPetsComponent:switchToExplorePlayer()
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("switchToExplorePlayer")
	end

	local curPetEnt = self:getCurPetEntity()

	if not self:checkExploreStopControlPet(false, true) or curPetEnt and not curPetEnt:checkExploreBeStopControlPet(false, true) then
		return false
	end

	self.exploreSwitchFlag = true
	self.clientExploreEntId = self.id
	self.clientExploreCancelEntId = nil

	self:cancelAbility()
	self:refreshVisible()
	self:refreshCombatPetsVisible()
	self:refreshExplorePetsVisible()

	if pg.pawn ~= pg.me then
		self:playSwitchToExplorePlayerAnim(Const.EVENT_CLIENT_PRE_EXPLORE)
	end

	self:sendSwitchControlRequest(0)
	self:switchToPlayer(Const.EVENT_CLIENT_PRE_EXPLORE)

	self.exploreSwitchFlag = nil

	self:refreshCurPetsAi()

	return true
end

function ClientPetsComponent:sendSwitchControlRequest(index)
	self.curExploreRequestId = self:genExploreRequestId()
	self.sendExploreRequestTime = Time.realSecondCache

	function self.exploreReqeustCallback()
		self:serverMsg("RPC_CS_StartExploreControll", index, self.curExploreRequestId)
	end

	self:serverMsg("RPC_CS_StartExploreControll", index, self.curExploreRequestId)
end

function ClientPetsComponent:sendStopExploreControlRequest()
	self.curExploreRequestId = self:genExploreRequestId()
	self.sendExploreRequestTime = Time.realSecondCache

	function self.exploreReqeustCallback()
		self:serverMsg("RPC_CS_StopExploreControll", self.curExploreRequestId)
	end

	self:serverMsg("RPC_CS_StopExploreControll", self.curExploreRequestId)
end

function ClientPetsComponent:getExploreCancelBackEnt()
	if not self:isControllingExploreEnt() then
		return nil
	end

	if pg.pawn ~= pg.me then
		if self.lastControlState == Const.CONTROL_STATE_CONTROL then
			local lastPetEnt = pg.getEntity(self.lastCombatPetId)

			if lastPetEnt then
				return lastPetEnt
			else
				return pg.me
			end
		else
			return pg.me
		end
	end

	return nil
end

function ClientPetsComponent:checkCanCancelSwitchToExploreEnt(showMsg)
	if not self:isControllingExploreEnt() then
		return true
	end

	local backToEnt = self:getExploreCancelBackEnt()

	if not pg.pawn:checkExploreDelayExit() then
		return false
	end

	if pg.pawn ~= pg.me and not pg.me:checkExploreDelayExit() then
		return false
	end

	if backToEnt and backToEnt ~= pg.pawn and not self:checkCanSwitchToTargetWithEnoughSpace(backToEnt, pg.pawn, showMsg) then
		return false
	end

	return true
end

function ClientPetsComponent:cancelSwitchToExploreEnt()
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("cancelSwitchToExploreEnt")
	end

	if not self:isControllingExploreEnt() then
		self:sendStopExploreControlRequest()

		return false
	end

	local backToEnt = self:getExploreCancelBackEnt()

	self.clientExploreEntId = nil

	if pg.pawn ~= pg.me then
		if self.lastControlState == Const.CONTROL_STATE_CONTROL then
			self.clientExploreCancelEntId = self.lastCombatPetId
		else
			self.clientExploreCancelEntId = pg.me.id
		end
	else
		self.clientExploreCancelEntId = nil
	end

	self:refreshVisible()
	self:refreshCombatPetsVisible()
	self:refreshExplorePetsVisible()

	if backToEnt then
		if backToEnt == pg.me then
			self:playSwitchToExplorePlayerAnim(Const.EVENT_CLIENT_PRE_EXPLORE)
			self:switchToPlayer(Const.EVENT_CLIENT_PRE_EXPLORE)
		elseif pg.pawn ~= backToEnt then
			if pg.pawn and pg.pawn.eModel then
				backToEnt:forceSetPosRot(pg.pawn:getPositionAgentPosition(), pg.pawn:getPositionAgentRotation(), true, true)
			end

			self:playSwitchToExplorePetAnim(Const.EVENT_CLIENT_PRE_EXPLORE, backToEnt)
			self:dispatchControlStateChange(pg.pawn.id, backToEnt.id)
			self:switchToPet(Const.EVENT_CLIENT_PRE_EXPLORE, backToEnt)
		end
	end

	self:sendStopExploreControlRequest()
	self:refreshCurPetsAi()

	return true
end

function ClientPetsComponent:onSwitchExploreEntFailed(inExploreState, controlState, curCombatPetId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("onSwitchToExploreEntFailed", inExploreState, controlState, curCombatPetId, self.curCombatPetId)
	end

	self:breakSwitchToExploreEnt()

	if controlState == Const.CONTROL_STATE_CONTROL then
		local lastPetEnt = curCombatPetId and pg.getEntity(curCombatPetId)

		if lastPetEnt then
			self:switchToPet(Const.EVENT_CLIENT_PRE_EXPLORE, lastPetEnt)
		else
			self:switchToPlayer(Const.EVENT_CLIENT_PRE_EXPLORE)
		end
	else
		self:switchToPlayer(Const.EVENT_CLIENT_PRE_EXPLORE)
	end

	if inExploreState then
		self:sendStopExploreControlRequest()
	end
end

function ClientPetsComponent:onExitSwitchExploreEntFailed(inExploreState, controlState, curCombatPetId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("onExitSwitchExploreEntFailed", inExploreState, controlState, curCombatPetId, self.curCombatPetId)
	end

	self:breakSwitchToExploreEnt()

	if controlState == Const.CONTROL_STATE_CONTROL then
		local lastPetEnt = curCombatPetId and pg.getEntity(curCombatPetId)

		if lastPetEnt then
			self:switchToPet(Const.EVENT_CLIENT_PRE_EXPLORE, lastPetEnt)
		else
			self:switchToPlayer(Const.EVENT_CLIENT_PRE_EXPLORE)
		end
	else
		self:switchToPlayer(Const.EVENT_CLIENT_PRE_EXPLORE)
	end
end

function ClientPetsComponent:onExitSwitchExploreEntSuccess(inExploreState, controlState, curCombatPetId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("onExitSwitchExploreEntSuccess", inExploreState, controlState, curCombatPetId, self.curCombatPetId, self:isControllingExploreEnt())
	end

	if self:isControllingExploreEnt() then
		self.clientExploreCancelEntId = nil

		return
	end

	self:breakSwitchToExploreEnt()

	if self.controlState == Const.CONTROL_STATE_CONTROL then
		local curPetEnt = self:getCurPetEntity()

		if pg.pawn ~= curPetEnt then
			self:switchToPet(Const.EVENT_CLIENT_PRE_EXPLORE, curPetEnt)
		end
	elseif pg.pawn ~= pg.me then
		self:switchToPlayer(Const.EVENT_CLIENT_PRE_EXPLORE)
	end
end

function ClientPetsComponent:onSkipAutoSwitch()
	self:refreshCurPetsAi()
	self:refreshCurPetVisible()
end

function ClientPetsComponent:onSkipRestoreAutoSwitch()
	self:refreshCurPetsAi()
	self:refreshCurPetVisible()
end

function ClientPetsComponent:breakSwitchToExploreEnt()
	self.clientExploreEntId = nil
	self.clientExploreCancelEntId = nil

	self:refreshVisible()
	self:refreshCombatPetsVisible()
	self:refreshExplorePetsVisible()
	self:refreshCurPetsAi()
end

function ClientPetsComponent:refreshCurPetsAi()
	local petEnt = self:getCurPetEntity()

	if petEnt then
		petEnt:refreshBtState()
	end
end

function ClientPetsComponent:dispatchControlStateChange(oldPetId, newPetId)
	if oldPetId then
		local oldPet = pg.getEntity(oldPetId)

		if oldPet then
			oldPet:postComponentMethod("onPetUnSummon")
		end
	end

	if newPetId then
		local newPet = pg.getEntity(newPetId)

		if newPet then
			newPet:postComponentMethod("onPetSummon")
		end
	end

	facade:SendMessageCommand(MessageName.PET_CHANGE_REFRESH, {
		ent = self,
		newPetId = newPetId
	})
end

function ClientPetsComponent:RPC_SC_OnControlExplorePet(success, requestId, inExploreState, controlState, curCombatPetId)
	if requestId == self.curExploreRequestId then
		self.curExploreRequestId = nil
		self.sendExploreRequestTime = nil
		self.exploreReqeustCallback = nil
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_OnControlExplorePet", success)
	end

	if not success then
		self:onSwitchExploreEntFailed(inExploreState, controlState, curCombatPetId)
	else
		if controlState == Const.CONTROL_STATE_CONTROL then
			local curPetEnt = pg.getEntity(curCombatPetId)

			if pg.pawn ~= curPetEnt then
				self:switchToPet(Const.EVENT_CLIENT_PRE_EXPLORE, curPetEnt)
			end
		elseif pg.pawn ~= pg.me then
			self:switchToPlayer(Const.EVENT_CLIENT_PRE_EXPLORE)
		end

		facade:SendMessageCommand(MessageName.ON_CONTROL_EXPLORE_PET)
	end
end

function ClientPetsComponent:RPC_SC_OnLeaveExplorePet(success, requestId, inExploreState, controlState, curCombatPetId)
	if requestId == self.curExploreRequestId then
		self.curExploreRequestId = nil
		self.sendExploreRequestTime = nil
		self.exploreReqeustCallback = nil
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_OnLeaveExplorePet", success)
	end

	if not success then
		self:onExitSwitchExploreEntFailed(inExploreState, controlState, curCombatPetId)
	else
		self:onExitSwitchExploreEntSuccess(inExploreState, controlState, curCombatPetId)
	end
end

function ClientPetsComponent:recordLastPetInfo(petEntId)
	local petEnt = pg.getEntity(petEntId)
	local playableState = petEnt:getCurrentPlayableState(0)
	local animation = playableState and playableState.Key or nil
	local time = playableState and playableState.Time or 0

	self.lastPetInfo = {
		templateId = petEnt.templateId,
		modelScale = petEnt.curModelScale,
		animation = animation,
		time = time,
		label = petEnt.label,
		gender = petEnt.gender
	}
end

function ClientPetsComponent:EVENT_AddEComponent()
	self:addEModelComponent(Const.COMPONENT_INDEX_FOLLOW)
end

function ClientPetsComponent:EVENT_OnTeleport(pos)
	if self.petSwitchAnim then
		self.petSwitchAnim:stop()
	end
end

function ClientPetsComponent:RPC_SC_SyncPreparePets()
	ClientUtils.updateMaxPreparedPetLevel(self)
	facade:SendMessageCommand(MessageName.PREPARE_PETS_UPDATE)
	self.subject:notify(AbilityConst.COMBAT_EVENT_ON_PET_LIST_CHANGE)
end

function ClientPetsComponent:RPC_SC_SetCombatPetIdAndIndex(curCombatPetId, curIndex)
	self:refreshSuitPowerFunction(curCombatPetId)

	if self.isMainPlayer then
		facade:SendMessageCommand(MessageName.COMBAT_PET_CHANGED, curIndex)
	end
end

function ClientPetsComponent:RPC_SC_OnRefreshCanEvolveStatus(petId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_OnRefreshCanEvolveStatus petId:%s", petId)
	end

	local petInfo = self:getPetInfo(petId, true)

	if petInfo == nil then
		self.logger:error("RPC_SC_OnRefreshCanEvolveStatus petInfo is nil, petId=%s", tostring(petId))

		return
	end

	local templateId = petInfo.templateId

	facade:SendMessageCommand(MessageName.PET_STAGE_UPDATE, {
		canStageUp = petInfo:canEvolveAny(),
		petId = petId,
		templateId = templateId
	})
end

function ClientPetsComponent:RPC_SC_refreshBasePropertyList(petId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_refreshBasePropertyList petId:%s", petId)
	end

	facade:sendMsgToUI(MessageName.PLAYER_PET_CUR_PROPERTY_CHANGED, {
		petId = petId
	})
end

function ClientPetsComponent:RPC_SC_OnPetChangeTemplate(petId, petInfoOld, needAnimation, reason)
	local petInfoNew = self:getPetInfo(petId)

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_OnPetChangeTemplate petId:%s, oldTmpId:%s, newTmplId:%s, reason:%s", petId, petInfoOld.templateId, petInfoNew.templateId, reason)
	end

	if needAnimation then
		local curPet = self:getCurPetEntity()

		if curPet then
			pg.game.evolution:startEvolution(petInfoOld, petInfoNew, curPet:getPosition(), curPet:getRotation())
		else
			pg.game.evolution:startEvolution(petInfoOld, petInfoNew, pg.me:getPosition(), pg.me:getRotation())
		end
	end

	self:refreshHasUltimatePetInPrepareList()
	facade:SendMessageCommand(MessageName.PREPARE_PETS_UPDATE)

	if self.curCombatPetId == petId then
		facade:SendMessageCommand(MessageName.COMBAT_PET_TEMPLATE_CHANGE)
	end

	if reason ~= Const.PCTR_SHAPE_SHIFT then
		local templateId = petInfoNew.templateId
		local petPrototypeId = petInfoNew.petPrototypeId
		local petData = PetData[templateId]
		local petHandbookMap = pg.me.petHandbookMap or {}
		local petHandbookInfo = petHandbookMap[petPrototypeId] or {}
		local isRare = Utils.isLabelShiny(petInfoNew.label)
		local petInfoList = {}
		local petInfo = {
			elementTypes = petData.elementType,
			gender = petInfoNew.gender,
			headIconName = petData.iconName,
			iconName = petData.iconName,
			id = petInfoNew.id,
			isBoss = Utils.isLabelElite(petInfoNew.label),
			isVariant = Utils.isLabelVariant(petInfoNew.label),
			isNew = not petHandbookInfo:isCatched(),
			isRare = isRare,
			isRareNew = isRare and not petHandbookInfo:isShinyCatched(),
			label = petInfoNew.label,
			lv = petInfoNew.level,
			name = petData.name,
			templateId = templateId
		}

		table.insert(petInfoList, petInfo)
		pg.global.ui.tips:pushPetGot(petInfoList)
		facade:SendMessageCommand(MessageName.MAIN_PLAYER_PET_EVOLVE, {
			petInfo = petInfo
		})
	end

	local petEnt = pg.getEntity(petId)

	if petEnt then
		petEnt:initNorAtkAbilityList(CharacterStateConst.isChildOfState(petEnt.characterState, CharacterStateConst.FLYING))
	end

	pg.global.ui.tips:recycleEvolveItem(petId)
end

function ClientPetsComponent:RPC_SC_OnChangeControlEndCD(controlEndCD)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_OnChangeControlEndCD %s", controlEndCD)
	end

	self.controlEndCD = controlEndCD
end

function ClientPetsComponent:RPC_SC_OnChangeSwitchEndCD(index, switchPetEndCD, switchPetCD)
	self.switchPetEndCDs[index] = switchPetEndCD
	self.switchPetCD = switchPetCD

	facade:sendMsgToUI(MessageName.SWITCH_PET_CD_UPDATE, {
		petIdx = index
	})
end

function ClientPetsComponent:RPC_SC_OnControlToFollow(inputEvent, params, oldPetTemplateId, oldPetId, newPetId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_OnSwitchToFollow", inputEvent)
	end

	self:playSwitchToPlayerAnim(inputEvent, params)
	self:switchToPlayer(inputEvent, params)
	self:postComponentMethod("EVENT_onControlPetSwitchToPlayer", oldPetTemplateId)
	self:cancelSneakCamera(nil)

	if self.isMainPlayer and self.eModel then
		local modelView = self.eModel.modelModelView

		if NotNil(modelView) then
			modelView:RefreshFaceSkeletonOnly()
		end
	end

	if newPetId == oldPetId then
		self:dispatchControlStateChange(nil, newPetId)
	else
		self:dispatchControlStateChange(oldPetId, newPetId)
	end

	self.eventEmitter:emit(EventConst.ON_PLAYER_SWITCH_CONTROL_ALL_CLIENT, self.actorId)
	pg.game.effect:getTeamLinkController():onControlStateChange(self, self.controlState, oldPetId)
end

function ClientPetsComponent:RPC_SC_OnSwithToSingle(inputEvent, params, oldPetId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_OnSwithToSingle", inputEvent)
	end

	if self.petSwitchAnim then
		self.petSwitchAnim:stop()
	end

	self.switchEndTime = nil

	self:switchToPlayer(inputEvent, params)
	self:setActive(ClientConst.MODEL_VISIBLE_KEY.SWITCHING, true)
	self:cancelSneakCamera(nil)

	if self.isMainPlayer and self.eModel then
		local modelView = self.eModel.modelModelView

		if NotNil(modelView) then
			modelView:RefreshFaceSkeletonOnly()
		end
	end

	self:dispatchControlStateChange(oldPetId)
	self.eventEmitter:emit(EventConst.ON_PLAYER_SWITCH_CONTROL_ALL_CLIENT, self.actorId)
	pg.game.effect:getTeamLinkController():onControlStateChange(self, self.controlState, oldPetId)
end

function ClientPetsComponent:RPC_SC_OnSwitchToControll(inputEvent, params, oldPetId, newPetId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_OnSwitchToControll", inputEvent)
	end

	self:playPlayerToPetAnim(inputEvent, params)

	local petEnt = pg.getEntity(newPetId)

	if petEnt then
		petEnt.inSwitchToControlMark = true
	end

	self:switchToPet(inputEvent, nil, params)

	if petEnt then
		petEnt.inSwitchToControlMark = nil
	end

	self:postComponentMethod("EVENT_onControlPlayerSwitchToPet")

	if newPetId == oldPetId then
		self:dispatchControlStateChange(nil, newPetId)
	else
		self:dispatchControlStateChange(oldPetId, newPetId)
	end

	self.eventEmitter:emit(EventConst.ON_PLAYER_SWITCH_CONTROL_ALL_CLIENT, self.actorId)
	pg.game.effect:getTeamLinkController():onControlStateChange(self, self.controlState)
end

function ClientPetsComponent:isExploreEvent(inputEvent)
	return inputEvent == Const.EVENT_EXPLORE_PET or inputEvent == Const.EVENT_LEAVE_EXPLORE_PET or inputEvent == Const.EVENT_EXPLORE_PLAYER or inputEvent == Const.EVENT_EXPLORE_LEAVE_PLAYER
end

function ClientPetsComponent:isPreExploreEvent(inputEvent)
	return inputEvent == Const.EVENT_CLIENT_PRE_EXPLORE
end

function ClientPetsComponent:cancelSneakCamera(newEnt)
	if not newEnt or not newEnt:getTemplateData().canBurrow then
		pg.game.camera.playerCameraMode:enableSneakCameraMode(false)
	end
end

function ClientPetsComponent:RPC_SC_OnControlToControl(inputEvent, params, oldPetTemplateId, newPetTemplateId, oldPetId, newPetId)
	local oldPetEnt = pg.getEntity(oldPetId)

	if self.authority == Const.AUTHORITY_MASTER and not self:isExploreEvent(inputEvent) and inputEvent ~= Const.EVENT_SHOW_PET_QTE then
		local newPetEnt = pg.getEntity(newPetId)

		if oldPetEnt and newPetEnt then
			newPetEnt:forceSetPosRot(oldPetEnt:getPosition(), oldPetEnt:getRotation(), true, true)

			local oldControllerComponent = oldPetEnt:getEModelComponent(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER)

			if params.oldPetState and CharacterStateConst.isChildOfState(params.oldPetState, CharacterStateConst.SNEAK) and newPetEnt:getTemplateData().canBurrow and NotNil(oldControllerComponent) then
				params.abilityStateDuration = oldControllerComponent.abilityCharacterStateInfo.abilityStateDuration
				params.abilityVelocity = oldControllerComponent.abilityCharacterStateInfo.abilityVelocity
			end
		end

		self:cancelSneakCamera(newPetEnt)
	end

	self:playPetToPetAnim(inputEvent, params)
	self:switchToPet(inputEvent, nil, params)
	self:postComponentMethod("EVENT_onControlPetSwitchToAnotherPet", oldPetTemplateId, newPetTemplateId)

	if self.isMainPlayer then
		facade:sendLuaEvent(SandboxConst.COMMON_EVENT.PLAYER_TOGGLE_PET)
	end

	if oldPetId == newPetId then
		self:dispatchControlStateChange(nil, newPetId)
	else
		self:dispatchControlStateChange(oldPetId, newPetId)
	end

	pg.game.effect:getTeamLinkController():onControlPetChange(self, oldPetEnt)
end

function ClientPetsComponent:RPC_SC_OnSingleToFollow(inputEvent, params, newPetId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_OnSingleToFollow", inspect(params), newPetId)
	end

	local petEnt = pg.getEntity(newPetId)

	if petEnt and params.showPosition then
		params.showPosition = Vector3.Convert(params.showPosition)

		petEnt:forceSetPosRot(params.showPosition, self:getRotation(), false, true)
	end

	if self.isMainPlayer then
		facade:sendLuaEvent(SandboxConst.COMMON_EVENT.PLAYER_TOGGLE_PET)
	end

	self:dispatchControlStateChange(nil, newPetId)
	pg.game.effect:getTeamLinkController():onControlStateChange(self, self.controlState)
end

function ClientPetsComponent:RPC_SC_OnFollowToSingle(inputEvent, params, oldPetId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_OnFollowToSingle", inspect(params), oldPetId)
	end

	self:dispatchControlStateChange(oldPetId, nil)
	pg.game.effect:getTeamLinkController():onControlStateChange(self, self.controlState)
end

function ClientPetsComponent:RPC_SC_OnFollowToFollow(inputEvent, params, oldPetTemplateId, newPetTemplateId, oldPetId, newPetId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_OnFollowToFollow %s", oldPetId, newPetId)
	end

	if self.authority == Const.AUTHORITY_MASTER and not self:isExploreEvent(inputEvent) then
		local oldPetEnt = pg.getEntity(oldPetId)
		local newPetEnt = pg.getEntity(newPetId)

		if oldPetEnt and newPetEnt then
			newPetEnt:forceSetPosRot(oldPetEnt:getPosition(), oldPetEnt:getRotation(), true, true)
		end
	end

	self:playFollowToFollowAnim(inputEvent, params)
	self:postComponentMethod("EVENT_onFollowPetSwitchToAnotherFollowPet", oldPetTemplateId, newPetTemplateId, oldPetId, newPetId)

	if self.isMainPlayer then
		facade:sendLuaEvent(SandboxConst.COMMON_EVENT.PLAYER_TOGGLE_PET)
	end

	if Utils.isBotPlayer(self) then
		local newPetEnt = pg.getEntity(newPetId)

		self:setEModelFollowTarget(newPetEnt)
	end

	self:dispatchControlStateChange(oldPetId, newPetId)
end

function ClientPetsComponent:RPC_SC_OnSummonPet(petEntId, inputEvent, extraData)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_OnSummonPet %s", petEntId, inputEvent, inspect(extraData))
	end

	local petEnt = pg.getEntity(petEntId)
	local isShowAppearDash, targetPos = extraData.isShowAppearDash, extraData.targetPos

	if petEnt then
		local isLocalControlledExploreEnt = self.isMainPlayer and pg.pawn == petEnt and self:isControllingExploreEnt()
		local exitFromExploreEnt = inputEvent == Const.EVENT_LEAVE_EXPLORE_PET

		if not isLocalControlledExploreEnt and not exitFromExploreEnt then
			petEnt:forceSetPosRot(self:getPosition(), self:getRotation(), false, true)
		end
	end

	self:onPetSummon(petEnt)

	local oldTemplateId = self.lastPetInfo and self.lastPetInfo.templateId or self.templateId

	if isShowAppearDash then
		petEnt.skillStateMgr:switchState(AbilityConst.SKILL_STATE_APPEAR_DASH, nil, oldTemplateId, nil, targetPos)
	end
end

function ClientPetsComponent:RPC_SC_OnUnSummonPet(petEntId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_OnUnSummonPet %s", petEntId)
	end

	local petEnt = pg.getEntity(petEntId)

	self:onPetUnSummon(petEnt)
end

function ClientPetsComponent:RPC_SC_SummonStandInPet(petEntId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_SummonStandInPet %s", petEntId)
	end

	local petEnt = pg.getEntity(petEntId)

	if petEnt then
		local selfPos = self:getPosition()
		local faceRotation = self:getRotation()
		local faceRotX = faceRotation.x
		local faceRotY = faceRotation.y
		local faceRotZ = faceRotation.z
		local faceRotW = faceRotation.w

		if self.lockedActorId and self.lockedActorId ~= 0 then
			local lockTargetEnt = pg.getEntityByActorId(self.lockedActorId)

			if lockTargetEnt then
				local lockTargetEntPos = lockTargetEnt:getPosition()
				local selfToTargetDirX = lockTargetEntPos.x - selfPos.x
				local selfToTargetDirZ = lockTargetEntPos.z - selfPos.z

				if selfToTargetDirX * selfToTargetDirX + selfToTargetDirZ * selfToTargetDirZ > 1e-12 then
					faceRotX, faceRotY, faceRotZ, faceRotW = Quaternion.LookRotationHoriXYZWNoGC(selfToTargetDirX, selfToTargetDirZ)
				end
			end
		end

		local offsetVec = SysConfigData.supportPetSummonOffset or Vector3.constZero
		local offsetX, offsetY, offsetZ = Quaternion.MulXYZByXYZW(faceRotX, faceRotY, faceRotZ, faceRotW, offsetVec[1], offsetVec[2], offsetVec[3])
		local summonPosX = selfPos.x + offsetX
		local summonPosY = selfPos.y + offsetY
		local summonPosZ = selfPos.z + offsetZ

		petEnt:forceSetPosRotEx(summonPosX, summonPosY, summonPosZ, faceRotX, faceRotY, faceRotZ, faceRotW, false, true)
		self:onPetSummon(petEnt)
		petEnt:playSupportPetFresnelEffect(true)
		petEnt:calcAndRefreshModelScale()
		petEnt:refreshVisible()
		petEnt:refreshControllerType()
	end
end

function ClientPetsComponent:onPetStart(petEnt)
	if pg.space and pg.space:isNpcDuel() then
		AIUtils.pauseBt(petEnt, AiConst.PauseBtReason.NpcDuelStart)
	end

	self:postComponentMethod("EVENT_OnPetStart", petEnt.actorId)
end

function ClientPetsComponent:onPetDestroy(petEnt)
	if self.petSwitchAnim and self.petSwitchAnim.currPetEnt == petEnt then
		self.petSwitchAnim:stop()
	end

	self:postComponentMethod("EVENT_OnPetDestroy", petEnt.actorId)
end

function ClientPetsComponent:onPetSummon(petEnt)
	if petEnt then
		petEnt:refreshVisible()

		local pdd = petEnt:getConfigData() or {}
		local petFightAudio = pdd.petFightAudio

		petEnt:playEffect("Eff_Common_Parmon_Switch")

		if petFightAudio then
			self:playSoundEvent(petFightAudio)
		end

		petEnt:postComponentMethod("onPetSummon")
		petEnt:refreshVisibleByMasterExploreState()
	end
end

function ClientPetsComponent:onPetUnSummon(petEnt)
	if petEnt then
		self.lastPetPosition = Vector3.Clone(petEnt:getPosition())

		if self.petSwitchAnim and self.petSwitchAnim.currPetEnt == petEnt then
			self.petSwitchAnim:stop()
		end

		petEnt:refreshVisible()

		if not EnableBotTest then
			petEnt:playSupportPetFresnelEffect(false)
		end

		petEnt:postComponentMethod("onPetUnSummon")
		EModelUtils.clearDisplacementVelocity(petEnt)
	end
end

function ClientPetsComponent:RPC_SC_OnAddPet(id, petInfo, sourceId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_OnAddPet %s, %d", id, sourceId)
	end

	self:setRedDotRecord(Const.CLIENT_KEY.PET_NEW_RED_DOT, id, true)
	facade:SendMessageCommand(MessageName.MAIN_PLAYER_PET_ADD, {
		sourcId = sourceId,
		petInfo = petInfo
	})
end

function ClientPetsComponent:RPC_SC_ChangePetLabel(petId, oldLabel, newLabel)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_ChangePetLabel petId:%s oldLabel:%d newLabel:%d", petId, oldLabel, newLabel)
	end

	local petEnt = self:getCurPetEntity(petId)

	if petEnt and petEnt.refreshAppearance then
		petEnt:refreshAppearance(true)
	end
end

function ClientPetsComponent:RPC_SC_ChangePetBodySizeType(petId, bodySizeType)
	local petEnt = self:getCurPetEntity(petId)

	if petEnt and petEnt.calcAndRefreshModelScale then
		petEnt:calcAndRefreshModelScale(true)
	end
end

function ClientPetsComponent:_cleanupReleasedPetRedDotRecords(releasedPetInfos)
	if not self.isMainPlayer or not Utils.isTable(releasedPetInfos) then
		return
	end

	local releasedPetIds = {}
	local affectedTemplateIdSet = {}
	local tagKeys = {}

	for _, releasedPetInfo in ipairs(releasedPetInfos) do
		if Utils.isTable(releasedPetInfo) then
			local petId = releasedPetInfo.petId or releasedPetInfo.id
			local templateId = releasedPetInfo.templateId

			if petId ~= nil then
				releasedPetIds[petId] = true
				releasedPetIds[#releasedPetIds + 1] = petId

				for _, labelMask in ipairs(PET_TAG_ANIM_RECORD_MASKS) do
					tagKeys[#tagKeys + 1] = getPetTagAnimRecordKey(petId, labelMask)
				end
			end

			if templateId ~= nil then
				affectedTemplateIdSet[templateId] = true
			end
		end
	end

	for petId, petInfo in pairs(self.pets) do
		local actualPetId = petInfo and (petInfo.id or petId)

		if petInfo and not releasedPetIds[actualPetId] and petInfo.templateId ~= nil then
			affectedTemplateIdSet[petInfo.templateId] = nil
		end
	end

	local evolveKeys = {}

	for templateId in pairs(affectedTemplateIdSet) do
		local petData = PetData[templateId]
		local evolveBranches = petData and PetEvolveData[petData.petPrototypeId]

		if Utils.isTable(evolveBranches) then
			for branchId in pairs(evolveBranches) do
				evolveKeys[#evolveKeys + 1] = getPetEvolveRecordKey(templateId, branchId)
			end
		end

		evolveKeys[#evolveKeys + 1] = getPetEvolveRecordKey(templateId, "emptyEvoBID")
	end

	if #releasedPetIds > 0 then
		self:deletePetRedDotRecords(Const.CLIENT_KEY.PET_NEW_RED_DOT, releasedPetIds)
	end

	if #tagKeys > 0 then
		self:deletePetRedDotRecords(Const.CLIENT_KEY.PET_TAG_ANIM_RECORD, tagKeys)
	end

	if #evolveKeys > 0 then
		self:deletePetRedDotRecords(Const.CLIENT_KEY.PET_EVOLVE_RED_DOT, evolveKeys)
	end
end

function ClientPetsComponent:RPC_SC_OnRecyclePet(releasedPetInfos)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_OnRecyclePet")
	end

	self:_cleanupReleasedPetRedDotRecords(releasedPetInfos)
	facade:SendMessageCommand(MessageName.ON_RECYCLE_PET, {})
end

function ClientPetsComponent:refreshRecyclingStatus(isRecycling)
	self.isRecycling = isRecycling
end

function ClientPetsComponent:RPC_SC_OnAddPetExp(id, level, exp, old_level, old_exp, old_prop, addExp)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_OnAddPetExp %s, lv:%d, exp:%d, old_lv:%d, old_exp:%d", id, level, exp, old_level, old_exp)
	end

	if old_level < level then
		local petEnt = pg.getEntity(id)

		if petEnt then
			local context = CTRPool.getContext()

			context.targetId = petEnt.actorId

			AIControllerUtils.sendAIEvent(petEnt, "LevelUpTrigger", context)
		end

		local info = {
			petId = id,
			newLevel = level,
			oldLevel = old_level,
			curExp = exp,
			oldExp = old_exp,
			oldProp = old_prop,
			addExp = addExp
		}

		facade:sendMsgToUI(MessageName.PET_LEVEL_CHANGED, info)
	else
		facade:sendMsgToUI(MessageName.PET_ADD_EXP, {
			petId = id,
			newLevel = level,
			oldLevel = old_level,
			curExp = exp,
			oldExp = old_exp,
			oldProp = old_prop,
			addExp = addExp
		})
	end
end

function ClientPetsComponent:EVENT_EnterScene()
	if self.isMainPlayer then
		if ToBool(self._gmObserveTargetUid) then
			self:attachGmObserveTarget(self._gmObserveTargetUid)
		elseif self:isControllingEgg() and self:getCurControllingEgg() then
			self:switchToEgg()
		elseif self:isControllingPet() and self:getCurPetEntity() then
			self:switchToPet(Const.EVENT_ENTER_SCENE)
		else
			self:switchToPlayer(Const.EVENT_ENTER_SCENE)
		end

		pg.game.controller:resetControllerState()
	end
end

function ClientPetsComponent:EVENT_ResetScene()
	if self.isMainPlayer then
		if ToBool(self._gmObserveTargetUid) then
			self:attachGmObserveTarget(self._gmObserveTargetUid)
		elseif self:isControllingPet() then
			self:switchToPet(Const.EVENT_RESET_SCENE)
		else
			self:switchToPlayer(Const.EVENT_RESET_SCENE)
		end
	end
end

function ClientPetsComponent:onPetReady(petEnt)
	if self.isMainPlayer and self.isInScene then
		if self:isControllingPet() and petEnt.id == self.curCombatPetId then
			self:switchToPet(Const.EVENT_ENTER_SCENE)
		else
			self:onPetSummon(petEnt)
		end
	end
end

function ClientPetsComponent:switchToPet(inputEvent, targetEnt, params)
	inputEvent = inputEvent or Const.EVENT_PET_DEFAULT

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("switchToPet", inputEvent, targetEnt and targetEnt.id, self.curCombatPetId)
	end

	if self.isMainPlayer then
		self:checkStatus(ConflictTypes.CT_SWITCH_PET, false)
	end

	local petEnt = targetEnt or self:getCurPetEntity()

	if self.isMainPlayer then
		if self:isExploreEvent(inputEvent) then
			local stateValid = false

			if not self:isControllingExploreEnt() then
				if pg.pawn ~= petEnt then
					stateValid = false
				else
					stateValid = true
				end
			else
				stateValid = true
			end

			if stateValid then
				self:refreshVisible()

				return
			end
		end

		if petEnt then
			if self:isControllingExploreEnt() and inputEvent ~= Const.EVENT_CLIENT_PRE_EXPLORE and self.clientExploreEntId ~= petEnt.id then
				self:breakSwitchToExploreEnt()
				self:sendStopExploreControlRequest()
			end

			local controller = pg.game.controller

			if not controller.switchInfo.enabled then
				if not petEnt:isAIRunning() then
					if self:checkNeedInherit(inputEvent, params) then
						controller:forceSaveControllerState(false, CharacterStateConst.getParentState(petEnt.characterState))
					elseif params and params.oldPetState and CharacterStateConst.isChildOfState(params.oldPetState, CharacterStateConst.SNEAK) and petEnt:getTemplateData().canBurrow then
						controller:forceSaveControllerState(false, params.oldPetState, params.abilityStateDuration, params.abilityVelocity)
					elseif params and params.oldPetState and CharacterStateConst.isChildOfState(params.oldPetState, CharacterStateConst.FLYING) and petEnt:getTemplateData().canFly then
						controller:forceSaveControllerState(false, params.oldPetState)
					else
						controller:forceSaveControllerState(true)
					end
				elseif petEnt:TAKE_ROOT_ST() or petEnt:TAKE_ROOT_IN_ST() then
					local controllerComponent = petEnt:getEModelComponent(Const.COMPONENT_AI_CONTROLLER)
					local abilityCharacterStateInfo = NotNil(controllerComponent) and controllerComponent.abilityCharacterStateInfo or nil

					controller:forceSaveControllerState(false, petEnt.characterState, abilityCharacterStateInfo and abilityCharacterStateInfo.abilityStateDuration)
				end
			end

			self:refreshVisible()

			if inputEvent == Const.EVENT_ENTER_SCENE or inputEvent == Const.EVENT_RESET_SCENE or inputEvent == Const.EVENT_SHOW_PET_QTE then
				-- block empty
			elseif inputEvent <= Const.EVENT_PET_DEFAULT and (self:checkSpecialSwitchPet(inputEvent, params) or self:checkSpecialSwitchPet2(inputEvent, params)) then
				-- block empty
			elseif self.eModel then
				local _spx, _spy, _spz = self.eModel:GetPositionAgentPosEx()
				local _srx, _sry, _srz, _srw = self.eModel:GetPositionAgentRotationEx()

				petEnt:forceSetPosRotEx(_spx, _spy, _spz, _srx, _sry, _srz, _srw, true, true)
			end
		else
			self:refreshVisible()
		end

		self:setEModelFollowTarget(petEnt)
		self:switchControl(petEnt, inputEvent, params)
	else
		self:setEModelFollowTarget(petEnt)
		self:refreshVisible()
	end
end

function ClientPetsComponent:tryTriggerSwitchEndCallback()
	if self.switchPlayerCallback then
		if Time.realSecondCache - self.switchPlayerCallbackTime < 5 then
			ClientUtils.tryWithLogError(function()
				self.switchPlayerCallback()
			end)
		end

		self.switchPlayerCallback = nil
	end
end

function ClientPetsComponent:switchToPlayer(inputEvent, params)
	inputEvent = inputEvent or Const.EVENT_PET_DEFAULT

	local oldPetState

	if self.isMainPlayer then
		if self:isExploreEvent(inputEvent) then
			local stateValid = false

			if not self:isControllingExploreEnt() then
				if pg.pawn ~= pg.me then
					stateValid = false
				else
					stateValid = true
				end
			else
				stateValid = true
			end

			if stateValid then
				self:refreshVisible()
				self:tryTriggerSwitchEndCallback()

				return
			end
		end

		if self:isControllingExploreEnt() and inputEvent ~= Const.EVENT_CLIENT_PRE_EXPLORE and self.clientExploreEntId ~= self.id then
			local exploreEnt = pg.getEntity(self.clientExploreEntId)

			oldPetState = exploreEnt and exploreEnt.characterState

			self:breakSwitchToExploreEnt()
			self:sendStopExploreControlRequest()
		end

		local controller = pg.game.controller

		if not controller.switchInfo.enabled then
			if oldPetState and CharacterStateConst.isChildOfState(oldPetState, CharacterStateConst.SWIMMING) then
				controller:forceSaveControllerState(false, oldPetState)
			else
				controller:forceSaveControllerState(true)
			end
		end

		if inputEvent == Const.EVENT_CLIENT_PRE_EXPLORE or inputEvent == Const.EVENT_RESET_SCENE then
			-- block empty
		elseif self:checkSpecialSwitchPlayer(inputEvent, params) and inputEvent == Const.EVENT_LEAVE_PET then
			-- block empty
		else
			local petEnt = self:getCurPetEntity()

			if petEnt then
				self:initPetPos(petEnt)
			end
		end

		self:refreshVisible()
		self:setEModelFollowTarget(nil)
		self:switchControl(nil, inputEvent, params)

		if not self:isPreExploreEvent(inputEvent) then
			self:tryTriggerSwitchEndCallback()
		end
	else
		self:setEModelFollowTarget(nil)
		self:refreshVisible()
	end
end

function ClientPetsComponent:switchControl(targetEnt, inputEvent, params)
	local controlEnt = targetEnt or self
	local inheritMotion = self:checkNeedInherit(inputEvent, params)
	local oldPawn = pg.pawn

	if pg.game.controller:controlEntity(controlEnt, inputEvent, params, inheritMotion) then
		facade:SendMessageCommand(MessageName.ON_CONTROL_ENT, {
			targetEnt = targetEnt,
			oldPawn = oldPawn,
			inputEvent = inputEvent,
			switchParams = params
		})
		pg.global.eventEmitter:emit(EventConst.ON_PLAYER_SWITCH_CONTROL)
		self.subject:notify(AbilityConst.COMBAT_EVENT_ON_PLAYER_SWITCH_CONTROL)
		self:postComponentMethod("EVENT_OnPetControlChanged")
	end

	self:refreshParticularEffectVisible()
end

function ClientPetsComponent:initPetPos(petEnt)
	if petEnt then
		local toPos = self:getPosition()
		local toRot = self:getRotation()

		if self.space and self.space:isNpcDuel() then
			toPos = petEnt:getPosition()
			toRot = petEnt:getRotation()
		end

		petEnt:forceSetPosRot(toPos, toRot, false, true)
	end
end

function ClientPetsComponent:isPrepareListEmpty()
	if not self.petPrepareList then
		return true
	end

	if #self.petPrepareList == 0 then
		return true
	end

	return false
end

function ClientPetsComponent:getControllingPet()
	if self:isControllingPet() then
		return self:getCurPetEntity()
	end

	return nil
end

function ClientPetsComponent:getCurPetEntity(petId)
	local entId = petId or self.curCombatPetId
	local ent = pg.getEntity(entId)

	if ent then
		return ent
	else
		return nil
	end
end

function ClientPetsComponent:getCurMainCombatPetEntity()
	if self:isPrepareListEmpty() then
		return nil
	end

	if self.space and self.space:isSupportPetMode() then
		local entId = self.petPrepareList[1]

		return pg.getEntity(entId)
	else
		if Utils.isPet(pg.pawn) then
			return pg.pawn
		end

		return self:getCurPetEntity()
	end
end

function ClientPetsComponent:isControllingExploreEnt()
	if self.clientExploreEntId then
		return not self.exploreSwitchFlag
	end

	return false
end

function ClientPetsComponent:checkPetControlUnlock()
	local petInfo = self:getPetInfo(self.curCombatPetId)

	if petInfo == nil then
		return true
	end

	local pData = PetData[petInfo.templateId]

	if pData.sychronize == 1 then
		return true
	end

	return self.petControlUnlocks[petInfo.templateId] == true or self.gmMode == 1
end

function ClientPetsComponent:getPetControlEthnicGroup()
	local curControllingPet = self:getControllingPet()

	if not curControllingPet then
		return 0
	end

	return curControllingPet:getConfigData().ethnicGroup or 0
end

function ClientPetsComponent:isForbidControlPet()
	if self.actorBuff:hasTag(AbilityConst.BUFF_TAG_FOBID_CONTROL_PET) then
		return true
	end

	return false
end

function ClientPetsComponent:checkCanControlPet(showNotice)
	local petInfo = self:getPetInfo(self.curCombatPetId)

	if petInfo == nil then
		return true
	end

	if not self:checkControlLevel(petInfo) and self.gmMode ~= 1 then
		if showNotice then
			pg.global.showBubbleMessageById(NoticeDef.CONTROL_PET_LEVEL_INVALID, self:getMaxControlLevel(), petInfo.level)
		end

		return false
	end

	if not self:checkPetControlUnlock() then
		if showNotice then
			pg.global.showBubbleMessageById(NoticeDef.CONTROL_PET_SYNCHRONIZE_INVALID)
		end

		return false
	end

	return true
end

function ClientPetsComponent:checkControlLevel(unit)
	if self.petTeamType == Const.PET_TEAM_TYPE_TMP_BOSS_CHALLENGE then
		return true
	end

	local isRobEggSpace = self.space and Utils.isRobEggSceneId(self.space.sceneId)

	if isRobEggSpace then
		return true
	end

	return self:getMaxControlLevel() >= unit.level
end

function ClientPetsComponent:isControllingPet()
	if self:isControllingExplorePet() then
		return true
	end

	if self:isControllingExplorePlayer() then
		return false
	end

	return self.controlState == Const.CONTROL_STATE_CONTROL
end

function ClientPetsComponent:checkInControllingPet(petEnt)
	if self:isControllingExplorePet() then
		return petEnt.id == self.clientExploreEntId
	end

	return petEnt.id == self.curCombatPetId
end

function ClientPetsComponent:isControllingSupportPet()
	if self.controlState == Const.CONTROL_STATE_CONTROL then
		local curPetEnt = self:getCurPetEntity()

		return Utils.isSupportPet(curPetEnt)
	end

	return false
end

function ClientPetsComponent:getControllingExploreEnt()
	if self.clientExploreEntId then
		return pg.getEntity(self.clientExploreEntId)
	end

	return nil
end

function ClientPetsComponent:isControllingExplorePet()
	local controlEnt = self:getControllingExploreEnt()

	if Utils.isPet(controlEnt) then
		return true
	end

	return false
end

function ClientPetsComponent:isControllingExplorePlayer()
	local controlEnt = self:getControllingExploreEnt()

	if controlEnt == self then
		return true
	end

	return false
end

function ClientPetsComponent:isControllingMaster()
	if pg.me and pg.me.id == self.clientExploreEntId then
		return true
	end

	return self.controlState == Const.CONTROL_STATE_FOLLOW or self.controlState == Const.CONTROL_STATE_SINGLE
end

function ClientPetsComponent:isControlFollow()
	return self.controlState == Const.CONTROL_STATE_FOLLOW
end

function ClientPetsComponent:isRidingPet()
	return self.controlState == Const.CONTROL_STATE_RIDE
end

function ClientPetsComponent:isPetInControl(petEntId)
	return self:isControllingPet() and self.curCombatPetId == petEntId
end

function ClientPetsComponent:isPetInFollow(petEntId)
	return self:isControllingMaster() and self.curCombatPetId == petEntId
end

function ClientPetsComponent:isPetInSelect(petEntId)
	return self.curCombatPetId == petEntId
end

function ClientPetsComponent:checkShowPetValidByIndex(index)
	local id = self.petPrepareList[index]

	if self.curCombatPetId == id then
		return false
	end

	return true
end

function ClientPetsComponent:checkSpecialSwitchPet(inputEvent, params)
	if inputEvent == Const.EVENT_ENTER_PET then
		return self:isInCombat()
	end

	return false
end

function ClientPetsComponent:checkNeedInherit(inputEvent, params)
	if inputEvent == Const.EVENT_ENTER_PET then
		return not self:isInCombat()
	end

	return false
end

function ClientPetsComponent:checkSpecialSwitchPet2(inputEvent, params)
	if inputEvent == Const.EVENT_ENTER_PET then
		local clientSwitchReason = (params or EMPTY_TABLE).clientSwitchReason

		if clientSwitchReason == Const.CLIENT_SWITCH_REASON.ManualSwitch then
			return true
		end
	end

	return false
end

function ClientPetsComponent:checkSpecialSwitchPlayer(inputEvent, params)
	if inputEvent == Const.EVENT_LEAVE_PET then
		return self:isInCombat()
	end

	return false
end

function ClientPetsComponent:setSwitchEndTime(endTime, skipRefresh)
	self.switchEndTime = endTime

	if not skipRefresh then
		self:refreshVisible()

		if self.refreshControllerType then
			self:refreshControllerType()
		end
	end

	if endTime == nil and self.isMainPlayer then
		local topLogoCtrl = pg.global.ui and pg.global.ui.topLogo

		if topLogoCtrl and topLogoCtrl.notifyPawnSwitchVisualDone then
			topLogoCtrl:notifyPawnSwitchVisualDone()
		end
	end
end

function ClientPetsComponent:playPlayerToPetAnim(inputEvent, params)
	if inputEvent == Const.EVENT_ENTER_PET then
		local petEnt = self:getCurPetEntity()

		if petEnt and self.petSwitchAnim then
			if self:checkSpecialSwitchPet(inputEvent, params) then
				if self:getUseQuickPetSwitch(params) then
					self.petSwitchAnim:playQuickSwitchToPetAnimSpecial(petEnt, self)
				else
					self.petSwitchAnim:playSwitchToPetAnimSpecial(petEnt, self)
				end
			elseif self:checkSpecialSwitchPet2(inputEvent, params) then
				if self:getUseQuickPetSwitch(params) then
					self.petSwitchAnim:playQuickSwitchToPetAnimSpecial2(petEnt, self)
				else
					self.petSwitchAnim:playSwitchToPetAnimSpecial2(petEnt, self)
				end
			else
				self.petSwitchAnim:playSwitchToPetAnim(petEnt, self)
			end
		end
	end
end

function ClientPetsComponent:playPlayerToEggAnim(eggEnt)
	if self.petSwitchAnim then
		self.petSwitchAnim:playSwitchToEggAnimSpecial(eggEnt, self)
	end
end

function ClientPetsComponent:getUseQuickPetSwitch(params)
	return self.actorCombatAttribute:getAttribValue(AttributeConst.use_quick_pet_switch) == 1 or params.clientSwitchReason == Const.CLIENT_SWITCH_REASON.FuncMenu
end

function ClientPetsComponent:playPetToPetAnim(inputEvent, params)
	if inputEvent == Const.EVENT_SHOW_PET or inputEvent == Const.EVENT_ENTER_PET then
		local petEnt = self:getCurPetEntity()

		if self.petSwitchAnim then
			self.petSwitchAnim:playPetToPetAnim(petEnt, self)
		end
	end
end

function ClientPetsComponent:playFollowToFollowAnim(inputEvent, params)
	if inputEvent == Const.EVENT_SHOW_PET and self.petSwitchAnim then
		local petEnt = self:getCurPetEntity()

		self.petSwitchAnim:playFollowToFollowAnim(petEnt)
	end
end

function ClientPetsComponent:playSwitchToPlayerAnim(inputEvent, params)
	if inputEvent == Const.EVENT_LEAVE_PET and self.petSwitchAnim then
		local petEnt = self:getCurPetEntity()

		if petEnt then
			if self:checkSpecialSwitchPlayer(inputEvent, params) and not self.captureSwitchFlag then
				self.petSwitchAnim:playSwitchToPlayerAnimSpecial(petEnt, self)
			else
				self.petSwitchAnim:playSwitchToPlayerAnim(petEnt, self)
			end
		end
	end
end

function ClientPetsComponent:playSwitchToExplorePetAnim(inputEvent, petEnt, isFromPlayer)
	if self.petSwitchAnim then
		self.petSwitchAnim:playSwitchToExplorePetAnim(petEnt, self, isFromPlayer)
	end
end

function ClientPetsComponent:playSwitchToExplorePlayerAnim(inputEvent)
	if self.petSwitchAnim then
		self.petSwitchAnim:playSwitchToExplorePlayerAnim(self)
	end
end

function ClientPetsComponent:on_customNameChanged(ov, nv, pid)
	facade:sendMsgToUI(MessageName.PET_CUSTOM_NAME_CHANGED, {
		petId = pid,
		name = nv
	})
end

function ClientPetsComponent:RPC_SC_OnPetInfoSwitchAbility(petId, abilityType)
	facade:sendMsgToUI(MessageName.PLAYER_PET_CUR_ABILITY_CHANGED, {
		petId = petId,
		index = abilityType
	})
end

function ClientPetsComponent:on_controlCharacter_changed(ov, nv, pid)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("on_featureChange>>", ov, nv, pid)
	end

	facade:sendMsgToUI(MessageName.PLAYER_PET_CUR_FEATURE_CHANGED, {
		petId = pid,
		ov = ov,
		nv = nv
	})
end

function ClientPetsComponent:on_followCharacter_changed(ov, nv, pid)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("on_featureChange>>", ov, nv, pid)
	end

	facade:sendMsgToUI(MessageName.PLAYER_PET_CUR_FEATURE_CHANGED, {
		petId = pid,
		ov = ov,
		nv = nv
	})
end

function ClientPetsComponent:onPetInfoLabelChange(ov, nv, pid)
	local pet = pg.getEntity(pid)

	if pet then
		pet:refreshParmonDye()
	end
end

function ClientPetsComponent:onPetTalentListChanged(oldValue, newValue, petId)
	facade:sendMsgToUI(MessageName.PET_TALENT_LIST_CHANGED, {
		petId = petId
	})
end

function ClientPetsComponent:on_curPetVisible_changed(oldV, newV)
	self:refreshCurPetVisible()
end

function ClientPetsComponent:setEModelFollowTarget(followEnt)
	if not self:hasEModelComponent(Const.COMPONENT_INDEX_FOLLOW) then
		return
	end

	self.eModel.followEntity = followEnt and followEnt.eModel or nil
end

function ClientPetsComponent:setCurPetVisible(key, visible)
	if visible then
		Bitset.clrBit(self.petHideKeys, key)
	else
		Bitset.setBit(self.petHideKeys, key)
	end

	self:refreshCurPetVisible()
end

function ClientPetsComponent:dumpPetHideKeys()
	return Bitset.dump(self.petHideKeys, ClientConst.MODEL_VISIBLE_KEY)
end

function ClientPetsComponent:EVENT_OnCharacterStateChange(oldState, newState)
	local isControllingMaster = self:isControllingMaster()

	if isControllingMaster then
		local wasSwimming = CharacterStateConst.isChildOfState(oldState, CharacterStateConst.SWIMMING)
		local isSwimming = CharacterStateConst.isChildOfState(newState, CharacterStateConst.SWIMMING)

		if wasSwimming ~= isSwimming then
			self:refreshSwimmingState()
		end
	end

	if (isControllingMaster or self == pg.me) and CharacterStateConst.isExploreState(oldState) ~= CharacterStateConst.isExploreState(newState) then
		self:refreshPetExploreStateVisible()

		if isControllingMaster then
			self:refreshCurPetsAi()
		end
	end
end

function ClientPetsComponent:EVENT_LoseControlled()
	self:refreshSwimmingState(false)
	self:refreshPetExploreStateVisible()
end

function ClientPetsComponent:checkInBlockCurPetState()
	if self:isControllingMaster() and not EnableBotTest and (self:GLIDE_ST() or self:SWIM_ST() or self:CLIMB_ST()) then
		return true
	end

	return false
end

function ClientPetsComponent:refreshPetExploreStateVisible()
	local petEnt = self:getCurPetEntity()

	if petEnt then
		petEnt:refreshVisibleByMasterExploreState()
	end
end

function ClientPetsComponent:refreshSwimmingState(isSwimming)
	if isSwimming == nil then
		isSwimming = self:SWIM_ST()
	end

	self:setCurPetVisible(ClientConst.MODEL_VISIBLE_KEY.SWIMMING, not isSwimming)
end

function ClientPetsComponent:RPC_SC_OnMasterExploreStateChange(isExplore)
	self:refreshSwimmingState(isExplore)
	self:refreshPetExploreStateVisible()
end

function ClientPetsComponent:checkCurPetVisible()
	if Bitset.any(self.petHideKeys) then
		return false
	end

	return self.curPetVisible
end

function ClientPetsComponent:checkPauseCurPetBt()
	if self:checkInBlockCurPetState() then
		return true
	end

	return false
end

function ClientPetsComponent:refreshCurPetVisible()
	local petEnt = self:getCurPetEntity()

	if petEnt then
		petEnt:refreshVisible()
	end
end

function ClientPetsComponent:refreshCombatPetsVisible()
	local petPrepareList = self.petPrepareList or {}

	for _, petId in ipairs(petPrepareList) do
		local petEnt = pg.getEntity(petId)

		if petEnt then
			petEnt:refreshVisible()
		end
	end
end

function ClientPetsComponent:refreshExplorePetsVisible()
	for abilityId, petId in pairs(self.petExploreList) do
		local petEnt = pg.getEntity(petId)

		if petEnt then
			petEnt:refreshVisible()
		end
	end
end

function ClientPetsComponent:RPC_SC_SetPetState(petState, targetActorId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("petState changed", petState, targetActorId)
	end
end

function ClientPetsComponent:setPetState(petState, targetActorId, force)
	self.petState = petState

	local ent = self:getCurPetEntity()

	if ent and ent.agent then
		if petState == Const.PET_STATE_GO then
			local tTargetActorId, targetPartId, targetAbilityId = pg.game.controller.lockHelper:getGoAutoLockEnt(ent)

			if LoggerManager.checkLogger(LoggerConst.INFO) then
				self.logger:info("ClientPetsComponent:PET_STATE_GO", tTargetActorId, targetPartId, targetAbilityId)
			end

			if Utils.isPuppet(pg.getEntityByActorId(tTargetActorId)) then
				if force then
					ent:lockTarget(tTargetActorId)

					local context = CTRPool.getContext()

					context.targetActorId = tTargetActorId
					context.skillId = targetAbilityId
					context.partId = targetPartId

					AIControllerUtils.sendAIEvent(ent, "CommandGoTrigger", context)
				elseif ent:getAttackTargetActorId() == tTargetActorId then
					return
				elseif not self:isInCombat() then
					ent:lockTarget(tTargetActorId)

					local context = CTRPool.getContext()

					context.targetActorId = tTargetActorId
					context.skillId = targetAbilityId
					context.partId = targetPartId

					AIControllerUtils.sendAIEvent(ent, "CommandGoTrigger", context)
				else
					ent:lockTarget(tTargetActorId)

					local context = CTRPool.getContext()

					context.enemyId = tTargetActorId

					AIControllerUtils.sendAIEvent(ent, "MasterSwitchTargetMsgTrigger", context)
				end
			else
				ent:lockTarget(tTargetActorId)

				local context = CTRPool.getContext()

				context.targetActorId = tTargetActorId
				context.skillId = targetAbilityId
				context.partId = targetPartId

				AIControllerUtils.sendAIEvent(ent, "CommandGoTrigger", context)
			end

			ent:removeAITag("TA_PetEnterBack")
		elseif petState == Const.PET_STATE_STOP then
			ent:unlockTarget()
		elseif petState == Const.PET_STATE_BACK then
			ent:unlockTarget()
			ent:addAITag("TA_PetEnterBack")
			AIControllerUtils.sendAIEvent(ent, "Event_PetEnterBack")
		end
	end
end

function ClientPetsComponent:checkPetUseGoSkill()
	local pet = self:getCurPetEntity()

	if not pet then
		return false
	end

	if self.lockedActorId and self.lockedActorId ~= 0 then
		local targetEntity = pg.getEntityByActorId(self.lockedActorId)

		if targetEntity and Utils.isResourceBox(targetEntity) then
			return false
		end

		if targetEntity and Utils.isEnvObj(targetEntity) then
			return true
		end

		if self.lockedActorId == self.petLockedActorId then
			return false
		end

		if self:checkPetInGoPlan() then
			return false
		end
	elseif self:checkPetInGoPlan() then
		return false
	else
		local ent = self:getCurPetEntity()

		if ent then
			local tTargetActorId, targetPartId, targetAbilityId = pg.game.controller.lockHelper:getGoAutoLockEnt(ent)

			if tTargetActorId and tTargetActorId ~= 0 then
				local tTargetEnt = pg.getEntityByActorId(tTargetActorId)

				if Utils.isPuppet(tTargetEnt) then
					if ent:getAttackTargetActorId() == tTargetActorId then
						return false
					else
						return true
					end
				elseif tTargetEnt and Utils.isResourceBox(tTargetEnt) then
					return false
				else
					return true
				end
			end
		end

		local curGameTime = self:getGameTime()

		if self.lastNoTargetGoTime then
			local noTargetGoCD = SysConfigData.noTargetGoCD or 20

			if curGameTime > self.lastNoTargetGoTime and curGameTime < self.lastNoTargetGoTime + noTargetGoCD then
				return false
			end
		end

		self.lastNoTargetGoTime = curGameTime
	end

	return true
end

function ClientPetsComponent:clearNotTargetLetGoCD()
	self.lastNoTargetGoTime = nil
end

function ClientPetsComponent:checkPetInGoPlan()
	local pet = self:getCurPetEntity()

	if pet then
		return pet:checkAIParmonPlanTag("TB_Pet_Command_Go")
	end

	return false
end

function ClientPetsComponent:executePetAdditiveAIEvent(triggerName, context)
	local ent = self:getCurPetEntity()

	if ent == nil then
		return
	end

	AIControllerUtils.sendAIEvent(ent, triggerName, context)
end

function ClientPetsComponent:RPC_SC_OnAddBehatred(targetActorId)
	local puppet = pg.getEntityByActorId(targetActorId)

	if puppet and Utils.isSemanticallyBoss(puppet) then
		self.clientSocialBossHatredMap[targetActorId] = 1
	end
end

function ClientPetsComponent:RPC_SC_OnSocialRemoveHatred(targetActorId)
	if self.clientSocialBossHatredMap[targetActorId] then
		self.clientSocialBossHatredMap[targetActorId] = nil
	end
end

function ClientPetsComponent:RPC_SC_OnAddHatred(targetActorId)
	local currPetEnt = self:getCurPetEntity()

	if currPetEnt and currPetEnt.agent then
		AIUtils.petAttractHatre(currPetEnt, targetActorId)
	end
end

function ClientPetsComponent:onPetBoxMapEntryDeleted(index, petBoxInfo)
	if self.isRecycling then
		return
	end
end

function ClientPetsComponent:onPetBoxMapEntryAdded(index, petBoxInfo)
	if self.isRecycling then
		return
	end
end

function ClientPetsComponent:onPetBoxMapValueChanged(ov, nv, index)
	if self.isRecycling then
		return
	end

	facade:SendMessageCommand(MessageName.PET_BOX_MAP_UPDATE, {})
end

function ClientPetsComponent:onPetBoxMapSequenceChanged(ov, nv)
	if self.isRecycling then
		return
	end

	facade:SendMessageCommand(MessageName.PET_BOX_MAP_SEQUENCE_UPDATE, {})
end

function ClientPetsComponent:onPetBoxMapCustomNameChanged(ov, nv, index)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("onPetBoxMapCustomNameChanged", ov, nv, index)
	end

	facade:SendMessageCommand(MessageName.ON_BOX_NAME_CHANGE, {
		index = index,
		newName = nv
	})
end

function ClientPetsComponent:onPetInExploreStateChanged(ov, nv)
	facade:SendMessageCommand(MessageName.PET_EXPLORE_STATE_CHANGED, {})
end

function ClientPetsComponent:onPetBoxMapIsNewChanged(ov, nv, index)
	return
end

function ClientPetsComponent:onPetActionModeChanged(ov, nv)
	return
end

function ClientPetsComponent:onSkeletonLoaded()
	self:on_curSocialId_changed("", self.curSocialId)
end

function ClientPetsComponent:on_curSocialId_changed(oldV, newV)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("on_curSocialId_changed", oldV, newV)
	end

	if string.isNilOrEmpty(newV) then
		self:stopPetExchangeEffects()
		self.eventEmitter:emit(EventConst.TOPLOGO_PET_EXCHANGE, false)

		return
	end

	local socialInfo = string.split(newV, "_")
	local _, player1, player2 = socialInfo[1], socialInfo[2], socialInfo[3]

	if pg.me.uid == player1 or pg.me.uid == player2 then
		local carryType = pg.me.carryType

		if carryType == Const.CARRY_TYPE.PET then
			pg.me:putDownCarryEnt()
		end
	end

	if self.uid == player1 then
		local otherPlayerEnt = pg.getEntityByUid(player2)

		if not otherPlayerEnt then
			return
		end

		self.petExchangeHandEffectId = self:playEffect(EffectConst.Eff_UI_PetExchange_Hand_R, nil, true)

		local handEffectId = otherPlayerEnt:playEffect(EffectConst.Eff_UI_PetExchange_Hand_L, nil, true)

		otherPlayerEnt.petExchangeHandEffectId = handEffectId
		self.petExchangeLinkEffectId = self:playLinkEffect(EffectConst.PET_EXCHANGE_LINK, otherPlayerEnt, nil)

		self:ensureToplogoComponent(UIConst.TOPLOGO_COMPONENT.PET_EXCHANGE)
		self.eventEmitter:emit(EventConst.TOPLOGO_PET_EXCHANGE, true)
		otherPlayerEnt:ensureToplogoComponent(UIConst.TOPLOGO_COMPONENT.PET_EXCHANGE)
		otherPlayerEnt.eventEmitter:emit(EventConst.TOPLOGO_PET_EXCHANGE, true)
	end
end

function ClientPetsComponent:RPC_SC_OnPetBoxAutoAdjust(boxIndex)
	return
end

function ClientPetsComponent:getPetBoxSlotIndex(petId)
	for boxIndex, boxInfo in self.petBoxMap:items() do
		for slotIndex, slotInfo in boxInfo:items() do
			if petId == slotInfo then
				return boxIndex, slotIndex
			end
		end
	end

	return nil, nil
end

function ClientPetsComponent:onPetFavoriteChanged(ov, nv, petId)
	local boxIndex, slotIndex = self:getPetBoxSlotIndex(petId)

	facade:SendMessageCommand(MessageName.PET_FAVORITE_CHANGE, {
		petId,
		nv
	})
end

function ClientPetsComponent:onPetFavoriteTypeChanged(ov, nv, petId)
	facade:SendMessageCommand(MessageName.PET_FAVORITE_TYPE_CHANGE, {
		petId,
		nv
	})
end

function ClientPetsComponent:on_petCurAbilityPresetChanged(ov, nv, petId)
	facade:sendMsgToUI(MessageName.PET_ABILITY_CUR_PRESET_IDX, {
		petId = petId,
		curIdx = nv
	})
end

function ClientPetsComponent:on_petSelectTransmogScheme_changed(ov, nv, petId)
	self:applyPetSelectTransmogScheme(petId, nv)
end

function ClientPetsComponent:on_petTransmogInfoMap_entry_added(petId, transmogInfo)
	self:applyPetSelectTransmogScheme(petId, transmogInfo and transmogInfo.selectTransmogScheme)
end

function ClientPetsComponent:OnPetProud()
	return
end

function ClientPetsComponent:OnPetEat()
	return
end

function ClientPetsComponent:onQuickCapture()
	return
end

function ClientPetsComponent:EVENT_ResetAllStateByEscape()
	self:breakSwitchToExploreEnt()
	self:sendStopExploreControlRequest()
end

function ClientPetsComponent:playTeamEmoji(messageBody)
	facade:sendMsgToUI(MessageName.PET_SHOW_EMOJI, messageBody)
end

function ClientPetsComponent:stopTeamEmoji(petId)
	facade:sendMsgToUI(MessageName.PET_SHOW_EMOJI, {
		petId = petId
	})
end

function ClientPetsComponent:petUseAbility(abilityId)
	local petEnt = self:getCurPetEntity()
	local abilityName = AbilityUtils.getAbilityName(abilityId)

	self.eventEmitter:emit(EventConst.TOPLOGO_DIALOGUE, true, DialogueConst.CUSTOM_BUBBLE_DIALOGUE_ID, abilityName)

	if petEnt then
		local lockEnt = pg.getEntityByActorId(self.petLockedActorId)

		if not lockEnt then
			petEnt:lockTarget(pg.me.lockedActorId)
		end

		local context = CTRPool.getContext()

		context.tSkillTargetActorId = self.petLockedActorId
		context.tSkillId = abilityId

		AIControllerUtils.sendAIEvent(petEnt, "CastSkillMsgTrigger", context)

		return true
	end

	return false
end

function ClientPetsComponent:commandPetUseQSkillOnEnvObj()
	local petEnt = self:getCurPetEntity()

	if not self:isControllingPet() and petEnt and not petEnt:isBTPaused() then
		-- block empty
	end

	return false
end

function ClientPetsComponent:switchPetCommandMode()
	if self.petCommandMode == AiConst.PET_COMMAND_MODE.Normal then
		self.petCommandMode = AiConst.PET_COMMAND_MODE.Conductor
	else
		self.petCommandMode = AiConst.PET_COMMAND_MODE.Normal
	end
end

function ClientPetsComponent:getPetCommandMode()
	return self.petCommandMode
end

function ClientPetsComponent:RPC_SC_OnItemAddPet(clientPetInfo, srcItemId)
	local templateId = clientPetInfo.templateId
	local petdata = PetData[templateId]

	clientPetInfo.headIconName = petdata.iconName
	clientPetInfo.name = pg.getLocalizationText(petdata.name)
	clientPetInfo.iconName = petdata.iconName
	clientPetInfo.elementTypes = petdata.elementType

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("itemaddpet", templateId, srcItemId)
	end

	if clientPetInfo.sourceId == Const.PET_FROM_EXCHANGE then
		pg.global.ui.hudV2:delayShowPetAdd(clientPetInfo)
	else
		if pg.me:isInFishingCapture() then
			return
		end

		pg.global.ui.tips:pushPetGot({
			clientPetInfo
		})

		if pg.global.ui:getModalPanelShowState(UIConst.UI_ID_TIPS) then
			pg.global.ui.tips:itemPetGot(clientPetInfo)
		end
	end
end

function ClientPetsComponent:RPC_SC_OnItemDelPet(templateId, realNum, num)
	local petdata = PetData[templateId]

	self:showBubbleMessage(NoticeDef.PET_FROM_EVENT_REMOVE, pg.getLocalizationText(petdata.name))
end

function ClientPetsComponent:RPC_SC_OnEggHatched(petId, eggId)
	local context = string.format("RPC_SC_OnEggHatched, petId=%s", tostring(petId))
	local envObjTemplateId, eggPrefabResID = Utils.getEggBindingSceneObjectIdByItemId(eggId, context, PetFertilityConst.fallbackEggResId)

	if not eggPrefabResID or eggPrefabResID == "" then
		return
	end

	local eggInfo = {
		templateId = envObjTemplateId,
		eggItemId = eggId,
		prefabResID = eggPrefabResID
	}
	local petCurrentInfo = pg.me:getPetInfo(petId)

	if not petCurrentInfo then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("RPC_SC_OnEggHatched can not get pet info!")
		end

		return
	end

	pg.game.soulEggEvolution:startSoulEggEvolution(eggInfo, petCurrentInfo)
end

function ClientPetsComponent:onSwitchPetForceCountChange(old, new)
	if new + 1 == old then
		ClientUtils.showBubbleMessage(NoticeDef.FORCE_SWITCH_PET_SUCCESS, new)

		self.lastSwitchPetForceTime = Time.realSecondCache
	end

	facade:sendMsgToUI(MessageName.PVP_SWITCH_PET_REMAIN_COUNT)
end

function ClientPetsComponent:getCurMaxCallFriendNum()
	local petEnt = self:getCurPetEntity()

	if petEnt == nil then
		return 0
	end

	local behaviorLevel = self.petBehaviorLearnMap and self.petBehaviorLearnMap:getPetBehaviorLevel(petEnt.templateId, Const.CALL_FRIEND_BEHAVIOR_ID) or 0
	local pbldd = PetBehaviorLevelData[Const.CALL_FRIEND_BEHAVIOR_ID]
	local levelConfig = pbldd and pbldd[behaviorLevel]
	local num = 0

	for _, attrInfo in ipairs(levelConfig.attrList or EMPTY_TABLE) do
		local attrType, attrValue = attrInfo[1], attrInfo[2]

		if attrType == "call_num" then
			num = tonumber(attrValue) or 0

			break
		end
	end

	return num
end

function ClientPetsComponent:startPetBehavior(behaviorId, targetActorId)
	self:serverMsg("RPC_CS_StartPetBehavior", behaviorId or 0, targetActorId or 0)
end

function ClientPetsComponent:RPC_SC_OnPetBehaviorStart(entId, behaviorId, behaviorLevel)
	local pbcdd = PetBehaviorConfigData[behaviorId]
	local pbldd = PetBehaviorLevelData[behaviorId]
	local levelConfig = pbldd and pbldd[behaviorLevel]

	if pbcdd == nil or pbldd == nil or levelConfig == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("config nil")
		end

		return
	end

	local petEnt = pg.getEntity(entId)

	if petEnt == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("petEnt nil")
		end

		return
	end

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_OnPetBehaviorStart", petEnt.id, inspect(levelConfig))
	end
end

function ClientPetsComponent:onCurCombatPetIdChange(old, new)
	self:updateFollowingPhantomList()
	self:refreshEntityManagerCurPet()

	if old and self.putDownCarryEnt and self.carryEnt and old == self.carryEnt.id then
		self:putDownCarryEnt()
	end

	facade:SendMessageCommand(MessageName.CUR_COMBAT_PET_CHANGED, {
		uid = self.uid,
		oldPetId = old,
		newPetId = new
	})
end

function ClientPetsComponent:onControlStateChange(old, new)
	facade:SendMessageCommand(MessageName.CONTROL_STATE_CHANGE, {
		playerId = self.uid,
		old = old,
		new = new
	})
	self:postComponentMethod("EVENT_OnPetControlChanged")

	if self == pg.me then
		self:refreshPetExploreStateVisible()
	end

	if self.updateStateCache then
		self:updateStateCache("CONTROL_ENT_ST")
	end
end

function ClientPetsComponent:onExploreAbilityIndexChange(ov, nv)
	if nv and nv > 0 then
		self.clientExploreEntId = self.petExploreList[nv]
	else
		self.clientExploreEntId = nil
	end
end

function ClientPetsComponent:onEnterSpace()
	facade:SendMessageCommand(MessageName.CONTROL_STATE_CHANGE, {
		playerId = self.uid
	})

	if self.enableForceChangeCombatPet then
		pg.game:setModuleEnable(UIConst.UI_HIDE_MATE_KEY.ENABLE_FORCE_CHANGE_COMBAT_PET, ClientConst.ModuleKey.PetList, false)
	end
end

function ClientPetsComponent:updateTwinPetChoice(index, callback)
	self:serverMsg("RPC_CS_UpdateTwinPetChoice", index, function(errorCode)
		if NoticeDef.SUCCESS ~= errorCode then
			ClientUtils.showBubbleMessageById(errorCode)
		end

		if callback then
			callback()
		end
	end)
end

function ClientPetsComponent:updateTwinPetChoiceScore(score, callback)
	self:serverMsg("RPC_CS_UpdateTwinChoiceScore", score, function(errorCode)
		if NoticeDef.SUCCESS ~= errorCode then
			ClientUtils.showBubbleMessageById(errorCode)
		end

		if callback then
			callback()
		end
	end)
end

function ClientPetsComponent:RPC_SC_OnPetMove(preBoxIndex, preSlotIndex, toBoxIndex, toSlotIndex, isSwap)
	facade:sendMsgToUI(MessageName.PET_MANAGEMENT_ON_PET_MOVE_FINISHED, {
		preBoxIndex = preBoxIndex,
		preSlotIndex = preSlotIndex,
		toBoxIndex = toBoxIndex,
		toSlotIndex = toSlotIndex,
		isSwap = isSwap
	})
end

function ClientPetsComponent:refreshEntityManagerCurPet()
	if self.isMainPlayer then
		appFacade.entityManager:SetCurCombatPetId(self.curCombatPetId)
	end
end

function ClientPetsComponent:commandPetAIMoveToPosDetectPlayerChange(detectPlayer, hashId, x, y, z)
	local petEnt = self:getCurPetEntity()

	if detectPlayer then
		self.commandPetAI[hashId] = true

		if petEnt and petEnt.agent then
			petEnt.agent:enterWait()

			local context = CTRPool.getContext()

			context.waitPos = Vector3(x, y, z)

			AIControllerUtils.sendAIEvent(petEnt, "EnterCannotFollowAreaMsg", context)
		end
	else
		self.commandPetAI[hashId] = nil

		if not self:checkCommandPetAIState() and petEnt and petEnt.agent then
			petEnt.agent:exitWait()
		end
	end
end

function ClientPetsComponent:checkCommandPetAIState()
	return next(self.commandPetAI) ~= nil
end

function ClientPetsComponent:on_enableForceChangeCombatPet_changed(ov, nv)
	pg.game:setModuleEnable(UIConst.UI_HIDE_MATE_KEY.ENABLE_FORCE_CHANGE_COMBAT_PET, ClientConst.ModuleKey.PetList, not nv)
end

function ClientPetsComponent:refreshParticularEffectVisible()
	if self:isControllingPet() then
		if pg.pawn then
			pg.global.effectMgr:SetControllingPetId(pg.pawn.templateId)
		end
	else
		pg.global.effectMgr:SetControllingPetId(-1)
	end
end

function ClientPetsComponent:setInLinkAnim(isInLinkAnim)
	self.isInLinkAnim = isInLinkAnim

	local petEnt = self:getCurPetEntity()

	if petEnt then
		petEnt:postComponentMethod("EVENT_MergedFormPeripheralStateChange")
	end
end

function ClientPetsComponent:onIsUsingExtraTempPet(old, new)
	facade:sendMsgToUI(MessageName.ROGUE_EXTRA_TEMP_PET_STATE_CHANGE)

	if self.updateStateCache then
		self:updateStateCache("EXTRA_TEMP_PET_ST")
	end
end

function ClientPetsComponent:onForceControlChanged(old, new)
	if self.updateStateCache then
		self:updateStateCache("FORCE_CONTROL_ST")
	end
end

function ClientPetsComponent:onPetTeamTypeChanged(old, new)
	if self.updateStateCache then
		self:updateStateCache("TMP_PET_TEAM_ST")
	end
end

function ClientPetsComponent:onCarryObjIdChanged(old, new)
	if self.updateStateCache then
		self:updateStateCache("HUG_ENT_ST")
	end
end

function ClientPetsComponent:SetInSwitchFlying(isInSwitchFlying)
	self.isInSwitchFlying = isInSwitchFlying
end

function ClientPetsComponent:givePetToSpaceFollower(petId, followerUid)
	if not self:isInTeam() or not self:isUidTeamMember(followerUid) then
		return
	end

	if not self.space or not self.space.canSpaceFollow or not self.space:canSpaceFollow() then
		return
	end

	local petInfo = self:getPetInfo(petId)
	local pedd = Utils.getGivePetConfig(petInfo)
	local friendshipLevel = pg.game.chat:getFriendship(followerUid)

	if not self:checkGivePetCanRemove(petInfo, pedd, friendshipLevel) then
		return
	end

	self:serverMsg("RPC_CS_GivePetToSpaceFollower", petId, followerUid)
end

function ClientPetsComponent:checkGivePetCanRemove(petInfo, pedd, friendshipLevel)
	local canGive, errorCode = Utils.checkGiveRemovePet(self, petInfo, friendshipLevel, pedd)

	if canGive then
		return true
	end

	if errorCode == Const.FollowGivePetError.EPRR_LIMIT_EXCEED then
		self:showGivePetLimitExceededTip(petInfo, pedd, friendshipLevel)

		return false
	end

	local textKey = Const.FollowGivePetNotify[errorCode]

	pg.global.showBubbleMessageRaw(pg.getGameString(textKey), 2)

	return false
end

function ClientPetsComponent:showGivePetLimitExceededTip(petInfo, pedd, friendshipLevel)
	local tip, isCredentialLimit = PetFriendTradeTextUtils.getGiveLimitExceededTip(self.useLimitMap, petInfo, pedd, friendshipLevel, not petInfo:isCatchReporting())

	if isCredentialLimit then
		pg.global.ui.tips:showTextTip(tip)
	else
		pg.global.showBubbleMessageRaw(tip, 2)
	end
end

function ClientPetsComponent:RPC_SC_GivePetToSpaceFollowerRet(retInfo)
	print("RPC_SC_GivePetToSpaceFollowerRet: ", inspect(retInfo))
	pg.global.showBubbleMessageRaw(pg.getGameString(Const.FollowGivePetNotify[retInfo.err]), 2)
	facade:SendMessageCommand(MessageName.ON_GIVE_PET, retInfo and retInfo.err)
end

function ClientPetsComponent:onPetPrepareListAdd(key, petId)
	local petEntity = pg.getEntity(petId)

	if petEntity and petEntity.abilityCompInitTriggerDone then
		ClientAbilityUtils.preloadAllAbility(petEntity)
	end
end

function ClientPetsComponent:onPetPrepareListChanged(oldList, newList)
	for _, petId in ipairs(newList) do
		if not Lume.find(oldList, petId) then
			local petEntity = pg.getEntity(petId)

			if petEntity and petEntity.abilityCompInitTriggerDone then
				ClientAbilityUtils.preloadAllAbility(petEntity)
			end
		end
	end

	self:refreshHasUltimatePetInPrepareList(newList)
end

return ClientPetsComponent
