-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Social\\Component\\InteractGestureComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local AppearanceAction = require("Data.appearance_action_data")
local AppearanceSuitData = require("Data.appearance_suit_data")
local ItemData = require("Data.item_data")
local FriendshipLevelFuncData = require("Data.friendship_level_func_data")
local InteractGestureFuncData = require("Data.interact_gesture_func_data")
local HomeObjectData = require("Data.home_object_data")
local HoldEntData = require("Data.hold_ent_data")
local HoldEntPanelConfig = require("Data.hold_ent_panel_config_data")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local TimerManager = require("Core.Timer.TimerManager")
local PlayableConst = require("Common.Const.PlayableConst")
local AutoPathFindUtils = require("Common.Utils.AutoPathFindUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientUtils = require("Utils.ClientUtils")
local HandheldAppearanceUtils = require("Utils.HandheldAppearanceUtils")
local ResLoader = require("GameApp.ResLoad.ResLoader")
local AddressDataConst = require("Const.AddressDataConst")
local NoticeDef = require("Common.NoticeDef")
local BuffConfigData = require("Data.buff_config_data")
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local MessageName = require("Const.MessageName")
local AudioConst = require("Const.AudioConst")
local GameObject = CS.UnityEngine.GameObject
local Object = CS.UnityEngine.Object
local UIUtils = CS.FunPlus.WorldX.Utils.UIUtils
local InteractData = require("Data.interact_data")
local RedDotConst = require("Const.RedDotConst")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local AIUtils = require("Common.Utils.AIUtils")
local AiConst = require("Common.Const.AiConst")
local MultiPetFollowStateMachine = require("GameApp.Social.Component.MultiPetFollowStateMachine")
local MultiPetFollowPresentation = require("GameApp.Social.Component.MultiPetFollowPresentation")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local PetProtoTypeData = require("Data.pet_prototype_data")
local InteractGestureComponent = Class.LiteClass("InteractGestureComponent")

InteractGestureComponent.MULTI_PET_FOLLOW_DISTANCE = 0.65
InteractGestureComponent.LITTLE_FIRE_PERSON_ACTION_ID = 801901

function InteractGestureComponent:playEndAnim(ent, endAnim)
	if not ent then
		return
	end

	if ent.eModel then
		ent.eModel.InSocialAnim = false
	end

	if not endAnim or endAnim == 0 then
		AnimationUtils.stopLayerAnimation(ent, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)

		return
	end

	local state = ent:playAnimation(endAnim, true, nil, false, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)

	if state then
		state:AddAutoTransition(0)
	end
end

InteractGestureComponent.InteractPlayType = {
	FaceTarget = 2,
	Direct = 1,
	Event = 3
}
InteractGestureComponent.InteractionAnimationType = {
	MultiDanceSyncAnimation = 12,
	MultiDance = 11,
	HumanPetInteract = 3,
	SimpleInteract = 2,
	Single = 1,
	None = 0,
	LieOnLeg = 22,
	Lie = 21
}
InteractGestureComponent.AppearanceObjectType = {
	Single = 0,
	Pet = 1
}
InteractGestureComponent.InteractGestureCacheKey = "InteractGestureCacheKey"
InteractGestureComponent.TOUCH_PET_SELF_ANIM = "TouchPet"
InteractGestureComponent.TOUCH_PET_TARGET_ANIM = "Idle"

function InteractGestureComponent:ctor()
	self:stopSelectPlayer()

	self.curInteractionSession = nil
	self.curInteractionSessionUid = nil
	self.singleInteractionSessions = {}
	self.activeFriendInteractions = {}
	self.multiInteractionSessions = {}
	self.lieOnLegAbsorbedEntities = {}
	self.recommendTimer = nil
	self.multiPetFollowCreatorUid = nil
	self.multiPetFollowMemberIndex = nil
	self.multiPetFollowTargetUid = nil
	self.multiPetFollowPawn = nil
	self.multiPetFollowStateMachine = nil
	self.appearanceActionPetPauses = {}
	self.pendingTouchPetRequest = nil
	self.multiPetFollowPresentation = MultiPetFollowPresentation.new(self.MULTI_PET_FOLLOW_DISTANCE)
	self.interactionAnimationManager = appFacade and appFacade.interactionAnimationManager or nil
end

function InteractGestureComponent:resetData()
	self:resumeAllAppearanceActionPets()
	self:detachMultiPetFollowTarget()
	self:clearMultiPetFollowPresentation()

	self.curInteractionSession = nil
	self.curInteractionSessionUid = nil
	self.singleInteractionSessions = {}
	self.activeFriendInteractions = {}
	self.multiInteractionSessions = {}
	self.lieOnLegAbsorbedEntities = {}
	self.recommendTimer = nil
	self.appearanceActionPetPauses = {}

	self:consumePendingTouchPetRequest()
end

function InteractGestureComponent:destroy()
	self:resumeAllAppearanceActionPets()
	self:detachMultiPetFollowTarget()
	self:clearMultiPetFollowPresentation()

	self.multiPetFollowPresentation = nil
	self.curInteractionSession = nil
	self.curInteractionSessionUid = nil
	self.singleInteractionSessions = {}

	self:stopInteractionSound()
	self:stopSelectPlayer()

	self.activeFriendInteractions = {}
	self.multiInteractionSessions = {}
	self.lieOnLegAbsorbedEntities = {}
	self.pendingDeformList = nil
	self.appearanceActionPetPauses = {}

	self:consumePendingTouchPetRequest()

	if self.recommendTimer then
		TimerManager.removeTimer(self.recommendTimer)

		self.recommendTimer = nil
	end
end

function InteractGestureComponent:tick()
	if not self.startTickAround or not pg.me then
		return
	end

	local pos = pg.me:getPosition()
	local findTarget = false

	if self.positionRecord and self:calculateSquaredDistance(pos, self.positionRecord) <= 0.0001 then
		return
	else
		self.positionRecord = Vector3.New(pos.x, pos.y, pos.z)
		findTarget = true
	end

	if not findTarget then
		return
	end

	local nearestEnt
	local minDistanceSquared = math.maxFloat
	local playerEnts = pg.me:entitiesInRange(5, Const.SEARCH_USR_TYPE_PLAYER, 0)
	local petEnts = pg.me:entitiesInRange(5, Const.SEARCH_USR_TYPE_PET, 0)

	for _, tActorId in ipairs(playerEnts) do
		local ent = pg.getEntityByActorId(tActorId)

		if not Utils.isPlayerGhost(ent) and not ent:CONTROLLING_PET_ST() then
			local _ex, _ey, _ez = ent.eModel:GetPositionAgentPosEx()
			local dist = self:calculateSquaredDistance(pg.me:getPosition(), Vector3.New(_ex, _ey, _ez))

			if dist < minDistanceSquared then
				minDistanceSquared = dist
				nearestEnt = ent
			end
		end
	end

	for _, tActorId in ipairs(petEnts) do
		local ent = pg.getEntityByActorId(tActorId)

		if ent:CONTROLLING_PET_ST() and ent.masterId ~= pg.me.id then
			local _ex, _ey, _ez = ent.eModel:GetPositionAgentPosEx()
			local dist = self:calculateSquaredDistance(pg.me:getPosition(), Vector3.New(_ex, _ey, _ez))

			if dist < minDistanceSquared then
				minDistanceSquared = dist
				nearestEnt = ent
			end
		end
	end

	if self.nearestEntRecord ~= nearestEnt then
		if self.nearestEntRecord then
			self.nearestEntRecord:executeTopLogoComponentMethod(UIConst.TOPLOGO_COMPONENT.SOCIAL, "refreshSelectFrame", {
				show = false
			})
		end

		if nearestEnt then
			nearestEnt:ensureAndExecuteTplComMethod(UIConst.TOPLOGO_COMPONENT.SOCIAL, "refreshSelectFrame", {
				show = true
			})
		end

		self.nearestEntRecord = nearestEnt

		if self.nearestEntRecord then
			facade:SendMessageCommand(MessageName.GESTURE_TARGET_CHANGE, {
				playerId = self.nearestEntRecord:CONTROLLING_PET_ST() and self.nearestEntRecord.master.uid or self.nearestEntRecord.uid
			})
		else
			facade:SendMessageCommand(MessageName.GESTURE_TARGET_CHANGE, {})
		end
	end
end

function InteractGestureComponent:stopInteractionSound()
	if self.curInteractionActionSound and pg.me then
		pg.me:stopSoundEvent(self.curInteractionActionSound)

		self.curInteractionActionSound = nil
	end
end

function InteractGestureComponent:playInteractionSound(actionSound)
	if not actionSound or not pg.me then
		return
	end

	pg.me:playSoundEvent(actionSound)

	self.curInteractionActionSound = actionSound
end

function InteractGestureComponent:calculateSquaredDistance(posA, posB)
	local dx = posA.x - posB.x
	local dy = posA.y - posB.y
	local dz = posA.z - posB.z

	return dx * dx + dy * dy + dz * dz
end

function InteractGestureComponent:getEntityKey(ent)
	return ent and (ent.uid and ent.uid ~= "" and ent.uid or ent.id)
end

function InteractGestureComponent:isLieOnLegAbsorbed(ent)
	local key = self:getEntityKey(ent)

	return key and self.lieOnLegAbsorbedEntities and self.lieOnLegAbsorbedEntities[key]
end

function InteractGestureComponent:setLieOnLegAbsorbed(session, ent, targetEnt)
	self.lieOnLegAbsorbedEntities[self:getEntityKey(ent)] = session
	self.lieOnLegAbsorbedEntities[self:getEntityKey(targetEnt)] = session
end

function InteractGestureComponent:clearLieOnLegAbsorbed(session, ent, targetEnt)
	for _, target in ipairs({
		ent,
		targetEnt
	}) do
		local key = self:getEntityKey(target)

		if key and self.lieOnLegAbsorbedEntities[key] == session then
			self.lieOnLegAbsorbedEntities[key] = nil
		end
	end
end

function InteractGestureComponent:findLieOnLegTarget(ent, actionState)
	if not ent then
		return
	end

	local entKey = self:getEntityKey(ent)
	local entPos = ent:getPosition()
	local nearestEnt, minDist = nil, math.maxFloat

	for _, actorId in ipairs(ent:entitiesInRange(2, Const.SEARCH_USR_TYPE_PLAYER, 0)) do
		local targetEnt = pg.getEntityByActorId(actorId)
		local targetKey = self:getEntityKey(targetEnt)

		if targetKey and targetKey ~= entKey and not Utils.isPlayerGhost(targetEnt) and targetEnt.singleActionState == actionState and not self:isLieOnLegAbsorbed(targetEnt) then
			local dist = self:calculateSquaredDistance(entPos, targetEnt:getPosition())

			if dist < minDist then
				minDist = dist
				nearestEnt = targetEnt
			end
		end
	end

	return nearestEnt
end

function InteractGestureComponent:compareGestureOrder(a, b)
	local interactOrderA = a.interactOrder
	local interactOrderB = b.interactOrder

	if interactOrderA ~= nil and interactOrderB ~= nil and interactOrderA ~= interactOrderB then
		return interactOrderB < interactOrderA
	end

	local sortIdA = a.sortId
	local sortIdB = b.sortId

	if sortIdA ~= nil and sortIdB ~= nil and sortIdA ~= sortIdB then
		return sortIdA < sortIdB
	end

	if interactOrderA ~= nil and interactOrderB == nil then
		return true
	end

	if interactOrderA == nil and interactOrderB ~= nil then
		return false
	end

	if sortIdA ~= nil and sortIdB == nil then
		return true
	end

	if sortIdA == nil and sortIdB ~= nil then
		return false
	end

	return (a.index or 0) < (b.index or 0)
end

function InteractGestureComponent:isActionUnlocked(data, actionShowIds)
	if not data then
		return false
	end

	local handheldActionState = HandheldAppearanceUtils.canUseAction(pg.me, data.index)

	if handheldActionState ~= nil then
		return handheldActionState
	end

	if data.homeTemplateId then
		return pg.me:getItemCountById(data.homeTemplateId) > 0
	end

	if data.initialClaim == 1 then
		return true
	end

	actionShowIds = actionShowIds or pg.me and pg.me.actionShowIds

	return actionShowIds and actionShowIds[data.index] or false
end

function InteractGestureComponent:isLittleFirePersonGuideOpen(player)
	if not ActivityUtils.curArenaIsActivateOpen(ActivityConst.EventType.LittleFirePerson) then
		return false
	end

	local isOpen = ActivityUtils.isOprActivityOpenByType(ActivityConst.EventType.LittleFirePerson, player)

	return isOpen
end

function InteractGestureComponent:canShowGestureData(data)
	if data and data.index == self.LITTLE_FIRE_PERSON_ACTION_ID then
		return self:isLittleFirePersonGuideOpen(pg.me)
	end

	return true
end

function InteractGestureComponent:isFriendActionPermissionUnlocked(data, friendId)
	for permissionId, funcData in ipairs(FriendshipLevelFuncData) do
		local isActionPermission = funcData.type == Const.FriendshipPermissionType.Action
		local isCurrentAction = funcData.value == data.index

		if isActionPermission and isCurrentAction then
			return pg.game.chat:isFriendshipPermissionUnlocked(friendId, permissionId)
		end
	end

	return true
end

function InteractGestureComponent:getAppearanceSuitActionQuality()
	local suitId = pg.me and pg.me.curShow and pg.me.curShow.suitId or 0
	local suitData = AppearanceSuitData[suitId]

	if suitId <= 0 or not suitData or not suitData.action or #suitData.action <= 0 then
		return 0
	end

	return math.max(ItemData[suitId] and ItemData[suitId].quality or 0, 4)
end

function InteractGestureComponent:getGestureDatas()
	local t = {}
	local preset = pg.me and pg.game.avatar:getAvatarPresetData(pg.game.avatar:getPresetKey(pg.me))
	local appearanceActionVisibility = require("Utils.HandheldAppearanceUIUtils").buildActionVisibility(require("Data.appearance_data"), require("Data.appearance_point_data"), preset and preset.body, AppearanceAction)
	local appearanceActionIds = {}
	local curShow = pg.me and pg.me.curShow
	local suitData = curShow and AppearanceSuitData[curShow.suitId]

	for _, actionId in ipairs(suitData and suitData.action or {}) do
		appearanceActionIds[actionId] = true
	end

	for interactAction, groupInfo in pairs(InteractGestureFuncData) do
		local labelInfo = groupInfo.label or {}
		local gestureGroup = {
			label = pg.getLocalizationText(labelInfo.name),
			actions = {}
		}

		for _, gestureInfo in pairs(groupInfo.actions or EMPTY_TABLE) do
			local info = {}

			for key, value in pairs(gestureInfo) do
				info[key] = value
			end

			if self:canShowGestureData(info) and appearanceActionVisibility[info.index] ~= false and (interactAction ~= Const.APPEARANCE_ACTION_TYPE.Appearance or appearanceActionIds[info.index]) then
				info.name = pg.getLocalizationText(info.name)
				gestureGroup.actions[#gestureGroup.actions + 1] = info
			end
		end

		t[interactAction] = gestureGroup
	end

	local actionShowIds = pg.me and pg.me.actionShowIds

	for _, gestureGroup in pairs(t) do
		table.sort(gestureGroup.actions, function(a, b)
			local unlockedA = self:isActionUnlocked(a, actionShowIds) and 1 or 0
			local unlockedB = self:isActionUnlocked(b, actionShowIds) and 1 or 0

			if unlockedB < unlockedA then
				return true
			elseif unlockedA < unlockedB then
				return false
			end

			return self:compareGestureOrder(a, b)
		end)
	end

	return t
end

function InteractGestureComponent:getActionCost(gestureData)
	local costItemId = gestureData and gestureData.costItemId and gestureData.costItemId[1]
	local costItemNum = gestureData and gestureData.costItemId and gestureData.costItemId[2]

	return costItemId, costItemNum
end

function InteractGestureComponent:isActionCostEnough(gestureData)
	local costItemId, costItemNum = self:getActionCost(gestureData)

	if costItemId == nil or costItemNum == nil then
		return true
	end

	if pg.me == nil or type(pg.me.getItemCountById) ~= "function" then
		return true
	end

	return costItemNum <= (pg.me:getItemCountById(costItemId) or 0)
end

function InteractGestureComponent:getTargetEnt()
	return self.nearestEntRecord
end

function InteractGestureComponent:handleActionPlayed(data, isRecommend)
	local ent = pg.me:isControllingPet() and pg.me:getCurPetEntity() or pg.me

	if not CharacterStateConst.isChildOfState(ent.characterState, CharacterStateConst.LOCOMOTION) and not pg.me.eModel.InSocialAnim then
		pg.global.showBubbleMessageRaw(pg.getGameString("FUNCTION_CANT_STATE"))

		return
	end

	if data.interactAction == Const.APPEARANCE_ACTION_TYPE.Furniture or data.interactAction == Const.APPEARANCE_ACTION_TYPE.Vehicle then
		pg.game.home:placeWorldFurniture(data.homeTemplateId, data.placeFurnitureDistance)
	elseif data.interactAction == Const.APPEARANCE_ACTION_TYPE.Single then
		self:playSingleAction(data, isRecommend)
	elseif data.interactAction == Const.APPEARANCE_ACTION_TYPE.Double then
		self:playTargetAction(data, isRecommend)
	elseif data.interactAction == Const.APPEARANCE_ACTION_TYPE.Multi then
		self:playMultiAction(data, isRecommend)
	elseif data.interactAction == Const.APPEARANCE_ACTION_TYPE.Emotion then
		self:playEmotionAction(data, isRecommend)
	elseif data.interactAction == Const.APPEARANCE_ACTION_TYPE.Appearance then
		self:playAppearanceAction(data, isRecommend)
	end
end

function InteractGestureComponent:playSingleAction(data, isRecommend)
	local function play()
		if data.playType == self.InteractPlayType.Event then
			pg.me:doEventByData({
				data.eventName
			})
		else
			pg.me:serverMsg("RPC_CS_PlayAppearanceAction", data.index, "", isRecommend ~= nil and true or false)
			pg.me:playSingleAction(data.index)
		end
	end

	if pg.me:isControllingPet() and not pg.pawn.isForceControlPet then
		pg.me:requestSwitchToPlayer(Const.CLIENT_SWITCH_REASON.Default, nil, function()
			play()
		end)
	else
		play()
	end
end

function InteractGestureComponent:isPetAppearanceAction(data)
	return data ~= nil and data.objectType == self.AppearanceObjectType.Pet
end

function InteractGestureComponent:getAppearanceActionPetEntity(data, ownerEnt)
	ownerEnt = ownerEnt or pg.me

	if not ownerEnt or not ownerEnt.getCurPetEntity then
		return nil
	end

	local petEnt = ownerEnt:getCurPetEntity()

	if not petEnt then
		return nil
	end

	local petPrototypeId = petEnt.petPrototypeId

	if not petPrototypeId or not table.contains(data.pet or {}, PetProtoTypeData[petPrototypeId].baseFormPet or petPrototypeId) then
		return nil
	end

	return petEnt
end

function InteractGestureComponent:playAppearanceAction(data, isRecommend)
	if self:isPetAppearanceAction(data) and not self:getAppearanceActionPetEntity(data) then
		local petName = Utils.isTable(data.pet) and PetProtoTypeData[data.pet[1]].name or ""

		pg.global.showBubbleMessageRaw(pg.getFormatText(pg.getGameString("APPEARANCE_ACTION_PET_INVALID"), pg.getLocalizationText(petName)))

		return
	end

	self:playSingleAction(data, isRecommend)
end

function InteractGestureComponent:pauseAppearanceActionPet(ownerEnt, petEnt)
	local key = self:getEntityKey(ownerEnt)

	if not key or not petEnt then
		return
	end

	local pauses = self.appearanceActionPetPauses

	if not pauses then
		pauses = {}
		self.appearanceActionPetPauses = pauses
	end

	pauses[key] = petEnt.id

	AIUtils.PauseAI(petEnt.id, AiConst.PauseBtReason.TouchPet)
end

function InteractGestureComponent:resumeAppearanceActionPet(ownerEnt)
	local key = self:getEntityKey(ownerEnt)
	local pauses = self.appearanceActionPetPauses
	local petEntId = key and pauses and pauses[key]

	if not petEntId then
		return
	end

	pauses[key] = nil

	AIUtils.ResumeAI(petEntId, AiConst.PauseBtReason.TouchPet)
end

function InteractGestureComponent:resumeAllAppearanceActionPets()
	local pauses = self.appearanceActionPetPauses

	self.appearanceActionPetPauses = {}

	if not pauses then
		return
	end

	for _, petEntId in pairs(pauses) do
		AIUtils.ResumeAI(petEntId, AiConst.PauseBtReason.TouchPet)
	end
end

function InteractGestureComponent:onSingleActionStateChanged(oldVal, newVal, ent, handheldToken)
	local entKey = ent ~= pg.me and self:getEntityKey(ent)
	local oldRecord = entKey and self.singleInteractionSessions[entKey]

	if oldRecord then
		local oldSession = oldRecord.session

		HandheldAppearanceUtils.stopForAction(ent, oldRecord.handheldAppearanceToken)

		oldSession.onComplete = nil
		oldSession.onInterrupt = nil

		self:cancelInteraction(oldSession, true)

		self.singleInteractionSessions[entKey] = nil
	end

	self:resumeAppearanceActionPet(ent)

	if newVal <= 0 then
		if ent == pg.me and self.curInteractionSession then
			self:cancelInteraction(self.curInteractionSession)
		elseif oldVal and ent ~= pg.me then
			local data = AppearanceAction[oldVal]
			local endAnim = data.res1 and data.res1[3] and self:getPlayableKey(data.res1[3])

			self:playEndAnim(ent, endAnim)
		end

		return
	end

	local data = AppearanceAction[newVal]

	if not data then
		HandheldAppearanceUtils.stopForAction(ent, handheldToken)

		return
	end

	local isPetAppearance = self:isPetAppearanceAction(data)
	local petEnt = isPetAppearance and self:getAppearanceActionPetEntity(data, ent) or nil

	if isPetAppearance and not petEnt then
		HandheldAppearanceUtils.stopForAction(ent, handheldToken)

		return
	end

	local sessionRecord, session

	local function onComplete()
		HandheldAppearanceUtils.stopForAction(ent, handheldToken)

		local isCurrentSession = entKey and self.singleInteractionSessions[entKey] == sessionRecord or not entKey and self.curInteractionSession == session

		if not isCurrentSession then
			return
		end

		if entKey then
			self.singleInteractionSessions[entKey] = nil
		end

		local endAnim = data.res1 and data.res1[3] and self:getPlayableKey(data.res1[3])

		self:playEndAnim(ent, endAnim)

		if petEnt then
			self:resumeAppearanceActionPet(ent)

			local petEndAnim = data.res2 and data.res2[3] and self:getPlayableKey(data.res2[3])

			self:playEndAnim(petEnt, petEndAnim)
		end
	end

	local isLieOnLeg = data.animParams and data.animParams[1] and data.animParams[1][1] == self.InteractionAnimationType.LieOnLeg
	local targetEnt = petEnt or isLieOnLeg and (self:findLieOnLegTarget(ent, newVal) or ent) or nil
	local isDoubleLieOnLeg = isLieOnLeg and targetEnt ~= ent

	session = self:getInteractionSession(data, ent, targetEnt, onComplete, nil, isLieOnLeg and not isDoubleLieOnLeg and self.InteractionAnimationType.Lie or nil)
	sessionRecord = {
		session = session,
		handheldAppearanceToken = handheldToken
	}

	local handheldLoop = HandheldAppearanceUtils.getLoop(ent, newVal)

	if handheldLoop == 1 then
		session.selfAnimLoopKey = session.selfAnimKey
	elseif handheldLoop == 0 then
		session.selfAnimLoopKey = 0
	end

	if isDoubleLieOnLeg then
		function session.onComplete(uid)
			onComplete()
			self:clearLieOnLegAbsorbed(session, ent, targetEnt)
		end

		function session.onInterrupt(uid)
			onComplete()
			self:clearLieOnLegAbsorbed(session, ent, targetEnt)
		end
	end

	local checkPass = self:queryCanInteract(session, petEnt and session.type or self.InteractionAnimationType.Single)

	if not checkPass then
		HandheldAppearanceUtils.stopForAction(ent, handheldToken)
		self:cancelInteraction(session)

		if ent == pg.me then
			pg.me:playSingleAction(0)
		end

		return
	end

	if petEnt then
		self:pauseAppearanceActionPet(ent, petEnt)
	end

	local started = self:startInteraction(data.actionSound, session, ent == pg.me)

	if not started then
		HandheldAppearanceUtils.stopForAction(ent, handheldToken)
	end

	if petEnt and not started then
		self:resumeAppearanceActionPet(ent)
	end

	if entKey and started then
		self.singleInteractionSessions[entKey] = sessionRecord
	end

	if isDoubleLieOnLeg and started then
		self:setLieOnLegAbsorbed(session, ent, targetEnt)
	end
end

function InteractGestureComponent:getPlayableKey(animName)
	if string.isNilOrEmpty(animName) then
		return 0
	end

	return PlayableConst[animName] or 0
end

function InteractGestureComponent:getInteractionEntity(ent)
	if not ent then
		return nil
	end

	if ent.eModel then
		return ent.eModel
	end

	return ent
end

function InteractGestureComponent:getTouchPetTemplateId(ent)
	if not ent then
		return nil
	end

	if ent.petInfo and ent.petInfo.templateId then
		return ent.petInfo.templateId
	end

	return ent.templateId
end

function InteractGestureComponent:getTouchPetParameter(targetEntity)
	local templateId = self:getTouchPetTemplateId(targetEntity)
	local configData = templateId and HoldEntData[templateId] or nil

	if not Utils.tableIsEmptyOrNil(configData) and not Utils.tableIsEmptyOrNil(configData.touchpetParameter) then
		return configData.touchpetParameter
	end

	return HoldEntPanelConfig.petTouchDefaultParameter
end

function InteractGestureComponent:getTouchPetInteractionSession(selfEntity, targetEntity, onComplete)
	local parameter = self:getTouchPetParameter(targetEntity)

	if not parameter then
		return nil
	end

	local interactionType = tonumber(parameter[1]) or self.InteractionAnimationType.HumanPetInteract

	if interactionType == self.InteractionAnimationType.None then
		interactionType = self.InteractionAnimationType.HumanPetInteract
	end

	local session = self.interactionAnimationManager:AcquireSetupSession(interactionType)

	if not session then
		return nil
	end

	local selfPos = parameter[4]
	local targetPos = parameter[5]

	session.self = self:getInteractionEntity(selfEntity)
	session.target = self:getInteractionEntity(targetEntity)
	session.selfAnimKey = self:getPlayableKey(self.TOUCH_PET_SELF_ANIM)
	session.selfAnimLoopKey = 0
	session.targetAnimKey = self:getPlayableKey(self.TOUCH_PET_TARGET_ANIM)
	session.targetAnimLoopKey = 0
	session.anchorWidth = tonumber(parameter[2]) or 0
	session.anchorLength = tonumber(parameter[3]) or 0
	session.selfPosX = selfPos and tonumber(selfPos[1]) or 0
	session.selfPosZ = selfPos and tonumber(selfPos[2]) or 0
	session.selfYaw = selfPos and tonumber(selfPos[3]) or 0
	session.targetPosX = targetPos and tonumber(targetPos[1]) or 0
	session.targetPosZ = targetPos and tonumber(targetPos[2]) or 0
	session.targetYaw = targetPos and tonumber(targetPos[3]) or 0

	local function finishFunc(uid, isComplete)
		if onComplete then
			onComplete(uid, isComplete)
		end

		self:clearCurrentInteractionSession(session, uid)
	end

	function session.onComplete(uid)
		finishFunc(uid, true)
	end

	function session.onInterrupt(uid)
		finishFunc(uid, false)
	end

	self.interactionAnimationManager:SetupWorldSpaceConfig(session)

	return session
end

function InteractGestureComponent:consumePendingTouchPetRequest(expectedRequest)
	local pendingRequest = self.pendingTouchPetRequest

	if not pendingRequest or expectedRequest and pendingRequest ~= expectedRequest then
		return nil
	end

	self.pendingTouchPetRequest = nil

	if pendingRequest.timeoutTimer then
		TimerManager.removeTimer(pendingRequest.timeoutTimer)

		pendingRequest.timeoutTimer = nil
	end

	return pendingRequest
end

function InteractGestureComponent:isTouchPetInteractionPending(targetEntityId)
	local request = self.pendingTouchPetRequest

	return request ~= nil and request.targetEntityId == targetEntityId
end

function InteractGestureComponent:requestTouchPetInteraction(selfEntity, targetEntity, onInteractionFinished, onHappyFinished)
	local targetEntityId = targetEntity and targetEntity.id

	if not selfEntity or not selfEntity.isMainPlayer or not targetEntityId or self.pendingTouchPetRequest or self:checkInteractGesturePlaying() then
		return false
	end

	if selfEntity.onVehicleActorId > 0 then
		pg.pawn:dismountSelf()
	end

	local request = {
		targetEntityId = targetEntityId,
		onInteractionFinished = onInteractionFinished,
		onHappyFinished = onHappyFinished
	}

	self.pendingTouchPetRequest = request
	request.timeoutTimer = TimerManager.addTimer(10, function()
		request.timeoutTimer = nil

		self:consumePendingTouchPetRequest(request)
	end)

	selfEntity:tryStrokeCarryPet(targetEntityId, function(noticeId)
		if noticeId ~= NoticeDef.SUCCESS then
			self:consumePendingTouchPetRequest(request)
		end
	end)

	return true
end

function InteractGestureComponent:playTouchPetInteraction(selfEntity, targetEntity)
	local targetEntityId = targetEntity and targetEntity.id or nil
	local onInteractionFinished, onHappyFinished
	local pendingRequest = self.pendingTouchPetRequest

	if selfEntity and selfEntity.isMainPlayer and pendingRequest and pendingRequest.targetEntityId == targetEntityId then
		pendingRequest = self:consumePendingTouchPetRequest()
		onInteractionFinished = pendingRequest.onInteractionFinished
		onHappyFinished = pendingRequest.onHappyFinished
	end

	local effectId
	local session = self:getTouchPetInteractionSession(selfEntity, targetEntity, function(_, isComplete)
		if ToBool(effectId) then
			targetEntity:stopEffectById(effectId)

			effectId = nil
		end

		AnimationUtils.stopLayerAnimation(selfEntity, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
		AnimationUtils.stopLayerAnimation(targetEntity, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)

		if onInteractionFinished then
			onInteractionFinished(isComplete)
		end

		if isComplete then
			local state = targetEntity:playAnimation(PlayableConst.Behav_HappyLoop, true, nil, false)

			if state then
				state:AddAutoTransition(0)
				state:AddEndCallback(function()
					if onHappyFinished then
						onHappyFinished(true)
					end

					AIUtils.ResumeAI(targetEntityId, AiConst.PauseBtReason.TouchPet)

					local petEntity = pg.getEntity(targetEntityId)

					if petEntity and Utils.isHomePet(petEntity) then
						petEntity:postComponentMethod("onHomelandAIPlanChanged")
					end
				end)

				return
			end
		end

		if onHappyFinished then
			onHappyFinished(isComplete)
		end

		AIUtils.ResumeAI(targetEntityId, AiConst.PauseBtReason.TouchPet)

		local petEntity = pg.getEntity(targetEntityId)

		if petEntity and Utils.isHomePet(petEntity) then
			petEntity:postComponentMethod("onHomelandAIPlanChanged")
		end
	end)

	if not session then
		return false
	end

	local checkPass = self:queryCanInteract(session, session.type)

	if not checkPass then
		self:cancelInteraction(session)

		return false
	end

	AIUtils.PauseAI(targetEntityId, AiConst.PauseBtReason.TouchPet)

	local started = self:startInteraction(nil, session, session.self == self:getInteractionEntity(pg.me))

	if not started then
		AIUtils.ResumeAI(targetEntityId, AiConst.PauseBtReason.TouchPet)
	else
		effectId = targetEntity:playEffect("Eff_Common_Behav_Love")

		local audioEmitter = targetEntity.eModel and targetEntity.eModel.audioEmitter or nil

		pg.game.audio:playPetEmotionSound(self:getTouchPetTemplateId(targetEntity), "Happy", audioEmitter)
	end

	return started
end

function InteractGestureComponent:queryCanInteract(session, sessionType)
	local isSelf = session.self == self:getInteractionEntity(pg.me)
	local canInteract = self.interactionAnimationManager:QueryCanInteract(session)

	if not canInteract then
		if isSelf then
			pg.global.showBubbleMessageRaw(pg.getGameString("INTERACT_ANIMATION_CHECK_FAILED"))
		end

		return false
	end

	local selfPoint = self.interactionAnimationManager:QuerySelfSessionPoint(session)
	local canReachPoint = not isSelf or AutoPathFindUtils.findPathToPos(pg.me, selfPoint.x, selfPoint.y, selfPoint.z, nil, AutoPathFindUtils.PathFindType.Voxel)

	if sessionType ~= self.InteractionAnimationType.Single and not canReachPoint then
		pg.global.showBubbleMessageRaw(pg.getGameString("INTERACT_ANIMATION_CANT_REACH_POINT"))

		return false
	end

	return true
end

function InteractGestureComponent:playTargetAction(data, isRecommend)
	local target = self.nearestEntRecord

	if target then
		local uid = target:CONTROLLING_PET_ST() and target.master.uid or target.uid

		if data.friendshipLevel and pg.game.chat:getFriendship(uid) < data.friendshipLevel then
			pg.global.showBubbleMessage(NoticeDef.FRIEND_INTIMACY_NOT_ENOUGH)
		elseif not self:isFriendActionPermissionUnlocked(data, uid) then
			pg.global.showBubbleMessage(NoticeDef.INTERACT_ACTION_LOCKED)
		else
			local previewActionData = self:getGenderMatchedFriendActionData(data, pg.me, target)
			local previewCheckSession = self:getInteractionSession(previewActionData, pg.me, target)
			local checkPass = self:queryCanInteract(previewCheckSession)

			self:cancelInteraction(previewCheckSession)

			if not checkPass then
				self:stopSelectPlayer()

				return
			end

			self:requestFriendAction(target, data, not data.needTargetAgree)
		end
	else
		pg.global.showBubbleMessageRaw(pg.getGameString("ACTION_NO_TARGET_TOAST"))
	end

	self:stopSelectPlayer()
end

function InteractGestureComponent:playMultiAction(data, isRecommend)
	if pg.me:isControllingPet() and not pg.pawn.isForceControlPet then
		pg.me:requestSwitchToPlayer(Const.CLIENT_SWITCH_REASON.Default, nil, function()
			pg.me:playMultiAction(data.index)
		end)
	else
		pg.me:playMultiAction(data.index)
	end
end

function InteractGestureComponent:playEmotionAction(data, isRecommend)
	pg.me:setActionState(data.index)
end

function InteractGestureComponent:getInteractionSession(data, selfEntity, targetEntity, onComplete, posIndex, forceType)
	posIndex = posIndex == nil and 1 or posIndex

	local initialType = self.InteractionAnimationType.SimpleInteract

	if data.interactAction == Const.APPEARANCE_ACTION_TYPE.Single or data.interactAction == Const.APPEARANCE_ACTION_TYPE.Appearance and data.objectType ~= self.AppearanceObjectType.Pet then
		initialType = self.InteractionAnimationType.Single
	elseif data.interactAction == Const.APPEARANCE_ACTION_TYPE.Multi then
		initialType = self.InteractionAnimationType.MultiDance
	elseif data.objectType == self.AppearanceObjectType.Pet and targetEntity then
		initialType = self.InteractionAnimationType.HumanPetInteract
	end

	local animParams = {
		selfPosX = 0,
		anchorLength = 0,
		anchorWidth = 0,
		selfYaw = 0,
		selfPosZ = 0,
		type = initialType
	}

	if data.animParams then
		animParams.type = data.animParams[1][1]
		animParams.anchorWidth = data.animParams[1][2]
		animParams.anchorLength = data.animParams[1][3]

		local posParam = posIndex > 0 and data.animParams[posIndex + 1] or nil

		animParams.selfPosX = posParam and posParam[1] or 0
		animParams.selfPosZ = posParam and posParam[2] or 0
		animParams.selfYaw = posParam and posParam[3] or 0
	end

	local type = forceType or animParams.type
	local session = self.interactionAnimationManager:AcquireSetupSession(type)

	session.self = self:getInteractionEntity(selfEntity)
	session.target = self:getInteractionEntity(targetEntity)

	local selfAnim = data.res1
	local targetAnim = (not targetEntity or not data.res2) and data.res1 or data.res2

	session.selfAnimKey = self:getPlayableKey(selfAnim and selfAnim[1] or 0)
	session.selfAnimLoopKey = self:getPlayableKey(selfAnim and selfAnim[2] and selfAnim[2] or 0)
	session.targetAnimKey = self:getPlayableKey(targetAnim and targetAnim[1] or 0)
	session.targetAnimLoopKey = self:getPlayableKey(targetAnim and targetAnim[2] and targetAnim[2] or 0)

	if onComplete then
		local function completeFunc(uid)
			onComplete(uid)
			self:clearCurrentInteractionSession(session, uid)
		end

		session.onComplete = completeFunc
		session.onInterrupt = completeFunc
	end

	session.anchorWidth = animParams.anchorWidth
	session.anchorLength = animParams.anchorLength
	session.selfPosX = animParams.selfPosX
	session.selfPosZ = animParams.selfPosZ
	session.selfYaw = animParams.selfYaw
	session.targetPosX = 0
	session.targetPosZ = 0
	session.targetYaw = 0

	self.interactionAnimationManager:SetupWorldSpaceConfig(session)

	return session
end

function InteractGestureComponent:getGenderMatchedFriendActionData(actionData, invitorEnt, receiverEnt)
	local animParams = actionData and self:getGenderAnimParams(actionData.animParams, invitorEnt, receiverEnt)

	if not animParams then
		return actionData
	end

	local ret = {}

	for k, v in pairs(actionData) do
		ret[k] = v
	end

	ret.animParams = animParams

	return ret
end

function InteractGestureComponent:getFriendActionGenderCode(ent)
	if not ent then
		return nil
	end

	if ent.CONTROLLING_PET_ST and ent:CONTROLLING_PET_ST() and ent.master then
		ent = ent.master
	end

	if ent.templateId == 3 or ent.gender == Const.GENDER_TYPE_FEMALE then
		return 1
	elseif ent.templateId == 4 or ent.gender == Const.GENDER_TYPE_MALE then
		return 2
	end

	return nil
end

function InteractGestureComponent:isGenderGroupedAnimParams(animParams)
	if not Utils.isTable(animParams) or not Utils.isTable(animParams[1]) or not Utils.isTable(animParams[1][1]) then
		return false
	end

	return true
end

function InteractGestureComponent:getFriendActionGenderParamKey(invitorEnt, receiverEnt)
	local invitorGender = self:getFriendActionGenderCode(invitorEnt)
	local receiverGender = self:getFriendActionGenderCode(receiverEnt)

	if not invitorGender or not receiverGender then
		return nil
	end

	return invitorGender * 10 + receiverGender
end

function InteractGestureComponent:getGenderAnimParams(animParams, invitorEnt, receiverEnt)
	if not animParams then
		return nil
	end

	if not self:isGenderGroupedAnimParams(animParams) then
		return nil
	end

	local targetGenderParamKey = self:getFriendActionGenderParamKey(invitorEnt, receiverEnt)

	if not targetGenderParamKey then
		return nil
	end

	for _, groupAnimParams in ipairs(animParams) do
		local header = groupAnimParams[1]

		if Utils.isTable(header) and tonumber(header[4]) == targetGenderParamKey then
			return groupAnimParams
		end
	end

	return nil
end

function InteractGestureComponent:cancelCurInteraction()
	if not self.curInteractionSession then
		return
	end

	self:cancelInteraction(self.curInteractionSession)
end

function InteractGestureComponent:clearCurrentInteractionSession(session, uid, skipSync)
	if self.curInteractionSession ~= session or uid and self.curInteractionSessionUid ~= uid then
		return
	end

	self.curInteractionSession = nil

	if pg.me and pg.me.eModel then
		pg.me.eModel.InSocialAnim = false
	end

	self.curInteractionSessionUid = nil

	self:stopInteractionSound()

	if pg.me then
		if not skipSync then
			if pg.me.singleActionState > 0 then
				pg.me:playSingleAction(0)
			end

			if pg.me.friendInteractAction.actionId > 0 then
				pg.me:exitFriendAction()
			end

			if pg.me.multiInteractAction.actionId > 0 then
				pg.me:exitMultiAction()
			end
		end

		facade:SendMessageCommand(MessageName.INTERACT_GESTURE_STATE_CHANGE)
	end
end

function InteractGestureComponent:cancelInteraction(session, skipSync)
	if not session then
		return
	end

	local uid = self.curInteractionSession == session and self.curInteractionSessionUid or session.uid

	if skipSync then
		self:clearCurrentInteractionSession(session, uid, true)
	end

	self.interactionAnimationManager:CancelInteraction(session)

	if not skipSync then
		self:clearCurrentInteractionSession(session, uid)
	end
end

function InteractGestureComponent:playAnim(data, isInvitor)
	pg.me:stopAllAnimation()
	pg.me:playAnimation(PlayableConst.Idle)

	local aniList = isInvitor and data.res1 or data.res2
	local startAnim, loopAnim = aniList[1], aniList[2]

	TimerManager.addTimer(0.2, function()
		local state = pg.me:playAnimation(startAnim, true, nil, false, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)

		if not state then
			return
		end

		if loopAnim then
			pg.me:setAnimationSequence(state, state.Length - 0.2, function(stateTime)
				if stateTime > 0 then
					local loopState = pg.me:playAnimation(loopAnim, true, nil, true, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)

					if loopState then
						loopState:SetLogicLoop(true)
					end
				end

				return true
			end)
		end

		if data.actionSound then
			pg.me:playSoundEvent(data.actionSound)
		end
	end)
end

function InteractGestureComponent:checkInteractGesturePlaying()
	return self.curInteractionSession ~= nil
end

function InteractGestureComponent:rayCastPlayer()
	local entId = UIUtils.RayCastPlayer()

	if string.isNilOrEmpty(entId) or entId == pg.me.id then
		return
	end

	local ent = pg.getEntity(entId)

	if not ent then
		return
	end

	if Utils.isPlayerGhost(ent) then
		return
	end

	if Utils.isPet(ent) and (not ent:CONTROLLING_PET_ST() or ent.masterId == pg.me.id) then
		return
	end

	if Utils.distance(pg.me:getPosition(), ent:getPosition()) > 5 then
		pg.global.showBubbleMessageRaw(pg.getGameString("INTERACT_TARGET_OUT_OF_RANGE"))

		return
	end

	if self.nearestEntRecord then
		self.nearestEntRecord:executeTopLogoComponentMethod(UIConst.TOPLOGO_COMPONENT.SOCIAL, "refreshSelectFrame", {
			show = false
		})
	end

	self.nearestEntRecord = ent

	self.nearestEntRecord:ensureAndExecuteTplComMethod(UIConst.TOPLOGO_COMPONENT.SOCIAL, "refreshSelectFrame", {
		show = true
	})

	local pos = pg.me:getPosition()

	self.positionRecord = pos and Vector3.New(pos.x, pos.y, pos.z) or nil

	facade:SendMessageCommand(MessageName.GESTURE_TARGET_CHANGE, {
		playerId = self.nearestEntRecord:CONTROLLING_PET_ST() and self.nearestEntRecord.master.uid or self.nearestEntRecord.uid
	})
end

function InteractGestureComponent:requestFriendAction(ent, gestureData, isSkipAccept)
	if not ent then
		return
	end

	if not self:isActionCostEnough(gestureData) then
		pg.global.showBubbleMessage(NoticeDef.ITEM_COUNT_LACK)

		return
	end

	local uid = ent:CONTROLLING_PET_ST() and ent.master.uid or ent.uid

	pg.pawn:faceToTarget(ent, nil, true)
	pg.me:requestFriendAction(uid, gestureData.index, isSkipAccept or false, function(result, reason)
		if result then
			if not isSkipAccept then
				pg.global.ui.tips:showTextTip(pg.getGameString("SEND_INVITE_SUCCESS"))
				pg.game.chat:handleTopLogoFriendInteract(pg.me.uid, true, ClientConst.FriendInteractType.FriendAction, gestureData.index)
			end
		elseif reason ~= NoticeDef.ITEM_COUNT_LACK then
			pg.global.ui.tips:showTextTip(pg.getGameString("FRIEND_ANIMATION_LOCKED"))
		end
	end)
end

function InteractGestureComponent:addBuff(actionId, entId)
	local ent = pg.getEntity(entId)

	if not ent then
		return
	end

	pg.me:serverMsg("RPC_CS_PlayAppearanceAction", actionId, entId, false)
end

function InteractGestureComponent:buildFriendInteractionKey(actionInfo)
	local actionId = actionInfo and actionInfo.actionId or 0

	if actionId <= 0 then
		return nil
	end

	return string.format("%s|%s|%s|%s", tostring(actionInfo.requestUid or ""), tostring(actionInfo.acceptUid or ""), tostring(actionId), tostring(actionInfo.start_ts or 0))
end

function InteractGestureComponent:onFriendInteractionSessionFinished(interactionKey, interactionUid)
	local interactionInfo = self.activeFriendInteractions[interactionKey]

	if not interactionInfo or interactionInfo.uid ~= interactionUid then
		return
	end

	self.activeFriendInteractions[interactionKey] = nil
end

function InteractGestureComponent:stopFriendInteraction(interactionKey, actionInfo)
	if string.isNilOrEmpty(interactionKey) then
		return
	end

	local interactionInfo = self.activeFriendInteractions[interactionKey]

	if interactionInfo then
		self.activeFriendInteractions[interactionKey] = nil

		self:cancelInteraction(interactionInfo.session, true)
	end
end

function InteractGestureComponent:onFriendInteractActionChanged(oldAction, newAction)
	local oldKey = self:buildFriendInteractionKey(oldAction)
	local newKey = self:buildFriendInteractionKey(newAction)

	if oldKey and oldKey ~= newKey then
		self:stopFriendInteraction(oldKey, oldAction)
	end

	if not newKey or self.activeFriendInteractions[newKey] then
		return
	end

	if newAction.acceptUid == pg.me.uid or newAction.requestUid == pg.me.uid then
		if pg.me:isControllingPet() and not pg.pawn.isForceControlPet then
			pg.me:requestSwitchToPlayer(Const.CLIENT_SWITCH_REASON.Default, nil, function()
				self:playFriendAction(newAction.actionId, newAction.requestUid, newAction.acceptUid, newAction.start_ts)
			end)
		else
			self:playFriendAction(newAction.actionId, newAction.requestUid, newAction.acceptUid, newAction.start_ts)
		end
	else
		self:playFriendAction(newAction.actionId, newAction.requestUid, newAction.acceptUid, newAction.start_ts)
	end
end

function InteractGestureComponent:findMultiActionMemberIndex(memberIds, uid)
	if not memberIds or not uid then
		return nil
	end

	for index, memberUid in ipairs(memberIds) do
		if memberUid == uid then
			return index
		end
	end

	return nil
end

function InteractGestureComponent:isMultiPetAction(action)
	return action and action.actionId and action.actionId > 0 and action.petPrototypeId and action.petPrototypeId > 0
end

function InteractGestureComponent:getMultiPetMemberIds(action)
	if not action then
		return {}
	end

	local creatorEnt = pg.getEntityByUid(action.creatorId)
	local creatorAction = creatorEnt and creatorEnt.multiInteractAction

	if creatorAction and creatorAction.actionId == action.actionId and creatorAction.creatorId == action.creatorId then
		return creatorAction.memberIds or {}
	end

	return action.memberIds or {}
end

function InteractGestureComponent:getMultiPetDeformId(uid, action)
	if not uid or not action then
		return 0
	end

	if uid == action.creatorId then
		return action.petPrototypeId or 0
	end

	local ent = pg.getEntityByUid(uid)
	local entAction = ent and ent.multiInteractAction

	if entAction and entAction.actionId == action.actionId and entAction.creatorId == action.creatorId then
		return entAction.petPrototypeId or 0
	end

	return 0
end

function InteractGestureComponent:deformMultiPetMember(uid, action)
	local ent = uid and pg.getEntityByUid(uid)
	local petPrototypeId = self:getMultiPetDeformId(uid, action)

	if not ent or petPrototypeId <= 0 or ent._multiPetDeformId == petPrototypeId then
		return
	end

	ent._multiPetDeformId = petPrototypeId

	AnimationUtils.stopLayerAnimation(ent, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
	ClientUtils.doEntityDeformToPet(ent, petPrototypeId)
end

function InteractGestureComponent:cancelMultiPetMemberDeform(uid)
	local ent = uid and pg.getEntityByUid(uid)

	if not ent or not ent._multiPetDeformId then
		return
	end

	ent._multiPetDeformId = nil

	ClientUtils.entityCancelDeform(ent)
end

function InteractGestureComponent:updateMultiPetFollow(action, memberIds, uid)
	if not pg.me or uid ~= pg.me.uid then
		return
	end

	if not action then
		self:detachMultiPetFollowTarget()

		return
	end

	local memberIndex = self:findMultiActionMemberIndex(memberIds, uid)

	if not memberIndex then
		self:detachMultiPetFollowTarget()

		return
	end

	local targetUid = memberIndex > 1 and memberIds[memberIndex - 1] or action.creatorId

	if not targetUid or targetUid == uid then
		self:detachMultiPetFollowTarget()

		return
	end

	self.multiPetFollowCreatorUid = action.creatorId
	self.multiPetFollowMemberIndex = memberIndex

	self:startMultiPetPositionStateFollow(targetUid)
end

function InteractGestureComponent:isValidMultiPetFollowEntity(ent)
	return ent and ent.actorId and ent.eModel ~= nil
end

function InteractGestureComponent:canDriveMultiPetFollowPawn(ent)
	return self:isValidMultiPetFollowEntity(ent) and ent.hasEModelComponent and ent:hasEModelComponent(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER)
end

function InteractGestureComponent:isMultiPetFollowControllerActive(pawn)
	local controllerSystem = pg.game and pg.game.controller
	local controller = controllerSystem and controllerSystem.curController

	return controller and controller.checkPawn and not controller.isVehicle and controller.pawn == pawn
end

function InteractGestureComponent:detachLegacyMultiPetAttach(pawn)
	if not pawn or not pawn._multiPetAttachTargetActorId then
		return
	end

	pawn._multiPetAttachTargetActorId = nil

	if pawn.cancelFollowTarget then
		pawn:cancelFollowTarget()
	end

	if pawn.eModel then
		pawn.eModel:Detach(Const.COMPONENT_ATTACH)
	end
end

function InteractGestureComponent:stopMultiPetFollowDriver()
	if self.multiPetFollowStateMachine then
		self.multiPetFollowStateMachine:stop()

		self.multiPetFollowStateMachine = nil
	end

	self:detachLegacyMultiPetAttach(self.multiPetFollowPawn)

	self.multiPetFollowPawn = nil
end

function InteractGestureComponent:startMultiPetFollowDriver(targetUid)
	local pawn = pg.pawn

	if not self:canDriveMultiPetFollowPawn(pawn) then
		self:stopMultiPetFollowDriver()

		self.multiPetFollowTargetUid = targetUid

		return
	end

	if self.multiPetFollowTargetUid == targetUid and self.multiPetFollowPawn == pawn then
		return
	end

	self:stopMultiPetFollowDriver()

	self.multiPetFollowTargetUid = targetUid
	self.multiPetFollowPawn = pawn

	self:detachLegacyMultiPetAttach(pawn)

	if pawn.cancelFollowTarget then
		pawn:cancelFollowTarget()
	end
end

function InteractGestureComponent:startMultiPetPositionStateFollow(targetUid)
	self:startMultiPetFollowDriver(targetUid)
end

function InteractGestureComponent:getMultiPetFollowStateMachine(pawn)
	if self.multiPetFollowStateMachine and self.multiPetFollowStateMachine.stateSourceUid ~= self.multiPetFollowCreatorUid then
		self:stopMultiPetPositionStateMachine()
	end

	if not self.multiPetFollowStateMachine then
		self.multiPetFollowStateMachine = MultiPetFollowStateMachine.new(pawn.actorId, self.multiPetFollowTargetUid, self.MULTI_PET_FOLLOW_DISTANCE, self.multiPetFollowCreatorUid)
	end

	return self.multiPetFollowStateMachine
end

function InteractGestureComponent:stopMultiPetPositionStateMachine()
	if self.multiPetFollowStateMachine then
		self.multiPetFollowStateMachine:stop()

		self.multiPetFollowStateMachine = nil
	end
end

function InteractGestureComponent:resolveMultiPetFollowEntities(pawn)
	local targetUid = self.multiPetFollowTargetUid

	if not targetUid then
		return nil, nil
	end

	pawn = pawn or pg.pawn

	if pawn ~= pg.pawn or not self:canDriveMultiPetFollowPawn(pawn) then
		self:stopMultiPetFollowDriver()

		return nil, nil
	end

	if self.multiPetFollowPawn ~= pawn then
		self:startMultiPetPositionStateFollow(targetUid)
	end

	local targetEnt = pg.getEntityByUid(targetUid)

	if not self:isValidMultiPetFollowEntity(targetEnt) or targetEnt.actorId == pawn.actorId then
		self:stopMultiPetPositionStateMachine()

		return pawn, nil
	end

	return pawn, targetEnt
end

function InteractGestureComponent:tickMultiPetFollowInput(pawn)
	if not self.multiPetFollowTargetUid then
		return false
	end

	local owner, targetEnt = self:resolveMultiPetFollowEntities(pawn)

	if not owner then
		return false
	end

	if not targetEnt then
		return false
	end

	local stateMachine = self:getMultiPetFollowStateMachine(owner)

	if not stateMachine:tickInput() then
		self:stopMultiPetPositionStateMachine()
	end

	return true
end

function InteractGestureComponent:tickMultiPetFollowTransform()
	if not self.multiPetFollowTargetUid then
		return
	end

	if not self:isMultiPetFollowControllerActive(pg.pawn) then
		if self.multiPetFollowPawn then
			self:stopMultiPetFollowDriver()
		end

		return
	end

	local pawn, targetEnt = self:resolveMultiPetFollowEntities(pg.pawn)

	if not pawn or not targetEnt then
		return
	end

	local stateMachine = self:getMultiPetFollowStateMachine(pawn)
	local displayPosition, displayRotation
	local presentation = self.multiPetFollowPresentation

	if presentation and pg.me then
		displayPosition, displayRotation = presentation:getMemberDisplayTransform(self.multiPetFollowCreatorUid, pg.me.uid, self.multiPetFollowMemberIndex)
	end

	if not stateMachine:tickTransform(displayPosition, displayRotation) then
		self:stopMultiPetPositionStateMachine()
	end
end

function InteractGestureComponent:tickMultiPetFollowPresentation()
	local presentation = self.multiPetFollowPresentation

	if presentation then
		presentation:tick(self.multiInteractionSessions)
	end
end

function InteractGestureComponent:clearMultiPetFollowPresentation()
	if self.multiPetFollowPresentation then
		self.multiPetFollowPresentation:clear()
	end
end

function InteractGestureComponent:detachMultiPetFollowTarget()
	local oldPawn = self.multiPetFollowPawn

	self:stopMultiPetFollowDriver()

	if pg.pawn ~= oldPawn then
		self:detachLegacyMultiPetAttach(pg.pawn)
	end

	self.multiPetFollowCreatorUid = nil
	self.multiPetFollowMemberIndex = nil
	self.multiPetFollowTargetUid = nil
end

function InteractGestureComponent:cancelMultiPetFollow(uid)
	if pg.me and uid == pg.me.uid then
		self:detachMultiPetFollowTarget()
	end
end

function InteractGestureComponent:addMultiPetSession(actionData, action, uid, targetEnt, creatorEnt, posIndex, memberIds)
	if not uid or not targetEnt or not creatorEnt then
		return
	end

	local curSessions = self.multiInteractionSessions[action.creatorId]

	if curSessions[uid] then
		self:updateMultiPetFollow(action, memberIds, uid)

		return
	end

	local session = self:getInteractionSession(actionData, targetEnt, creatorEnt, nil, posIndex)

	curSessions[uid] = session

	if pg.me and uid == pg.me.uid then
		self:setCurrentInteractionSession(session)
		self:updateMultiPetFollow(action, memberIds, uid)
	end
end

function InteractGestureComponent:cancelMultiPetSession(creatorId, uid)
	local sessions = creatorId and self.multiInteractionSessions[creatorId]
	local session = sessions and sessions[uid]

	if session then
		self:cancelInteraction(session, true)

		sessions[uid] = nil
	end

	self:cancelMultiPetFollow(uid)
end

function InteractGestureComponent:onMultiPetInteractActionChanged(oldAction, newAction, actionOwnerUid)
	local oldCreatorId = oldAction and oldAction.creatorId or ""
	local newCreatorId = newAction and newAction.creatorId or ""
	local oldMembers = oldAction and oldAction.memberIds or {}
	local newMembers = self:getMultiPetMemberIds(newAction)

	if self:isMultiPetAction(oldAction) and (not self:isMultiPetAction(newAction) or oldCreatorId ~= newCreatorId) then
		if actionOwnerUid and actionOwnerUid ~= oldCreatorId then
			self:cancelMultiPetSession(oldCreatorId, actionOwnerUid)
			self:cancelMultiPetMemberDeform(actionOwnerUid)

			return
		end

		self:cancelMultiPetSession(oldCreatorId, oldCreatorId)
		self:cancelMultiPetMemberDeform(oldCreatorId)

		for _, uid in ipairs(oldMembers) do
			self:cancelMultiPetSession(oldCreatorId, uid)
			self:cancelMultiPetMemberDeform(uid)
		end

		self.multiInteractionSessions[oldCreatorId] = nil

		return
	end

	if not self:isMultiPetAction(newAction) then
		return
	end

	local actionData = AppearanceAction[newAction.actionId]
	local creatorEnt = pg.getEntityByUid(newCreatorId)

	if not actionData or not creatorEnt then
		return
	end

	self.multiInteractionSessions[newCreatorId] = self.multiInteractionSessions[newCreatorId] or {}

	if creatorEnt.refreshActionStateInteraction then
		creatorEnt:refreshActionStateInteraction()
	end

	if actionOwnerUid and actionOwnerUid ~= newCreatorId then
		local memberIndex = self:findMultiActionMemberIndex(newMembers, actionOwnerUid) or 1
		local memberEnt = pg.getEntityByUid(actionOwnerUid)

		if actionOwnerUid == pg.me.uid and pg.me:isControllingPet() and not pg.pawn.isForceControlPet then
			pg.me:requestSwitchToPlayer(Const.CLIENT_SWITCH_REASON.Default, nil, function()
				self:deformMultiPetMember(actionOwnerUid, newAction)
				self:addMultiPetSession(actionData, newAction, actionOwnerUid, memberEnt, creatorEnt, memberIndex, newMembers)
			end)
		else
			self:deformMultiPetMember(actionOwnerUid, newAction)
			self:addMultiPetSession(actionData, newAction, actionOwnerUid, memberEnt, creatorEnt, memberIndex, newMembers)
		end

		return
	end

	self:deformMultiPetMember(newCreatorId, newAction)
	self:addMultiPetSession(actionData, newAction, newCreatorId, creatorEnt, creatorEnt, 0, newMembers)

	for _, uid in ipairs(oldMembers) do
		if not table.contains(newMembers, uid) then
			self:cancelMultiPetSession(newCreatorId, uid)
			self:cancelMultiPetMemberDeform(uid)
		end
	end

	for index, uid in ipairs(newMembers) do
		local memberEnt = pg.getEntityByUid(uid)

		self:deformMultiPetMember(uid, newAction)
		self:addMultiPetSession(actionData, newAction, uid, memberEnt, creatorEnt, index, newMembers)
	end
end

function InteractGestureComponent:onMultiInteractActionChanged(oldAction, newAction, actionOwnerUid)
	if self:isMultiPetAction(oldAction) or self:isMultiPetAction(newAction) then
		self:onMultiPetInteractActionChanged(oldAction, newAction, actionOwnerUid)

		return
	end

	local function findMemberIndex(memberIds, uid)
		if not memberIds or not uid then
			return nil
		end

		for index, memberUid in ipairs(memberIds) do
			if memberUid == uid then
				return index
			end
		end

		return nil
	end

	local function cancelSession(session)
		self:cancelInteraction(session, true)
	end

	local oldCreatorId = oldAction.creatorId
	local sessions = self.multiInteractionSessions[oldCreatorId]

	if oldAction.actionId > 0 and newAction.actionId <= 0 then
		if actionOwnerUid and actionOwnerUid ~= oldCreatorId then
			if sessions and sessions[actionOwnerUid] then
				cancelSession(sessions[actionOwnerUid])

				sessions[actionOwnerUid] = nil
			end

			return
		end

		local creatorEnt = pg.getEntityByUid(oldCreatorId)

		if creatorEnt then
			creatorEnt:refreshActionStateInteraction()
		end

		if sessions then
			for _, session in pairs(sessions) do
				cancelSession(session)
			end

			self.multiInteractionSessions[oldCreatorId] = nil
		end

		return
	end

	if newAction.actionId <= 0 then
		return
	end

	local actionData = AppearanceAction[newAction.actionId]
	local creatorEnt = pg.getEntityByUid(newAction.creatorId)

	if not actionData or not creatorEnt then
		return
	end

	local creatorAction = creatorEnt.multiInteractAction
	local newMembers = newAction.memberIds or {}

	newMembers = actionOwnerUid and actionOwnerUid ~= newAction.creatorId and creatorAction and creatorAction.memberIds or newMembers

	local function playMultiEndAnim(ent)
		local endAnim = actionData.res1 and actionData.res1[3] and self:getPlayableKey(actionData.res1[3])

		self:playEndAnim(ent, endAnim)
	end

	local function addSession(uid, targetEnt, posIndex)
		if not uid or not targetEnt then
			return
		end

		local function innerAddSession()
			local curSessions = self.multiInteractionSessions[newAction.creatorId]

			if curSessions[uid] then
				return
			end

			local session = self:getInteractionSession(actionData, targetEnt, creatorEnt, function()
				return playMultiEndAnim(targetEnt)
			end, posIndex)

			if not self:queryCanInteract(session) then
				self:cancelInteraction(session)

				if uid == pg.me.uid then
					pg.me:exitMultiAction()
				end

				return
			end

			self:startInteraction(actionData.actionSound, session, uid == pg.me.uid)

			curSessions[uid] = session
		end

		if uid == pg.me.uid and pg.me:isControllingPet() and not pg.pawn.isForceControlPet then
			pg.me:requestSwitchToPlayer(Const.CLIENT_SWITCH_REASON.Default, nil, function()
				innerAddSession()
			end)
		else
			innerAddSession()
		end
	end

	self.multiInteractionSessions[newAction.creatorId] = self.multiInteractionSessions[newAction.creatorId] or {}

	creatorEnt:refreshActionStateInteraction()

	if actionOwnerUid and actionOwnerUid ~= newAction.creatorId then
		local memberIndex = findMemberIndex(newMembers, actionOwnerUid)

		if memberIndex then
			addSession(actionOwnerUid, pg.getEntityByUid(actionOwnerUid), memberIndex)
		end

		return
	end

	if not sessions or oldAction.actionId <= 0 or oldCreatorId ~= newAction.creatorId then
		addSession(newAction.creatorId, creatorEnt, 0)

		for index, memberUid in ipairs(newMembers) do
			addSession(memberUid, pg.getEntityByUid(memberUid), index)
		end

		return
	end

	for uid, session in pairs(sessions) do
		if uid ~= newAction.creatorId and not table.contains(newMembers, uid) then
			cancelSession(session)

			sessions[uid] = nil
		end
	end

	for index, memberUid in ipairs(newMembers) do
		if not sessions[memberUid] then
			addSession(memberUid, pg.getEntityByUid(memberUid), index)
		end
	end
end

function InteractGestureComponent:playFriendAction(actionId, invitorUid, receiverUid, startTs)
	local interactionInfo = {
		actionId = actionId,
		requestUid = invitorUid,
		acceptUid = receiverUid,
		start_ts = startTs or 0
	}
	local interactionKey = self:buildFriendInteractionKey(interactionInfo)

	if not interactionKey or self.activeFriendInteractions[interactionKey] then
		return false
	end

	local includeSelf = invitorUid == pg.me.uid or receiverUid == pg.me.uid

	if includeSelf then
		local carryType = pg.me.carryType

		if carryType == Const.CARRY_TYPE.PET then
			pg.me:putDownCarryEnt()
		end

		if pg.me.onVehicleActorId > 0 then
			pg.pawn:dismountSelf()
		end
	end

	local actionData = AppearanceAction[actionId]

	if not actionData then
		return false
	end

	local invitorEnt = pg.getEntityByUid(invitorUid)
	local receiverEnt = pg.getEntityByUid(receiverUid)

	if not invitorEnt or not receiverEnt then
		return false
	end

	actionData = self:getGenderMatchedFriendActionData(actionData, invitorEnt, receiverEnt)

	local function onComplete(uid)
		local invitorEndAnim = actionData.res1 and actionData.res1[3] and self:getPlayableKey(actionData.res1[3])

		self:playEndAnim(invitorEnt, invitorEndAnim)

		local receiverEndAnim = actionData.res2 and actionData.res2[3] and self:getPlayableKey(actionData.res2[3])

		self:playEndAnim(receiverEnt, receiverEndAnim)
		self:onFriendInteractionSessionFinished(interactionKey, uid)
	end

	local session = self:getInteractionSession(actionData, invitorEnt, actionData.needTargetAgree and receiverEnt or invitorEnt, onComplete)
	local checkPass = self:queryCanInteract(session)

	if not checkPass then
		self:cancelInteraction(session)

		if includeSelf then
			pg.me:exitFriendAction()
		end

		return
	end

	self.activeFriendInteractions[interactionKey] = {
		uid = session.uid,
		session = session
	}

	local started = self:startInteraction(actionData.actionSound, session, includeSelf)

	if not started then
		self.activeFriendInteractions[interactionKey] = nil

		return false
	end

	if includeSelf and pg.me.uid == invitorUid then
		pg.game.chat:handleTopLogoFriendInteract(pg.me.uid, false, ClientConst.FriendInteractType.FriendAction)
	end

	if AppearanceAction[receiverEnt.actionState] and AppearanceAction[receiverEnt.actionState].interactId then
		local recoverActions = InteractData[AppearanceAction[receiverEnt.actionState].interactId].events[1][2] or {}

		if table.contains(recoverActions, actionId) then
			receiverEnt:setActionState(Const.PlayerActionState.None)
		end
	end

	return started
end

function InteractGestureComponent:startInteraction(actionSound, session, includeSelf)
	if includeSelf then
		self:stopInteractionSound()
		pg.me:stopAllAnimation()
		self:setCurrentInteractionSession(session)

		local pos

		if session.self == pg.me.eModel then
			pos = self.interactionAnimationManager:QuerySelfSessionPoint(session)
		elseif session.target == pg.me.eModel then
			pos = self.interactionAnimationManager:QueryTargetSessionPoint(session)
		end

		if pos and pg.me.forceSetPosRot then
			local targetPos = Vector3.New(pos.x, pos.y, pos.z)

			pg.me:forbidPositionCheck({
				Const.FORBID_POSITION_REASON.SOCIAL,
				0,
				targetPos
			})
			pg.me:forceSetPosRot(targetPos, Quaternion.Euler(0, pos.w or 0, 0), true, true)
		end
	end

	local started = self.interactionAnimationManager:StartInteraction(session)

	if not started then
		self:cancelInteraction(session)
	elseif includeSelf then
		self:playInteractionSound(actionSound)
	end

	return started
end

function InteractGestureComponent:setCurrentInteractionSession(session, skipSetSocialAnim)
	local oldSession = self.curInteractionSession

	self.curInteractionSession = session
	self.curInteractionSessionUid = session and session.uid or nil

	if oldSession and oldSession ~= session then
		self:cancelInteraction(oldSession, true)
	end

	if pg.me and pg.me.eModel and not skipSetSocialAnim then
		pg.me.eModel.InSocialAnim = true
	end

	facade:SendMessageCommand(MessageName.INTERACT_GESTURE_STATE_CHANGE)
end

function InteractGestureComponent:recommendGesture(cfgId)
	local appearanceActionData = AppearanceAction[cfgId]

	if not appearanceActionData then
		return
	end

	local hudCtrl = pg.global.ui.hudV2

	if hudCtrl and hudCtrl.showRecommendGesture then
		hudCtrl:showRecommendGesture(true, {
			icon = appearanceActionData.icon,
			func = function()
				self:playAnim({
					res1 = appearanceActionData.res1,
					actionSound = appearanceActionData.actionSound
				}, true)
			end
		})

		if self.recommendTimer then
			TimerManager.removeTimer(self.recommendTimer)
		end

		self.recommendTimer = TimerManager.addTimer(10, function()
			if hudCtrl and hudCtrl.showRecommendGesture then
				hudCtrl:showRecommendGesture(false)
			end
		end)
	end
end

function InteractGestureComponent:addGhost(ent)
	if not ent then
		return
	end

	if not self.ghostGroup then
		self.ghostGroup = GameObject("GhostGroup")

		Object.DontDestroyOnLoad(self.ghostGroup)
	end

	if not self.ghostPool then
		self.ghostPool = {}
	end

	if self.ghostPool[ent.id] then
		return
	end

	local loader = ResLoader.new()

	self.ghostPool[ent.id] = {}
	self.ghostPool[ent.id].taskId = loader:load(AddressDataConst.GHOST, function(gameObject)
		local info = {
			gameObject = gameObject,
			animation = gameObject:GetComponent("ObjectReference"):GetRefValue("stateGhostAnimation")
		}

		info.gameObject.name = string.format("Ghost_%s", ent.id)

		info.gameObject.transform:SetParent(self.ghostGroup.transform)

		self.ghostPool[ent.id].loader = loader
		self.ghostPool[ent.id].info = info

		local objectReference = info.gameObject:GetComponent("ObjectReference")
		local ghostFollowPlayerAround = objectReference:GetRefValue("ghostFollowPlayerAround")
		local txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")

		ghostFollowPlayerAround:FollowByActorId(ent.actorId)
	end)
end

function InteractGestureComponent:removeGhost(ent)
	if not ent or not self.ghostPool then
		return
	end

	local ghost = self.ghostPool[ent.id]

	if not ghost then
		return
	end

	local function inner()
		pg.global.resMgr:TryCancelGOLoadAsyncTask(ghost.taskId)
		ghost.loader:destroy()

		ghost.loader = nil
		ghost.info = nil
		ghost.taskId = nil
		self.ghostPool[ent.id] = nil
	end

	if ghost.info then
		UIUtils.PlayAnimation(ghost.info.animation, "VX_3D_StateGhost_Out", function()
			inner()
		end)
	else
		inner()
	end
end

function InteractGestureComponent:startSelectPlayer(playerId)
	self.startTickAround = true

	if playerId then
		local targetEnt = pg.getEntityByUid(playerId)

		targetEnt = targetEnt and (targetEnt:CONTROLLING_PET_ST() and targetEnt.getCurPetEntity and targetEnt:getCurPetEntity() or targetEnt)

		if Utils.isPlayerGhost(targetEnt) then
			targetEnt = nil
		end

		if self.nearestEntRecord and self.nearestEntRecord ~= targetEnt then
			self.nearestEntRecord:executeTopLogoComponentMethod(UIConst.TOPLOGO_COMPONENT.SOCIAL, "refreshSelectFrame", {
				show = false
			})
		end

		self.nearestEntRecord = targetEnt

		if self.nearestEntRecord then
			self.nearestEntRecord:ensureAndExecuteTplComMethod(UIConst.TOPLOGO_COMPONENT.SOCIAL, "refreshSelectFrame", {
				show = true
			})
			facade:SendMessageCommand(MessageName.GESTURE_TARGET_CHANGE, {
				playerId = self.nearestEntRecord:CONTROLLING_PET_ST() and self.nearestEntRecord.master.uid or self.nearestEntRecord.uid
			})

			local pos = pg.me and pg.me:getPosition() or nil

			self.positionRecord = pos and Vector3.New(pos.x, pos.y, pos.z) or nil
		else
			facade:SendMessageCommand(MessageName.GESTURE_TARGET_CHANGE, {})
		end
	end

	local hud = pg.global.ui.hudV2

	if hud then
		hud:muteEventSystemListener(not self.startTickAround)
	end
end

function InteractGestureComponent:stopSelectPlayer()
	self.startTickAround = false

	if self.nearestEntRecord then
		self.nearestEntRecord:executeTopLogoComponentMethod(UIConst.TOPLOGO_COMPONENT.SOCIAL, "refreshSelectFrame", {
			show = false
		})

		self.nearestEntRecord = nil
	end

	local hud = pg.global.ui.hudV2

	if hud then
		pg.global.ui.hudV2:muteEventSystemListener(not self.startTickAround)
	end

	self.positionRecord = nil
end

function InteractGestureComponent:muteInteractGestureFunc(mute)
	if pg.global.ui.hudV2 then
		pg.global.ui.hudV2:showEmotionBtn(not mute)
	end
end

function InteractGestureComponent:setPendingDeform(uid, shouldDeform)
	if not self.pendingDeformList then
		self.pendingDeformList = {}
	end

	self.pendingDeformList[uid] = shouldDeform
end

function InteractGestureComponent:checkPlayerShouldDeform(uid)
	return self.pendingDeformList and self.pendingDeformList[uid] or false
end

function InteractGestureComponent:getInteractGestureCache()
	local ret = {}

	if not pg.me then
		return ret
	end

	local curActionsStr = pg.global.prefsCacheUtils:getString(pg.me.uid .. self.InteractGestureCacheKey, "")

	for _, actionId in ipairs(string.split(curActionsStr, "|") or EMPTY_TABLE) do
		if actionId ~= "" then
			ret[tonumber(actionId)] = true
		end
	end

	return ret
end

local function saveInteractGestureCache(cache, cacheKey)
	local actionIds = {}

	for actionId, viewed in pairs(cache) do
		if viewed then
			actionIds[#actionIds + 1] = tonumber(actionId) or actionId
		end
	end

	table.sort(actionIds, function(left, right)
		return tonumber(left) < tonumber(right)
	end)

	for index, actionId in ipairs(actionIds) do
		actionIds[index] = tostring(actionId)
	end

	pg.global.prefsCacheUtils:setString(cacheKey, table.concat(actionIds, "|"))
end

function InteractGestureComponent:markInteractGestureViewed(actionId)
	if not pg.me or not pg.me.actionShowIds then
		return
	end

	local id = tonumber(actionId) or actionId

	if not pg.me.actionShowIds[id] then
		return
	end

	local cache = self:getInteractGestureCache()

	cache[id] = true

	saveInteractGestureCache(cache, pg.me.uid .. self.InteractGestureCacheKey)
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.HUD_INTERACT_GESTURE)
end

function InteractGestureComponent:isNewInteractGesture(actionId)
	if not pg.me or not pg.me.actionShowIds then
		return false
	end

	local id = tonumber(actionId) or actionId

	return pg.me.actionShowIds[id] and not self:getInteractGestureCache()[id] or false
end

function InteractGestureComponent:hasNewInteractGesture(interactAction)
	if not pg.me or not pg.me.actionShowIds then
		return RedDotConst.RedDotStyle.NONE
	end

	local curActions = self:getInteractGestureCache()

	for actionId, unlock in pairs(pg.me.actionShowIds) do
		local data = AppearanceAction[actionId]

		if data and data.initialClaim ~= 1 and unlock and not curActions[actionId] and (not interactAction or data.interactAction == interactAction) then
			return RedDotConst.RedDotStyle.NEW
		end
	end

	return RedDotConst.RedDotStyle.NONE
end

return InteractGestureComponent
