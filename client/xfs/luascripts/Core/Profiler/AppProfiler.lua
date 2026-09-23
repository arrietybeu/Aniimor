-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Profiler\\AppProfiler.lua

local AppProfiler = {}
local running = false
local func_stats = {}
local ignore_set = {}
local phonestcore = require("phonestcore")
local debug_sethook = debug.sethook
local debug_getinfo = debug.getinfo
local get_time = phonestcore.getNanosecondUTC
local time_unit_ms = 1000000
local table_insert = table.insert
local table_sort = table.sort
local start_time = 0
local sample_count = 0
local sample_mode = false
local frame_time_data = {}
local frame_index_map = {}
local current_begin_times = {}

local function hook_handler(event)
	local info = debug_getinfo(2, "f")
	local f = info.func

	if ignore_set[f] then
		return
	end

	local s = func_stats[f]

	if not s then
		local n = debug_getinfo(2, "Sn")

		s = {
			0,
			0,
			0,
			0,
			n,
			debug.traceback()
		}
		func_stats[f] = s
	end

	if event == "call" then
		s[3] = s[3] + 1

		if s[3] == 1 then
			s[4] = get_time()
		end
	else
		local d = s[3]

		if d > 0 then
			if d == 1 then
				s[1] = s[1] + (get_time() - s[4])
				s[2] = s[2] + 1
			end

			s[3] = d - 1
		end
	end
end

local ispause = false

function AppProfiler.addIgnore(f)
	ignore_set[f] = true
end

function AppProfiler.isRunning()
	return running
end

function AppProfiler.isPause()
	return running and ispause
end

function AppProfiler.pause()
	if not running then
		return
	end

	if ispause then
		return
	end

	ispause = true

	debug_sethook()
end

function AppProfiler.resume()
	if not running then
		return
	end

	if not ispause then
		return
	end

	ispause = false

	debug_sethook(hook_handler, "cr")
end

function AppProfiler.start()
	if running then
		return
	end

	local hook = debug.gethook()

	if hook ~= nil then
		return
	end

	start_time = os.clock()
	running = true

	debug_sethook(hook_handler, "cr")
end

function AppProfiler.stop()
	if not running then
		return
	end

	debug_sethook()

	running = false
end

function AppProfiler.startSample()
	if sample_mode then
		return
	end

	sample_mode = true

	if sample_count == 0 then
		start_time = os.clock()
	end
end

AppProfiler.start2 = AppProfiler.startSample

function AppProfiler.stopSample()
	if not sample_mode then
		return
	end

	sample_mode = false

	if running then
		debug_sethook()

		running = false
	end
end

function AppProfiler.beginSample()
	if not sample_mode then
		return
	end

	sample_count = sample_count + 1

	if running then
		return
	end

	if debug.gethook() ~= nil then
		return
	end

	running = true

	debug_sethook(hook_handler, "cr")
end

function AppProfiler.endSample()
	if not sample_mode then
		return
	end

	if not running then
		return
	end

	debug_sethook()

	running = false
end

function AppProfiler.clear()
	if not running then
		return
	end

	debug_sethook()

	func_stats = {}
	sample_count = 0
	running = false
end

function AppProfiler.save()
	local was_running = running

	if was_running then
		AppProfiler.stop()
	end

	local now = os.clock()
	local elapsed = now - start_time
	local cost = sample_count > 0 and sample_count or elapsed
	local date_str = os.date("%Y%m%d_%H%M%S")
	local flat_list = {}

	for f, s in pairs(func_stats) do
		local info = s[5]

		if info then
			local name = string.format("%s:%d (%s)", info.short_src or "unknown", info.linedefined or -1, info.name or "anonymous")

			table_insert(flat_list, {
				name = name,
				total = s[1],
				avg = s[2] > 0 and s[1] / s[2] or 0,
				count = s[2],
				trace = s[6]
			})
		end
	end

	local function dump(filename, data)
		local path = "Logs\\" .. filename
		local file = io.open(path, "w")

		if file then
			file:write("{\n")
			file:write(string.format("\"time elapsed\":%.2f,\n", elapsed))
			file:write(string.format("\"sample count\":%d,\n", sample_count))
			file:write(string.format("\"time unit\":\"second\",\n"))
			file:write(string.format("\"rank time unit\":\"ms\",\n"))
			file:write("\"rank\":[\n")

			for i, v in ipairs(data) do
				file:write(string.format("  {\"func\":\"%s\", \"total\":%.6f, \"avg\":%.6f, \"count\":%d, \"trace\":\"%s\"}%s\n", v.name, v.total / time_unit_ms, v.avg / time_unit_ms, v.count, v.trace, i == #data and "" or ","))
			end

			file:write("]")
			file:write("}")
			file:close()
		end
	end

	table_sort(flat_list, function(a, b)
		return a.total > b.total
	end)

	local top_total = {}

	for i = 1, math.min(5000, #flat_list) do
		top_total[i] = flat_list[i]
	end

	dump("profile_total_" .. date_str .. ".json", top_total)
	table_sort(flat_list, function(a, b)
		return a.avg > b.avg
	end)

	local top_avg = {}

	for i = 1, math.min(5000, #flat_list) do
		top_avg[i] = flat_list[i]
	end

	dump("profile_avg_" .. date_str .. ".json", top_avg)

	local top_avg2 = {}

	for i = 1, #flat_list do
		if flat_list[i].count > cost / 2 then
			top_avg2[#top_avg2 + 1] = flat_list[i]

			if #top_avg2 > 5000 then
				break
			end
		end
	end

	dump("profile_avg2_" .. date_str .. ".json", top_avg2)

	if was_running then
		AppProfiler.start()
	end
end

function AppProfiler.beginSampleTime(name)
	current_begin_times[name] = get_time()
end

function AppProfiler.endSampleTime(name)
	local begin_t = current_begin_times[name]

	if not begin_t then
		return
	end

	current_begin_times[name] = nil

	local elapsed = get_time() - begin_t
	local frame = Time.unityFrameCount
	local idx = frame_index_map[frame]
	local stats

	if idx then
		stats = frame_time_data[idx].stats
	else
		stats = {}

		table_insert(frame_time_data, {
			frame = frame,
			stats = stats
		})

		frame_index_map[frame] = #frame_time_data
	end

	if stats[name] then
		stats[name] = stats[name] + elapsed
	else
		stats[name] = elapsed
	end
end

function AppProfiler.clearTime()
	frame_time_data = {}
	frame_index_map = {}
	current_begin_times = {}
end

function AppProfiler.saveTime(sortByTime)
	local date_str = os.date("%Y%m%d_%H%M%S")
	local path = "Logs\\profile_time_" .. date_str .. ".json"
	local file = io.open(path, "w")

	if not file then
		return
	end

	file:write("{\n")
	file:write(string.format("\"sort\":\"%s\",\n", sortByTime and "time" or "name"))
	file:write("\"time unit\":\"ms\",\n")
	file:write("\"frames\":[\n")

	local frame_count = #frame_time_data

	for i, entry in ipairs(frame_time_data) do
		local list = {}

		for n, elapsed in pairs(entry.stats) do
			table_insert(list, {
				name = n,
				elapsed = elapsed
			})
		end

		if sortByTime then
			table_sort(list, function(a, b)
				return a.elapsed > b.elapsed
			end)
		else
			table_sort(list, function(a, b)
				return a.name < b.name
			end)
		end

		file:write(string.format("  {\"frame\":%d,\"items\":[", entry.frame))

		local item_count = #list

		for j, item in ipairs(list) do
			file:write(string.format("{\"name\":\"%s\",\"time\":%.6f}%s", item.name, item.elapsed / time_unit_ms, j == item_count and "" or ","))
		end

		file:write("]}")
		file:write(i == frame_count and "\n" or ",\n")
	end

	file:write("]\n}")
	file:close()
end

local function _frame()
	return _G.Time and Time.unityFrameCount or -1
end

local function _stats_size()
	local n = 0

	for _ in pairs(func_stats) do
		n = n + 1
	end

	return n
end

local function _hook_desc()
	local h = debug.gethook()

	if h == nil then
		return "nil"
	end

	if h == hook_handler then
		return "self"
	end

	return tostring(h)
end

function AppProfiler.startSampleLog()
	local frame = _frame()

	print(string.format("[AppProf.startSample] frame=%d sample_mode=%s running=%s sample_count=%d", frame, tostring(sample_mode), tostring(running), sample_count))

	if sample_mode then
		print("[AppProf.startSample] SKIP: sample_mode already true")

		return
	end

	sample_mode = true

	if sample_count == 0 then
		start_time = os.clock()

		print(string.format("[AppProf.startSample] reset start_time=%.3f", start_time))
	end

	print("[AppProf.startSample] OK sample_mode<-true")
end

function AppProfiler.beginSampleLog()
	local frame = _frame()

	print(string.format("[AppProf.beginSample] frame=%d sample_mode=%s running=%s sample_count=%d hook=%s", frame, tostring(sample_mode), tostring(running), sample_count, _hook_desc()))

	if not sample_mode then
		print("[AppProf.beginSample] SKIP: sample_mode==false (forget to call startSample/startSampleLog?)")

		return
	end

	sample_count = sample_count + 1

	if running then
		print(string.format("[AppProf.beginSample] SKIP install (running==true), sample_count=%d", sample_count))

		return
	end

	if debug.gethook() ~= nil then
		print(string.format("[AppProf.beginSample] SKIP install: other hook already set (%s); sample_count=%d", _hook_desc(), sample_count))

		return
	end

	running = true

	debug_sethook(hook_handler, "cr")
	print(string.format("[AppProf.beginSample] OK hook installed, sample_count=%d", sample_count))
end

function AppProfiler.endSampleLog()
	local frame = _frame()

	print(string.format("[AppProf.endSample] frame=%d sample_mode=%s running=%s sample_count=%d func_stats=%d hook=%s", frame, tostring(sample_mode), tostring(running), sample_count, _stats_size(), _hook_desc()))

	if not sample_mode then
		print("[AppProf.endSample] SKIP: sample_mode==false")

		return
	end

	if not running then
		print("[AppProf.endSample] SKIP: running==false (hook never installed in matching begin?)")

		return
	end

	debug_sethook()

	running = false

	print(string.format("[AppProf.endSample] OK hook removed, func_stats=%d", _stats_size()))
end

function AppProfiler.saveLog()
	local frame = _frame()
	local n = _stats_size()
	local elapsed = os.clock() - start_time

	print(string.format("[AppProf.save] BEGIN frame=%d running=%s sample_mode=%s sample_count=%d func_stats=%d elapsed=%.3fs hook=%s", frame, tostring(running), tostring(sample_mode), sample_count, n, elapsed, _hook_desc()))

	if n == 0 then
		print("[AppProf.save] WARN func_stats empty. Likely causes: " .. "(1) startSample() never called -> beginSample is no-op; " .. "(2) begin/end never paired during target code; " .. "(3) another hook present at beginSample time.")

		return
	end

	local before_ts = os.date("%Y%m%d_%H%M%S")
	local ok, err = pcall(AppProfiler.save)
	local after_ts = os.date("%Y%m%d_%H%M%S")

	if not ok then
		print("[AppProf.save] ERROR pcall: " .. tostring(err))

		return
	end

	local found = false

	for _, prefix in ipairs({
		"profile_total",
		"profile_avg",
		"profile_avg2"
	}) do
		for _, ts in ipairs({
			after_ts,
			before_ts
		}) do
			local p = "Logs\\" .. prefix .. "_" .. ts .. ".json"
			local f = io.open(p, "r")

			if f then
				local sz = f:seek("end", 0)

				f:close()
				print(string.format("[AppProf.save] OK %s size=%d bytes", p, sz))

				found = true

				break
			end
		end
	end

	if not found then
		print(string.format("[AppProf.save] FAIL: no output file at Logs\\profile_*_%s.json. " .. "Check: (a) Logs/ dir exists & writable (io.open silently returns nil otherwise); " .. "(b) cwd correct.", after_ts))
	end
end

function AppProfiler.trigger()
	if sample_mode then
		AppProfiler.save()

		return
	end

	if not running then
		AppProfiler.start()
	else
		AppProfiler.save()
	end
end

function AppProfiler.clear_trigger()
	local was_running = running

	if was_running then
		debug_sethook()

		running = false
	end

	AppProfiler.save()

	func_stats = {}
	sample_count = 0
	start_time = os.clock()
	frame_time_data = {}
	frame_index_map = {}
	current_begin_times = {}

	collectgarbage("collect")

	if was_running then
		running = true

		debug_sethook(hook_handler, "cr")
	end
end

return AppProfiler
