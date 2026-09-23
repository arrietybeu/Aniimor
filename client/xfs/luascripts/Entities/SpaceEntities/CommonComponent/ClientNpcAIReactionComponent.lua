-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientNpcAIReactionComponent.lua

local Class = require("Core.Framework.Class")
local AiConst = require("Common.Const.AiConst")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local EventBus = require("Common.Ability.Buff.EventBus")
local AbilityConst = require("Common.Const.AbilityConst")
local EventConst = require("Common.Const.EventConst")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local CTRPool = require("Common.AICt.CTRPool")
local ClientNpcAIReactionComponent = Class.Component("ClientNpcAIReactionComponent")

function ClientNpcAIReactionComponent:ctor()
	self.NpcAIReaction = {
		trapEnts = {},
		castAbilityObserver = EventBus.EventObserver()
	}
end

function ClientNpcAIReactionComponent:onEnterSpace()
	if not Utils.isNpc(self) then
		return
	end

	if self.npcAIReactionEvent ~= nil then
		return
	end

	if self.addRangeEvent then
		self.npcAIReactionEvent = self:addRangeEvent(Const.TRAP_EVENT_ID_NPC_AI_REACTION, AiConst.NpcReactionRange, AiConst.NpcReactionRange)
	end
end

function ClientNpcAIReactionComponent:onLeaveSpace()
	if self.npcAIReactionEvent then
		self:removeRangeEvent(self.npcAIReactionEvent, true)

		self.npcAIReactionEvent = nil
	end
end

function ClientNpcAIReactionComponent:onEnterTrap(actorId, eventId)
	if eventId ~= Const.TRAP_EVENT_ID_NPC_AI_REACTION then
		return
	end

	if self.NpcAIReaction.trapEnts[actorId] then
		return
	end

	self.NpcAIReaction.trapEnts[actorId] = true

	local ent = pg.getEntityByActorId(actorId)

	if ent and ent.subject then
		self.NpcAIReaction.castAbilityObserver:listen(ent.subject, AbilityConst.COMBAT_EVENT_CAST_ABILITY, self:getEntityCastAbilityCallback())
	end

	if Utils.isPlayer(ent) then
		ent.eventEmitter:addEventListener(EventConst.ON_PLAYER_SWITCH_CONTROL_ALL_CLIENT, self:getPlayerSwitchControllCallback())
	end
end

function ClientNpcAIReactionComponent:onLeaveTrap(actorId, eventId)
	if eventId ~= Const.TRAP_EVENT_ID_NPC_AI_REACTION then
		return
	end

	if not self.NpcAIReaction.trapEnts[actorId] then
		return
	end

	self.NpcAIReaction.trapEnts[actorId] = nil

	local ent = pg.getEntityByActorId(actorId)

	if ent and ent.subject then
		self.NpcAIReaction.castAbilityObserver:unlisten(ent.subject, AbilityConst.COMBAT_EVENT_CAST_ABILITY, self:getEntityCastAbilityCallback())
	end

	if Utils.isPlayer(ent) then
		ent.eventEmitter:removeEventListener(EventConst.ON_PLAYER_SWITCH_CONTROL_ALL_CLIENT, self:getPlayerSwitchControllCallback())
	end
end

function ClientNpcAIReactionComponent:onDestroy()
	if self.NpcAIReaction.castAbilityObserver then
		self.NpcAIReaction.castAbilityObserver:unlistenAll()
	end
end

function ClientNpcAIReactionComponent:getEntityCastAbilityCallback()
	if self.NpcAIReaction.entityCastAbilityCallback == nil then
		function self.NpcAIReaction.entityCastAbilityCallback(combatContext)
			local context = CTRPool.getContext()

			context.entityActorId = combatContext.actorId

			AIControllerUtils.sendAIEvent(self, "EntityCastAbilityTrigger", context)
		end
	end

	return self.NpcAIReaction.entityCastAbilityCallback
end

function ClientNpcAIReactionComponent:getPlayerSwitchControllCallback()
	if self.NpcAIReaction.playerSwitchControllCallback == nil then
		function self.NpcAIReaction.playerSwitchControllCallback(actorId)
			local context = CTRPool.getContext()

			context.entityActorId = actorId

			AIControllerUtils.sendAIEvent(self, "PlayerSwitchControllTrigger", context)
		end
	end

	return self.NpcAIReaction.playerSwitchControllCallback
end

return ClientNpcAIReactionComponent
