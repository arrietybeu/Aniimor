-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphCharacterFillLightNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphCharacterFillLightNode = DialogueGraphFlowNode.extend("DialogueGraphCharacterFillLightNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE

function DialogueGraphCharacterFillLightNode.run(ctx)
	local enableFillLight = ctx:getInput("enableFillLightVInput", false)
	local fillLightIntensity = ctx:getInput("fillLightIntensityVInput", 0)

	ctx:callCmd(NodeFunc.SCENE_SET_CHARACTER_FILL_LIGHT, enableFillLight, fillLightIntensity)
	ctx:triggerFlow("Out")
end

return DialogueGraphCharacterFillLightNode
