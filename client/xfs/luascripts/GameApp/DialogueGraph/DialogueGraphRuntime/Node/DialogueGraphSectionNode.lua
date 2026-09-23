-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphSectionNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE
local DialogueGraphNodeConst = require("Const.DialogueGraphNodeConst")
local DialogueGraphConst = require("Const.DialogueGraphConst")
local DialogueGraphUtils = require("GameApp.DialogueGraph.DialogueGraphUtils")
local DialogueGraphSectionNode = DialogueGraphFlowNode.extend("DialogueGraphSectionNode")

local function isValidAnimationConfig(value)
	return type(value) == "table" and #value >= 2
end

local function asNumber(value, defaultValue)
	local numberValue = tonumber(value)

	if numberValue == nil then
		return defaultValue
	end

	return numberValue
end

local function enumValue(value, values, defaultValue)
	return tonumber(value) or values[value] or defaultValue
end

local function buildCameraData(ctx)
	local cameraId = ctx:getInput("dialogsetCameraIdVInput", 0)

	if cameraId == 0 then
		return nil
	end

	local cameraData = {
		cameraId = cameraId,
		cameraBlendInTime = ctx:getInput("dialogsetCameraBlendInTimeVInput", -1),
		cameraBlendOutTime = ctx:getInput("dialogsetCameraBlendOutTimeVInput", -1),
		cameraBlendFuction = enumValue(ctx:getInput("dialogsetCameraBlendFuctionVInput", 2), DialogueGraphConst.BlendFunction, 2),
		cameraOpenDOF = ctx:getInput("dialogsetCameraOpenDOFVInput", false)
	}
	local movementType = enumValue(ctx:getInput("dialogsetCameraMovementTypeVInput", 0), DialogueGraphConst.MovementType, 0)
	local blendTime = asNumber(ctx:getInput("dialogsetCameraMovementTimeVInput", 0), 0)

	if movementType ~= 0 and blendTime ~= 0 then
		local movementData = {
			type = movementType,
			blendTime = blendTime,
			blendFunc = enumValue(ctx:getInput("dialogsetCameraMovementFuncVInput", 2), DialogueGraphConst.BlendFunction, 2),
			blendExp = ctx:getInput("dialogsetCameraMovementExpVInput", 2),
			mode = enumValue(ctx:getInput("dialogsetCameraMovementModeVInput", 0), DialogueGraphConst.MovementMode, 0)
		}

		if movementType == 1 then
			movementData.vector = DialogueGraphUtils.toVector3(ctx:getInput("dialogsetCameraMovementVectorVInput"))
		else
			movementData.angle = ctx:getInput("dialogsetCameraMovementAngleVInput", 0)
		end

		cameraData.movementData = movementData
	end

	return cameraData
end

local function appendChoice(ctx, nodeId, branch, choicePorts)
	local choiceIndex = #choicePorts + 1
	local dialogueId = ctx:getNodeField(nodeId, "dialogueId", 0)
	local animCfg = ctx:getNodeField(nodeId, "animCfg")

	if isValidAnimationConfig(animCfg) then
		branch[choiceIndex] = {
			dialogueId = dialogueId,
			actionId = animCfg
		}
	else
		branch[choiceIndex] = dialogueId
	end

	choicePorts[choiceIndex] = {
		portId = "Out",
		nodeId = nodeId
	}
end

local function evaluateConditionNode(ctx, nodeId, kind)
	if kind == DialogueGraphNodeConst.DialogueGraphConditionNode then
		local fieldValue = ctx:getNodeField(nodeId, "triggerId", 0)
		local triggerId = ctx:getNodeInput(nodeId, "triggerIdVInput", fieldValue)

		if triggerId <= 0 then
			return false
		end

		return ctx:callCmd(NodeFunc.CONDITION_CHECK_TRIGGER, triggerId) == true
	end

	if kind == DialogueGraphNodeConst.DialogueGraphSwitchBoolNode then
		local fieldValue = ctx:getNodeField(nodeId, "condition", false)

		return ctx:getNodeInput(nodeId, "Condition", fieldValue) == true
	end

	local condition = ctx:getNodeField(nodeId, "condition", {})

	return ctx:callCmd(NodeFunc.CONDITION_CHECK_STATUS, condition) == true
end

local function resolveTargetNode(ctx, nodeId, fallbackPort, branch, choicePorts, normalPorts)
	if nodeId == nil then
		return
	end

	local kind = ctx:getNodeKindByNodeId(nodeId)

	if kind == DialogueGraphNodeConst.DialogueGraphChoiceNode then
		appendChoice(ctx, nodeId, branch, choicePorts)

		return
	end

	if kind == DialogueGraphNodeConst.DialogueGraphFlowSplitNode then
		local portCount = asNumber(ctx:getNodeField(nodeId, "portCount", 0), 0)

		for index = 0, portCount - 1 do
			local subPort = tostring(index)
			local targets = ctx:getFlowTargetsFromNode(nodeId, subPort)
			local target = targets and targets[1] or nil

			if target ~= nil then
				resolveTargetNode(ctx, target.nodeId, {
					nodeId = nodeId,
					portId = subPort
				}, branch, choicePorts, normalPorts)
			end
		end

		return
	end

	if kind == DialogueGraphNodeConst.DialogueGraphConditionNode or kind == DialogueGraphNodeConst.DialogueGraphTriggerConditionNode or kind == DialogueGraphNodeConst.DialogueGraphSwitchBoolNode then
		local passed = evaluateConditionNode(ctx, nodeId, kind)
		local portId = passed and "True" or "False"
		local targets = ctx:getFlowTargetsFromNode(nodeId, portId)
		local target = targets and targets[1] or nil

		if target == nil then
			return
		end

		resolveTargetNode(ctx, target.nodeId, {
			nodeId = nodeId,
			portId = portId
		}, branch, choicePorts, normalPorts)

		return
	end

	normalPorts[#normalPorts + 1] = fallbackPort
end

local function buildBranchInfo(ctx, portCount)
	local branch = {}
	local normalPorts = {}
	local choicePorts = {}
	local hasChoice = false
	local sectionNodeId = ctx:nodeId()

	for index = 0, portCount - 1 do
		local portId = tostring(index)
		local targets = ctx:getFlowTargets(portId)
		local target = targets and targets[1] or nil

		if target ~= nil then
			resolveTargetNode(ctx, target.nodeId, {
				nodeId = sectionNodeId,
				portId = portId
			}, branch, choicePorts, normalPorts)
		end
	end

	hasChoice = #choicePorts > 0

	return hasChoice, branch, normalPorts, choicePorts
end

local function buildShowDialogParam(ctx, hasChoice)
	local param = {}
	local chatType = asNumber(ctx:getField("chatType", 0), 0)

	function param.callback(branchId, index)
		if not ctx:isValid() then
			return
		end

		local branchIndex = asNumber(branchId, 0) - 1

		ctx:delayFrame(1, function()
			if not ctx:tryConsumeRunToken() then
				return
			end

			if hasChoice then
				local choicePorts = ctx:stateGet("choicePorts", {})
				local choicePort = choicePorts[branchIndex + 1]

				if choicePort ~= nil then
					ctx:triggerNodeFlow(choicePort.nodeId, choicePort.portId)
				end
			end

			local normalPorts = ctx:stateGet("normalPorts", {})

			for normalIndex, normalPort in ipairs(normalPorts) do
				if not hasChoice or normalIndex - 1 ~= branchIndex then
					ctx:triggerNodeFlow(normalPort.nodeId, normalPort.portId)
				end
			end

			if not hasChoice then
				ctx:triggerFlow("ShowFinOut")
			end
		end)
	end

	if chatType > 0 then
		param.chatType = chatType
		param.playType = ctx:getField("blackScreenPlayType", 0)
		param.intervalTime = ctx:getField("blackScreenIntervalTime", 2)
		param.outOrNot = ctx:getInput("enableFadeOutVInput", false) and 1 or 0
		param.inOrNot = ctx:getInput("enableFadeInVInput", false) and 1 or 0
		param.outTime = ctx:getInput("fadeOutTimeVInput", 0.5)
		param.inTime = ctx:getInput("fadeInTimeVInput", 0.5)
	end

	local duration = asNumber(ctx:getField("duration", 0), 0)

	if duration > 0 then
		param.duration = duration
	end

	local skipTime = asNumber(ctx:getField("skipTime", 0), 0)

	if skipTime > 0 then
		param.skipTime = skipTime
	end

	local lookAtId = asNumber(ctx:getInput("lookAtIdVInput", 0), 0)

	if lookAtId > 0 then
		param.lookAtId = lookAtId
	end

	if ctx:getField("disableCamera", false) then
		param.disableCameraAnim = true
	end

	param.disableLipMotion = ctx:getInput("disableLipMotionVInput", false)
	param.enablePresetLookAt = not ctx:getInput("disablePresetLookAtVInput", false)

	local animCfg = ctx:getField("animCfg")

	if isValidAnimationConfig(animCfg) then
		param.actionId = animCfg
	else
		local anim = ctx:getField("anim")

		if not string.isNilOrEmpty(anim) then
			param.actionId = anim
		end
	end

	local npcId = asNumber(ctx:getField("npcId", -1), -1)

	if npcId > 0 then
		param.npcId = npcId
	end

	local npcStaticId = asNumber(ctx:getField("npcStaticId", -1), -1)

	if npcStaticId ~= -1 then
		param.npcStaticId = npcStaticId
	end

	param.cameraData = buildCameraData(ctx)
	param.matchAudioDuration = ctx:getField("matchAudioDuration", true)

	if hasChoice then
		local defaultSkipBranch = asNumber(ctx:getInput("defaultSkipBranchVInput", 0), 0)

		if defaultSkipBranch > 0 then
			param.defaultSkipBranch = defaultSkipBranch
		end

		param.branch = ctx:stateGet("branch", {})

		function param.showBranchCallback()
			if ctx:isValid() then
				ctx:triggerFlow("ShowFinOut")
			end
		end
	else
		local audioName = ctx:getField("audioName")

		if not string.isNilOrEmpty(audioName) then
			param.audioName = audioName
		end

		function param.onSetDuration(value)
			local timeout = asNumber(value, 0)

			timeout = timeout > 0 and timeout + 1 or 5

			ctx:delay(timeout, function()
				if ctx:isValid() and ctx:callCmd(NodeFunc.DIALOGUE_IS_AUTO_PLAYING) then
					param.callback(1, 0)
				end
			end)
		end
	end

	return param
end

function DialogueGraphSectionNode.run(ctx)
	local dialogueId = asNumber(ctx:getInput("dialogueIdVInput", 0), 0)
	local chatType = asNumber(ctx:getField("chatType", 0), 0)
	local portCount = asNumber(ctx:getField("portCount", 1), 1)
	local hasChoice, branch, normalPorts, choicePorts = buildBranchInfo(ctx, portCount)

	if dialogueId == 0 and chatType ~= 5 and chatType ~= 7 then
		ctx:fail("dialogueId is not configured")

		return
	end

	ctx:stateSet("normalPorts", normalPorts)

	if hasChoice then
		ctx:stateSet("branch", branch)
		ctx:stateSet("choicePorts", choicePorts)
	end

	local entityId = ctx:getInput("entityIdVInput")
	local param = buildShowDialogParam(ctx, hasChoice)

	ctx:callCmd(NodeFunc.DIALOGUE_SHOW_DIALOG, dialogueId, entityId, param)
end

return DialogueGraphSectionNode
