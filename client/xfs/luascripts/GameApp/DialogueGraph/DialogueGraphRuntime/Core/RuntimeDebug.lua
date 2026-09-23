-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Core\\RuntimeDebug.lua

local RuntimeDebug = {}
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local json = require("json")
local logger = LoggerManager.getLogger("DialogueGraphRuntimeDebug")
local captureMode = "Flow"
local MAX_SNAPSHOT_DEPTH = 4
local MAX_SNAPSHOT_ITEMS = 64
local MAX_STRING_LENGTH = 2048

local function truncateUtf8(value, maxCharacters)
	local byteIndex = 1
	local byteLength = #value
	local characterCount = 0
	local lastByte = 0

	while byteIndex <= byteLength and characterCount < maxCharacters do
		local firstByte = string.byte(value, byteIndex)
		local width = 1

		if firstByte >= 240 then
			width = 4
		elseif firstByte >= 224 then
			width = 3
		elseif firstByte >= 192 then
			width = 2
		end

		lastByte = math.min(byteLength, byteIndex + width - 1)
		byteIndex = byteIndex + width
		characterCount = characterCount + 1
	end

	if byteLength < byteIndex then
		return value, false
	end

	return string.sub(value, 1, lastByte), true
end

local function tryReadMember(value, member)
	local ok, result = xpcall(function()
		return value[member]
	end, debug.traceback)

	return ok and result or nil
end

local function normalizeInteropValue(value)
	local typeName, fullTypeName
	local isEnum = false
	local getType = tryReadMember(value, "GetType")

	if getType ~= nil then
		local ok, runtimeType = xpcall(getType, debug.traceback, value)

		if ok and runtimeType ~= nil then
			typeName = tryReadMember(runtimeType, "Name")
			fullTypeName = tryReadMember(runtimeType, "FullName")
			isEnum = tryReadMember(runtimeType, "IsEnum") == true
		end
	end

	if isEnum then
		return tostring(value)
	end

	if typeName == "Vector2" then
		return {
			type = typeName,
			x = tryReadMember(value, "x"),
			y = tryReadMember(value, "y")
		}
	end

	if typeName == "Vector3" then
		return {
			type = typeName,
			x = tryReadMember(value, "x"),
			y = tryReadMember(value, "y"),
			z = tryReadMember(value, "z")
		}
	end

	if typeName == "Vector4" or typeName == "Quaternion" then
		return {
			type = typeName,
			x = tryReadMember(value, "x"),
			y = tryReadMember(value, "y"),
			z = tryReadMember(value, "z"),
			w = tryReadMember(value, "w")
		}
	end

	if typeName == "Color" then
		return {
			type = typeName,
			x = tryReadMember(value, "r"),
			y = tryReadMember(value, "g"),
			z = tryReadMember(value, "b"),
			w = tryReadMember(value, "a")
		}
	end

	local objectName = tryReadMember(value, "name")

	if objectName ~= nil and fullTypeName ~= nil and string.sub(fullTypeName, 1, 12) == "UnityEngine." then
		return {
			unsupported = true,
			type = fullTypeName,
			name = objectName
		}
	end

	return {
		truncated = false,
		unsupported = true,
		type = fullTypeName or typeName or type(value)
	}
end

local function callReport(graphItem, eventType, nodeId, portId, detail)
	graphItem:ReportLuaRuntimeDebugEvent(eventType, nodeId, portId, detail)
end

local function normalizeValue(value, depth, visited)
	local valueType = type(value)

	if value == nil or valueType == "boolean" or valueType == "number" then
		return value
	end

	if valueType == "string" then
		local normalized, truncated = truncateUtf8(value, MAX_STRING_LENGTH)

		if not truncated then
			return value
		end

		return {
			type = "string",
			truncated = true,
			value = normalized
		}
	end

	if valueType == "function" then
		return {
			type = "function",
			unsupported = true
		}
	end

	if valueType == "userdata" or valueType == "cdata" then
		return normalizeInteropValue(value)
	end

	if valueType ~= "table" then
		return {
			unsupported = true,
			type = valueType,
			value = tostring(value)
		}
	end

	if depth >= MAX_SNAPSHOT_DEPTH then
		return {
			type = "table",
			truncated = true
		}
	end

	if visited[value] then
		return {
			cycle = true,
			type = "table"
		}
	end

	visited[value] = true

	local result = {}
	local arrayLength = #value
	local isArray = arrayLength > 0

	if isArray then
		local arrayCount = 0

		for key in pairs(value) do
			if type(key) ~= "number" or key < 1 or arrayLength < key or key % 1 ~= 0 then
				isArray = false

				break
			end

			arrayCount = arrayCount + 1
		end

		isArray = isArray and arrayCount == arrayLength
	end

	if isArray then
		for index = 1, math.min(arrayLength, MAX_SNAPSHOT_ITEMS) do
			result[index] = normalizeValue(value[index], depth + 1, visited)
		end

		if arrayLength > MAX_SNAPSHOT_ITEMS then
			result[MAX_SNAPSHOT_ITEMS + 1] = {
				truncated = true
			}
		end

		visited[value] = nil

		return result
	end

	local count = 0

	for key, item in pairs(value) do
		count = count + 1

		if count > MAX_SNAPSHOT_ITEMS then
			result.__truncated = true

			break
		end

		result[tostring(key)] = normalizeValue(item, depth + 1, visited)
	end

	visited[value] = nil

	return result
end

local function snapshot(value)
	return normalizeValue(value, 0, {})
end

local function encode(payload)
	if json == nil or json.encode == nil then
		return nil, "json.encode is unavailable"
	end

	local ok, encoded = xpcall(json.encode, debug.traceback, payload)
	local var_8_0 = ok and encoded or nil

	if ok then
		-- block empty
	end

	return var_8_0, encoded
end

local function report(runtime, eventType, nodeId, portId, payload)
	if not UNITY_EDITOR or captureMode == "Off" or runtime == nil or runtime.debugPreviewDisabled then
		return 0
	end

	local graphItem = runtime.graphItem

	if graphItem == nil then
		return 0
	end

	runtime.debugSequence = (runtime.debugSequence or 0) + 1
	payload = payload or {}
	payload.eventType = eventType
	payload.nodeId = nodeId or -1
	payload.passToken = payload.passToken or runtime.passToken or 0

	if portId ~= nil and payload.outputPortId == nil and eventType == "FlowOut" then
		payload.outputPortId = portId
	end

	local encoded, encodeError = encode(payload)

	if encoded == nil then
		runtime.debugPreviewDisabled = true

		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("encode dialogue graph runtime debug event failed, event=%s error=%s", tostring(eventType), tostring(encodeError))
		end

		return 0
	end

	local ok, err = xpcall(callReport, debug.traceback, graphItem, eventType, nodeId or -1, portId, encoded)

	if ok then
		return runtime.debugSequence
	end

	runtime.debugPreviewDisabled = true

	if LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("report dialogue graph runtime debug event failed, event=%s error=%s", tostring(eventType), tostring(err))
	end

	return 0
end

local function contextPayload(ctx, detail)
	return {
		nodeKind = ctx:nodeKind(),
		inputPortId = ctx:inputPort(),
		activationId = ctx:activationId(),
		parentActivationId = ctx:parentActivationId(),
		triggerSequence = ctx:triggerSequence(),
		passToken = ctx:passToken(),
		detail = detail
	}
end

function RuntimeDebug.setCaptureMode(mode)
	captureMode = mode or "Flow"
end

function RuntimeDebug.getCaptureMode()
	return captureMode
end

function RuntimeDebug.isSemanticCaptureEnabled()
	return captureMode == "Semantic" or captureMode == "Comparison"
end

function RuntimeDebug.graphStart(runtime)
	local graphName = runtime ~= nil and runtime.data ~= nil and runtime.data.graphName or nil

	report(runtime, "GraphStart", -1, nil, {
		comparePolicy = "OrderedStrict",
		graphName = graphName,
		detail = {
			captureMode = captureMode
		}
	})
end

function RuntimeDebug.nodeEnter(runtime, ctx)
	local payload = contextPayload(ctx)

	payload.comparePolicy = "OrderedStrict"

	report(runtime, "NodeEnter", ctx:nodeId(), nil, payload)
end

function RuntimeDebug.flowOut(runtime, ctx, portId)
	local payload = contextPayload(ctx)

	payload.outputPortId = portId
	payload.comparePolicy = "OrderedStrict"

	return report(runtime, "FlowOut", ctx:nodeId(), portId, payload)
end

function RuntimeDebug.nodeExit(runtime, ctx, exitReason, resultCode)
	local payload = contextPayload(ctx, {
		exitReason = exitReason or "Success",
		resultCode = tostring(resultCode or 0)
	})

	payload.comparePolicy = "OrderedStrict"

	report(runtime, "NodeExit", ctx:nodeId(), nil, payload)
end

function RuntimeDebug.nodeFailure(runtime, ctx, message)
	local payload = contextPayload(ctx, {
		message = tostring(message or "NodeFailure")
	})

	payload.detailText = tostring(message or "NodeFailure")
	payload.comparePolicy = "OrderedStrict"

	report(runtime, "NodeFailure", ctx:nodeId(), nil, payload)
end

function RuntimeDebug.runtimeDiagnostic(runtime, eventType, ctx, detail, comparePolicy)
	local payload
	local nodeId = -1

	if ctx ~= nil then
		payload = contextPayload(ctx, snapshot(detail))
		nodeId = ctx:nodeId()
	else
		payload = {
			detail = snapshot(detail),
			passToken = runtime and runtime.passToken or 0
		}
	end

	payload.comparePolicy = comparePolicy or "DiagnosticOnly"
	payload.detailText = type(detail) == "string" and detail or nil

	report(runtime, eventType, nodeId, nil, payload)
end

function RuntimeDebug.flowIgnored(runtime, ctx, portId, reason)
	local payload = contextPayload(ctx, {
		reason = reason or "invalid",
		portId = portId
	})

	payload.outputPortId = portId
	payload.comparePolicy = "DiagnosticOnly"

	report(runtime, "FlowIgnored", ctx:nodeId(), portId, payload)
end

function RuntimeDebug.graphPause(runtime)
	report(runtime, "GraphPause", -1, nil, {
		comparePolicy = "OrderedStrict"
	})
end

function RuntimeDebug.graphResume(runtime)
	report(runtime, "GraphResume", -1, nil, {
		comparePolicy = "OrderedStrict"
	})
end

function RuntimeDebug.graphFinish(runtime, code)
	report(runtime, "GraphFinish", -1, nil, {
		comparePolicy = "OrderedStrict",
		detailText = tostring(code or 0),
		detail = {
			resultCode = tostring(code or 0)
		}
	})
end

function RuntimeDebug.graphDispose(runtime)
	report(runtime, "GraphDispose", -1, nil, {
		comparePolicy = "OrderedStrict",
		detail = {
			reason = "Dispose"
		}
	})
end

return RuntimeDebug
