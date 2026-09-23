-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Social\\Component\\CocktailInviteBubble.lua

local Class = require("Core.Framework.Class")
local TimerManager = require("Core.Timer.TimerManager")
local MessageName = require("Const.MessageName")
local InteractionConst = require("Common.Const.InteractionConst")
local AppearanceAction = require("Data.appearance_action_data")
local NoticeDef = require("Common.NoticeDef")
local Utils = require("Common.Utils.Utils")
local SocialConst = require("Common.Const.SocialConst")
local CocktailInviteBubble = Class.LiteClass("CocktailInviteBubble")

CocktailInviteBubble.INVITE_ACTION_ID = InteractionConst.STYLE_CONST.ARK_COCKTAIL_INTERACT

function CocktailInviteBubble:getCocktailCost()
	local actionData = AppearanceAction[SocialConst.COCKTAIL_ACTION_ID]

	if actionData == nil or not Utils.isTable(actionData.costItemId) then
		return nil, nil
	end

	return actionData.costItemId[1], actionData.costItemId[2]
end

function CocktailInviteBubble:isNeedTargetAgree(needTargetAgree)
	if needTargetAgree == true then
		return true
	end

	if type(needTargetAgree) == "number" and needTargetAgree > 0 then
		return true
	end

	return false
end

function CocktailInviteBubble:getInviteTargetUid(ent)
	if ent == nil then
		return nil
	end

	if ent.CONTROLLING_PET_ST and ent:CONTROLLING_PET_ST() == true and ent.master ~= nil then
		return ent.master.uid
	end

	return ent.uid
end

function CocktailInviteBubble:isEntityInRange(ent, distance)
	if ent == nil or pg.pawn == nil then
		return false
	end

	if ent.visible == false then
		return false
	end

	if not ent.getPosition or not pg.pawn.getPosition then
		return false
	end

	local entPos = ent:getPosition()
	local pawnPos = pg.pawn:getPosition()

	if entPos == nil or pawnPos == nil then
		return false
	end

	local dis = Vector3.Distance(entPos, pawnPos)

	return dis <= distance
end

function CocktailInviteBubble:buildCocktailGestureData()
	local actionData = AppearanceAction[SocialConst.COCKTAIL_ACTION_ID]

	if actionData == nil then
		return nil
	end

	local gestureData = {}

	for key, value in pairs(actionData) do
		gestureData[key] = value
	end

	gestureData.index = SocialConst.COCKTAIL_ACTION_ID

	return gestureData
end

function CocktailInviteBubble:resetData()
	if self._bubbles ~= nil then
		local actorIds = {}

		for actorId, _ in pairs(self._bubbles) do
			actorIds[#actorIds + 1] = actorId
		end

		for _, actorId in ipairs(actorIds) do
			self:detach(actorId)
		end
	end

	self._bubbles = {}
end

function CocktailInviteBubble:_selfHasCocktail()
	if pg.me == nil then
		return false
	end

	local costItemId, costItemNum = self:getCocktailCost()

	if costItemId == nil or costItemNum == nil then
		return false
	end

	local count = pg.me:getItemCountById(costItemId) or 0

	return costItemNum <= count
end

function CocktailInviteBubble:_checkCocktailInvite(targetEnt, gestureData, interactGestureComponent)
	if targetEnt == nil or gestureData == nil or interactGestureComponent == nil then
		return false
	end

	if pg.me == nil then
		return false
	end

	local targetUid = self:getInviteTargetUid(targetEnt)

	if targetUid == nil then
		return false
	end

	local friendshipLevel = tonumber(gestureData.friendshipLevel)

	if friendshipLevel ~= nil and friendshipLevel > 0 then
		local curFriendshipLevel = pg.game.chat:getFriendship(targetUid) or 0

		if curFriendshipLevel < friendshipLevel then
			pg.global.showBubbleMessage(NoticeDef.FRIEND_INTIMACY_NOT_ENOUGH)

			return false
		end
	end

	if interactGestureComponent.interactionAnimationManager == nil then
		return true
	end

	local previewActionData = interactGestureComponent:getGenderMatchedFriendActionData(gestureData, pg.me, targetEnt)
	local session = interactGestureComponent:getInteractionSession(previewActionData, pg.me, targetEnt)

	if session == nil then
		return false
	end

	local checkPass = interactGestureComponent:queryCanInteract(session)

	interactGestureComponent:cancelInteraction(session)

	return checkPass == true
end

function CocktailInviteBubble:_requestCocktailInvite(targetEnt)
	if targetEnt == nil then
		return
	end

	local interactGestureComponent = pg.game.social.interactGestureComponent

	if interactGestureComponent == nil then
		return
	end

	local gestureData = self:buildCocktailGestureData()

	if gestureData == nil then
		return
	end

	if self:_checkCocktailInvite(targetEnt, gestureData, interactGestureComponent) ~= true then
		return
	end

	local isSkipAccept = self:isNeedTargetAgree(gestureData.needTargetAgree) ~= true

	interactGestureComponent:requestFriendAction(targetEnt, gestureData, isSkipAccept)
	self:detach(targetEnt.actorId)
end

function CocktailInviteBubble:tryAttach(targetEnt)
	if targetEnt == nil then
		return
	end

	if self:_selfHasCocktail() ~= true then
		return
	end

	local actorId = targetEnt.actorId

	if actorId == nil then
		return
	end

	local globalId = targetEnt:getGlobalId()

	if globalId == nil then
		return
	end

	if self._bubbles == nil then
		self._bubbles = {}
	end

	self:detach(actorId)

	local triggerInfo = {
		globalId = globalId,
		actionPrototypeId = CocktailInviteBubble.INVITE_ACTION_ID,
		interactionType = InteractionConst.INTERACTION_TYPE_ARK_PLAYER_INTERACT,
		overrideType = InteractionConst.INTERACTION_TYPE_ARK_PLAYER_INTERACT,
		canInteractiveFunc = function()
			local curEnt = pg.getEntityByActorId(actorId)

			return self:_selfHasCocktail() == true and self:isEntityInRange(curEnt, SocialConst.COCKTAIL_INVITE_DISTANCE) == true
		end,
		interactFunc = function()
			local curEnt = pg.getEntityByActorId(actorId)

			self:_requestCocktailInvite(curEnt)
		end
	}

	self._bubbles[actorId] = {
		triggerInfo = triggerInfo,
		timerId = TimerManager.addTimer(SocialConst.COCKTAIL_INVITE_TTL_SEC, function()
			self:detach(actorId)
		end)
	}

	facade:SendMessageCommand(MessageName.ENTER_TRIGGER, triggerInfo)
end

function CocktailInviteBubble:detach(actorId)
	if actorId == nil or self._bubbles == nil then
		return
	end

	local bubble = self._bubbles[actorId]

	if bubble == nil then
		return
	end

	if bubble.timerId ~= nil then
		TimerManager.removeTimer(bubble.timerId)
	end

	if bubble.triggerInfo ~= nil then
		facade:SendMessageCommand(MessageName.LEAVE_TRIGGER, bubble.triggerInfo)
	end

	self._bubbles[actorId] = nil
end

function CocktailInviteBubble:destroy()
	self:resetData()
end

return CocktailInviteBubble
