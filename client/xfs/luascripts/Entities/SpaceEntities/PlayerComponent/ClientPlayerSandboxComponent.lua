-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientPlayerSandboxComponent.lua

local Class = require("Core.Framework.Class")
local ClientChestRewardAttractCtrl = require("GameApp.Sandbox.ClientChestRewardAttractCtrl")
local InteractData = require("Data.interact_data")
local ConflictTypes = require("Common.ConflictTypes")
local MessageName = require("Const.MessageName")
local InteractionConst = require("Common.Const.InteractionConst")
local PlayableConst = require("Common.Const.PlayableConst")
local Time = require("Core.Common.Time")
local Utils = require("Common.Utils.Utils")
local ClientPlayerSandboxComponent = Class.Component("ClientPlayerSandboxComponent")

function ClientPlayerSandboxComponent:start()
	self._entityAIEventInfo = {}

	self:refreshCancelLevelItemInteractState()
	self:refreshAnimState()
end

function ClientPlayerSandboxComponent:preDestroy()
	self:removeCancelLevelItemInteractTrigger()
end

function ClientPlayerSandboxComponent:isInLevelItemInteractState()
	return self.interactLevelItemPrototypeId and self.interactLevelItemPrototypeId ~= 0
end

function ClientPlayerSandboxComponent:tempDisableCancelLevelInteract(delayTime)
	self.canCancelLevelItemInteractTime = Time.realSecondCache + delayTime
end

function ClientPlayerSandboxComponent:checkIsInteractWith(interactSandboxId, interactLevelItemId)
	return self.interactSandboxId == interactSandboxId and self.interactLevelItemId == interactLevelItemId
end

function ClientPlayerSandboxComponent:checkCanCancelLevelItemInteractState()
	if self.canCancelLevelItemInteractTime and self.canCancelLevelItemInteractTime > Time.realSecondCache then
		return false
	end

	return true
end

function ClientPlayerSandboxComponent:cancelLevelItemInteractState()
	self:serverMsg("RPC_CS_CancelLevelItemInteractState")
end

function ClientPlayerSandboxComponent:RPC_SC_PlayChestRewardAttract(payload)
	ClientChestRewardAttractCtrl.playSyncedAbsorbBatch(payload)
end

function ClientPlayerSandboxComponent:on_interactLevelItemPrototypeId_changed(oldVal, newVal)
	if self.updateStateCache then
		self:updateStateCache("MULTI_INTERACT_ST")
	end

	if self.interactLevelItemPrototypeId and self.interactLevelItemPrototypeId ~= 0 then
		local interactInfo = InteractData[self.interactLevelItemPrototypeId] or {}

		self.currentInteractLevelItemPrototypeId = self.interactLevelItemPrototypeId

		local startAnim = interactInfo.startAnim
		local loopAnim = interactInfo.loopAnim

		if startAnim and self.isMainPlayer then
			local interactAnimState = self:playAnimation(startAnim, true)

			self.levelItemInteractAnim = startAnim

			interactAnimState:AddEndCallback(function(reason)
				if reason == PlayableConst.END_REASON.PLAYBACK and loopAnim then
					self:playAnimation(loopAnim)

					self.levelItemInteractAnim = loopAnim
				end
			end)
		elseif loopAnim then
			self:playAnimation(loopAnim)

			self.levelItemInteractAnim = loopAnim
		elseif self.levelItemInteractAnim then
			self:stopAnimation(self.levelItemInteractAnim)

			self.levelItemInteractAnim = nil
		end
	else
		if self.levelItemInteractAnim then
			self:stopAnimation(self.levelItemInteractAnim)

			self.levelItemInteractAnim = nil
		end

		if self.currentInteractLevelItemPrototypeId and self.isMainPlayer then
			local interactInfo = InteractData[self.currentInteractLevelItemPrototypeId] or {}
			local endAnim = interactInfo.endAnim

			if endAnim then
				local state = self:playTrivialAnimation(endAnim)

				state:AddAutoTransition(0)
			end
		end
	end

	self:refreshCancelLevelItemInteractState()
end

function ClientPlayerSandboxComponent:refreshAnimState()
	if self.interactLevelItemPrototypeId and self.interactLevelItemPrototypeId ~= 0 then
		self.currentInteractLevelItemPrototypeId = self.interactLevelItemPrototypeId

		local interactInfo = InteractData[self.interactLevelItemPrototypeId] or {}
		local loopAnim = interactInfo.loopAnim

		if loopAnim then
			self:playAnimation(loopAnim)

			self.levelItemInteractAnim = loopAnim
		end
	end
end

function ClientPlayerSandboxComponent:refreshCancelLevelItemInteractState()
	if self.isMainPlayer then
		if self:isInLevelItemInteractState() then
			facade:SendMessageCommand(MessageName.ENTER_TRIGGER, {
				dist = 0,
				globalId = self:getGlobalId(),
				actionPrototypeId = InteractionConst.INTERACT_CANCEL_MULTI_INTERACT_ACTION_ID,
				triggerSrcType = InteractionConst.TRIGGER_SRC_TYPE.LEVEL_ITEM_INTERACT,
				canInteractiveFunc = function()
					return self:checkCanCancelLevelItemInteractState()
				end,
				interactFunc = function()
					self:cancelLevelItemInteractState()
				end
			})
		else
			self:removeCancelLevelItemInteractTrigger()
		end
	end
end

function ClientPlayerSandboxComponent:removeCancelLevelItemInteractTrigger()
	if not self.isMainPlayer then
		return
	end

	facade:SendMessageCommand(MessageName.LEAVE_TRIGGER, {
		actionPrototypeId = InteractionConst.INTERACT_CANCEL_MULTI_INTERACT_ACTION_ID,
		globalId = self:getGlobalId(),
		triggerSrcType = InteractionConst.TRIGGER_SRC_TYPE.LEVEL_ITEM_INTERACT
	})
end

function ClientPlayerSandboxComponent:getSandboxPhase(sandboxId)
	return self.sandboxPhase[sandboxId] or 0
end

function ClientPlayerSandboxComponent:registerEntityAIEventInfo(staticId, planId)
	if not staticId or not planId then
		return
	end

	self._entityAIEventInfo[staticId] = self._entityAIEventInfo[staticId] or {}

	local count = self._entityAIEventInfo[staticId][planId] or 0

	self._entityAIEventInfo[staticId][planId] = count + 1
end

function ClientPlayerSandboxComponent:unRegisterEntityAIEventInfo(staticId, planId)
	if not self._entityAIEventInfo or not self._entityAIEventInfo[staticId] then
		return
	end

	local count = self._entityAIEventInfo[staticId][planId] or 0

	self._entityAIEventInfo[staticId][planId] = count - 1

	if self._entityAIEventInfo[staticId][planId] <= 0 then
		self._entityAIEventInfo[staticId][planId] = nil
	end

	if Utils.isEmptyTable(self._entityAIEventInfo[staticId]) then
		self._entityAIEventInfo[staticId] = nil
	end
end

function ClientPlayerSandboxComponent:getEntityAIEventInfo(staticId, planId)
	if not staticId or not self._entityAIEventInfo or not self._entityAIEventInfo[staticId] then
		return
	end

	if not planId then
		return not Utils.tableIsEmptyOrNil(self._entityAIEventInfo[staticId])
	else
		return self._entityAIEventInfo[staticId][planId]
	end
end

function ClientPlayerSandboxComponent:getSandboxFinishQuestEvent(sandboxId, eventId)
	if not self.sandboxQuestEventMap[sandboxId] then
		return false
	end

	return self.sandboxQuestEventMap[sandboxId][eventId] or false
end

return ClientPlayerSandboxComponent
