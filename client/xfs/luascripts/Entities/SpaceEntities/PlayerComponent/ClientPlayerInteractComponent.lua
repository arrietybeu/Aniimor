-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientPlayerInteractComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local ClientConst = require("Const.ClientConst")
local MessageName = require("Const.MessageName")
local InteractionConst = require("Common.Const.InteractionConst")
local AppearanceAction = require("Data.appearance_action_data")
local InteractData = require("Data.interact_data")
local EventEnumData = require("Data.event_enum_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")
local NoticeDef = require("Common.NoticeDef")
local Bitset = require("Common.Bitset")
local ClientFKeyInteractBase = require("Entities.SpaceEntities.CommonComponent.ClientFKeyInteractBase")
local ClientPlayerInteractComponent = Class.Component("ClientPlayerInteractComponent", ClientFKeyInteractBase)

function ClientPlayerInteractComponent:start()
	self.actionStateInteractions = {}
	self.isInPlayerTrigger = false
end

function ClientPlayerInteractComponent:onEnterSpace()
	local curSpaceSceneId = self.space and self.space.sceneId or 0

	if not self.isMainPlayer and (not Utils.isSelfInSpaceDungeon() or Utils.isRobEggSceneId(curSpaceSceneId)) then
		self:refreshInteractTrigger()
	end
end

function ClientPlayerInteractComponent:getInteractiveDist()
	return 3
end

function ClientPlayerInteractComponent:checkLinkedPetHideOnly()
	if self.isMainPlayer or not self.isControllingPet or not self:isControllingPet() then
		return false
	end

	local switchingKey = ClientConst.MODEL_VISIBLE_KEY.SWITCHING

	return self:checkOnlySwitchingHide(self.modelActiveKeys, switchingKey) and self:checkOnlySwitchingHide(self.modelVisibleKeys, switchingKey)
end

function ClientPlayerInteractComponent:refreshTriggerState()
	if self.triggerId and self:checkLinkedPetHideOnly() then
		self.eModel:SetTriggerActive(self.triggerId, true)

		return
	end

	ClientFKeyInteractBase.refreshTriggerState(self)
end

function ClientPlayerInteractComponent:onEnterInteractTrigger()
	if pg.me:GM_OBSERVE_ST() or self.GM_OBSERVE_ST and self:GM_OBSERVE_ST() then
		return
	end

	self.isInPlayerTrigger = true
	self.playerInTrigger = true

	if pg.me and pg.me.shouldHideByMySpaceFollowTeam and pg.me:shouldHideByMySpaceFollowTeam(self.uid) then
		self:hideSpaceFollowInteractionOptions()

		return
	end

	if pg.me ~= self and (Utils.isRobEggSceneId(self.space.sceneId) or self.gmMode == Const.NO_COST_MODE) then
		if Utils.isPartner(pg.me, self) and pg.me:isAlive() then
			self:showFirstAidPlayerInteraction()
		end

		return
	end

	if Utils.isSelfInSpaceDungeon() then
		return
	end

	local playerId = self.uid
	local openType = ClientConst.PlayerInfoOpenType.FaceToFace

	if Utils.isPlayerGhost(self) or Utils.isPetGhost(self) then
		local player = Utils.isPetGhost(self) and pg.getEntity(self.masterId) or self

		playerId = Utils.getSourceUidByPlayerGhostUid(player.playerUid) or playerId
		openType = ClientConst.PlayerInfoOpenType.PlayerGhost
	end

	facade:SendMessageCommand(MessageName.ENTER_TRIGGER, {
		globalId = self:getGlobalId(),
		interactionType = InteractionConst.INTERACTION_TYPE_FRIEND,
		actionPrototypeId = InteractionConst.STYLE_CONST.FRIEND_INTERACT,
		dist = InteractData[InteractionConst.STYLE_CONST.FRIEND_INTERACT].interactiveDist,
		interactFunc = function()
			local param = {
				openType = openType,
				playerId = playerId,
				openSource = pg.game.chat.AddFriendSource.FaceToFace
			}

			LuaUIUtils.openInfoPlayerCard(param)
		end
	})
	self:refreshActionStateInteraction()
end

function ClientPlayerInteractComponent:onLeaveInteractTrigger()
	self.isInPlayerTrigger = false
	self.playerInTrigger = false

	facade:SendMessageCommand(MessageName.LEAVE_TRIGGER, {
		globalId = self:getGlobalId(),
		interactionType = InteractionConst.INTERACTION_TYPE_FRIEND
	})
	facade:SendMessageCommand(MessageName.LEAVE_TRIGGER, {
		globalId = self:getGlobalId(),
		interactionType = InteractionConst.INTERACTION_TYPE_FALLEN_AID
	})
	facade:SendMessageCommand(MessageName.LEAVE_TRIGGER, {
		globalId = self:getGlobalId(),
		interactionType = InteractionConst.INTERACTION_TYPE_DISCOVER_PLAYER
	})
	self:clearActionStateInteraction()
end

function ClientPlayerInteractComponent:buildActionStateInteractionInfo(actionState)
	local actionData = AppearanceAction[actionState]
	local interactId = actionData and actionData.interactId or 0

	if interactId <= 0 then
		return nil, 0
	end

	local interactCfg = InteractData[interactId]

	if not interactCfg then
		return nil, 0
	end

	return {
		globalId = self:getGlobalId(),
		interactionType = InteractionConst.INTERACTION_TYPE_INTERACT_ANIMATION,
		actionPrototypeId = interactId,
		actionState = actionState,
		dist = interactCfg.interactiveDist or 0,
		interactFunc = function()
			self:triggerActionStateInteractionEvents(interactId, actionState)
		end
	}, interactId
end

function ClientPlayerInteractComponent:triggerActionStateInteractionEvents(interactId, actionState)
	local hasInteraction = false

	for _, info in ipairs(self.actionStateInteractions or EMPTY_TABLE) do
		if info.actionPrototypeId == interactId then
			hasInteraction = true

			break
		end
	end

	if not hasInteraction then
		return
	end

	local interactCfg = InteractData[interactId]

	if not interactCfg or not interactCfg.events or not pg.me or not pg.me.doEventByData then
		return
	end

	local context = {
		fromEntUid = self.uid,
		fromEntId = self.id,
		globalId = self:getGlobalId(),
		interactId = interactId,
		actionState = actionState
	}

	for _, eventData in ipairs(interactCfg.events) do
		local eventName, param, ratio, delay = Utils.safeUnpack(eventData)
		local eventCfg = EventEnumData[eventName]
		local eventContext = Utils.deepCopyTable(context)

		if eventCfg and eventCfg.eventFlag == "s" then
			-- block empty
		else
			pg.me:doEventByData({
				eventName,
				param,
				delay,
				ratio
			}, eventContext)
		end
	end
end

function ClientPlayerInteractComponent:shouldHideActionStateInteraction(actionState)
	local actionData = AppearanceAction[actionState]
	local action = self.multiInteractAction

	if not actionData or actionData.interactAction ~= Const.APPEARANCE_ACTION_TYPE.Multi or not action then
		return false
	end

	if action.actionId ~= actionState then
		return false
	end

	if action.creatorId ~= self.uid then
		return true
	end

	local memberIds = action.memberIds or {}
	local personMaxNum = actionData.personNum and actionData.personNum[2] or 0

	return table.contains(memberIds, pg.me.uid) or personMaxNum > 0 and personMaxNum <= #memberIds + 1
end

function ClientPlayerInteractComponent:canShowActionStateInteraction(info)
	if self.isMainPlayer or self.uid == pg.me.uid or not self.isInPlayerTrigger or not info or pg.me and pg.me.shouldHideByMySpaceFollowTeam and pg.me:shouldHideByMySpaceFollowTeam(self.uid) or self:shouldHideActionStateInteraction(info.actionState) then
		return false
	end

	return true
end

function ClientPlayerInteractComponent:hideSpaceFollowInteractionOptions()
	facade:SendMessageCommand(MessageName.LEAVE_TRIGGER, {
		globalId = self:getGlobalId(),
		interactionType = InteractionConst.INTERACTION_TYPE_FRIEND
	})
	facade:SendMessageCommand(MessageName.LEAVE_TRIGGER, {
		globalId = self:getGlobalId(),
		interactionType = InteractionConst.INTERACTION_TYPE_FALLEN_AID
	})
	facade:SendMessageCommand(MessageName.LEAVE_TRIGGER, {
		globalId = self:getGlobalId(),
		interactionType = InteractionConst.INTERACTION_TYPE_DISCOVER_PLAYER
	})
	self:clearActionStateInteraction()
end

function ClientPlayerInteractComponent:refreshSpaceFollowInteraction()
	if pg.me and pg.me.shouldHideByMySpaceFollowTeam and pg.me:shouldHideByMySpaceFollowTeam(self.uid) then
		self:hideSpaceFollowInteractionOptions()
	elseif self.isInPlayerTrigger then
		self:onEnterInteractTrigger()
	end
end

function ClientPlayerInteractComponent:showActionStateInteraction(info)
	if not self:canShowActionStateInteraction(info) then
		return
	end

	facade:SendMessageCommand(MessageName.ENTER_TRIGGER, info)
end

function ClientPlayerInteractComponent:hideActionStateInteraction(info, skipRefresh)
	if not info or not info.actionPrototypeId or info.actionPrototypeId <= 0 then
		return
	end

	if not pg.game or not pg.game.interaction then
		return
	end

	facade:SendMessageCommand(MessageName.LEAVE_TRIGGER, info)

	if not skipRefresh then
		pg.game.interaction:refreshInteraction(true)
	end
end

function ClientPlayerInteractComponent:buildActionStateInteractions()
	local infoList = {}

	local function tryAdd(actionState)
		local info, interactId = self:buildActionStateInteractionInfo(actionState)

		if not info or interactId <= 0 or not self:canShowActionStateInteraction(info) then
			return
		end

		for _, oldInfo in ipairs(infoList) do
			if oldInfo.actionPrototypeId == interactId then
				return
			end
		end

		infoList[#infoList + 1] = info
	end

	if self.multiInteractAction then
		tryAdd(self.multiInteractAction.actionId)
	end

	if self.actionState then
		tryAdd(self.actionState)
	end

	if #infoList <= 0 and self.friendInteractAction then
		tryAdd(self.friendInteractAction.actionId)
	end

	return infoList
end

function ClientPlayerInteractComponent:refreshActionStateInteraction()
	local oldInfoList = self.actionStateInteractions or {}
	local newInfoList = self:buildActionStateInteractions()
	local changed = false

	local function containsInfo(infoList, targetInfo)
		for _, info in ipairs(infoList) do
			if info.actionPrototypeId == targetInfo.actionPrototypeId and info.actionState == targetInfo.actionState then
				return true
			end
		end

		return false
	end

	for _, oldInfo in ipairs(oldInfoList) do
		if not containsInfo(newInfoList, oldInfo) then
			self:hideActionStateInteraction(oldInfo, true)

			changed = true
		end
	end

	for _, info in ipairs(newInfoList) do
		if not containsInfo(oldInfoList, info) then
			changed = true

			self:showActionStateInteraction(info)
		end
	end

	self.actionStateInteractions = newInfoList

	if changed and pg.game and pg.game.interaction then
		pg.game.interaction:refreshInteraction(true)
	end
end

function ClientPlayerInteractComponent:clearActionStateInteraction()
	for _, info in ipairs(self.actionStateInteractions or EMPTY_TABLE) do
		self:hideActionStateInteraction(info, true)
	end

	if pg.game and pg.game.interaction then
		pg.game.interaction:refreshInteraction(true)
	end

	self.actionStateInteractions = {}
end

function ClientPlayerInteractComponent:showFirstAidPlayerInteraction()
	facade:SendMessageCommand(MessageName.ENTER_TRIGGER, {
		needCheckDis = true,
		dist = 0,
		globalId = self:getGlobalId(),
		interactionType = InteractionConst.INTERACTION_TYPE_FALLEN_AID,
		actionPrototypeId = InteractionConst.STYLE_CONST.FALLEN_AID,
		preCheckFunc = function()
			if self:FALLEN_AID_ST() then
				local toastId = Utils.isTargetInSelfRescue(self) and NoticeDef.TARGET_IN_SELF_RESCUING or NoticeDef.CANNOT_RESCUE_TARGET_BE_RESCUED_BY_OTHERS

				pg.global.showBubbleMessageById(toastId)

				return false
			end

			return true
		end,
		interactFunc = function()
			pg.me:doFirstAid(self.actorId, self.playerName)
		end
	})
end

function ClientPlayerInteractComponent:destroy()
	if not self.playerInTrigger then
		self:clearActionStateInteraction()
	end

	ClientFKeyInteractBase.destroy(self)
end

function ClientPlayerInteractComponent:onInteractRecord_add(id, num)
	facade:sendMsgToUI(MessageName.PLAYER_INTERACT_RECORD_ADD, {
		interactId = id
	})
end

function ClientPlayerInteractComponent:onInteractRecord_deleted(id, num)
	facade:sendMsgToUI(MessageName.PLAYER_INTERACT_RECORD_DELETE, {
		interactId = id
	})
end

function ClientPlayerInteractComponent:refreshNpcDialogueBubbleByStaticId(staticId)
	local ent = self.space and self.space:getEntityByStaticId(staticId)

	if ent and ent.refreshTrapEventTrigger then
		ent:refreshTrapEventTrigger()
	end
end

function ClientPlayerInteractComponent:on_npcDialogueBubbleId_added(staticId, dialogueId)
	self:refreshNpcDialogueBubbleByStaticId(staticId)
end

function ClientPlayerInteractComponent:on_npcDialogueBubbleId_deleted(staticId, dialogueId)
	self:refreshNpcDialogueBubbleByStaticId(staticId)
end

function ClientPlayerInteractComponent:on_npcDialogueBubbleId_changed(ov, nv, staticId)
	if ov == nv then
		return
	end

	self:refreshNpcDialogueBubbleByStaticId(staticId)
end

function ClientPlayerInteractComponent:checkOnlySwitchingHide(flags, switchingKey)
	local hideKeys = Bitset.getList(flags)

	for i = 1, #hideKeys do
		if hideKeys[i] ~= switchingKey then
			return false
		end
	end

	return true
end

return ClientPlayerInteractComponent
