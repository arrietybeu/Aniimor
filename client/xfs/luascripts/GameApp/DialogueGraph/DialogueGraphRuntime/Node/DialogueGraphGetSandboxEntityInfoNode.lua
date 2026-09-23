-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphGetSandboxEntityInfoNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE
local DialogueGraphGetSandboxEntityInfoNode = DialogueGraphFlowNode.extend("DialogueGraphGetSandboxEntityInfoNode")

local function getTargetTransform(ctx)
	local cached = ctx:stateGet("targetTransform")

	if cached ~= nil then
		return cached
	end

	local target = ctx:callCmd(NodeFunc.ENTITY_GET_SANDBOX_LEVEL_ITEM_TRANSFORM, ctx:getInput("sandboxIDVInput", 0), ctx:getInput("staticDVInput", 0))

	ctx:stateSet("targetTransform", target)

	return target
end

local function findRecursive(transform, boneName)
	if transform == nil then
		return nil
	end

	if transform.name == boneName then
		return transform
	end

	local childCount = tonumber(transform.childCount) or 0

	for index = 0, childCount - 1 do
		local found = findRecursive(transform:GetChild(index), boneName)

		if found ~= nil then
			return found
		end
	end

	return nil
end

function DialogueGraphGetSandboxEntityInfoNode.getPosition(ctx)
	local transform = getTargetTransform(ctx)

	return transform ~= nil and transform.position or Vector3.zero
end

function DialogueGraphGetSandboxEntityInfoNode.getEulerAngles(ctx)
	local transform = getTargetTransform(ctx)

	return transform ~= nil and transform.eulerAngles or Vector3.zero
end

function DialogueGraphGetSandboxEntityInfoNode.getBoneTransform(ctx)
	local transform = getTargetTransform(ctx)
	local boneName = ctx:getInput("boneNameVInput")

	if transform ~= nil and not string.isNilOrEmpty(boneName) then
		return findRecursive(transform, boneName) or transform
	end

	return transform
end

return DialogueGraphGetSandboxEntityInfoNode
