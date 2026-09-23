-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientFKeyInteractBase.lua

local Class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local ClientFKeyInteractBase = Class.Component("ClientFKeyInteractBase")

function ClientFKeyInteractBase:onTriggerEnter(userData)
	if userData == ClientConst.TriggerType.FKey then
		self:onEnterInteractTrigger()
	end
end

function ClientFKeyInteractBase:onTriggerExit(userData)
	if userData == ClientConst.TriggerType.FKey and self.playerInTrigger then
		self:onLeaveInteractTrigger()
	end
end

function ClientFKeyInteractBase:EVENT_OnActiveChange(active)
	self:refreshTriggerState()
end

function ClientFKeyInteractBase:EVENT_OnModelVisibleChange(visible)
	self:refreshTriggerState()
end

function ClientFKeyInteractBase:preDestroy()
	self:clearInteractTrigger()
end

function ClientFKeyInteractBase:clearInteractTrigger()
	if self.playerInTrigger then
		self:onLeaveInteractTrigger()
	end

	local triggerId = self.triggerId

	self.triggerId = nil
	self.interactiveDist = 0

	if triggerId then
		self.eModel:DestroyTrigger(triggerId)
	end
end

function ClientFKeyInteractBase:destroy()
	return
end

function ClientFKeyInteractBase:refreshInteractTrigger()
	local newInteractiveDist = self:getInteractiveDist()

	if newInteractiveDist ~= self.interactiveDist then
		self.interactiveDist = newInteractiveDist

		if self.interactiveDist > 0 then
			if not self.triggerId then
				self.triggerId = self.eModel and self:createTrigger(self.interactiveDist)
			else
				self.eModel:RefreshTrigger(self.triggerId, self.id, self.interactiveDist)
			end
		elseif self.triggerId then
			self:clearInteractTrigger()
		end
	end

	if self.triggerId then
		local offsetX, offsetY, offsetZ = self:getInteractTriggerOffset()

		if offsetX ~= nil then
			self.eModel:SetTriggerLocalOffsetEx(self.triggerId, offsetX, offsetY, offsetZ)
		end

		self:refreshTriggerState()
	end

	if self.playerInTrigger and self:useReentryGuard() then
		self:onLeaveInteractTrigger()
		self:onEnterInteractTrigger()
	end
end

function ClientFKeyInteractBase:refreshTriggerState()
	if self.triggerId and self.visible ~= nil and self.active ~= nil then
		if self.visible and self.active then
			self.eModel:SetTriggerActive(self.triggerId, true)
		else
			self.eModel:SetTriggerActive(self.triggerId, false)
		end
	end
end

function ClientFKeyInteractBase:createTrigger(dist)
	return self.eModel:CreateSphereTrigger(ClientConst.TriggerType.FKey, dist)
end

function ClientFKeyInteractBase:getInteractiveDist()
	return 0
end

function ClientFKeyInteractBase:getInteractTriggerOffset()
	return nil
end

function ClientFKeyInteractBase:useReentryGuard()
	return false
end

function ClientFKeyInteractBase:onEnterInteractTrigger()
	return
end

function ClientFKeyInteractBase:onLeaveInteractTrigger()
	return
end

return ClientFKeyInteractBase
