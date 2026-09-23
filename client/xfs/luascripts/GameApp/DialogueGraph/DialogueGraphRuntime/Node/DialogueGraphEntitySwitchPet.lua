-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphEntitySwitchPet.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphEntitySwitchPet = DialogueGraphFlowNode.extend("DialogueGraphEntitySwitchPet")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE

function DialogueGraphEntitySwitchPet.run(ctx)
	local playerEntityId = ctx:getInput("playerEntIdVInput")
	local petEntityId = ctx:getInput("petEntIdVInput")

	if string.isNilOrEmpty(playerEntityId) or string.isNilOrEmpty(petEntityId) then
		return false, "玩家或者宠物实体为空！", true
	end

	local function finishCallback()
		if not ctx:tryConsumeRunToken() then
			return
		end

		ctx:triggerFlow("Finish")
	end

	ctx:delay(3, finishCallback)

	local switchToPet = ctx:getInput("switchToPetVInput", true)
	local command = switchToPet and NodeFunc.ENTITY_PLAY_SWITCH_TO_PET or NodeFunc.ENTITY_PLAY_SWITCH_TO_PLAYER

	ctx:callCmd(command, playerEntityId, petEntityId, ctx:getInput("isIdyllVInput", false), finishCallback)
	ctx:triggerFlow("Out")
end

return DialogueGraphEntitySwitchPet
