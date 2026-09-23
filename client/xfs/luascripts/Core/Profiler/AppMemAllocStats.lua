-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Profiler\\AppMemAllocStats.lua

local AppMemAllocStats = {}
local running = false
local last_mem = 0
local collect_stack_heap = true
local records = {}
local get_mem = collectgarbage
local debug_gethook = debug.gethook
local debug_sethook = debug.sethook
local debug_getinfo = debug.getinfo
local table_insert = table.insert
local table_sort = table.sort
local get_time = os.clock
local start_time = get_time()

function AppMemAllocStats.start()
	if not UNITY_EDITOR then
		return
	end

	local existing_hook = debug_gethook()

	if existing_hook or running then
		return
	end

	last_mem = get_mem("count") * 1024
	running = true

	local is_chunck_printed = false

	debug_sethook(function(event, line)
		local current_mem = get_mem("count") * 1024
		local diff = current_mem - last_mem

		if diff > 2 then
			local info = debug_getinfo(2, "S")

			if info then
				local src = debug.traceback()
				local src_tab = records[src]

				if not src_tab then
					src_tab = {}
					records[src] = src_tab
				end

				local tabInfo = src_tab[line]

				if not tabInfo then
					tabInfo = {
						0,
						0,
						debug.traceback(),
						info.linedefined,
						info.lastlinedefined
					}
					src_tab[line] = tabInfo
				end

				tabInfo[1] = tabInfo[1] + diff
				tabInfo[2] = tabInfo[2] + 1
			end

			last_mem = get_mem("count") * 1024
		else
			last_mem = current_mem
		end
	end, "l")
end

if not collect_stack_heap then
	function AppMemAllocStats.collect_stack(diff)
		local info = debug_getinfo(3, "Sl")

		if info then
			local src = info.short_src
			local line = info.currentline

			if line < 0 then
				src = debug.traceback()
			end

			local src_tab = records[src]

			if not src_tab then
				src_tab = {}
				records[src] = src_tab
			end

			local tabInfo = src_tab[line]

			if not tabInfo then
				tabInfo = {
					0,
					0,
					debug.traceback(),
					info.linedefined,
					info.lastlinedefined
				}
				src_tab[line] = tabInfo
			end

			tabInfo[1] = tabInfo[1] + diff
			tabInfo[2] = tabInfo[2] + 1
		end
	end
else
	function AppMemAllocStats.collect_stack(diff)
		local src = debug.traceback()
		local src_tab = records[src]

		if not src_tab then
			src_tab = {}
			records[src] = src_tab
		end

		local line = 1
		local tabInfo = src_tab[line]

		if not tabInfo then
			tabInfo = {
				0,
				0,
				src_tab,
				0,
				0
			}
			src_tab[line] = tabInfo
		end

		tabInfo[1] = tabInfo[1] + diff
		tabInfo[2] = tabInfo[2] + 1
	end
end

function AppMemAllocStats.collect_add(name, diff)
	if not running then
		return
	end

	local src = name
	local src_tab = records[src]

	if not src_tab then
		src_tab = {}
		records[src] = src_tab
	end

	local line = 1
	local tabInfo = src_tab[line]

	if not tabInfo then
		tabInfo = {
			0,
			0,
			src_tab,
			0,
			0
		}
		src_tab[line] = tabInfo
	end

	tabInfo[1] = tabInfo[1] + diff
	tabInfo[2] = tabInfo[2] + 1
end

local sample_stack = {}
local sample_mode = false

function AppMemAllocStats.startSample()
	if not UNITY_EDITOR then
		return
	end

	if sample_mode then
		return
	end

	sample_mode = true
end

function AppMemAllocStats.stopSample()
	if not sample_mode then
		return
	end

	sample_mode = false

	for i = #sample_stack, 1, -1 do
		sample_stack[i] = nil
	end
end

function AppMemAllocStats.beginSample()
	if not sample_mode then
		return
	end

	table_insert(sample_stack, get_mem("count") * 1024)
end

function AppMemAllocStats.endSample()
	if not sample_mode then
		return
	end

	local idx = #sample_stack

	if idx == 0 then
		return
	end

	local start_mem = sample_stack[idx]

	sample_stack[idx] = nil

	if not start_mem then
		return
	end

	local current_mem = get_mem("count") * 1024
	local diff = current_mem - start_mem

	if diff > 2 then
		local info = debug_getinfo(2, "Sl")

		if info then
			local src = debug.traceback()
			local line = info.currentline
			local src_tab = records[src]

			if not src_tab then
				src_tab = {}
				records[src] = src_tab
			end

			local tabInfo = src_tab[line]

			if not tabInfo then
				tabInfo = {
					0,
					0,
					debug.traceback(),
					info.linedefined,
					info.lastlinedefined
				}
				src_tab[line] = tabInfo
			end

			tabInfo[1] = tabInfo[1] + diff
			tabInfo[2] = tabInfo[2] + 1
		end
	end
end

function AppMemAllocStats.stop()
	if not UNITY_EDITOR then
		return
	end

	if not running then
		return
	end

	debug_sethook()

	running = false
end

function AppMemAllocStats.clear()
	AppMemAllocStats.stop()

	records = {}
end

function AppMemAllocStats.save()
	if not UNITY_EDITOR then
		return
	end

	local was_running = running

	if was_running then
		AppMemAllocStats.stop()
	end

	local totalAlloc = 0
	local head100Alloc = 0
	local now = get_time()
	local flat_list = {}

	for src, lines in pairs(records) do
		for line, size in pairs(lines) do
			table_insert(flat_list, {
				loc = string.format("%s:%d (%d)  %s$%s$%s", src, line, size[2], tostring(size[3]), tostring(size[4]), tostring(size[5])),
				size = size[1]
			})

			totalAlloc = totalAlloc + size[1]
		end
	end

	table_sort(flat_list, function(a, b)
		return a.size > b.size
	end)

	for i, info in ipairs(flat_list) do
		head100Alloc = head100Alloc + info.size
	end

	local count = math.min(5000, #flat_list)
	local date_str = os.date("%Y%m%d_%H%M%S")
	local filename = "Logs\\profile_mem_" .. date_str .. ".json"

	if UNITY_EDITOR then
		filename = "Logs\\profile_mem_" .. date_str .. ".json"
	else
		filename = "profile_mem_" .. date_str .. ".json"
	end

	local f = io.open(filename, "w")

	if f then
		f:write("{\n")
		f:write(string.format("  \"time\":%.2f,\n", now - start_time))
		f:write(string.format("  \"total\":%.2f,\n", get_mem("count") / 1024))
		f:write(string.format("  \"totalAlloc\":%.2f,\n", totalAlloc / 1024 / 1024))
		f:write(string.format("  \"head100Alloc\":%.2f,\n", head100Alloc / 1024 / 1024))
		f:write(string.format("  \"desc\":\"time in seconds, other in MB, rank in KB\",\n"))
		f:write(string.format("  \"rank\":[\n"))

		for i = 1, count do
			local item = flat_list[i]

			f:write(string.format("  {\"location\":\"%s\", \"growth_bytes\":%d}%s\n", item.loc:gsub("\\", "\\\\"):gsub("\"", "\""), math.round(item.size / 1024), i == count and "" or ","))
		end

		f:write("]")
		f:write("}")
		f:close()
	end

	if was_running then
		AppMemAllocStats.start()
	end
end

function AppMemAllocStats.trigger()
	if not UNITY_EDITOR then
		return
	end

	if not running then
		AppMemAllocStats.start()
	else
		AppMemAllocStats.save()
	end
end

return AppMemAllocStats
