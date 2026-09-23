-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\TimeScale\\TimeScaleZone.lua

local Class = require("Core.Framework.Class")
local camp_data = require("Data.camp_data")
local Const = require("Common.Const.Const")
local Vector3 = Vector3
local ToBool = ToBool
local TimeScaleZone = Class.LiteClass("TimeScaleZoneParam")

function TimeScaleZone:init(zoneId, casterId, position, radius, timeScale, duration, ignoreActorId)
	self.zoneId = zoneId
	self.casterId = casterId
	self.position = position
	self.ignoreActorId = ignoreActorId

	if radius < 0 then
		self.radiusSqr = -1
	else
		self.radiusSqr = radius * radius
	end

	self.duration = duration
	self.currTime = 0
	self.timeScale = timeScale
	self.camp = nil

	if self.casterId then
		local caster = pg.getEntityByActorId(self.casterId)

		self.camp = caster and caster.camp
	end

	if self.camp then
		self.campInfo = camp_data[self.camp]
	else
		self.campInfo = nil
	end
end

function TimeScaleZone:applyTimeZoneParams(params)
	self.zoneId = params.zoneId
	self.casterId = params.casterId
	self.position = Vector3.Clone(params.position)
	self.radiusSqr = params.radiusSqr
	self.duration = params.duration
	self.currTime = params.currTime
	self.timeScale = params.timeScale
	self.camp = params.camp
	self.ignoreActorId = params.ignoreActorId

	if self.camp then
		self.campInfo = camp_data[self.camp]
	else
		self.campInfo = nil
	end
end

function TimeScaleZone:getTimeZoneParams()
	local params = {
		zoneId = self.zoneId,
		casterId = self.casterId,
		position = self.position,
		radiusSqr = self.radiusSqr,
		duration = self.duration,
		currTime = self.currTime,
		timeScale = self.timeScale,
		camp = self.camp,
		ignoreActorId = self.ignoreActorId
	}

	return params
end

function TimeScaleZone:activate(deltaTime)
	self.currTime = self.currTime + deltaTime
end

function TimeScaleZone:isValid()
	return self.currTime <= self.duration
end

function TimeScaleZone:checkCamp(targetEnt)
	if self.campInfo == nil then
		return true
	end

	local camp = targetEnt and targetEnt.camp

	if not camp then
		return true
	end

	return self.campInfo[camp] ~= Const.WORLD_PAIRS_CAMP_PARTNER
end

function TimeScaleZone:checkInRange(pos)
	if self.radiusSqr < 0 then
		return true
	end

	local distanceSqr = Vector3.SqrDistance(pos, self.position)

	return distanceSqr <= self.radiusSqr
end

function TimeScaleZone:checkIgnoreTimeScale(targetEnt)
	if not targetEnt then
		return false
	end

	if targetEnt.isTimeScaleNoEffect and targetEnt:isTimeScaleNoEffect() then
		return true
	end

	return false
end

function TimeScaleZone:checkTimeScale(targetEnt)
	if not targetEnt then
		return true, self.timeScale
	end

	if targetEnt.actorId == self.ignoreActorId then
		return false, 1
	end

	if not self:checkCamp(targetEnt) then
		return false, 1
	end

	if self:checkIgnoreTimeScale(targetEnt) then
		return false, 1
	end

	return true, self.timeScale
end

return TimeScaleZone
