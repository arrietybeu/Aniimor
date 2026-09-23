-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Profiler\\MemoryReferenceStringInfo.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local MemoryReferenceStringInfo = {}
local rawNext = rawget(_G, "raw_next") or next
local luaKeywords = {
	["until"] = true,
	["true"] = true,
	["then"] = true,
	["return"] = true,
	["repeat"] = true,
	["or"] = true,
	["not"] = true,
	["nil"] = true,
	["local"] = true,
	["in"] = true,
	["if"] = true,
	["function"] = true,
	["for"] = true,
	["false"] = true,
	["end"] = true,
	["elseif"] = true,
	["else"] = true,
	["do"] = true,
	["break"] = true,
	["and"] = true,
	["while"] = true
}
local primitiveValueString

local function appendLocatorStep(locator, step)
	if locator == nil then
		return nil
	end

	return locator .. "\n" .. step
end

local function tableLocatorAccessor(key)
	if type(key) == "string" and string.match(key, "^[_%a][_%w]*$") and not luaKeywords[key] then
		return "." .. key
	end

	local keyString = primitiveValueString(key)

	if keyString ~= nil then
		return "[" .. keyString .. "]"
	end

	return nil
end

local function appendTableLocatorAccess(locator, key)
	if locator == nil then
		return nil
	end

	local accessor = tableLocatorAccessor(key)

	if accessor == nil then
		return nil
	end

	local lastLine = string.match(locator, "[^\n]*$") or locator

	if #lastLine + #accessor <= 240 then
		return locator .. accessor
	end

	return appendLocatorStep(locator, "object = object" .. accessor)
end

local function isExpandable(object)
	local objectType = type(object)

	return objectType == "table" or objectType == "function" or objectType == "thread" or objectType == "userdata"
end

local function getRealMetatable(object)
	if debug.getmetatable then
		local ok, mt = pcall(debug.getmetatable, object)

		if ok then
			return mt
		end
	end

	return getmetatable(object)
end

local function getWeakMode(mt)
	if type(mt) ~= "table" then
		return false, false
	end

	local mode = rawget(mt, "__mode")

	if type(mode) ~= "string" then
		return false, false
	end

	return string.find(mode, "k", 1, true) ~= nil, string.find(mode, "v", 1, true) ~= nil
end

local function getTableClassName(object)
	local fieldNames = {
		"__cname",
		"class",
		"_className",
		"className"
	}

	for _, fieldName in ipairs(fieldNames) do
		local value = rawget(object, fieldName)

		if type(value) == "string" then
			return value
		end
	end

	return nil
end

local function decorateTablePath(path, object)
	local className = getTableClassName(object)

	if className then
		path = path .. "[class:" .. className .. "]"
	end

	if object == _G then
		path = path .. "[_G]"
	end

	return path
end

function primitiveValueString(value)
	local valueType = type(value)

	if valueType == "string" then
		return string.format("%q", value)
	elseif valueType == "number" or valueType == "boolean" then
		return tostring(value)
	elseif valueType == "nil" then
		return "nil"
	end

	return nil
end

local function objectDescription(object)
	local objectType = type(object)

	if objectType == "string" then
		return string.format("%q", object)
	elseif objectType == "number" or objectType == "boolean" then
		return tostring(object)
	elseif objectType ~= "table" then
		return "<" .. objectType .. ">"
	end

	local parts = {
		"<table"
	}
	local className = getTableClassName(object)

	if className then
		parts[#parts + 1] = " class=" .. className
	end

	local entityId = rawget(object, "id")
	local entityIdString = primitiveValueString(entityId)

	if entityIdString then
		parts[#parts + 1] = " id=" .. entityIdString
	end

	parts[#parts + 1] = ">"

	return table.concat(parts)
end

local function tableEdgePaths(parentPath, key, entryIndex)
	local keyString = primitiveValueString(key)

	if keyString then
		local keyType = type(key)

		return parentPath .. ".[table:key " .. keyType .. ":" .. keyString .. "]", parentPath .. "[" .. keyType .. ":" .. keyString .. "]"
	end

	local keyType = type(key)

	return parentPath .. ".[table:key#" .. entryIndex .. ":" .. keyType .. "]", parentPath .. ".[table:value#" .. entryIndex .. " keyType=" .. keyType .. "]"
end

local function normalizeMaxRecords(maxRecords)
	maxRecords = tonumber(maxRecords) or -1

	if maxRecords ~= maxRecords then
		return -1
	end

	return math.floor(maxRecords)
end

local function createContext(maxRecords, targets, sourceInfo)
	local context = {
		maxRecords = normalizeMaxRecords(maxRecords),
		targetByObject = {},
		targetInfos = {},
		visited = {},
		stack = {},
		shortSrc = sourceInfo and sourceInfo.short_src or "None",
		currentLine = sourceInfo and sourceInfo.currentline or -1
	}

	for index, target in ipairs(targets or EMPTY_TABLE) do
		local object = target.object

		assert(object ~= nil, "MemoryReferenceStringInfo target object can not be nil")

		local info = context.targetByObject[object]

		if not info then
			local objectName = target.objectName

			if type(objectName) ~= "string" or objectName == "" then
				objectName = objectDescription(object)
			end

			info = {
				totalEdges = 0,
				object = object,
				objectName = objectName,
				description = objectDescription(object),
				edges = {}
			}
			context.targetByObject[object] = info

			if isExpandable(object) then
				context.visited[object] = true
			end
		end

		context.targetInfos[index] = info
	end

	return context
end

local function recordEdge(context, object, path, locator)
	local info = context.targetByObject[object]

	if not info then
		return
	end

	info.totalEdges = info.totalEdges + 1

	if context.maxRecords <= 0 or #info.edges < context.maxRecords then
		info.edges[#info.edges + 1] = {
			path = path,
			locator = locator
		}
	end
end

local function enqueue(context, object, path, locator)
	if not isExpandable(object) or context.visited[object] then
		return
	end

	context.visited[object] = true
	context.stack[#context.stack + 1] = {
		object = object,
		path = path,
		locator = locator
	}
end

local function recordAndEnqueue(context, object, path, locator)
	recordEdge(context, object, path, locator)
	enqueue(context, object, path, locator)
end

local function processTable(context, object, path, locator)
	path = decorateTablePath(path, object)

	if object == _G then
		locator = "local object = _G"
	end

	local mt = getRealMetatable(object)
	local weakKeys, weakValues = getWeakMode(mt)
	local entryIndex = 0

	for key, value in rawNext, object do
		entryIndex = entryIndex + 1

		local keyPath, valuePath = tableEdgePaths(path, key, entryIndex)

		if not weakKeys then
			recordAndEnqueue(context, key, keyPath, nil)
		end

		if not weakValues then
			local valueLocator = appendTableLocatorAccess(locator, key)

			recordAndEnqueue(context, value, valuePath, valueLocator)
		end
	end

	if mt ~= nil then
		recordAndEnqueue(context, mt, path .. ".[metatable]", appendLocatorStep(locator, "object = __entityLeakGetMetatable(object)"))
	end
end

local function safeGetEnvironment(object)
	local getfenv = debug.getfenv

	if not getfenv then
		return nil
	end

	local ok, environment = pcall(getfenv, object)

	if ok then
		return environment
	end

	return nil
end

local function processFunction(context, object, path, locator)
	local functionInfo = debug.getinfo(object, "Su")

	if functionInfo then
		path = path .. "[line:" .. tostring(functionInfo.linedefined) .. "@file:" .. tostring(functionInfo.short_src) .. "]"

		for index = 1, functionInfo.nups do
			local upvalueName, upvalue = debug.getupvalue(object, index)

			if type(upvalueName) ~= "string" or upvalueName == "" then
				upvalueName = tostring(index)
			end

			recordAndEnqueue(context, upvalue, path .. ".[upvalue:" .. upvalueName .. "]", appendLocatorStep(locator, "object = __entityLeakGetUpvalue(object, " .. string.format("%q", upvalueName) .. ")"))
		end
	end

	local environment = safeGetEnvironment(object)

	if environment ~= nil then
		recordAndEnqueue(context, environment, path .. ".[function:environment]", appendLocatorStep(locator, "object = __entityLeakGetEnvironment(object)"))
	end
end

local function processThread(context, object, path, locator)
	local environment = safeGetEnvironment(object)

	if environment ~= nil then
		recordAndEnqueue(context, environment, path .. ".[thread:environment]", appendLocatorStep(locator, "object = __entityLeakGetEnvironment(object)"))
	end

	local mt = getRealMetatable(object)

	if mt ~= nil then
		recordAndEnqueue(context, mt, path .. ".[thread:metatable]", appendLocatorStep(locator, "object = __entityLeakGetMetatable(object)"))
	end
end

local function processUserdata(context, object, path, locator)
	local environment = safeGetEnvironment(object)

	if environment ~= nil then
		recordAndEnqueue(context, environment, path .. ".[userdata:environment]", appendLocatorStep(locator, "object = __entityLeakGetEnvironment(object)"))
	end

	local mt = getRealMetatable(object)

	if mt ~= nil then
		recordAndEnqueue(context, mt, path .. ".[userdata:metatable]", appendLocatorStep(locator, "object = __entityLeakGetMetatable(object)"))
	end
end

local function collectReferenceEdges(context, roots)
	for _, root in ipairs(roots) do
		enqueue(context, root.object, root.name, root.locator)
	end

	while #context.stack > 0 do
		local stackIndex = #context.stack
		local item = context.stack[stackIndex]

		context.stack[stackIndex] = nil

		local objectType = type(item.object)

		if objectType == "table" then
			processTable(context, item.object, item.path, item.locator)
		elseif objectType == "function" then
			processFunction(context, item.object, item.path, item.locator)
		elseif objectType == "thread" then
			processThread(context, item.object, item.path, item.locator)
		elseif objectType == "userdata" then
			processUserdata(context, item.object, item.path, item.locator)
		end
	end
end

local function appendLine(lines, content)
	lines[#lines + 1] = content
end

local function appendTelnetLocator(lines, locator)
	appendLine(lines, "--------------------------------------------------------")
	appendLine(lines, "-- Telnet locator (execute all lines in order):")
	appendLine(lines, "-- BEGIN ENTITY_LEAK_TELNET_LOCATOR")
	appendLine(lines, "local function __entityLeakGetUpvalue(f, n) if type(f) ~= \"function\" then return end; for i = 1, 255 do local k, v = debug.getupvalue(f, i); if k == n then return v end; if not k then return end end end")
	appendLine(lines, "local function __entityLeakGetEnvironment(v) local ok, env = pcall(debug.getfenv, v); if ok then return env end end")
	appendLine(lines, "local function __entityLeakGetMetatable(v) local f = debug.getmetatable or getmetatable; local ok, mt = pcall(f, v); if ok then return mt end end")
	appendLine(lines, locator)
	appendLine(lines, "local entityLeakId = type(object) == \"table\" and object.id or nil")
	appendLine(lines, "local entityLeakDestroyed = type(object) == \"table\" and object.destroyed or nil")
	appendLine(lines, "print(string.format(\"ENTITY_LEAK_LOCATOR object=%s entityId=%s destroyed=%s\", tostring(object), tostring(entityLeakId), tostring(entityLeakDestroyed)))")
	appendLine(lines, "-- END ENTITY_LEAK_TELNET_LOCATOR")
end

local function buildReferenceString(context, info)
	local edges = {}

	for index, edge in ipairs(info.edges) do
		edges[index] = edge
	end

	table.sort(edges, function(first, second)
		return first.path < second.path
	end)

	local lines = {}

	appendLine(lines, "--------------------------------------------------------")
	appendLine(lines, "-- Collect external direct strong references at line:" .. tostring(context.currentLine) .. "@file:" .. tostring(context.shortSrc))
	appendLine(lines, "--------------------------------------------------------")
	appendLine(lines, "-- For Object: " .. info.description .. " (" .. info.objectName .. "), found " .. tostring(info.totalEdges) .. " external direct strong reference edge(s), showing " .. tostring(#edges) .. ".")
	appendLine(lines, "--------------------------------------------------------")

	local locator

	for _, edge in ipairs(edges) do
		appendLine(lines, edge.path)

		locator = locator or edge.locator
	end

	if locator ~= nil then
		appendTelnetLocator(lines, locator)
	end

	return table.concat(lines, "\n")
end

local function dumpFromRoots(maxRecords, targets, roots, sourceInfo)
	local context = createContext(maxRecords, targets, sourceInfo)

	collectReferenceEdges(context, roots)

	local results = {}
	local stats = {}

	for index, info in ipairs(context.targetInfos) do
		results[index] = buildReferenceString(context, info)
		stats[index] = {
			totalEdges = info.totalEdges,
			shownEdges = #info.edges
		}
	end

	return results, stats
end

local function dumpFromRoot(maxRecords, targets, rootName, rootObject, sourceInfo, rootLocator)
	assert(rootObject ~= nil, "MemoryReferenceStringInfo root object can not be nil")

	return dumpFromRoots(maxRecords, targets, {
		{
			name = rootName or "root",
			object = rootObject,
			locator = rootLocator
		}
	}, sourceInfo)
end

function MemoryReferenceStringInfo.DumpMemorySnapshotObjects(maxRecords, targets)
	local roots = {
		{
			name = "registry",
			object = debug.getregistry()
		},
		{
			name = "_G",
			locator = "local object = _G",
			object = _G
		}
	}
	local pgObject = rawget(_G, "pg")

	if type(pgObject) == "table" then
		roots[#roots + 1] = {
			name = "_G[string:\"pg\"]",
			locator = "local object = _G.pg",
			object = pgObject
		}

		local globalObject = rawget(pgObject, "global")

		if type(globalObject) == "table" then
			roots[#roots + 1] = {
				name = "_G[string:\"pg\"][string:\"global\"]",
				locator = "local object = _G.pg.global",
				object = globalObject
			}
		end
	end

	return dumpFromRoots(maxRecords, targets, roots, debug.getinfo(2, "Sl"))
end

function MemoryReferenceStringInfo.DumpMemorySnapshotObjectsFromRoot(maxRecords, targets, rootName, rootObject, rootLocator)
	return dumpFromRoot(maxRecords, targets, rootName, rootObject, debug.getinfo(2, "Sl"), rootLocator)
end

function MemoryReferenceStringInfo.DumpMemorySnapshotSingleObject(maxRecords, objectName, object)
	if object == nil then
		return nil, nil
	end

	local results, stats = MemoryReferenceStringInfo.DumpMemorySnapshotObjects(maxRecords, {
		{
			objectName = objectName,
			object = object
		}
	})

	return results[1], stats[1]
end

return MemoryReferenceStringInfo
