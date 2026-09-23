-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Profiler\\Profiler.lua

local vmProfiler = require("vmprofiler")
local TimerManager = require("Core.Timer.TimerManager")
local LoggerManager = require("Core.Log.LoggerManager")
local CallbackHandler = require("Core.Common.CallbackHandler")
local GameEngineMetrics = require("Core.Server.Monitoring.GameEngineMetrics")
local logger = LoggerManager.getLogger("Profiler")
local Profiler = {
	openFileFlag = false,
	outfile = "./profiler.txt",
	gcTracingFlag = false,
	output = io.stdout
}

function Profiler:initProfiler(luaVMProfiler)
	if luaVMProfiler == nil or luaVMProfiler.isOpen == nil or not luaVMProfiler.isOpen then
		return
	else
		logger:info("luaVMProfiler is open")
	end

	self.luaVMProfiler = luaVMProfiler

	vmProfiler.initProfiler()
	self:startGCTracing()
end

function Profiler:startGCTracing()
	if self.gcTracingFlag or self.luaVMProfiler == nil or not self.luaVMProfiler.isOpen then
		return
	end

	self.gcTracingFlag = true

	self:openGCSwitch()
	vmProfiler.gcTimeStatisticsBegin()

	local stepMS = 1000

	if self.luaVMProfiler.stepMS ~= nil then
		stepMS = tonumber(self.luaVMProfiler.stepMS)
	end

	self.gcTimer = TimerManager.addRepeatTimer(stepMS / 1000, function()
		local totalTime, gcMaxTime, gcCount, maxScanTime, totalScanTime, freeCount = vmProfiler.gcTimeDetailInfo()

		GameEngineMetrics.luaVMGCSweepCount:add(gcCount)
		GameEngineMetrics.luaVMGCSweepMaxNS:set(gcMaxTime)
		GameEngineMetrics.luaVMGCSweepTotalNS:add(totalTime)
		GameEngineMetrics.luaVMGCScanTotalNS:add(totalScanTime)
		GameEngineMetrics.luaVMGCScanMaxNS:set(maxScanTime)
		GameEngineMetrics.luaVMGCFreeCount:add(freeCount)
	end)
end

function Profiler:stopGCTracing()
	if not self.gcTracingFlag then
		return
	end

	self.gcTracingFlag = false

	self:closeGCSwitch()

	if self.gcTimer ~= nil then
		TimerManager.removeTimer(self.gcTimer)
		vmProfiler.gcTimeStatisticsFinish()
		vmProfiler.gcTimeDetailInfo()

		self.gcTimer = nil
	end
end

function Profiler:_openProfilerFile()
	if self.openFileFlag == true then
		return
	end

	self.openFileFlag = true

	local file = assert(io.open(self.outfile, "w"))

	self.output = file
end

function Profiler:start(lastSecond)
	self:startGCTime(lastSecond)
	self:startFuncConsum(lastSecond)
end

function Profiler:stop()
	self:closeGCSwitch()
	self:closeFuncSwitch()
end

function Profiler:openGCSwitch()
	vmProfiler.setGCTimeSwitch(1)
	vmProfiler.setObjDebugSwitch(1)
end

function Profiler:closeGCSwitch()
	vmProfiler.setGCTimeSwitch(0)
	vmProfiler.setObjDebugSwitch(0)
end

function Profiler:startGCTime(lastSecond)
	logger:info("start gc timer statistic, last second:%d", lastSecond)
	self:openGCSwitch()
	vmProfiler.gcTimeStatisticsBegin()
	vmProfiler.beginObjDebugStatistics()

	self.gcTimer = TimerManager.addTimer(lastSecond, function()
		logger:info("stop gc timer statistic")
		vmProfiler.gcTimeStatisticsFinish()
		vmProfiler.finishObjDebugStatistics()
		TimerManager.removeTimer(self.gcTimer)
		self:_printGCConsumCollect()
		self:_printObjDebugStatistics()
	end)
end

function Profiler:_printGCConsumCollect()
	local printType = "gc time"

	self:_beginPrint(printType)

	local totalTime, maxTime, gcCount, maxScanTime, totalScanTime = vmProfiler.gcTimeDetailInfo()

	self:_prints("total time: ", totalTime)
	self:_prints("max time: ", maxTime)
	self:_prints("gc count: ", gcCount)
	self:_prints("max scan time:", maxScanTime)
	self:_prints("total scan time:", totalScanTime)
	self:_finishPrint(printType)
end

function Profiler:_printObjDebugStatistics()
	local printType = "object debug"

	self:_beginPrint(printType)

	local objDetail = vmProfiler.objDebugStatisticsDetail()

	for k, v in pairs(objDetail) do
		self:_prints("table:", v)
	end

	self:_finishPrint(printType)
end

function Profiler:openFuncSwitch()
	self:_openProfilerFile()
	vmProfiler.setFuncTimeSwitch(1)
end

function Profiler:closeFuncSwitch()
	vmProfiler.setFuncTimeSwitch(0)
end

function Profiler:startFuncConsum(lastSecond)
	logger:info("start func consum statistic, last second:%d", lastSecond)
	self:openFuncSwitch()
	vmProfiler.beginFuncStatistics()

	self.funcCosumTimer = TimerManager.addTimer(lastSecond, function()
		vmProfiler.finishFuncStatistics()
		TimerManager.removeTimer(self.funcCosumTimer)
		self:_printFuncConsum()
	end)
end

function Profiler:_printFuncConsum()
	local printType = "function consume"

	self:_beginPrint(printType)

	local funcConsumDetail = vmProfiler.funcStatisticsDetail()

	for k, v in pairs(funcConsumDetail) do
		self:prints("function info:", v)
	end

	self:_finishPrint(printType)
end

function Profiler:testTimer()
	TimerManager.addTimer(10, function()
		logger:info("call timerEndPrint")
	end)
end

function Profiler:_prints(...)
	local outStr = ""

	for i = 1, select("#", ...) do
		local temp = select(i, ...) or ""

		outStr = outStr .. tostring(temp) .. "\t"
	end

	outStr = outStr .. "\n"

	self.output:write(outStr)
end

function Profiler:_beginPrint(printType)
	self:_openProfilerFile()
	self:_prints("=================== print ", printType, " detail start===================")
end

function Profiler:_finishPrint(printType)
	self:_prints("=================== print ", printType, " detail end===================")
	self:_prints("\n\n")
	self.output:flush()
end

return Profiler
