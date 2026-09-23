-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Core\\DynamicValueRuntime.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("WorldXGraph")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE
local SafeCallbackWithStatusAndReturn = require("Core.Framework.SafeCallbackWithStatusAndReturn")
local DynamicValueRuntime = {}

local function normalizeId(dynamicValueId)
	dynamicValueId = tonumber(dynamicValueId)

	if dynamicValueId == nil or dynamicValueId < 0 then
		return nil
	end

	return dynamicValueId
end

function DynamicValueRuntime.create(ctx, creator)
	local ok, result = SafeCallbackWithStatusAndReturn(creator, ctx:nodeId())
	local dynamicValueId = ok and normalizeId(result) or nil

	if dynamicValueId == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("Create dynamic value failed: nodeId=%s error=%s", tostring(ctx:nodeId()), tostring(ok and "invalid id" or result))
		end

		return nil
	end

	return dynamicValueId
end

function DynamicValueRuntime.getInput(ctx, portId, fallbackFieldId)
	local fallbackValue

	if fallbackFieldId ~= nil then
		fallbackValue = ctx:getField(fallbackFieldId, nil)
	end

	return normalizeId(ctx:getInput(portId, fallbackValue))
end

function DynamicValueRuntime.bindInput(ctx, portId, fallbackFieldId)
	local dynamicValueId = DynamicValueRuntime.getInput(ctx, portId, fallbackFieldId)

	if dynamicValueId == nil then
		return false
	end

	local ok, result = SafeCallbackWithStatusAndReturn(function()
		return ctx:callCmd(NodeFunc.DYNAMIC_VALUE_BIND, ctx:nodeId(), portId, dynamicValueId)
	end)

	if ok and result ~= false then
		return true
	end

	if LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("Bind dynamic value failed: nodeId=%s portId=%s dynamicValueId=%s error=%s", tostring(ctx:nodeId()), tostring(portId), tostring(dynamicValueId), tostring(ok and "BindDynamicValue returned false" or result))
	end

	return false
end

function DynamicValueRuntime.bindAll(ctx)
	local dynamicInputs = ctx:getDynamicInputs()

	if dynamicInputs == nil then
		return 0
	end

	local boundCount = 0

	for index = 1, #dynamicInputs do
		if DynamicValueRuntime.bindInput(ctx, dynamicInputs[index]) then
			boundCount = boundCount + 1
		end
	end

	return boundCount
end

return DynamicValueRuntime
