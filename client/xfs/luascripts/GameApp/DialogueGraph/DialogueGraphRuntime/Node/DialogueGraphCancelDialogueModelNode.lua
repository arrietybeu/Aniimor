-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphCancelDialogueModelNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphCancelDialogueModelNode = DialogueGraphFlowNode.extend("DialogueGraphCancelDialogueModelNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE

function DialogueGraphCancelDialogueModelNode.run(ctx)
	local enableEvent = ctx:getInput("enableEventVInput", true)
	local enablePlayerMove = ctx:getInput("enablePlayerMoveVInput", true)
	local resumeNearbyMonsterAI = ctx:getInput("resumeNearbyMonsterAIVInput", true)
	local showAllUI = ctx:getInput("showAllUIVInput", true)
	local showTopLogo = ctx:getInput("showTopLogoVInput", true)
	local enableCameraZoom = ctx:getInput("enableCameraZoomVInput", true)
	local endSkip = ctx:getInput("endSkipVInput", false)
	local param = {}

	if showAllUI then
		param.hideAllUI = false
	end

	if enableEvent then
		param.blockEvent = false
	end

	if showTopLogo then
		param.hideTopLogo = false
	end

	if enableCameraZoom then
		param.blockCameraZoom = false
	end

	if enablePlayerMove then
		param.blockPlayerMove = false
	end

	if resumeNearbyMonsterAI then
		param.resumeNearbyMonsterAI = true
	end

	if endSkip then
		param.turnOffPlayback = true
	end

	if enableEvent or enablePlayerMove then
		param.disableDialogueCom = true
	end

	ctx:callCmd(NodeFunc.DIALOGUE_SET_MODEL, param)
	ctx:triggerFlow("Out")
end

return DialogueGraphCancelDialogueModelNode
