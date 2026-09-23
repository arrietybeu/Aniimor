-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Profiler\\GCRootProfiler.lua

local GCRootProfiler = {}
local rawNext = rawget(_G, "raw_next") or next
local NEW_LINE = string.char(10)
local DEFAULT_MAX_DEPTH = 64
local DEFAULT_MAX_NODES = 1000000
local DEFAULT_MAX_PATHS = 1
local DEFAULT_MAX_SECONDS = 60
local REFERENCE_TYPES = {
	table = true,
	userdata = true,
	["function"] = true,
	thread = true
}
local DEFAULT_SKIP_FIELDS = {}

local function singleLine(value)
	return tostring(value):gsub("[\r\n\t]", " ")
end

local function safeToString(value)
	local ok, result = pcall(tostring, value)

	if ok then
		return singleLine(result)
	end

	return "<" .. type(value) .. ">"
end

local function safeGetMetatable(value)
	local getter = debug.getmetatable or getmetatable
	local ok, mt = pcall(getter, value)

	if ok and type(mt) == "table" then
		return mt
	end

	return nil
end

local function getClassName(value)
	if type(value) ~= "table" then
		return nil
	end

	local className = rawget(value, "__cname") or rawget(value, "class") or rawget(value, "_className") or rawget(value, "typeName") or rawget(value, "className")

	if type(className) == "string" then
		return className
	end

	local mt = safeGetMetatable(value)
	local index = mt and rawget(mt, "__index")

	if type(index) == "table" then
		className = rawget(index, "__cname") or rawget(index, "class") or rawget(index, "_className") or rawget(index, "typeName") or rawget(index, "className")

		if type(className) == "string" then
			return className
		end
	end

	return nil
end

local function getFunctionSource(func)
	local ok, info = pcall(debug.getinfo, func, "S")

	if not ok or not info then
		return nil, nil
	end

	return info.short_src or info.source, info.linedefined
end

local function describeObject(value)
	local valueType = type(value)
	local description = {
		type = valueType,
		address = safeToString(value),
		className = getClassName(value)
	}

	if valueType == "function" then
		description.source, description.line = getFunctionSource(value)
	end

	return description
end

local function getRawField(value, key)
	if type(value) ~= "table" then
		return nil
	end

	return rawget(value, key)
end

local function describeTarget(target)
	local result = describeObject(target)

	result.id = getRawField(target, "id")
	result.destroyed = getRawField(target, "destroyed")
	result.sceneId = getRawField(target, "sceneId")

	return result
end

local function formatKey(key)
	local keyType = type(key)

	if keyType == "string" then
		return "[" .. string.format("%q", key) .. "]"
	elseif keyType == "number" or keyType == "boolean" then
		return "[" .. tostring(key) .. "]"
	end

	return "[key:" .. keyType .. ":" .. safeToString(key) .. "]"
end

local function formatRegistrySlot(key)
	local keyType = type(key)

	if keyType == "string" then
		return string.format("%q", key)
	elseif keyType == "number" or keyType == "boolean" then
		return tostring(key)
	end

	return "key:" .. keyType .. ":" .. safeToString(key)
end

local function formatFunctionEdge(upvalueName)
	return "[upvalue:" .. tostring(upvalueName) .. "]"
end

local function formatThreadFrame(info, level)
	local source = info and (info.short_src or info.source)
	local line = info and info.currentline

	if source then
		return "[stack:" .. singleLine(source) .. ":" .. tostring(line or -1) .. ":level=" .. tostring(level) .. "]"
	end

	return "[stack:level=" .. tostring(level) .. "]"
end

local function positiveInteger(value, defaultValue)
	value = tonumber(value)

	if not value or value < 1 then
		return defaultValue
	end

	return math.floor(value)
end

local function normalizeOptions(options)
	options = options or {}

	return {
		collectGarbage = options.collectGarbage ~= false,
		scanGlobals = options.scanGlobals ~= false,
		scanRegistry = options.scanRegistry ~= false,
		scanThreadStacks = options.scanThreadStacks ~= false,
		includeMetatables = options.includeMetatables ~= false,
		includeEnvironments = options.includeEnvironments ~= false,
		maxDepth = positiveInteger(options.maxDepth, DEFAULT_MAX_DEPTH),
		maxNodes = positiveInteger(options.maxNodes, DEFAULT_MAX_NODES),
		maxPaths = positiveInteger(options.maxPaths, DEFAULT_MAX_PATHS),
		maxSeconds = tonumber(options.maxSeconds) or DEFAULT_MAX_SECONDS,
		skipFields = options.skipFields or DEFAULT_SKIP_FIELDS
	}
end

local function isTraversable(value, targetType)
	local valueType = type(value)

	if REFERENCE_TYPES[valueType] then
		return true
	end

	return valueType == "string" and targetType == "string"
end

local function buildStep(edge, value)
	local description = describeObject(value)

	description.edge = edge

	return description
end

local function reverseArray(values)
	local left = 1
	local right = #values

	while left < right do
		values[left], values[right] = values[right], values[left]
		left = left + 1
		right = right - 1
	end
end

function GCRootProfiler.Find(target, options)
	assert(target ~= nil, "GCRootProfiler.Find target can not be nil")

	local targetType = type(target)

	assert(targetType ~= "number" and targetType ~= "boolean", "GCRootProfiler.Find target must be a collectable Lua object")

	local config = normalizeOptions(options)

	if config.collectGarbage then
		collectgarbage("collect")
		collectgarbage("collect")
	end

	local started = os.clock()
	local queueObjects = {}
	local queueParents = {}
	local queueEdges = {}
	local queueDepths = {}
	local visited = {}
	local paths = {}
	local pathSet = {}
	local queueHead = 1
	local queueTail = 0
	local expandedNodes = 0
	local depthLimited = false
	local nodeLimited = false
	local stopReason

	local function createPath(parentIndex, targetEdge)
		local nodeIndices = {}
		local current = parentIndex

		while current do
			nodeIndices[#nodeIndices + 1] = current
			current = queueParents[current]
		end

		reverseArray(nodeIndices)

		local chain = {}
		local pathParts = {}

		for _, nodeIndex in ipairs(nodeIndices) do
			local edge = queueEdges[nodeIndex]

			chain[#chain + 1] = buildStep(edge, queueObjects[nodeIndex])
			pathParts[#pathParts + 1] = edge
		end

		chain[#chain + 1] = buildStep(targetEdge, target)
		pathParts[#pathParts + 1] = targetEdge

		local path = table.concat(pathParts)

		if not pathSet[path] then
			pathSet[path] = true
			paths[#paths + 1] = {
				path = path,
				chain = chain
			}
		end
	end

	local function enqueue(value, parentIndex, edge, depth)
		if value == target then
			createPath(parentIndex, edge)

			return #paths >= config.maxPaths
		end

		if not isTraversable(value, targetType) or visited[value] then
			return false
		end

		if queueTail >= config.maxNodes then
			nodeLimited = true

			return false
		end

		queueTail = queueTail + 1
		queueObjects[queueTail] = value
		queueParents[queueTail] = parentIndex
		queueEdges[queueTail] = edge
		queueDepths[queueTail] = depth
		visited[value] = true

		return false
	end

	local function enqueueRoot(value, rootName)
		if value == target then
			createPath(nil, rootName)

			return #paths >= config.maxPaths
		end

		return enqueue(value, nil, rootName, 0)
	end

	if config.scanGlobals and enqueueRoot(_G, "_G") then
		stopReason = "maxPaths"
	end

	if not stopReason and config.scanRegistry then
		local registry = debug.getregistry()
		local key, value = rawNext(registry, nil)

		while key ~= nil do
			local slot = formatRegistrySlot(key)
			local valueRoot = "registry[" .. slot .. "]"

			if key == "_LOADED" and package and value == package.loaded then
				valueRoot = "package.loaded"
			elseif key == "_PRELOAD" and package and value == package.preload then
				valueRoot = "package.preload"
			end

			if enqueueRoot(value, valueRoot) then
				stopReason = "maxPaths"

				break
			end

			if enqueueRoot(key, "registry[" .. slot .. "]<key>") then
				stopReason = "maxPaths"

				break
			end

			key, value = rawNext(registry, key)
		end
	end

	while not stopReason and queueHead <= queueTail do
		if config.maxSeconds > 0 and expandedNodes % 1024 == 0 and os.clock() - started >= config.maxSeconds then
			stopReason = "maxSeconds"

			break
		end

		local nodeIndex = queueHead

		queueHead = queueHead + 1

		local object = queueObjects[nodeIndex]
		local objectType = type(object)
		local depth = queueDepths[nodeIndex]

		expandedNodes = expandedNodes + 1

		if depth >= config.maxDepth then
			depthLimited = true
		elseif objectType == "table" then
			local mt = safeGetMetatable(object)
			local mode = mt and rawget(mt, "__mode")
			local weakKeys = type(mode) == "string" and string.find(mode, "k", 1, true) ~= nil
			local weakValues = type(mode) == "string" and string.find(mode, "v", 1, true) ~= nil
			local key, value = rawNext(object, nil)

			while key ~= nil do
				local keyPath = formatKey(key)

				if not weakKeys and enqueue(key, nodeIndex, keyPath .. "<key>", depth + 1) then
					stopReason = "maxPaths"

					break
				end

				local skipValue = type(key) == "string" and config.skipFields[key]

				if not stopReason and not weakValues and not skipValue and enqueue(value, nodeIndex, keyPath, depth + 1) then
					stopReason = "maxPaths"

					break
				end

				key, value = rawNext(object, key)
			end

			if not stopReason and config.includeMetatables and mt and enqueue(mt, nodeIndex, "[metatable]", depth + 1) then
				stopReason = "maxPaths"
			end
		elseif objectType == "function" then
			local ok, info = pcall(debug.getinfo, object, "u")
			local upvalueCount = ok and info and info.nups or 0

			for i = 1, upvalueCount do
				local upvalueName, upvalue = debug.getupvalue(object, i)

				if enqueue(upvalue, nodeIndex, formatFunctionEdge(upvalueName or i), depth + 1) then
					stopReason = "maxPaths"

					break
				end
			end

			if not stopReason and config.includeEnvironments and debug.getfenv then
				local envOk, env = pcall(debug.getfenv, object)

				if envOk and env and env ~= _G and enqueue(env, nodeIndex, "[function:environment]", depth + 1) then
					stopReason = "maxPaths"
				end
			end
		elseif objectType == "thread" then
			local statusOk, threadStatus = pcall(coroutine.status, object)

			if config.scanThreadStacks and statusOk and threadStatus ~= "running" then
				local level = 0

				while not stopReason do
					local infoOk, info = pcall(debug.getinfo, object, level, "Sfl")

					if not infoOk or not info then
						break
					end

					local framePath = formatThreadFrame(info, level)

					if info.func and enqueue(info.func, nodeIndex, framePath .. "[function]", depth + 1) then
						stopReason = "maxPaths"

						break
					end

					local localIndex = 1

					while not stopReason do
						local localOk, localName, localValue = pcall(debug.getlocal, object, level, localIndex)

						if not localOk or localName == nil then
							break
						end

						if enqueue(localValue, nodeIndex, framePath .. "[local:" .. tostring(localName) .. "#" .. tostring(localIndex) .. "]", depth + 1) then
							stopReason = "maxPaths"

							break
						end

						localIndex = localIndex + 1
					end

					local varargIndex = -1

					while not stopReason do
						local varargOk, varargName, varargValue = pcall(debug.getlocal, object, level, varargIndex)

						if not varargOk or varargName == nil then
							break
						end

						if enqueue(varargValue, nodeIndex, framePath .. "[vararg:" .. tostring(-varargIndex) .. "]", depth + 1) then
							stopReason = "maxPaths"

							break
						end

						varargIndex = varargIndex - 1
					end

					level = level + 1
				end
			end

			if not stopReason and config.includeEnvironments and debug.getfenv then
				local envOk, env = pcall(debug.getfenv, object)

				if envOk and env and env ~= _G and enqueue(env, nodeIndex, "[thread:environment]", depth + 1) then
					stopReason = "maxPaths"
				end
			end

			if not stopReason and config.includeMetatables then
				local mt = safeGetMetatable(object)

				if mt and enqueue(mt, nodeIndex, "[thread:metatable]", depth + 1) then
					stopReason = "maxPaths"
				end
			end
		elseif objectType == "userdata" then
			if config.includeEnvironments and debug.getfenv then
				local envOk, env = pcall(debug.getfenv, object)

				if envOk and env and env ~= _G and enqueue(env, nodeIndex, "[" .. objectType .. ":environment]", depth + 1) then
					stopReason = "maxPaths"
				end
			end

			if not stopReason and config.includeMetatables then
				local mt = safeGetMetatable(object)

				if mt and enqueue(mt, nodeIndex, "[" .. objectType .. ":metatable]", depth + 1) then
					stopReason = "maxPaths"
				end
			end
		end
	end

	stopReason = stopReason or #paths >= config.maxPaths and "maxPaths" or nodeLimited and "maxNodes" or depthLimited and "maxDepth" or "exhausted"

	return {
		found = #paths > 0,
		paths = paths,
		target = describeTarget(target),
		gcPasses = config.collectGarbage and 2 or 0,
		expandedNodes = expandedNodes,
		queuedNodes = queueTail,
		elapsedSeconds = os.clock() - started,
		stopReason = stopReason,
		limits = {
			maxDepth = config.maxDepth,
			maxNodes = config.maxNodes,
			maxPaths = config.maxPaths,
			maxSeconds = config.maxSeconds
		},
		traversal = {
			threadStacks = config.scanThreadStacks,
			metatables = config.includeMetatables,
			environments = config.includeEnvironments
		}
	}
end

local function sanitizeFilePart(value)
	value = tostring(value or "object")
	value = value:gsub("[^%w_%-]", "_")

	if value == "" then
		return "object"
	end

	return value
end

local function getDefaultOutputDirectory()
	if rawget(_G, "UNITY_EDITOR") then
		return "./Logs/"
	end

	local application = rawget(_G, "Application")

	if application then
		local ok, path = pcall(function()
			return application.persistentDataPath
		end)

		if ok and type(path) == "string" and path ~= "" then
			return path .. "/"
		end
	end

	return "./"
end

local function resolveOutputPath(targetDescription, outputFile)
	if not outputFile or outputFile == "" then
		local objectName = targetDescription.className or targetDescription.type

		outputFile = "GC_ROOT_PROFILE_" .. sanitizeFilePart(objectName) .. "_" .. os.date("%Y%m%d-%H%M%S") .. ".txt"
	elseif not string.find(string.lower(outputFile), "%.txt$") then
		outputFile = outputFile .. ".txt"
	end

	local hasDirectory = string.find(outputFile, "/", 1, true) or string.find(outputFile, "\\", 1, true) or string.match(outputFile, "^%a:")

	if hasDirectory then
		return outputFile
	end

	return getDefaultOutputDirectory() .. outputFile
end

local function writeObjectDescription(file, prefix, description)
	file:write(prefix, "type=", tostring(description.type), " address=", tostring(description.address))

	if description.className then
		file:write(" class=", tostring(description.className))
	end

	if description.source then
		file:write(" source=", tostring(description.source), ":", tostring(description.line))
	end

	file:write(NEW_LINE)
end

function GCRootProfiler.Dump(target, outputFile, options)
	local result = GCRootProfiler.Find(target, options)
	local outputPath = resolveOutputPath(result.target, outputFile)
	local file, err = io.open(outputPath, "w")

	if not file then
		return nil, err
	end

	file:write("Lua GC root profile", NEW_LINE)
	file:write("time=", os.date("%Y-%m-%d %H:%M:%S"), NEW_LINE)
	file:write("gc_passes=", tostring(result.gcPasses), NEW_LINE)
	writeObjectDescription(file, "target ", result.target)

	if result.target.id ~= nil then
		file:write("target_id=", safeToString(result.target.id), NEW_LINE)
	end

	if result.target.destroyed ~= nil then
		file:write("target_destroyed=", safeToString(result.target.destroyed), NEW_LINE)
	end

	if result.target.sceneId ~= nil then
		file:write("target_sceneId=", safeToString(result.target.sceneId), NEW_LINE)
	end

	file:write("found=", tostring(result.found), NEW_LINE)
	file:write("paths_found=", tostring(#result.paths), NEW_LINE)
	file:write("expanded_nodes=", tostring(result.expandedNodes), NEW_LINE)
	file:write("queued_nodes=", tostring(result.queuedNodes), NEW_LINE)
	file:write("elapsed_seconds=", string.format("%.6f", result.elapsedSeconds), NEW_LINE)
	file:write("stop_reason=", tostring(result.stopReason), NEW_LINE)
	file:write("limits maxPaths=", tostring(result.limits.maxPaths), " maxDepth=", tostring(result.limits.maxDepth), " maxNodes=", tostring(result.limits.maxNodes), " maxSeconds=", tostring(result.limits.maxSeconds), NEW_LINE)
	file:write("traversal threadStacks=", tostring(result.traversal.threadStacks), " metatables=", tostring(result.traversal.metatables), " environments=", tostring(result.traversal.environments), NEW_LINE)

	for pathIndex, pathInfo in ipairs(result.paths) do
		file:write(NEW_LINE, "[ROOT PATH ", tostring(pathIndex), "]", NEW_LINE)
		file:write("path=", pathInfo.path, NEW_LINE)
		file:write("step_count=", tostring(#pathInfo.chain), NEW_LINE)

		for stepIndex, step in ipairs(pathInfo.chain) do
			local stepType = stepIndex == 1 and "ROOT" or "EDGE"

			file:write(string.format("%02d %s %s", stepIndex, stepType, step.edge), NEW_LINE)
			writeObjectDescription(file, "   object ", step)
		end
	end

	if not result.found then
		file:write(NEW_LINE, "No strong path was found within the configured limits.", NEW_LINE)
	end

	file:write(NEW_LINE, "Notes: weak keys/values and the current profiler call stack are excluded; ")

	if result.traversal.threadStacks then
		file:write("suspended thread stacks are traversed; ")
	else
		file:write("thread stack traversal is disabled; ")
	end

	file:write("native-only fields are not traversed.", NEW_LINE)
	file:close()
	print(string.format("GC root profile written: %s, found=%s, paths=%d", outputPath, tostring(result.found), #result.paths))

	return outputPath, result
end

if jit and jit.off then
	jit.off(GCRootProfiler.Find, true)
	jit.off(GCRootProfiler.Dump, true)
end

return GCRootProfiler
