-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientPushComponent.lua

local Class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local MessageName = require("Const.MessageName")
local InteractionConst = require("Common.Const.InteractionConst")
local ConflictTypes = require("Common.ConflictTypes")
local PlayableConst = require("Common.Const.PlayableConst")
local Const = require("Common.Const.Const")
local ClientPushComponent = Class.Component("ClientPushComponent")

function ClientPushComponent:start()
	return
end

function ClientPushComponent:canPushEntity(targetEntity)
	if not self:isControllingMaster() then
		return false
	end

	if self:isPushing() then
		return false
	end

	local ret = self:checkStatus(ConflictTypes.CT_PUSH, false, nil, true)

	if not ret then
		return false
	end

	return true
end

function ClientPushComponent:isPushing()
	return self.pushingEnt ~= nil and self.pushingEnt.eModel ~= nil
end

function ClientPushComponent:pushEntity(targetEntity)
	local pushComponent = targetEntity.eModel:GetPushComponent()

	if pushComponent then
		pushComponent:StartPush(self.eModel)

		if self.authority == Const.AUTHORITY_MASTER then
			self:ResetVelocity()

			local state = self:playAnimation(PlayableConst.Push)

			if state then
				self.pushingEnt = targetEntity

				self:disableMotion(ClientConst.DISABLE_MOTION_KEY.PUSHING, true)
				state:AddEndCallback(function(reason)
					self.pushingEnt = nil

					self:disableMotion(ClientConst.DISABLE_MOTION_KEY.PUSHING, false)
				end)
			end
		else
			self:playAnimation(PlayableConst.Push)
		end
	end
end

function ClientPushComponent:cancelPush()
	if self:isPushing() then
		self:stopAnimation(PlayableConst.Push)

		local pushComponent = self.pushingEnt.eModel:GetPushComponent()

		if pushComponent then
			pushComponent:StopPush()
		end

		if self.authority == Const.AUTHORITY_MASTER then
			self.pushingEnt = nil

			self:disableMotion(ClientConst.DISABLE_MOTION_KEY.PUSHING, false)
		end
	end
end

return ClientPushComponent
