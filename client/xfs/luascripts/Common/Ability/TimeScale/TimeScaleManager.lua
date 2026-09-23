-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\TimeScale\\TimeScaleManager.lua

local Class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local Time = require("Core.Common.Time")
local GlobalFreeze = require("Common.Ability.TimeScale.GlobalFreeze")
local TimeScaleZone = require("Common.Ability.TimeScale.TimeScaleZone")
local SafeCallback = require("Core.Framework.SafeCallback")
local TimeScaleManager = Class.LiteClass("TimeScaleManager")

function TimeScaleManager:ctor(space)
	self.space = space
	self.timeZones = {}
	self.timeZoneGenId = 0
	self.globalTimeScale = 1
	self.globalTimeZoneScale = 1
	self.globalScaledTime = 0
	self.globalFreeze = GlobalFreeze()
	self.globalFreezeTimeScale = 1
	self.entities = {}
	self.tickEntities = {}
	self.temp_removeIds = {}
end

function TimeScaleManager:destroy()
	table.clear(self.tickEntities)
	table.clear(self.entities)

	self.space = nil

	self.globalFreeze:stopFreeze()
end

function TimeScaleManager:genTimeZoneInstanceId()
	self.timeZoneGenId = self.timeZoneGenId + 1

	return self.timeZoneGenId
end

function TimeScaleManager:tick(deltaTime)
	if next(self.timeZones) then
		table.clear(self.temp_removeIds)

		for zoneId, timeZone in pairs(self.timeZones) do
			if timeZone:isValid() then
				timeZone:activate(deltaTime)
			else
				self.temp_removeIds[#self.temp_removeIds + 1] = zoneId
			end
		end

		for _, removeId in ipairs(self.temp_removeIds) do
			self:removeTimeZone(removeId)
		end
	end

	self.globalFreeze:updateValue()

	local gameTime = self.space:getGameTime()

	if not self.lastTickTime then
		self.lastTickTime = gameTime
	end

	local gameDeltaTime = gameTime - self.lastTickTime

	if gameDeltaTime < 0 then
		gameDeltaTime = 0
	end

	self.lastTickTime = gameTime

	self:updateGlobalFreeze()

	if pg.global.csAbilityMgr then
		pg.global.csAbilityMgr.abilityDeltaTime = gameDeltaTime
	end

	self.globalScaledTime = self.globalScaledTime + self.globalTimeZoneScale * self.globalFreezeTimeScale * gameDeltaTime

	for _, ent in pairs(self.tickEntities) do
		ent:updateScaledTime(gameDeltaTime, self.globalFreezeTimeScale)
	end
end

function TimeScaleManager:registerEnt(id, ent, useSimpleTimeScale)
	self.entities[id] = ent

	if not useSimpleTimeScale then
		self.tickEntities[id] = ent
	end
end

function TimeScaleManager:unRegisterEnt(id, ent)
	if self.entities[id] == ent then
		self.entities[id] = nil
		self.tickEntities[id] = nil
	end
end

function TimeScaleManager:isRegistered(id)
	return self.entities[id] ~= nil
end

function TimeScaleManager:updateGlobalFreeze()
	if self.space:isMultiPlayerEnv() then
		self.globalFreezeTimeScale = 1

		return
	end

	self.globalFreezeTimeScale = self.globalFreeze:getTimeScale()
end

function TimeScaleManager:getGlobalFreeze()
	return self.globalFreezeTimeScale
end

function TimeScaleManager:startGlobalFreeze(freezeScale, inTime, outTime, keepTime)
	if self.space:isMultiPlayerEnv() then
		return
	end

	if type(freezeScale) ~= "number" or freezeScale ~= freezeScale then
		return
	end

	freezeScale = math.max(freezeScale, 0)

	if not _G_IsDebugMode then
		freezeScale = math.clamp(freezeScale, 0, 1)
	end

	self.globalFreeze:startFreeze(freezeScale, inTime, outTime, keepTime)
	self.globalFreeze:updateValue()

	if pg.component == "client" and self.space then
		pg.me:serverSpaceMsg("RPC_CS_StartGlobalFreeze", {
			freezeScale,
			inTime,
			outTime,
			keepTime
		})
	end
end

function TimeScaleManager:getTimeScale(targetEnt)
	if self.space:isMultiPlayerEnv() then
		return 1
	end

	if Utils.tableIsEmptyOrNil(self.timeZones) then
		return 1
	end

	local resultScale = 1

	for zoneId, timeZone in pairs(self.timeZones) do
		local valid, timeScale = timeZone:checkTimeScale(targetEnt)

		resultScale = math.min(timeScale, resultScale)
	end

	return math.max(0, resultScale)
end

function TimeScaleManager:onSyncTimeZone(timeZoneParams)
	local timeZone = TimeScaleZone()

	timeZone:applyTimeZoneParams(timeZoneParams)
	self:addTimeZone(timeZone)
end

function TimeScaleManager:createTimeZone(casterId, position, radius, timeScale, duration, ignoreActorId)
	local zoneId = self:genTimeZoneInstanceId()
	local timeZone = TimeScaleZone.new()

	timeZone:init(zoneId, casterId, position, radius, timeScale, duration, ignoreActorId)
	self:addTimeZone(timeZone)

	return zoneId
end

function TimeScaleManager:addTimeZone(timeZone)
	if self.space:isMultiPlayerEnv() then
		return
	end

	if timeZone then
		self.timeZones[timeZone.zoneId] = timeZone

		if pg.component == "game" and self.space then
			self.space:allClientsMsg("RPC_SC_AddTimeZone", timeZone:getTimeZoneParams())
		end

		self:refreshAllEntitiesTimeScale()
	end
end

function TimeScaleManager:removeTimeZone(zoneId, sync)
	if pg.component == "game" and sync and self.space then
		self.space:allClientsMsg("RPC_SC_RemoveTimeZone", zoneId)
	end

	self.timeZones[zoneId] = nil

	self:refreshAllEntitiesTimeScale()
end

function TimeScaleManager:refreshGlobalZoneTimeScale()
	self.globalTimeZoneScale = self:getTimeScale(nil)
end

function TimeScaleManager:onMultiPlayerEnvChanged(multiPlayerEnv)
	self:refreshAllEntitiesTimeScale()
end

function TimeScaleManager:onGameTimeScaleChange()
	for _, ent in pairs(self.entities) do
		if ent and ent.applyTimeScale then
			SafeCallback(ent.applyTimeScale, ent)
		end
	end
end

function TimeScaleManager:refreshAllEntitiesTimeScale()
	self:refreshGlobalZoneTimeScale()

	for _, ent in pairs(self.entities) do
		if ent and ent.refreshTimeScale then
			SafeCallback(ent.refreshTimeScale, ent)
		end
	end
end

return TimeScaleManager
