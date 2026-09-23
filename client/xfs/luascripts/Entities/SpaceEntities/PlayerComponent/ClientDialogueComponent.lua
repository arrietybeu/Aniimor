-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientDialogueComponent.lua

local class = require("Core.Framework.Class")
local DialogueGraphConst = require("Const.DialogueGraphConst")
local ClientDialogueComponent = class.Component("ClientDialogueComponent")

function ClientDialogueComponent:ctor()
	self.currentBranchState = {}
	self.playDialogueGraphInfo = {}
end

function ClientDialogueComponent:start()
	return
end

function ClientDialogueComponent:ReqPlayDialogueGraph(dialogueGraphId, context)
	self:serverMsg("RPC_CS_RequestPlayDialogueGraph", dialogueGraphId, context or {})
end

function ClientDialogueComponent:ReqFinishPlayDialogueGraph(dialogueGraphId, ret, context, rpcArgs, callback)
	self:serverMsg("RPC_CS_FinishPlayDialogueGraph", dialogueGraphId, ret, context or {}, rpcArgs or {}, function(ret)
		if callback then
			callback(ret)
		end
	end)
end

function ClientDialogueComponent:ReqBatchDialogue(eventId, batchDialogueList, isRandom)
	self:serverMsg("RPC_CS_ReqBatchDialogue", eventId, batchDialogueList, isRandom or false)
end

function ClientDialogueComponent:RPC_SC_PlayBatchDialogue(eventId, curBatchDialogueId)
	local context = {}

	context.eventId = eventId

	pg.game.dialogue:playDialogueGraph(curBatchDialogueId, nil, nil, context)
end

function ClientDialogueComponent:SetSkipScenePromptToday(noSkipScenePromptToday)
	self:serverMsg("RPC_CS_SetSkipScenePromptToday", noSkipScenePromptToday)
end

function ClientDialogueComponent:DialoguePauseRenewInvincible(entActorIds, dialogueGraphId)
	if entActorIds == nil or #entActorIds == 0 then
		return
	end

	self:serverMsg("RPC_CS_DialoguePauseRenewInvincible", entActorIds, dialogueGraphId)
end

function ClientDialogueComponent:RPC_SC_GmCloseCurDialogueGraph(dialogueGraphId)
	if dialogueGraphId == 0 then
		pg.game.dialogue:stopAllDialogueGraph(DialogueGraphConst.INTERRUPTED_FORCE_CLOSE_SERVER)
	else
		pg.game.dialogue:stopDialogueGraph(dialogueGraphId)
	end
end

return ClientDialogueComponent
