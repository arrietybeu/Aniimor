-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Common\\TickManager.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local TimerManager = require("Core.Timer.TimerManager")
local CommonRepo = require("Core.Common.CommonRepo")
local try = require("Core.Framework.Exception")
local CallbackHandler = require("Core.Common.CallbackHandler")
local LoggerManager = require("Core.Log.LoggerManager")
local Time = require("Core.Common.Time")
local Utils = require("Common.Utils.Utils")
local logger = LoggerManager.getLogger("TickManager")
local TickManager = {}

TickManager._tickObj = {}
TickManager._tickManagerLastTime = 0
TickManager._tickLastTime = {}
TickManager._tickInterval = {}
TickManager._tickTimer = nil

function TickManager.containObj(obj)
	return TickManager._tickInterval[obj] ~= nil
end

function TickManager.addTick(obj, interval)
	if TickManager._tickObj[obj] == nil then
		TickManager._tickObj[obj] = true
	end

	TickManager._tickLastTime[obj] = Time.getTickSecond()
	TickManager._tickInterval[obj] = interval

	if TickManager._tickTimer == nil then
		TickManager._tickTimer = TimerManager.addRepeatNextFrameCb(TickManager.__tick__)
	end
end

function TickManager.removeTick(obj, interval)
	if TickManager._tickObj[obj] ~= nil then
		TickManager._tickObj[obj] = nil
		TickManager._tickLastTime[obj] = nil
		TickManager._tickInterval[obj] = nil
	end

	if next(TickManager._tickObj) == nil and TickManager._tickTimer ~= nil then
		TimerManager.delFrameCb(TickManager._tickTimer)

		TickManager._tickTimer = nil
	end
end

function TickManager.__tick__()
	local lastTime = TickManager._tickManagerLastTime
	local curTime = Time.getTickSecond()

	TickManager._tickManagerLastTime = curTime

	local deltaTime, allowTick
	local tickObj = TickManager._tickObj
	local tickLastTime = TickManager._tickLastTime
	local tickInterval = TickManager._tickInterval
	local doTick = TickManager.__doTick__

	if SampleUtils and SampleUtils.sampleOn() then
		doTick = TickManager.__doTickSample__
	end

	for obj, _ in pairs(tickObj) do
		deltaTime = curTime - tickLastTime[obj]

		if deltaTime < 0 then
			deltaTime = 0

			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("__tick__ deltaTime < 0", curTime, lastTime)
			end
		end

		local interval = tickInterval[obj]

		allowTick = interval <= deltaTime or interval <= 0

		if allowTick then
			tickLastTime[obj] = curTime

			doTick(obj, deltaTime)
		end
	end
end

function TickManager.__doTick__(obj, deltaTime)
	local tickFunc = obj.tick
	local status, err = xpcall(tickFunc, debug.traceback, obj, deltaTime)

	if not status then
		local ex = err or "unknown error occurred"

		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("__tick__ traceback occurred", ex)
		end
	end
end

function TickManager.__doTickSample__(obj, deltaTime)
	local tickFunc = obj.tick

	SampleUtils.beginSampleEx(SampleUtils.showSampleDesc(tickFunc))

	local status, err = xpcall(tickFunc, debug.traceback, obj, deltaTime)

	SampleUtils.endSampleEx()

	if not status then
		local ex = err or "unknown error occurred"

		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("__tick__ traceback occurred", ex)
		end
	end
end

return TickManager
