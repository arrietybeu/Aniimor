-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientInteractionAnimationComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local class = require("Core.Framework.Class")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientConst = require("Const.ClientConst")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local CTRPool = require("Common.AICt.CTRPool")
local TimerManager = require("Core.Timer.TimerManager")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local AppearanceAction = require("Data.appearance_action_data")
local SysConfigData = require("Data.sys_config_data")
local HotkeyConst = require("Const.HotkeyConst")
local MessageName = require("Const.MessageName")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local NoticeDef = require("Common.NoticeDef")
local Utils = require("Common.Utils.Utils")
local PlayableConst = require("Common.Const.PlayableConst")
local PlatformSocialService = require("SDK.Platform.PlatformSocialService")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local ClientUtils = require("Utils.ClientUtils")
local HandheldAppearanceUtils = require("Utils.HandheldAppearanceUtils")
local ClientInteractionAnimationComponent = class.Component("ClientInteractionAnimationComponent")
local Vector3 = Vector3

local function randomItem(t)
	return t and #t > 0 and t[math.random(1, #t)] or nil
end

function ClientInteractionAnimationComponent:setFeedbackUid(uid, actionId)
	if uid and uid ~= "" then
		self:setFeedbackEntity(pg.getEntityByUid(uid), actionId)
	end
end

function ClientInteractionAnimationComponent:setFeedbackFriend(action, actionId)
	if not action then
		return
	end

	self:setFeedbackUid(action.requestUid, actionId)
	self:setFeedbackUid(action.acceptUid, actionId)
end

function ClientInteractionAnimationComponent:setFeedbackMulti(action, actionId)
	if not action then
		return
	end

	self:setFeedbackUid(action.creatorId, actionId)

	for _, uid in pairs(action.memberIds or EMPTY_TABLE) do
		self:setFeedbackUid(uid, actionId)
	end
end

function ClientInteractionAnimationComponent:schedulePetFeedback()
	local actions = pg.me and pg.me._petActionFeedbackActions

	if not pg.me or pg.me._petActionFeedbackTimer or not actions or not next(actions) then
		return
	end

	pg.me._petActionFeedbackTimer = TimerManager.addTimer(SysConfigData.PET_ACTION_FEEDBACK_CD or 10, function()
		if pg.me then
			pg.me._petActionFeedbackTimer = nil
		end

		if pg.me then
			pg.me:tryPetActionFeedback()
		end
	end)
end

function ClientInteractionAnimationComponent:tryPetActionFeedback()
	local actions = pg.me and pg.me._petActionFeedbackActions

	if not pg.me or pg.me._petActionFeedbackTimer or not actions or not next(actions) then
		return
	end

	local range = SysConfigData.PET_ACTION_FEEDBACK_RANGE or 5
	local chosenEnt, chosenAnimPool, chosenEmojiPool, count

	for actorId, actionId in pairs(actions) do
		local ent = pg.getEntityByActorId(actorId)
		local data = AppearanceAction[actionId]

		if not ent or not data then
			actions[actorId] = nil
		elseif Vector3.SqrDistance(ent:getPosition(), pg.me:getPosition()) <= range * range then
			local isSelf = ent.uid == pg.me.uid
			local animPool = isSelf and data.ownerPetAction or data.passerbypetAction
			local emojiPool = isSelf and data.ownerpetEmoji or data.passerbypetEmoji

			if animPool and emojiPool then
				count = (count or 0) + 1

				if math.random(count) == 1 then
					chosenEnt, chosenAnimPool, chosenEmojiPool = ent, animPool, emojiPool
				end
			end
		end
	end

	if chosenEnt then
		local anim = randomItem(chosenAnimPool)
		local emoji = randomItem(chosenEmojiPool)

		if anim and emoji then
			local context = CTRPool.getContext()

			context.entityActorId = chosenEnt.actorId

			if Utils.isTable(anim) and (anim[2] or anim[3]) then
				context.animationStartKey, context.animationLoopKey, context.animationEndKey = anim[1], anim[2], anim[3]
			else
				context.animationKey = Utils.isTable(anim) and anim[1] or anim
			end

			context.emojiBubbleKey = Utils.isTable(emoji) and emoji[1] or emoji

			local petEnt = pg.me:getCurPetEntity()

			if petEnt then
				AIControllerUtils.sendAIEvent(petEnt, "Event_PetRespondToPlayerAction", context)
				self:schedulePetFeedback()
			else
				CTRPool.tryReturnContext(context)
			end
		end
	end
end

function ClientInteractionAnimationComponent:ctor()
	return
end

function ClientInteractionAnimationComponent:init(avtDict)
	self:disableMoveAction(false)

	return true
end

function ClientInteractionAnimationComponent:isDeformMultiInteractAction(action)
	return action and action.actionId > 0 and action.petPrototypeId > 0
end

function ClientInteractionAnimationComponent:tryRefreshInteractionAction()
	if not self.isModelLoaded or not self.visible or not self.eModel then
		return
	end

	if pg.game.social.interactGestureComponent:checkPlayerShouldDeform(self.uid) then
		pg.game.social.interactGestureComponent:setPendingDeform(self.uid, nil)
		ClientUtils.entityCancelDeform(self)
	end

	if self.singleActionState and self.singleActionState > 0 then
		self:on_singleActionState_changed(0, self.singleActionState)
	end

	if self.friendInteractAction and self.friendInteractAction.actionId > 0 then
		self:on_friendInteractAction_changed({
			actionId = 0
		}, self.friendInteractAction)
	end

	if self.multiInteractAction and self.multiInteractAction.actionId > 0 then
		self:on_multiInteractAction_changed({
			actionId = 0
		}, self.multiInteractAction)
	end
end

function ClientInteractionAnimationComponent:EVENT_OnAnimatorReady()
	self:tryRefreshInteractionAction()
end

function ClientInteractionAnimationComponent:EVENT_OnModelVisibleChange(visible)
	if visible then
		self:tryRefreshInteractionAction()
	end
end

function ClientInteractionAnimationComponent:preDestroy()
	HandheldAppearanceUtils.clear(self)

	if self and pg.me and self == pg.me then
		TimerManager.removeTimer(self._petActionFeedbackTimer)

		self._petActionFeedbackTimer = nil
		self._petActionFeedbackActions = nil

		if self.singleActionState and self.singleActionState > 0 then
			self:playSingleAction(0)
		end

		if self.friendInteractAction and self.friendInteractAction.actionId > 0 then
			self:exitFriendAction()
		end

		if self.multiInteractAction and self.multiInteractAction.actionId > 0 then
			self:exitMultiAction()
		end

		return
	end

	self:setFeedbackEntity(self, 0)

	if self.singleActionState and self.singleActionState > 0 then
		self:on_singleActionState_changed(self.singleActionState, 0)
	end

	if self.friendInteractAction and self.friendInteractAction.actionId > 0 then
		self:on_friendInteractAction_changed(self.friendInteractAction, {
			actionId = 0
		})
	end

	if self.multiInteractAction and self.multiInteractAction.actionId > 0 then
		self:on_multiInteractAction_changed(self.multiInteractAction, {
			actionId = 0
		})
	end
end

function ClientInteractionAnimationComponent:destroy()
	TimerManager.removeTimer(self._petActionFeedbackTimer)

	self._petActionFeedbackTimer = nil
	self._petActionFeedbackActions = nil
end

function ClientInteractionAnimationComponent:setFeedbackEntity(ent, actionId)
	if not ent or not ent.actorId then
		return
	end

	if not pg.me then
		return
	end

	pg.me._petActionFeedbackActions = pg.me._petActionFeedbackActions or {}
	pg.me._petActionFeedbackActions[ent.actorId] = actionId and actionId > 0 and actionId or nil
end

function ClientInteractionAnimationComponent:playSingleAction(actionId)
	self:serverMsg("RPC_CS_SetSingleActionState", actionId)
end

function ClientInteractionAnimationComponent:EVENT_OnCharacterStateChange(oldState, newState)
	local handheldPreview = self._appearanceHandheldPreviewComponent

	if handheldPreview and handheldPreview.isActive and handheldPreview.onCharacterStateChanged then
		handheldPreview:onCharacterStateChanged(newState)
	end
end

function ClientInteractionAnimationComponent:on_singleActionState_changed(oldVal, newVal)
	self.logger:debug("on_singleActionState_changed", inspect(oldVal), inspect(newVal))

	if self.updateStateCache then
		self:updateStateCache("SOCIAL_INTERACT_ACTION_ST")
	end

	local handheldPreview = self._appearanceHandheldPreviewComponent

	if handheldPreview and handheldPreview.isActive and handheldPreview.onActionStateChanged then
		handheldPreview:onActionStateChanged(newVal)
	end

	if not self.eModel.modelView:IsAnimatorRead() then
		return
	end

	local handheldToken = HandheldAppearanceUtils.showForAction(self, newVal)

	self:setFeedbackEntity(self, newVal)
	self:tryPetActionFeedback()
	pg.game.social.interactGestureComponent:onSingleActionStateChanged(oldVal, newVal, self, handheldToken)

	local disableMove = HandheldAppearanceUtils.shouldDisableMove(self, newVal)

	if disableMove == nil then
		local actionConfig = AppearanceAction[newVal]

		disableMove = newVal > 0 and actionConfig and not actionConfig.isMoveStop or false
	end

	self:disableMoveAction(disableMove)
end

function ClientInteractionAnimationComponent:requestFriendAction(uid, actionId, isSkipAccept, callback)
	local playerInfo = pg.game.chat:getPlayerInfo(uid)

	if PlatformSocialService:peekPlatformUserBlockedByLocalUser(playerInfo) == true then
		pg.global.showBubbleMessage(NoticeDef.PRIVACY_SETTING_MISSMATCH)

		return
	end

	if not isSkipAccept then
		if playerInfo then
			local displayName = LuaUIUtils.getPlayerDisplayName(uid, playerInfo.playerName)
			local _h = ClientInteractionAnimationComponent._platformHooks

			displayName = _h and _h.resolveInteractPlayerDisplayName and _h.resolveInteractPlayerDisplayName(self, uid, playerInfo, displayName) or displayName

			pg.global.showBubbleMessageRaw(pg.getFormatText(pg.getGameString("REQUEST_FRIEND_ACTION"), displayName))
		else
			self:queryPlayerInfo(uid, nil, true, function(info)
				local displayName = LuaUIUtils.getPlayerDisplayName(uid, info.playerName)
				local _h = ClientInteractionAnimationComponent._platformHooks

				displayName = _h and _h.resolveInteractPlayerDisplayName and _h.resolveInteractPlayerDisplayName(self, uid, info, displayName) or displayName

				pg.global.showBubbleMessageRaw(pg.getFormatText(pg.getGameString("REQUEST_FRIEND_ACTION"), displayName))
			end)
		end
	end

	self:serverMsg("RPC_CS_RequestFriendAction", uid, actionId, isSkipAccept, function(result, reason)
		if callback then
			callback(result, reason)
		end
	end)
end

function ClientInteractionAnimationComponent:confirmFriendAction(uid, actionId, isAccept, callback)
	self:serverMsg("RPC_CS_ConfirmFriendAction", uid, actionId, isAccept, function(result, reason)
		if callback then
			callback(result, reason)
		end
	end)
end

function ClientInteractionAnimationComponent:RPC_SC_RequestFriendAction(uid, actionId)
	pg.me:queryPlayerInfo(uid, nil, true, function(playerInfo)
		if PlatformSocialService:peekPlatformUserBlockedByLocalUser(playerInfo) == true then
			return
		end

		pg.game.chat:recvRequestFriendAction(uid, actionId)
	end)
end

function ClientInteractionAnimationComponent:RPC_SC_RefuseFriendAction(uid, actionId)
	self.logger:debug("RPC_SC_RefuseFriendAction uid=%s actionId=%s", uid, actionId)
	pg.game.chat:handleTopLogoFriendInteract(self.uid, false, ClientConst.FriendInteractType.FriendAction)
	pg.global.showBubbleMessageRaw(pg.getGameString("CHAT_PVP_INVITE_REFUSE_1"))
end

function ClientInteractionAnimationComponent:exitFriendAction()
	pg.me:serverMsg("RPC_CS_ExitFriendAction")
end

function ClientInteractionAnimationComponent:on_friendInteractAction_changed(oldVal, newVal)
	self.logger:debug("on_friendInteractAction_changed", inspect(oldVal), inspect(newVal))

	if self.updateStateCache then
		self:updateStateCache("SOCIAL_INTERACT_ACTION_ST")
	end

	if not self.eModel.modelView:IsAnimatorRead() then
		return
	end

	self:setFeedbackFriend(oldVal, 0)
	self:setFeedbackFriend(newVal, newVal and newVal.actionId or 0)
	self:tryPetActionFeedback()

	local oldRequestUid = oldVal and oldVal.requestUid or ""
	local oldAcceptUid = oldVal and oldVal.acceptUid or ""
	local newRequestUid = newVal and newVal.requestUid or ""
	local newAcceptUid = newVal and newVal.acceptUid or ""

	if self.uid ~= oldRequestUid and self.uid ~= oldAcceptUid and self.uid ~= newRequestUid and self.uid ~= newAcceptUid then
		return
	end

	if pg.game.social.interactGestureComponent then
		pg.game.social.interactGestureComponent:onFriendInteractActionChanged(oldVal, newVal)
	end

	self:disableMoveAction(newVal.actionId > 0 and not AppearanceAction[newVal.actionId].isMoveStop)
end

function ClientInteractionAnimationComponent:playMultiAction(actionId, callback)
	self:serverMsg("RPC_CS_PlayMultiAppearanceAction", actionId, function(result)
		if callback then
			callback(result)
		end
	end)
end

function ClientInteractionAnimationComponent:joinMultiAction(targetUid, callback)
	self:serverMsg("RPC_CS_JoinMultiAppearanceAction", targetUid, function(result)
		if callback then
			callback(result)
		end
	end)
end

function ClientInteractionAnimationComponent:exitMultiAction()
	self:serverMsg("RPC_CS_ExitMultiAppearanceAction")
end

function ClientInteractionAnimationComponent:refreshMultiInteractActionTopLogo(multiInteractAction)
	local targetEnt = self

	if self.isControllingPet and self:isControllingPet() then
		targetEnt = self:getCurPetEntity()
	end

	if not targetEnt then
		return
	end

	if multiInteractAction.actionId > 0 and multiInteractAction.creatorId == self.uid then
		targetEnt:ensureAndExecuteTplComMethod(UIConst.TOPLOGO_COMPONENT.ACTION_STATE, "setMultiInteractAction", multiInteractAction)
	else
		targetEnt:executeTopLogoComponentMethod(UIConst.TOPLOGO_COMPONENT.ACTION_STATE, "setMultiInteractAction", multiInteractAction)
	end
end

function ClientInteractionAnimationComponent:on_multiInteractAction_changed(oldVal, newVal)
	self.logger:debug("on_multiInteractAction_changed", inspect(oldVal), inspect(newVal))

	if self.updateStateCache then
		self:updateStateCache("SOCIAL_INTERACT_ACTION_ST")
	end

	self:refreshMultiInteractActionTopLogo(newVal)

	if not self.eModel.modelView:IsAnimatorRead() then
		if self:isDeformMultiInteractAction(oldVal) then
			pg.game.social.interactGestureComponent:setPendingDeform(self.uid, true)
		end

		return
	end

	self:setFeedbackMulti(oldVal, 0)
	self:setFeedbackMulti(newVal, newVal and newVal.actionId or 0)
	self:tryPetActionFeedback()

	local oldCreatorId = oldVal and oldVal.creatorId or ""
	local newCreatorId = newVal and newVal.creatorId or ""
	local isCreatorAction = self.uid == oldCreatorId or self.uid == newCreatorId
	local hasMultiAction = (oldVal and oldVal.actionId or 0) > 0 or (newVal and newVal.actionId or 0) > 0

	if (isCreatorAction or hasMultiAction) and pg.game.social.interactGestureComponent then
		pg.game.social.interactGestureComponent:onMultiInteractActionChanged(oldVal, newVal, self.uid)
	end

	local actionConfig = AppearanceAction[newVal.actionId]
	local disableMove = newVal.actionId > 0 and actionConfig and not actionConfig.isMoveStop
	local enableCreatorMove = disableMove and actionConfig.enableCreatorMove == 1 and self.uid == newVal.creatorId

	self:disableMoveAction(disableMove, enableCreatorMove)
end

function ClientInteractionAnimationComponent:setMoveOnlyInputActionEnabled(enable)
	for _, actionPath in ipairs(HotkeyConst.PLAYER_MOVE_ONLY_BLOCK_ACTIONS) do
		pg.game.input:setInputActionEnabled(actionPath, enable, HotkeyConst.INPUT_BLOCK_FLAG.InteractGesture)
	end
end

function ClientInteractionAnimationComponent:disableMoveAction(disable, enableMoveOnly)
	if self ~= pg.me then
		return
	end

	if disable and enableMoveOnly then
		self:setMoveOnlyInputActionEnabled(false)
		pg.game.input:setInputMapEnabled(HotkeyConst.INPUT_MAP_ACTION_KEY.Player, true, HotkeyConst.INPUT_BLOCK_FLAG.InteractGesture)

		return
	end

	self:setMoveOnlyInputActionEnabled(true)
	pg.game.input:setInputMapEnabled(HotkeyConst.INPUT_MAP_ACTION_KEY.Player, not disable, HotkeyConst.INPUT_BLOCK_FLAG.InteractGesture)
end

function ClientInteractionAnimationComponent:EVENT_OnMoveInputStateChanged(nv)
	if not nv then
		return
	end

	local moveStop = false

	if self.singleActionState and self.singleActionState > 0 then
		local handheldMoveStop = HandheldAppearanceUtils.shouldStopOnMove(self, self.singleActionState)
		local actionConfig = AppearanceAction[self.singleActionState]

		if handheldMoveStop ~= nil then
			moveStop = handheldMoveStop
		elseif actionConfig and actionConfig.isMoveStop then
			moveStop = true
		end
	elseif self.friendInteractAction and self.friendInteractAction.actionId > 0 and AppearanceAction[self.friendInteractAction.actionId].isMoveStop then
		moveStop = true
	elseif self.multiInteractAction and self.multiInteractAction.actionId > 0 and AppearanceAction[self.multiInteractAction.actionId].isMoveStop then
		moveStop = true
	elseif pg.game.social.interactGestureComponent.curInteractionSession and pg.game.social.interactGestureComponent.curInteractionSession.type == pg.game.social.interactGestureComponent.InteractionAnimationType.HumanPetInteract then
		moveStop = true
	end

	if not moveStop then
		return
	end

	pg.game.social.interactGestureComponent:cancelCurInteraction()
end

function ClientInteractionAnimationComponent:on_actionShowIds_changed(oldVal, newVal)
	if self ~= pg.me then
		return
	end

	facade:SendMessageCommand(MessageName.INTERACT_GESTURE_UNLOCK_CHANGED)
	facade:SendMessageCommand(MessageName.PHOTO_ASSET_UNLOCK_CHANGED)
end

return ClientInteractionAnimationComponent
