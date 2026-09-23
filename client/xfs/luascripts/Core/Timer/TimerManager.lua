-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Timer\\TimerManager.lua

local class = require("Core.Framework.Class")
local TimerManager = class.Class("TimerManager")
local globalDeclare = require("Core.Framework.Global")

local function isJitEnabled()
	local ps5 = rawget(_G, "UNITY_PS5")

	return ps5 == false and jit
end

local profile = isJitEnabled() and require("jit.profile") or nil
local SampleUtils
local timerIdToHandler = {}
local timerIdRepeated = {}
local frameIdToHandler = {}
local frameIdRepeated = {}
local repeatFrameIdToHandler = {}
local addTimerHook, addRepeatTimerHook, removeTimerHook, phonestcore, SafeCallback, LoggerManager, LoggerConst, logger
local _G_IsDebugMode = false
local _names = {}
local _counts = {}

setmetatable(_names, {
	__mode = "k"
})

local function showSimpleDesc(handler)
	local desc = _names[handler]

	if desc then
		return desc
	end

	if type(handler) == "table" then
		local metatable = getmetatable(handler)

		handler = metatable.__call
	end

	local funcInfo = debug.getinfo(handler, "S")
	local funcDesc = string.sub(funcInfo.short_src, -26, -1)
	local startIndex = string.find(funcDesc, "CallbackHandler")

	if startIndex ~= nil then
		local _, objValue = debug.getupvalue(handler, 1)
		local _, funValue = debug.getupvalue(handler, 2)

		if objValue ~= nil and objValue[funValue] ~= nil then
			funcInfo = debug.getinfo(objValue[funValue], "S")
			funcDesc = string.sub(funcInfo.short_src, -26, -1)
		end
	end

	local desc = string.format("...%s:%s", funcDesc, funcInfo.linedefined)

	_names[handler] = desc
	_counts[desc] = (_counts[desc] or 0) + 1

	return desc
end

local function addTimerHelp(isRepeat, delay, handler, isRecover, leftMs)
	assert(type(handler) == "function" or type(handler) == "table" and getmetatable(handler) and getmetatable(handler).__call)

	local timerId

	if isRecover then
		timerId = phonestcore.recoverTimer(isRepeat, delay, leftMs)
	else
		timerId = phonestcore.addTimer(isRepeat, delay)
	end

	timerIdToHandler[timerId] = handler

	if isRepeat then
		timerIdRepeated[timerId] = true
	end

	return timerId
end

function TimerManager.addTimer(delay, handler, ...)
	if addTimerHook then
		return addTimerHook(delay, handler, ...)
	else
		return addTimerHelp(false, delay, handler)
	end
end

function TimerManager.addRepeatTimer(delay, handler, ...)
	if addRepeatTimerHook then
		return addRepeatTimerHook(delay, handler, ...)
	else
		return addTimerHelp(true, delay, handler)
	end
end

function TimerManager.removeTimer(timerId)
	if timerId == nil then
		return
	end

	if removeTimerHook and timerId then
		return removeTimerHook(timerId)
	end

	timerIdRepeated[timerId] = nil

	if timerId then
		phonestcore.removeTimer(timerId)
		TimerManager.disposeHandler(timerIdToHandler[timerId])

		timerIdToHandler[timerId] = nil
	end
end

function TimerManager.setHook(addTimerFunc, addRepeatTimerFunc, removeTimerFunc)
	addTimerHook = addTimerFunc
	addRepeatTimerHook = addRepeatTimerFunc
	removeTimerHook = removeTimerFunc
end

function TimerManager.recoverTimer(delay, leftMs, isRepeat, handler, ...)
	if isRepeat then
		if addRepeatTimerHook then
			return addRepeatTimerHook(delay, handler, ...)
		else
			return addTimerHelp(true, delay, handler, true, leftMs)
		end
	elseif addTimerHook then
		return addTimerHook(delay, handler, ...)
	else
		return addTimerHelp(false, delay, handler, true, leftMs)
	end
end

function TimerManager.checkTimerValid(timerId)
	return timerIdToHandler[timerId] ~= nil
end

function TimerManager.getTimerIdToHandler()
	return timerIdToHandler
end

function TimerManager.getSerializableTimerLeftMs(timerid)
	return phonestcore.getTimerLeftMs(timerid)
end

local function addFrameCbHelper(frameId, isRepeat, handler)
	if isRepeat then
		frameIdRepeated[frameId] = true
	end

	frameIdToHandler[frameId] = handler
end

function TimerManager.addNextFrameCb(handler)
	local frameId = phonestcore.addNextFrameCb()

	addFrameCbHelper(frameId, false, handler)

	return frameId
end

function TimerManager.addRepeatNextFrameCb(handler)
	local frameId = phonestcore.addRepeatNextFrameCb()

	repeatFrameIdToHandler[frameId] = handler

	return frameId
end

function TimerManager.addSpecificFrameCb(frameCount, isRepeat, handler)
	if frameCount <= 0 then
		if isRepeat then
			return TimerManager.addRepeatNextFrameCb(handler)
		else
			TimerManager.addNextFrameCb(handler)

			return nil
		end
	end

	local frameId = phonestcore.addSpecificFrameCb(frameCount, isRepeat)

	addFrameCbHelper(frameId, isRepeat, handler)

	return frameId
end

function TimerManager.delFrameCb(frameId)
	if repeatFrameIdToHandler[frameId] ~= nil then
		TimerManager.disposeHandler(repeatFrameIdToHandler[frameId])

		repeatFrameIdToHandler[frameId] = nil

		if next(repeatFrameIdToHandler) == nil then
			phonestcore.stopRepeatNextFrameCb()
		end
	else
		phonestcore.delSpecificFrameCb(frameId)
		TimerManager.disposeHandler(frameIdToHandler[frameId])

		frameIdToHandler[frameId] = nil
		frameIdRepeated[frameId] = nil
	end
end

local function TimerManagerHandlerWithSample(timerId)
	local handler = timerIdToHandler[timerId]

	if not timerIdRepeated[timerId] then
		TimerManager.removeTimer(timerId)
	end

	if handler then
		SampleUtils.beginSample(showSimpleDesc(handler))

		local status, ret = xpcall(handler, debug.traceback)

		if not status and LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("SafeCallback traceback occurred \n", showSimpleDesc(handler), ret)
		end

		SampleUtils.endSample()
	else
		phonestcore.removeTimer(timerId)
	end
end

local function TimerManagerHandlerNoSample(timerId)
	local handler = timerIdToHandler[timerId]

	if not timerIdRepeated[timerId] then
		TimerManager.removeTimer(timerId)
	end

	if handler then
		local status, ret = xpcall(handler, debug.traceback)

		if not status and LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("SafeCallback traceback occurred \n", showSimpleDesc(handler), ret)
		end
	else
		phonestcore.removeTimer(timerId)
	end
end

local TimerManagerHandler = TimerManagerHandlerNoSample

globalDeclare("TimerManagerHandler", TimerManagerHandlerNoSample)

local function TimersCallbackHandlerWithSample(timerIds)
	local handler
	local size = #timerIds

	if _G_IsDebugMode and size >= 100 then
		print("NextFramesHandler timerIds size:", size)
	end

	for i = 1, size do
		local timerId = timerIds[i]

		handler = timerIdToHandler[timerId]

		if not timerIdRepeated[timerId] then
			TimerManager.removeTimer(timerId)
		end

		if handler then
			SampleUtils.beginSample(showSimpleDesc(handler))

			local status, ret = xpcall(handler, debug.traceback)

			if not status and LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("SafeCallback traceback occurred \n", showSimpleDesc(handler), ret)
			end

			SampleUtils.endSample()
		else
			phonestcore.removeTimer(timerId)
		end
	end
end

local function TimersCallbackHandlerNoSample(timerIds)
	local handler
	local size = #timerIds

	if _G_IsDebugMode and size >= 100 then
		print("NextFramesHandler timerIds size:", size)
	end

	for i = 1, size do
		local timerId = timerIds[i]

		handler = timerIdToHandler[timerId]

		if not timerIdRepeated[timerId] then
			TimerManager.removeTimer(timerId)
		end

		if handler then
			local status, ret = xpcall(handler, debug.traceback)

			if not status and LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("SafeCallback traceback occurred \n", showSimpleDesc(handler), ret)
			end
		else
			phonestcore.removeTimer(timerId)
		end
	end
end

globalDeclare("TimersCallbackHandler", TimersCallbackHandlerNoSample)

local TimersCallbackHandler = TimersCallbackHandlerNoSample

local function NextFrameHandlerWithSample(frameId)
	local handler = frameIdToHandler[frameId]
	local isRepeatHandler = frameIdRepeated[frameId]

	if not isRepeatHandler then
		frameIdToHandler[frameId] = nil
		frameIdRepeated[frameId] = nil
	end

	if handler then
		SampleUtils.beginSample(showSimpleDesc(handler))

		local status, ret = xpcall(handler, debug.traceback)

		if not status and LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("SafeCallback traceback occurred \n", showSimpleDesc(handler), ret)
		end

		SampleUtils.endSample()
	end

	if not isRepeatHandler then
		TimerManager.disposeHandler(handler)
	end
end

local function NextFrameHandlerNoSample(frameId)
	local handler = frameIdToHandler[frameId]
	local isRepeatHandler = frameIdRepeated[frameId]

	if not isRepeatHandler then
		frameIdToHandler[frameId] = nil
		frameIdRepeated[frameId] = nil
	end

	if handler then
		local status, ret = xpcall(handler, debug.traceback)

		if not status and LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("SafeCallback traceback occurred \n", showSimpleDesc(handler), ret)
		end
	end

	if not isRepeatHandler then
		TimerManager.disposeHandler(handler)
	end
end

globalDeclare("NextFrameHandler", NextFrameHandlerNoSample)

local NextFrameHandler = NextFrameHandlerNoSample

local function NextFramesHandlerWithSample(frameIds)
	local size = #frameIds

	if _G_IsDebugMode and size >= 100 then
		print("NextFramesHandler frameIds size:", size)
	end

	local handler

	for i = 1, size do
		local frameId = frameIds[i]

		handler = frameIdToHandler[frameId]

		local isRepeatHandler = frameIdRepeated[frameId]

		if not isRepeatHandler then
			frameIdToHandler[frameId] = nil
			frameIdRepeated[frameId] = nil
		end

		if handler then
			SampleUtils.beginSample(showSimpleDesc(handler))

			local status, ret = xpcall(handler, debug.traceback)

			if not status and LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("SafeCallback traceback occurred \n", showSimpleDesc(handler), ret)
			end

			SampleUtils.endSample()
		end

		if not isRepeatHandler then
			TimerManager.disposeHandler(handler)
		end
	end
end

local function NextFramesHandlerNoSample(frameIds)
	local size = #frameIds

	if _G_IsDebugMode and size >= 100 then
		print("NextFramesHandler frameIds size:", size)
	end

	local handler

	for i = 1, size do
		local frameId = frameIds[i]

		handler = frameIdToHandler[frameId]

		local isRepeatHandler = frameIdRepeated[frameId]

		if not isRepeatHandler then
			frameIdToHandler[frameId] = nil
			frameIdRepeated[frameId] = nil
		end

		if handler then
			local status, ret = xpcall(handler, debug.traceback)

			if not status and LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("SafeCallback traceback occurred \n", showSimpleDesc(handler), ret)
			end
		end

		if not isRepeatHandler then
			TimerManager.disposeHandler(handler)
		end
	end
end

globalDeclare("NextFramesHandler", NextFramesHandlerNoSample)

local NextFramesHandler = NextFramesHandlerNoSample

local function frameHandleWithSample()
	for _, handler in pairs(repeatFrameIdToHandler) do
		SampleUtils.beginSample(showSimpleDesc(handler))

		local status, ret = xpcall(handler, debug.traceback)

		if not status and LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("SafeCallback traceback occurred \n", showSimpleDesc(handler), ret)
		end

		SampleUtils.endSample()
	end
end

local function frameHandleNoSample()
	for _, handler in pairs(repeatFrameIdToHandler) do
		local status, ret = xpcall(handler, debug.traceback)

		if not status and LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("SafeCallback traceback occurred \n", showSimpleDesc(handler), ret)
		end
	end
end

local RepeatFrameHandler = frameHandleNoSample

globalDeclare("RepeatFrameHandler", frameHandleNoSample)

local _sampleArr = {
	"NextFrameCallbackManager",
	"ServiceManager",
	"TimerManager",
	"pullDelayHandler",
	"pluginAppTick",
	"5"
}

local function LuaBeginSample(index)
	if SampleUtils then
		SampleUtils.beginSampleEx(_sampleArr[index] or index)
	end
end

globalDeclare("LuaBeginSample", LuaBeginSample)

local function LuaEndSample()
	if SampleUtils then
		SampleUtils.endSampleEx()
	end
end

globalDeclare("LuaEndSample", LuaEndSample)

function TimerManager.init()
	_G_IsDebugMode = _G._G_IsDebugMode
	phonestcore = require("phonestcore")
	SafeCallback = require("Core.Framework.SafeCallback")
	LoggerManager = require("Core.Log.LoggerManager")
	LoggerConst = require("Core.Log.LoggerConst")
	logger = LoggerManager.getLogger("SafeCallback")
end

function TimerManager.shiftTimer(handlerID, delta)
	local timer = timerIdToHandler[handlerID]

	if timer == nil then
		return
	end

	phonestcore.shiftTimer(timer, delta)
end

function TimerManager.shiftAllTimer(delta)
	phonestcore.shiftAllTimer(delta)
end

function TimerManager.disposeHandler(handler)
	if type(handler) == "table" and handler.dispose then
		handler:dispose()
	end
end

if profile then
	TimerManager.stackSamples = {}

	local function jitProfileCb(thread, samples, vmstate)
		local stackDump = profile.dumpstack(thread, "fl", 10)
		local stackSamples = TimerManager.stackSamples

		if not stackSamples[stackDump] then
			stackSamples[stackDump] = 0
		end

		stackSamples[stackDump] = stackSamples[stackDump] + samples
	end

	function TimerManager.startJitProfile()
		profile.start("fl", jitProfileCb)
	end

	function TimerManager.stopJitProfile()
		profile.stop()
	end

	function TimerManager.dumpJitProfile()
		local stackSamples = TimerManager.stackSamples
		local sortedSamples = {}

		for stack, count in pairs(stackSamples) do
			table.insert(sortedSamples, {
				stack = stack,
				count = count
			})

			stackSamples[stack] = nil
		end

		table.sort(sortedSamples, function(a, b)
			return a.count > b.count
		end)
		print("JIT Profile Results:")

		for _, entry in ipairs(sortedSamples) do
			print(string.format("Count: %d\nStack:\n%s\n", entry.count, entry.stack))
		end
	end
end

function TimerManager.enableSample(enable)
	SampleUtils = require("Utils.SampleUtils")
	RepeatFrameHandler = enable and frameHandleWithSample or frameHandleNoSample
	_G.RepeatFrameHandler = RepeatFrameHandler
	TimerManagerHandler = enable and TimerManagerHandlerWithSample or TimerManagerHandlerNoSample
	_G.TimerManagerHandler = TimerManagerHandler
	NextFrameHandler = enable and NextFrameHandlerWithSample or NextFrameHandlerNoSample
	_G.NextFrameHandler = NextFrameHandler
	TimersCallbackHandler = enable and TimersCallbackHandlerWithSample or TimersCallbackHandlerNoSample
	_G.TimersCallbackHandler = TimersCallbackHandler
	NextFramesHandler = enable and NextFramesHandlerWithSample or NextFramesHandlerNoSample
	_G.NextFramesHandler = NextFramesHandler

	local phonestcore = require("phonestcore")
	local notifyLuaCallbackChanged = rawget(phonestcore, "notifyLuaCallbackChanged")

	if notifyLuaCallbackChanged then
		notifyLuaCallbackChanged()
	end
end

return TimerManager
