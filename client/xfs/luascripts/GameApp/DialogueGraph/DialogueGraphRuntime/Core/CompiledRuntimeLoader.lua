-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Core\\CompiledRuntimeLoader.lua

local CompiledRuntimeLoader = {}
local Runtime = require("GameApp.DialogueGraph.DialogueGraphRuntime.Core.Runtime")
local Performance = require("GameApp.DialogueGraph.DialogueGraphRuntime.Core.Performance")
local SafeCallbackWithStatusAndReturn = require("Core.Framework.SafeCallbackWithStatusAndReturn")
local AccessControl = require("Core.Framework.AccessControl")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("CompiledRuntimeLoader")

local function applyDataPatch(data, patchFunc)
	data = AccessControl:getRawTable(data)

	local dialogueId = data.dialogueId

	assert(patchFunc(data) ~= false, "dialogue graph patch rejected")
	assert(data.dialogueId == dialogueId, "patch cannot change dialogueId")
	assert(type(data.nodes) == "table", "invalid patched nodes")

	return data
end

local function getDialogueGraphModuleName(dialogueId)
	return string.format("Data.DialogueGraph.DialogueGraph_%d", dialogueId)
end

local function loadGraphData(moduleName)
	package.loaded[moduleName] = nil

	local data = require(moduleName)

	package.loaded[moduleName] = nil

	return data
end

function CompiledRuntimeLoader.create(data, context)
	return Runtime.load(data, context.graphItem, context.luaCmd, context.luaVariables)
end

function CompiledRuntimeLoader.preload(dialogueId, context)
	local preloadStartedAt = Performance.nowMs()
	local moduleName = getDialogueGraphModuleName(dialogueId)
	local dataLoadStartedAt = Performance.nowMs()
	local data = loadGraphData(moduleName)

	data = CompiledRuntimeLoader.applyHotfix(data, dialogueId)

	local dataLoadMs = Performance.elapsedMs(dataLoadStartedAt)
	local runtimeCreateStartedAt = Performance.nowMs()
	local runner = CompiledRuntimeLoader.create(data, context)
	local performance = runner and runner.performance or nil

	Performance.record(performance, "dataLoadMs", dataLoadMs)
	Performance.record(performance, "runtimeCreateMs", Performance.elapsedMs(runtimeCreateStartedAt))
	Performance.record(performance, "preloadMs", Performance.elapsedMs(preloadStartedAt))

	return {
		moduleName = moduleName,
		runner = runner
	}
end

function CompiledRuntimeLoader.hotfixDialogueGraph(dialogueId, patchFunc)
	assert(type(dialogueId) == "number", "invalid dialogueId")
	assert(patchFunc == nil or type(patchFunc) == "function", "invalid dialogue graph patch")

	CompiledRuntimeLoader.dataPatches = CompiledRuntimeLoader.dataPatches or {}
	CompiledRuntimeLoader.dataPatches[dialogueId] = patchFunc
end

function CompiledRuntimeLoader.applyHotfix(data, dialogueId)
	local patches = CompiledRuntimeLoader.dataPatches
	local patchFunc = patches and patches[dialogueId]

	if patchFunc == nil then
		return data
	end

	local ok, result = SafeCallbackWithStatusAndReturn(applyDataPatch, data, patchFunc)

	if ok then
		return result
	end

	if LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("DialogueGraph hotfix failed, id=%s, reloading base config: %s", tostring(dialogueId), tostring(result))
	end

	return loadGraphData(getDialogueGraphModuleName(dialogueId))
end

function CompiledRuntimeLoader.dispose(result)
	if result == nil then
		return
	end

	local disposeOk = true
	local disposeError

	if result.runner ~= nil and result.runner.dispose ~= nil then
		disposeOk, disposeError = SafeCallbackWithStatusAndReturn(result.runner.dispose, result.runner)
	end

	local moduleName = result.moduleName

	if moduleName ~= nil then
		package.loaded[moduleName] = nil
	end

	result.runner = nil
	result.moduleName = nil

	if not disposeOk then
		error(disposeError)
	end
end

return CompiledRuntimeLoader
