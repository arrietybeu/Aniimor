-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientInteractionComponent.lua

local Class = require("Core.Framework.Class")
local InteractData = require("Data.interact_data")
local ClientConst = require("Const.ClientConst")
local MessageName = require("Const.MessageName")
local ClientFKeyInteractBase = require("Entities.SpaceEntities.CommonComponent.ClientFKeyInteractBase")
local ClientInteractionComponent = Class.Component("ClientInteractionComponent", ClientFKeyInteractBase)

function ClientInteractionComponent:start()
	self.localOffset = self:getInteractLocalOffset()

	self:refreshInteractTrigger()
end

function ClientInteractionComponent:createTrigger(dist)
	local localOffset = self.localOffset

	return self.eModel:CreateSphereTriggerWithOffsetEx(ClientConst.TriggerType.FKey, dist, localOffset[1], localOffset[2], localOffset[3])
end

function ClientInteractionComponent:getInteractLocalOffset()
	if self.getOverrideInteractLocalOffset then
		return self:getOverrideInteractLocalOffset()
	end

	local configData = self:getConfigData()
	local interactLocalOffset = configData.interactLocalOffset or {
		0,
		0,
		0
	}

	return Vector3(interactLocalOffset[1], interactLocalOffset[2], interactLocalOffset[3])
end

function ClientInteractionComponent:getInteractiveDist()
	local interactiveDist = 0
	local cfgData = self:getConfigData()

	if cfgData and cfgData.interactiveDist then
		interactiveDist = cfgData.interactiveDist
	elseif self.getInteractionListData then
		local interactionData = self:getInteractionListData()

		if interactionData then
			local maxDistance = 0

			for _, actData in ipairs(interactionData) do
				local interactData = InteractData[actData.actionPrototypeId] or {}
				local dis = actData.overrideInteractDis or interactData.interactiveDist or 2
				local interactIconDist = interactData.interactiveIconDist or 0

				dis = math.max(dis, interactIconDist)

				if maxDistance < dis then
					maxDistance = dis
				end
			end

			interactiveDist = maxDistance
		end
	end

	if self.getBeHoldDistance then
		interactiveDist = math.max(interactiveDist, self:getBeHoldDistance())
	end

	if self.isRobSpaceEgg then
		interactiveDist = math.max(interactiveDist, 2)
	end

	return interactiveDist
end

function ClientInteractionComponent:onTriggerEnter(userData)
	if not self.sandboxReady then
		return nil
	end

	if userData == ClientConst.TriggerType.FKey then
		self:onEnterInteractTrigger()
	end
end

function ClientInteractionComponent:onEnterInteractTrigger()
	self.playerInTrigger = true

	if self.getInteractionListData then
		self._interactionData = self:getInteractionListData()

		if self._interactionData then
			facade:SendMessageCommand(MessageName.ENTER_TRIGGER_MULTI_INTERACT, self._interactionData)
		end
	end

	if self.getCarryInteractionListData then
		self._carryInteractionData = self:getCarryInteractionListData()

		if self._carryInteractionData then
			facade:SendMessageCommand(MessageName.ENTER_TRIGGER, self._carryInteractionData)
		end
	end

	self:postComponentMethod("EVENT_OnEnterInteractRange")
end

function ClientInteractionComponent:onLeaveInteractTrigger()
	self.playerInTrigger = false

	if self._interactionData then
		facade:SendMessageCommand(MessageName.LEAVE_TRIGGER_MULTI_INTERACT, self._interactionData)

		self._interactionData = nil
	end

	if self._carryInteractionData then
		facade:SendMessageCommand(MessageName.LEAVE_TRIGGER, self._carryInteractionData)

		self._carryInteractionData = nil
	end

	self:postComponentMethod("EVENT_OnLeaveInteractRange")
end

function ClientInteractionComponent:refreshInteractTriggerEvent()
	self:refreshInteractTrigger()

	if self.triggerId then
		self:onLeaveInteractTrigger()
		self:onEnterInteractTrigger()
	end
end

return ClientInteractionComponent
