-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientChestComponent.lua

local Utils = require("Common.Utils.Utils")
local SysConfigData = require("Data.sys_config_data")
local class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local ClientChestComponent = class.Component("ClientChestComponent")

function ClientChestComponent:start()
	self:resetChestData()
end

function ClientChestComponent:onEnterTrap(actorId, eventId)
	if eventId ~= Const.TRAP_EVENT_ID_CHEST_RANGE then
		return
	end

	if self.ChestDetect.rangeEntsChest[actorId] then
		return
	end

	local ent = pg.getEntityByActorId(actorId)

	if Utils.isChestVisible(pg.me, ent) then
		self.ChestDetect.rangeEntsChest[actorId] = ent

		local rangeTypeChests = self.ChestDetect.rangeTypeChests

		if rangeTypeChests then
			local typeChests = rangeTypeChests[ent.templateId]

			if not typeChests then
				typeChests = {}
				rangeTypeChests[ent.templateId] = typeChests
			end

			typeChests[actorId] = ent
		end
	end
end

function ClientChestComponent:onLeaveTrap(actorId, eventId)
	if eventId ~= Const.TRAP_EVENT_ID_CHEST_RANGE then
		return
	end

	local chest = self.ChestDetect.rangeEntsChest[actorId]

	if chest then
		self.ChestDetect.rangeEntsChest[actorId] = nil

		local rangeTypeChests = self.ChestDetect.rangeTypeChests

		if rangeTypeChests then
			local typeChests = rangeTypeChests[chest.templateId]

			if typeChests then
				typeChests[actorId] = nil
			end
		end
	end
end

function ClientChestComponent:resetChestData()
	self.ChestDetect = {
		rangeEntsChest = {}
	}
end

function ClientChestComponent:destroy()
	self:clearChestRangeEvent()
end

function ClientChestComponent:clearChestRangeEvent()
	if self.ChestDetect.rangeEvent then
		self:removeRangeEvent(self.ChestDetect.rangeEvent, true)
		self:resetChestData()
	end
end

function ClientChestComponent:onEnterSpace()
	local dist = SysConfigData.CHEST_TRACK_MAX_DISTANCE or 110

	if self.ChestDetect then
		self.ChestDetect.rangeEvent = self:addRangeEvent(Const.TRAP_EVENT_ID_CHEST_RANGE, dist, dist)
	end
end

function ClientChestComponent:onLeaveSpace()
	self:clearChestRangeEvent()
end

local _emptyChest = {}

function ClientChestComponent:GetRangeEntsChest()
	if not self.ChestDetect then
		return _emptyChest
	end

	return self.ChestDetect.rangeEntsChest
end

function ClientChestComponent:GetRangeTypeChests()
	local detect = self.ChestDetect

	if not detect then
		return _emptyChest
	end

	local rangeTypeChests = detect.rangeTypeChests

	if not rangeTypeChests then
		rangeTypeChests = {}

		for actorId, ent in pairs(detect.rangeEntsChest) do
			local templateId = ent.templateId
			local typeChests = rangeTypeChests[templateId]

			if not typeChests then
				typeChests = {}
				rangeTypeChests[templateId] = typeChests
			end

			typeChests[actorId] = ent
		end

		detect.rangeTypeChests = rangeTypeChests
	end

	return rangeTypeChests
end

return ClientChestComponent
