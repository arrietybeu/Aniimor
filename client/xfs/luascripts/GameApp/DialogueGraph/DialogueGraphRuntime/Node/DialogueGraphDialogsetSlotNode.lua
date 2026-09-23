-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphDialogsetSlotNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphDialogsetSlotNode = DialogueGraphFlowNode.extend("DialogueGraphDialogsetSlotNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE
local LookupCommand = {
	position = {
		ID = NodeFunc.DIALOGUE_GET_DIALOGSET_POSITION_BY_ID,
		Index = NodeFunc.DIALOGUE_GET_DIALOGSET_POSITION_BY_INDEX
	},
	rotation = {
		ID = NodeFunc.DIALOGUE_GET_DIALOGSET_ROTATION_BY_ID,
		Index = NodeFunc.DIALOGUE_GET_DIALOGSET_ROTATION_BY_INDEX
	},
	entityStaticId = {
		ID = NodeFunc.DIALOGUE_GET_DIALOGSET_ENTITY_ID_BY_ID,
		Index = NodeFunc.DIALOGUE_GET_DIALOGSET_ENTITY_ID_BY_INDEX
	}
}

local function getLookup(ctx)
	local sceneId = ctx:getInput("sceneIDVinput", 0)
	local dialogsetId = ctx:getInput("dialogsetIDVInput", 0)

	if sceneId <= 0 or dialogsetId <= 0 then
		return nil
	end

	local slotId = ctx:getInput("slotIDVInput", 0)

	if ctx:isValueInputConnected("SlotID") or slotId > 0 then
		return sceneId, dialogsetId, slotId, "ID"
	end

	local slotIndex = ctx:getInput("slotIndexVInput", 0)

	if ctx:isValueInputConnected("slotIndexVInput") or slotIndex > 0 then
		return sceneId, dialogsetId, slotIndex, "Index"
	end

	return nil
end

local function getCached(ctx, key)
	local readyKey = key .. "Ready"

	if ctx:stateGet(readyKey, false) then
		return ctx:stateGet(key, nil)
	end

	local sceneId, dialogsetId, slot, lookupType = getLookup(ctx)

	if sceneId == nil then
		return nil
	end

	local value = ctx:callCmd(LookupCommand[key][lookupType], sceneId, dialogsetId, slot)

	ctx:stateSet(key, value)
	ctx:stateSet(readyKey, true)

	return value
end

function DialogueGraphDialogsetSlotNode.getOutPosition(ctx)
	return getCached(ctx, "position") or Vector3.zero
end

function DialogueGraphDialogsetSlotNode.getOutRotation(ctx)
	return getCached(ctx, "rotation")
end

function DialogueGraphDialogsetSlotNode.getOutEulerAngle(ctx)
	local rotation = DialogueGraphDialogsetSlotNode.getOutRotation(ctx)

	return rotation ~= nil and rotation.eulerAngles or Vector3.zero
end

function DialogueGraphDialogsetSlotNode.getOutEntStaticId(ctx)
	return getCached(ctx, "entityStaticId") or 0
end

return DialogueGraphDialogsetSlotNode
