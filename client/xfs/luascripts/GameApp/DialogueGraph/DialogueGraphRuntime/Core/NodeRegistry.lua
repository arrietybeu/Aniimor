-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Core\\NodeRegistry.lua

local NodeRegistry = {}
local Performance = require("GameApp.DialogueGraph.DialogueGraphRuntime.Core.Performance")
local DialogueGraphNodeConst = require("Const.DialogueGraphNodeConst")
local SafeCallbackWithStatusAndReturn = require("Core.Framework.SafeCallbackWithStatusAndReturn")
local NODE_MODULE_PREFIX = "GameApp.DialogueGraph.DialogueGraphRuntime.Node."
local MODULE_PATH_OVERRIDES = {}

local function validateKind(kind)
	if type(kind) ~= "string" or kind == "" then
		error("invalid dialogue graph node kind: " .. tostring(kind))
	end

	if not string.match(kind, "^[%a_][%w_]*$") then
		error("invalid dialogue graph node kind: " .. tostring(kind))
	end
end

function NodeRegistry.getKindName(kind)
	if type(kind) == "number" then
		local kindName = DialogueGraphNodeConst[kind]

		if kindName == nil then
			error("invalid dialogue graph node kind id: " .. tostring(kind))
		end

		return kindName
	end

	validateKind(kind)

	return kind
end

function NodeRegistry.getKindValue(kind)
	if type(kind) == "number" then
		return kind
	end

	validateKind(kind)

	local kindValue = DialogueGraphNodeConst[kind]

	if kindValue == nil then
		error("invalid dialogue graph node kind: " .. tostring(kind))
	end

	return kindValue
end

function NodeRegistry.getModulePath(kind)
	local kindName = NodeRegistry.getKindName(kind)

	return MODULE_PATH_OVERRIDES[kindName] or NODE_MODULE_PREFIX .. kindName
end

function NodeRegistry.getNodeClass(kind)
	local kindName = NodeRegistry.getKindName(kind)
	local modulePath = NodeRegistry.getModulePath(kindName)
	local didLoad = package.loaded[modulePath] == nil
	local requireStartedAt = Performance.nowMs()
	local ok, nodeClass = SafeCallbackWithStatusAndReturn(require, modulePath)

	if not ok then
		error(string.format("load dialogue graph node failed: kind=%s, module=%s, error=%s", tostring(kind), modulePath, tostring(nodeClass)))
	end

	if nodeClass == nil then
		error(string.format("dialogue graph node module returned nil: kind=%s, module=%s", tostring(kind), modulePath))
	end

	local requireElapsedMs = didLoad and Performance.elapsedMs(requireStartedAt) or 0

	return nodeClass, didLoad, requireElapsedMs
end

function NodeRegistry.clear(kind)
	if kind ~= nil then
		local kindName = NodeRegistry.getKindName(kind)
		local modulePath = NodeRegistry.getModulePath(kindName)

		package.loaded[modulePath] = nil

		return
	end

	for _, kindName in ipairs(DialogueGraphNodeConst) do
		package.loaded[NodeRegistry.getModulePath(kindName)] = nil
	end
end

return NodeRegistry
