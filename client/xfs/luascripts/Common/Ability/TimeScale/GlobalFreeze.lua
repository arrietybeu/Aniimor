-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\TimeScale\\GlobalFreeze.lua

local Time = require("Core.Common.Time")
local Class = require("Core.Framework.Class")
local GlobalFreeze = Class.LiteClass("GlobalFreeze")

function GlobalFreeze:ctor()
	self.targetTimeScale = 1
	self.inTime = 0
	self.outTime = 0
	self.keepTime = 0
	self.startTime = 0
	self.duration = 0
	self.timeScale = 1
end

function GlobalFreeze:startFreeze(timeScale, inTime, outTime, keepTime)
	self.inTime = math.max(0, inTime)
	self.outTime = math.max(0, outTime)
	self.keepTime = math.max(0, keepTime)
	self.targetTimeScale = timeScale
	self.duration = inTime + outTime + keepTime
	self.startTime = Time.realSecondCache
end

function GlobalFreeze:stopFreeze()
	self.startTime = 0
	self.duration = 0
end

function GlobalFreeze:isValid()
	return Time.realSecondCache < self.startTime + self.duration
end

function GlobalFreeze:updateValue()
	if Time.realSecondCache < self.startTime then
		self.startTime = Time.realSecondCache
	end

	if self:isValid() then
		local now = Time.realSecondCache
		local currTime = now - self.startTime
		local targetScale = 1

		if self.inTime > 0 and currTime < self.inTime then
			targetScale = math.lerp(1, self.targetTimeScale, currTime / self.inTime)
		elseif self.keepTime > 0 and currTime < self.keepTime + self.inTime then
			targetScale = self.targetTimeScale
		elseif self.outTime > 0 and currTime < self.duration then
			targetScale = math.lerp(self.targetTimeScale, 1, (currTime - self.keepTime - self.inTime) / self.outTime)
		end

		self.timeScale = targetScale
	else
		self.timeScale = 1
	end
end

function GlobalFreeze:getTimeScale()
	return self.timeScale
end

return GlobalFreeze
