-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Framework\\Profiler.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("Profiler")
local Profiler = {}
local jitprof

local function isJitEnabled()
	return UNITY_PS5 == false and jit
end

function Profiler:_func_title(funcinfo)
	local name = funcinfo.name or "anonymous"
	local line = string.format("%d", funcinfo.linedefined or 0)
	local source = funcinfo.short_src or "C_FUNC"

	return string.format("%s\t%s: %s", name, source, line)
end

function Profiler:_func_report(funcinfo)
	local title = self:_func_title(funcinfo)
	local report = self._reports_index[title]

	if not report then
		report = {
			totaltime = 0,
			callcount = 0,
			title = self:_func_title(funcinfo)
		}
		self._reports_index[title] = report

		table.insert(self._reports, report)
	end

	return report
end

function Profiler:_profiling_call(funcinfo)
	local report = self:_func_report(funcinfo)

	report.calltime = os.clock()
	report.callcount = report.callcount + 1
end

function Profiler:_profiling_return(funcinfo)
	local stoptime = os.clock()
	local report = self:_func_report(funcinfo)

	if report.calltime and report.calltime > 0 then
		report.totaltime = report.totaltime + (stoptime - report.calltime)
		report.calltime = 0
	end
end

function Profiler._profiling_handler(hooktype)
	local funcinfo = debug.getinfo(2, "nS")

	if hooktype == "call" then
		Profiler:_profiling_call(funcinfo)
	elseif hooktype == "return" then
		Profiler:_profiling_return(funcinfo)
	end
end

function string:endsWith(ending)
	return ending == "" or self:sub(-#ending) == ending
end

function Profiler._tracing_handler(hooktype)
	local funcinfo = debug.getinfo(2, "nS")

	if hooktype == "call" then
		local name = funcinfo.name
		local source = funcinfo.short_src

		if name and source and source:endsWith(".lua") then
			local line = string.format("%d", funcinfo.linedefined or 0)

			if Profiler._tracer then
				Profiler._tracer(name, source, line)
			elseif LoggerManager.checkLogger(LoggerConst.INFO) then
				logger:info(string.format("%-30s: %s: %s", name, source, line))
			end
		end
	end
end

function Profiler:start()
	collectgarbage("stop")

	local mode = self:mode()

	if mode and mode == "trace" then
		debug.sethook(Profiler._tracing_handler, "cr", 0)
	else
		self._reports = {}
		self._reports_index = {}
		self._start_time = os.clock()

		debug.sethook(Profiler._profiling_handler, "cr", 0)
	end
end

local function profiler_callback(thread, samples, vmstate)
	if not jitprof then
		return
	end

	if vmstate == "C" then
		-- block empty
	end

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		logger:debug("---------------- profiler_callback", inspect(samples), vmstate)
	end

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		logger:debug(jitprof.dumpstack(thread, "pfFlZ", -100))
	end

	local a = samples
end

function Profiler:startJit()
	if not isJitEnabled() then
		return
	end

	jitprof = jitprof or require("jit.profile")

	jitprof.start("fl", profiler_callback)
end

function Profiler:stopJit()
	if jitprof then
		jitprof.stop()
	end
end

function Profiler:stop()
	local mode = self:mode()

	if mode and mode == "trace" then
		debug.sethook()
	else
		self._end_time = os.clock()

		debug.sethook()

		local totaltime = self._end_time - self._start_time

		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("==totaltime==percent==callcount==avgtime==title==")
		end

		table.sort(self._reports, function(a, b)
			return a.totaltime > b.totaltime
		end)

		for _, report in ipairs(self._reports) do
			local percent = report.totaltime / totaltime * 100

			if percent < 0.1 then
				break
			end

			if self._reporter then
				self._reporter(report.totaltime, percent, report.callcount, report.title)
			elseif LoggerManager.checkLogger(LoggerConst.INFO) then
				logger:info("%s", string.format("%10.3f, %6.2f%%, %9d, %8.6f, %s", report.totaltime, percent, report.callcount, report.totaltime / report.callcount, report.title))
			end
		end

		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("=================================================")
		end
	end

	collectgarbage("restart")
end

function Profiler:setReporter(reporter)
	self._reporter = reporter
end

function Profiler:setTracer(tracer)
	self._tracer = tracer
end

function Profiler:setMode(mode)
	self._mode = mode
end

function Profiler:mode()
	if self._mode == "trace" then
		return self._mode
	end

	return "perf"
end

return Profiler
