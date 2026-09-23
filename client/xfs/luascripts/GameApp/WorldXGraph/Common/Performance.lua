-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\WorldXGraph\\Common\\Performance.lua

local LoggerConst = require("Core.Log.LoggerConst")
local LoggerManager = require("Core.Log.LoggerManager")
local Performance = {}

local function metrics()
	local cs = CS

	return cs and cs.FunPlus and cs.FunPlus.WorldX and cs.FunPlus.WorldX.DialogueGraph and cs.FunPlus.WorldX.DialogueGraph.DialogueGraphCompiledLuaRuntime or nil
end

function Performance.IsEnabled()
	return LoggerManager.checkLogger(LoggerConst.DEBUG)
end

function Performance.NowMs()
	if not Performance.IsEnabled() then
		return nil
	end

	return os.clock() * 1000
end

function Performance.ElapsedMs(startedAt)
	if startedAt == nil or not Performance.IsEnabled() then
		return 0
	end

	return os.clock() * 1000 - startedAt
end

function Performance.Record(methodName, milliseconds)
	if not Performance.IsEnabled() then
		return
	end

	local runtimeMetrics = metrics()

	if runtimeMetrics == nil then
		return
	end

	local ok, recorder = pcall(function()
		return runtimeMetrics[methodName]
	end)

	if ok and recorder ~= nil then
		pcall(recorder, milliseconds)
	end
end

function Performance.Add(perf, millisecondsKey, countKey, milliseconds)
	if not Performance.IsEnabled() or perf == nil then
		return
	end

	perf[millisecondsKey] = (perf[millisecondsKey] or 0) + milliseconds
	perf[countKey] = (perf[countKey] or 0) + 1
end

function Performance.Flush(perf)
	if not Performance.IsEnabled() then
		return
	end

	local runtimeMetrics = metrics()

	if runtimeMetrics == nil or perf == nil then
		return
	end

	local ok, recorder = pcall(function()
		return runtimeMetrics.RecordLuaDetailPerformance
	end)

	if ok and recorder ~= nil then
		pcall(recorder, perf.logicRequireMs or 0, perf.logicRequireCount or 0, perf.nodeCmdMs or 0, perf.nodeCmdCount or 0)
	end
end

return Performance
