-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\SampleUtils.lua

local Class = require("Core.Framework.Class")
local CSProfiler = CS.UnityEngine.Profiling.Profiler
local CSSampleUtils = CS.FunPlus.WorldX.Utils.SampleUtils
local enableSampleEx = false
local SampleUtils = {
	isEnabled = false
}

function SampleUtils.sampleOn()
	return SampleUtils.isEnabled
end

function SampleUtils.sampleVoid()
	return
end

function SampleUtils.enableSample(enable)
	SampleUtils.isEnabled = enable

	local TimerManager = require("Core.Timer.TimerManager")

	TimerManager.enableSample(enable)

	if enable then
		SampleUtils.beginSampleEx = SampleUtils.beginSampleS
		SampleUtils.endSampleEx = SampleUtils.endSample
	else
		SampleUtils.beginSampleEx = SampleUtils.sampleVoid
		SampleUtils.endSampleEx = SampleUtils.sampleVoid
	end
end

function SampleUtils.beginSample(name)
	CSSampleUtils.BeginSample(name)
end

function SampleUtils.endSample()
	CSSampleUtils.EndSample()
end

function SampleUtils.sampleLuaMemoryOn()
	return appFacade.luaManager:IsEnableSampleLuaMemory()
end

function SampleUtils.enableSampleLuaMemory(enable)
	appFacade.luaManager:SetEnableSampleLuaMemory(enable)
end

local get_time = phonestcore.getNanosecondUTC
local time_unit_in_us = 1000

if enableSampleEx then
	local sampleStack = {}
	local sampleResult = {}

	function SampleUtils.beginSampleEx(name)
		sampleStack[#sampleStack + 1] = name
		sampleStack[#sampleStack + 1] = get_time()
	end

	function SampleUtils.endSampleEx()
		local time = get_time()
		local top = #sampleStack

		sampleResult[#sampleResult + 1] = sampleStack[top - 1]
		sampleResult[#sampleResult + 1] = time - sampleStack[top]
		sampleStack[top] = nil
		sampleStack[top - 1] = nil
	end

	function SampleUtils.logSampleEx()
		if not SampleUtils.isEnabled then
			return
		end

		local result = {}

		for i = #sampleResult, 1, -2 do
			local name = sampleResult[i - 1]
			local time = sampleResult[i]

			result[#result + 1] = string.format("%s: %.3f", name, time / time_unit_in_us)
			sampleResult[i] = nil
			sampleResult[i - 1] = nil
		end

		print(result[1], table.concat(result, "\n"))
	end
else
	SampleUtils.beginSampleEx = SampleUtils.sampleVoid
	SampleUtils.endSampleEx = SampleUtils.sampleVoid

	function SampleUtils.beginSampleS(name)
		SampleUtils.beginSample(tostring(name))
	end

	function SampleUtils.logSampleEx()
		return
	end
end

local _logTimeBegin = 0
local _logTimeName = ""

function SampleUtils.logTimeBegin(name)
	_logTimeName = name
	_logTimeBegin = get_time()
end

function SampleUtils.logTimeEnd()
	local time = get_time() - _logTimeBegin

	print(_logTimeName, time / time_unit_in_us)
end

function SampleUtils.getTotalReservedMemoryLong()
	return CSProfiler.GetTotalReservedMemoryLong()
end

function SampleUtils.getTotalAllocatedMemoryLong()
	return CSProfiler.GetTotalAllocatedMemoryLong()
end

function SampleUtils.getTotalUnusedReservedMemoryLong()
	return CSProfiler.GetTotalUnusedReservedMemoryLong()
end

function SampleUtils.getMonoHeapSizeLong()
	return CSProfiler.GetMonoHeapSizeLong()
end

function SampleUtils.getMonoUsedSizeLong()
	return CSProfiler.GetMonoUsedSizeLong()
end

local _names = {}
local _counts = {}

function SampleUtils.showSampleDesc(handler)
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

function SampleUtils.launchProfileRecord(delayStopSecond)
	SampleUtils.enableSample(true)

	delayStopSecond = delayStopSecond or 20

	SampleUtils.finishProfileRecord()
	CSSampleUtils.StartProfileRecord(delayStopSecond)

	local TimerManager = require("Core.Timer.TimerManager")

	SampleUtils.delayStopProfileRecordTimer = TimerManager.addTimer(delayStopSecond, function()
		SampleUtils.finishProfileRecord()
	end)

	return "Profile录制开始"
end

function SampleUtils.finishProfileRecord(isJumpTo)
	isJumpTo = isJumpTo or 1

	local ret = 0

	if SampleUtils.delayStopProfileRecordTimer then
		CSSampleUtils.StopProfileRecord(isJumpTo)

		local TimerManager = require("Core.Timer.TimerManager")

		TimerManager.removeTimer(SampleUtils.delayStopProfileRecordTimer)

		SampleUtils.delayStopProfileRecordTimer = nil
		ret = 1
	end

	return ret
end

function SampleUtils.jumpToProfileRecord()
	CSSampleUtils.JumpToProfileRecord()
end

return SampleUtils
