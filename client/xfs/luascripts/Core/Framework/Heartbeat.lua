-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Framework\\Heartbeat.lua

local Time = require("Core.Common.Time")
local Class = require("Core.Framework.Class")
local TimerManager = require("Core.Timer.TimerManager")
local CallbackHandler = require("Core.Common.CallbackHandler")
local Heartbeat = Class.LightClass("Heartbeat")

function Heartbeat:ctor(interval, retryNum, heartbeat, timeout)
	self.interval = interval
	self.retryNum = retryNum
	self.remainNum = self.retryNum
	self.heartbeat = heartbeat
	self.timeout = timeout
	self.timer = nil
end

function Heartbeat:destroy()
	if self.timer ~= nil then
		TimerManager.removeTimer(self.timer)

		self.timer = nil
	end

	self.heartbeat = nil
	self.timeout = nil
end

function Heartbeat:startBeat()
	self.timer = TimerManager.addTimer(self.interval, CallbackHandler(self, "onHeartbeat"))
end

function Heartbeat:restartBeat()
	self:onHeartBeatAck()
	self:startBeat()
end

function Heartbeat:onHeartbeat()
	self.timer = nil
	self.remainNum = self.remainNum - 1

	if self.remainNum >= 0 then
		self.heartbeat()

		self.timer = TimerManager.addTimer(self.interval, CallbackHandler(self, "onHeartbeat"))
	else
		self.timeout()
	end
end

function Heartbeat:onHeartBeatAck()
	self.remainNum = self.retryNum
end

return Heartbeat
