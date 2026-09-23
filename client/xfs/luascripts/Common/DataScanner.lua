-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\DataScanner.lua

local DataScanner = {}

local function valueToString(value)
	if type(value) == "table" then
		local parts = {}
		local hasArrayPart = false

		for i, v in ipairs(value) do
			hasArrayPart = true

			table.insert(parts, valueToString(v))
		end

		for k, v in pairs(value) do
			if type(k) ~= "number" or not hasArrayPart then
				table.insert(parts, tostring(k) .. "=" .. valueToString(v))
			end
		end

		return "{" .. table.concat(parts, ",") .. "}"
	else
		return tostring(value)
	end
end

local function parseArgs(argStr)
	if not argStr then
		return {}
	end

	argStr = argStr:gsub("^%s+", ""):gsub("%s+$", "")

	if not argStr:match("^{.*}$") then
		argStr = "{" .. argStr .. "}"
	end

	argStr = argStr:gsub("\\\"", "\"")

	local fn, err = loadstring("return " .. argStr)

	if not fn then
		print("错误: 参数格式不正确 - " .. tostring(err))
		print("原始参数: " .. argStr)

		return {}
	end

	local success, result = pcall(fn)

	if not success then
		print("错误: 参数解析失败 - " .. tostring(result))
		print("原始参数: " .. argStr)

		return {}
	end

	if type(result) ~= "table" then
		print("错误: 参数必须是一个表")
		print("原始参数: " .. argStr)

		return {}
	end

	return result
end

local function findCommonDataPath()
	local lfs = require("lfs")

	local function searchInPath(path)
		for searchPath in string.gmatch(path, "[^;]+") do
			searchPath = searchPath:gsub("^\"(.*)\"$", "%1")

			local dataDir = searchPath:match("(.*Common)/")

			if dataDir then
				dataDir = dataDir .. "/Data"

				local attr = lfs.attributes(dataDir)

				if attr and attr.mode == "directory" then
					return dataDir
				end
			end
		end

		return nil
	end

	local dataPath = searchInPath(package.path)

	if dataPath then
		return dataPath
	end

	local currentDir = lfs.currentdir()
	local commonDir = currentDir:match("(.*Common)")

	if commonDir then
		local dataDir = commonDir .. "/Data"
		local attr = lfs.attributes(dataDir)

		if attr and attr.mode == "directory" then
			return dataDir
		end
	end

	return nil
end

local TaskConfig = {
	graph_event = {
		description = "Scan scene graph nodes that use the specified event name",
		usage = "graph_event {'setMarkState'}",
		handler = function(params)
			local output = {
				success = true,
				messages = {},
				results = {}
			}

			local function addMessage(msg)
				table.insert(output.messages, msg)
			end

			local eventName = type(params[1]) == "string" and params[1]

			if not eventName then
				output.success = false
				output.error = "graph_event task requires an event name parameter"

				addMessage("Error: " .. output.error)

				return output
			end

			local results = {}
			local lfs = require("lfs")
			local dataPath = findCommonDataPath()

			if not dataPath then
				output.success = false
				output.error = "Cannot find Common/Data directory"

				addMessage("Error: " .. output.error)

				return output
			end

			local baseDir = dataPath .. "/Scene"

			addMessage("Scanning directory: " .. baseDir)

			local function scanDir(dir)
				for file in lfs.dir(dir) do
					if file ~= "." and file ~= ".." then
						local path = dir .. "/" .. file
						local attr = lfs.attributes(path)

						if attr and attr.mode == "directory" then
							scanDir(path)
						elseif file == "scene_graph_data.lua" then
							local success, data = pcall(dofile, path)

							if success and type(data) == "table" then
								for graphId, graph in pairs(data) do
									if type(graph) == "table" and graph.nodes then
										for nodeId, node in pairs(graph.nodes) do
											if node.className == "PlayerEventNode" and node._inputPortValues and node._inputPortValues.EventName == eventName then
												local reference = {
													scene = dir:match("Scene/([^/]+)"),
													graphId = graphId,
													nodeId = nodeId,
													params = node.actionData and node.actionData.eventParams
												}

												table.insert(results, reference)
											end
										end
									end
								end
							end
						end
					end
				end
			end

			scanDir(baseDir)
			addMessage(string.format("\nFound references for event '%s':", eventName))

			for _, ref in ipairs(results) do
				local paramsStr = ""

				if ref.params then
					paramsStr = " Parameters: " .. valueToString(ref.params)
				end

				addMessage(string.format("Scene[%s] Graph[%s] Node[%s]%s", ref.scene, ref.graphId, ref.nodeId, paramsStr))
			end

			addMessage(string.format("\nTotal references found: %d", #results))

			output.results = results

			return output
		end
	}
}

function DataScanner.execute(taskName, params)
	local output = {
		success = true,
		messages = {},
		results = {},
		taskName = taskName
	}

	local function addMessage(msg)
		table.insert(output.messages, msg)
	end

	local task = TaskConfig[taskName]

	if not task then
		output.success = false
		output.error = string.format("Task '%s' not found", taskName)

		addMessage("Error: " .. output.error)

		return output
	end

	addMessage(string.format("\nExecuting task: %s", taskName))
	addMessage(string.format("Description: %s", task.description))

	local taskOutput = task.handler(params)

	for _, msg in ipairs(taskOutput.messages) do
		addMessage(msg)
	end

	output.success = taskOutput.success
	output.error = taskOutput.error
	output.results = taskOutput.results

	if arg and arg[0]:match("DataScanner.lua$") then
		for _, msg in ipairs(output.messages) do
			print(msg)
		end
	end

	return output
end

local function showHelp()
	local output = {
		success = true,
		messages = {}
	}
	local helpText = "Usage: lua DataScanner.lua [options] <task_name> {parameter_list}\n\nOptions:\n  -h    Show this help message\n  -l    List all available tasks\n\nParameter Format:\n  Use Lua table syntax with single quotes for strings, e.g.: {'string'} or {123}\n\nExamples:\n  lua DataScanner.lua graph_event {'setMarkState'}\n  lua DataScanner.lua -l\n\nNotes:\n  1. When running directly, Data directory must be in current or parent directory\n  2. When using require, ensure Data directory is in lua search path\n"

	table.insert(output.messages, helpText)

	if arg and arg[0]:match("DataScanner.lua$") then
		io.stdout:write(helpText .. "\n")
	end

	return output
end

local function showTaskList()
	local output = {
		success = true,
		messages = {}
	}

	table.insert(output.messages, "\nAvailable Tasks:")

	for name, task in pairs(TaskConfig) do
		table.insert(output.messages, string.format("\n%s:", name))
		table.insert(output.messages, string.format("  Description: %s", task.description))

		if task.usage then
			table.insert(output.messages, string.format("  Usage: lua DataScanner.lua %s", task.usage))
		end
	end

	if arg and arg[0]:match("DataScanner.lua$") then
		for _, msg in ipairs(output.messages) do
			print(msg)
		end
	end

	return output
end

local function main(...)
	local args = {
		...
	}

	if #args == 0 then
		return showHelp()
	end

	if args[1] == "-h" then
		return showHelp()
	elseif args[1] == "-l" then
		return showTaskList()
	end

	local taskName = args[1]
	local params = parseArgs(table.concat(args, " ", 2))

	return DataScanner.execute(taskName, params)
end

if arg and arg[0]:match("DataScanner.lua$") then
	if package.config:sub(1, 1) == "\\" then
		os.execute("chcp 65001 > nul")
	end

	main(unpack(arg))
else
	return DataScanner
end
