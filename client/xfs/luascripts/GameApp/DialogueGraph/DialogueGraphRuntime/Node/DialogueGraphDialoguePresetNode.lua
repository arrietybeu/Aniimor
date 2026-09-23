-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphDialoguePresetNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE
local DialogueGraphDialoguePresetNode = DialogueGraphFlowNode.extend("DialogueGraphDialoguePresetNode")
local NodeMode = {
	OneToOne = 0,
	Group = 1
}
local ReactPreset = {
	Stay = 3,
	LookAtIk = 2,
	BackToIdle = 1,
	TurnToPlayer = 0
}
local CameraPreset = {
	None = 2,
	Immersive = 1,
	Free = 0
}

local function enumValue(value, values, defaultValue)
	return tonumber(value) or values[value] or defaultValue
end

function DialogueGraphDialoguePresetNode.run(ctx)
	local entityId = ctx:getInput("npcIdVInput")
	local staticId = ctx:getInput("staticIdVInput", 0)

	if string.isNilOrEmpty(entityId) and staticId == 0 then
		ctx:triggerFlow("Finish")
		ctx:triggerFlow("FOut")

		return false, "没有配置实体", true
	end

	local nodeMode = enumValue(ctx:getField("nodeMode", 0), NodeMode, 0)
	local cameraPreset = enumValue(ctx:getField("cameraPreset", 0), CameraPreset, 0)
	local param = {
		cameraPreset = cameraPreset
	}

	if nodeMode == 0 then
		local reactPreset = enumValue(ctx:getField("reactPreset", 0), ReactPreset, 0)

		param.reactPreset = reactPreset
		param.resetOrientation = reactPreset == 0 and ctx:getField("resetOrientation", true) or false
		param.enableDefaultLookAt = ctx:getField("enableDefaultLookAt", true)
	else
		param.enableGroupLookAt = ctx:getField("enableGroupLookAt", true)
	end

	local function finishCallback()
		if not ctx:tryConsumeRunToken() then
			return
		end

		ctx:triggerFlow("Finish")
	end

	ctx:delay(3.1, finishCallback)

	local targetId = entityId

	if string.isNilOrEmpty(targetId) then
		targetId = staticId
	end

	ctx:callCmd(NodeFunc.DIALOGUE_ENTER_DIALOGUE_PRESET, nodeMode, targetId, param, finishCallback)
	ctx:triggerFlow("FOut")
end

return DialogueGraphDialoguePresetNode
