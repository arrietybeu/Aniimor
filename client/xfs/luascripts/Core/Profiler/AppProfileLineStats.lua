-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Profiler\\AppProfileLineStats.lua

local AppProfileLineStats = {}
local running = false
local func_stats = {}
local debug_gethook = debug.gethook
local debug_sethook = debug.sethook
local debug_getinfo = debug.getinfo
local get_time = phonestcore.getNanosecondUTC
local time_unit_ms = 1000000
local table_insert = table.insert
local table_sort = table.sort
local start_time = 0
local last_time = 0
local isEnterLua = 0

local function hook_handler(event, line)
	if event == "line" then
		if isEnterLua <= 0 then
			return
		end

		local current_time = get_time()
		local diff = current_time - last_time

		if diff < 2000000 then
			local f = debug.traceback()
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

			s[1] = s[1] + diff
			s[2] = s[2] + 1
		end

		last_time = get_time()
	elseif event == "return" then
		isEnterLua = isEnterLua - 1
	elseif event == "call" then
		isEnterLua = isEnterLua + 1

		if isEnterLua <= 1 then
			last_time = get_time()
		end
	else
		isEnterLua = false
	end
end

local function hook_handlerLine(event, line)
	local current = get_time()
	local diff = current - last_time

	if diff > 1000 and diff < 2000000 then
		local info = debug_getinfo(2, "S")

		if info then
			local src = info.short_src
			local src_tab = func_stats[src]

			if not src_tab then
				src_tab = {}
				func_stats[src] = src_tab
			end

			local tabInfo = src_tab[line]

			if not tabInfo then
				tabInfo = {
					0,
					0,
					info.source,
					info.linedefined,
					info.lastlinedefined
				}
				src_tab[line] = tabInfo
			end

			tabInfo[1] = tabInfo[1] + diff
			tabInfo[2] = tabInfo[2] + 1
		end
	end

	last_time = get_time()
end

function AppProfileLineStats.start()
	if not UNITY_EDITOR then
		return
	end

	if running then
		return
	end

	local hook = debug_gethook()

	if hook ~= nil then
		print("AppProfileLineStats other hook exist")

		return
	end

	print("AppProfileLineStats.start")

	start_time = os.clock()
	last_time = start_time
	running = true

	debug_sethook(hook_handlerLine, "l")
end

function AppProfileLineStats.stop()
	if not UNITY_EDITOR then
		return
	end

	if not running then
		return
	end

	debug_sethook()

	running = false
end

function AppProfileLineStats.clear()
	if not UNITY_EDITOR then
		return
	end

	if not running then
		return
	end

	debug_sethook()

	func_stats = {}
	running = false
end

function AppProfileLineStats.save()
	if not UNITY_EDITOR then
		return
	end

	local was_running = running

	if was_running then
		AppProfileLineStats.stop()
	end

	local now = os.clock()
	local cost = now - start_time
	local date_str = os.date("%Y%m%d_%H%M%S")
	local flat_list = {}

	for src, lines in pairs(func_stats) do
		for line, size in pairs(lines) do
			table_insert(flat_list, {
				name = string.format("%s:%d (%d)  %s$%s$%s", src, line, size[2], tostring(size[3]), tostring(size[4]), tostring(size[5])),
				total = size[1],
				avg = size[2] > 0 and size[1] / size[2] or 0,
				size = size[1],
				count = size[2]
			})
		end
	end

	local function dump(filename, data)
		local path

		if UNITY_EDITOR then
			path = "Logs\\" .. filename
		else
			path = filename
		end

		local file = io.open(path, "w")

		if file then
			file:write("{\n")
			file:write(string.format("\"time elapsed\":%.2f,\n", cost))
			file:write(string.format("\"time unit\":\"second\",\n"))
			file:write("\"rank\":[\n")

			for i, v in ipairs(data) do
				file:write(string.format("  {\"func\":\"%s\", \"total\":%.6f, \"avg\":%.6f, \"count\":%d}%s\n", v.name, v.total / time_unit_ms, v.avg / time_unit_ms, v.count, i == #data and "" or ","))
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

	dump("profile_line_total_" .. date_str .. ".json", top_total)
	table_sort(flat_list, function(a, b)
		return a.avg > b.avg
	end)

	local top_avg = {}

	for i = 1, math.min(5000, #flat_list) do
		top_avg[i] = flat_list[i]
	end

	dump("profile_line_avg_" .. date_str .. ".json", top_avg)

	if was_running then
		AppProfileLineStats.start()
	end
end

function AppProfileLineStats.trigger()
	if not UNITY_EDITOR then
		return
	end

	if not running then
		AppProfileLineStats.start()
	else
		AppProfileLineStats.save()
	end
end

return AppProfileLineStats
