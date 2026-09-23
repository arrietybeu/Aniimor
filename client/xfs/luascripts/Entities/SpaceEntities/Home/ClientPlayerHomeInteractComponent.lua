-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\Home\\ClientPlayerHomeInteractComponent.lua

local Class = require("Core.Framework.Class")
local HomeObjectData = require("Data.home_object_data")
local ClientConst = require("Const.ClientConst")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local InteractData = require("Data.interact_data")
local PlayableConst = require("Common.Const.PlayableConst")
local MessageName = require("Const.MessageName")
local InteractionConst = require("Common.Const.InteractionConst")
local ClientPlayerHomeInteractComponent = Class.Component("ClientPlayerHomeInteractComponent")

function ClientPlayerHomeInteractComponent:start()
	self:refreshCancelHomeInteractState()
	self:refreshHomeInteractAnimState()
end

function ClientPlayerHomeInteractComponent:preDestroy()
	self:removeCancelHomeInteractTrigger()
end

function ClientPlayerHomeInteractComponent:isInHomeInteractState()
	return self.interactHomePrototypeId and self.interactHomePrototypeId ~= 0
end

function ClientPlayerHomeInteractComponent:cancelHomeInteractState()
	self:serverMsg("RPC_CS_CancelHomeInteractState")
end

function ClientPlayerHomeInteractComponent:on_interactHomePrototypeId_changed(oldVal, newVal)
	if self.updateStateCache then
		self:updateStateCache("HOME_INTERACT_ST")
	end

	if self.interactHomePrototypeId and self.interactHomePrototypeId ~= 0 then
		local interactInfo = InteractData[self.interactHomePrototypeId] or {}

		self.curInteractHomePrototypeId = self.interactHomePrototypeId

		local startAnim = interactInfo.startAnim
		local loopAnim = interactInfo.loopAnim

		if startAnim then
			local interactAnimState = self:playAnimation(startAnim, true)

			self.homeItemInteractAnim = startAnim

			if interactAnimState then
				interactAnimState:AddEndCallback(function(reason)
					if reason == PlayableConst.END_REASON.PLAYBACK and loopAnim then
						self:playAnimation(loopAnim)

						self.homeItemInteractAnim = loopAnim
					end
				end)
			elseif loopAnim then
				self:playAnimation(loopAnim)

				self.homeItemInteractAnim = loopAnim
			end
		elseif loopAnim then
			self:playAnimation(loopAnim)

			self.homeItemInteractAnim = loopAnim
		elseif self.homeItemInteractAnim then
			self:stopAnimation(self.homeItemInteractAnim)

			self.homeItemInteractAnim = nil
		end
	else
		if self.homeItemInteractAnim then
			self:stopAnimation(self.homeItemInteractAnim)

			self.homeItemInteractAnim = nil
		end

		if self.curInteractHomePrototypeId then
			local interactInfo = InteractData[self.curInteractHomePrototypeId] or {}
			local endAnim = interactInfo.endAnim

			if endAnim then
				self:playTrivialAnimation(endAnim)
			end
		end
	end

	self:refreshCancelHomeInteractState()
end

function ClientPlayerHomeInteractComponent:refreshHomeInteractAnimState()
	if self:isInHomeInteractState() then
		self.curInteractHomePrototypeId = self.interactHomePrototypeId

		local interactInfo = InteractData[self.interactHomePrototypeId] or {}
		local loopAnim = interactInfo.loopAnim

		if loopAnim then
			self:playAnimation(loopAnim)

			self.homeItemInteractAnim = loopAnim
		end
	end
end

function ClientPlayerHomeInteractComponent:refreshCancelHomeInteractState()
	if self.isMainPlayer then
		if self:isInHomeInteractState() then
			facade:SendMessageCommand(MessageName.ENTER_TRIGGER, {
				dist = 0,
				globalId = self:getGlobalId(),
				actionPrototypeId = InteractionConst.INTERACT_CANCEL_MULTI_INTERACT_ACTION_ID,
				triggerSrcType = InteractionConst.TRIGGER_SRC_TYPE.HOME_INTERACT,
				interactFunc = function()
					self:cancelHomeInteractState()
				end
			})
		else
			self:removeCancelHomeInteractTrigger()
		end
	end
end

function ClientPlayerHomeInteractComponent:removeCancelHomeInteractTrigger()
	if not self.isMainPlayer then
		return
	end

	facade:SendMessageCommand(MessageName.LEAVE_TRIGGER, {
		actionPrototypeId = InteractionConst.INTERACT_CANCEL_MULTI_INTERACT_ACTION_ID,
		globalId = self:getGlobalId(),
		triggerSrcType = InteractionConst.TRIGGER_SRC_TYPE.HOME_INTERACT
	})
end

return ClientPlayerHomeInteractComponent
