-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphChangeEntityStateNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphChangeEntityStateNode = DialogueGraphFlowNode.extend("DialogueGraphChangeEntityStateNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Logger = LoggerManager.getLogger("DialogueGraphChangeEntityStateNode")

function DialogueGraphChangeEntityStateNode.run(ctx)
	local entityId = ctx:getInput("entityIdVInput")
	local staticId = ctx:getInput("staticIdVInput", 0)
	local characterState = ctx:getInput("characterStateVInput", 0)
	local playableState = ctx:getInput("playableStateVInput")
	local autoResume = ctx:getInput("autoResumeVInput", false)
	local succeeded = ctx:callCmd(NodeFunc.ENTITY_CHANGE_STATE, entityId, staticId, characterState, playableState, autoResume)

	if not succeeded then
		return false, string.format("找不到对应实体！EntityId:%s StaticId:%s", tostring(entityId), tostring(staticId)), true
	end

	ctx:triggerFlow("Out")
end

return DialogueGraphChangeEntityStateNode
