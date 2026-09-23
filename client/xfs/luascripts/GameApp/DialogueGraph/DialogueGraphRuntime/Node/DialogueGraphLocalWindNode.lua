-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphLocalWindNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphLocalWindNode = DialogueGraphFlowNode.extend("DialogueGraphLocalWindNode")
local DialogueGraphUtils = require("GameApp.DialogueGraph.DialogueGraphUtils")
local DynamicValueRuntime = require("GameApp.DialogueGraph.DialogueGraphRuntime.Core.DynamicValueRuntime")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE
local Vector3 = Vector3
local Quaternion = Quaternion

local function stop(ctx)
	ctx:callCmd(NodeFunc.SCENE_DISABLE_LOCAL_WIND, ctx:nodeId())

	local effectId = ctx:stateGet("effectId", 0)

	if effectId ~= 0 then
		ctx:callCmd(NodeFunc.EFFECT_STOP, tonumber(ctx:stateGet("generatorId", 0)) or 0, effectId)
		ctx:stateSet("effectId", 0)
	end
end

function DialogueGraphLocalWindNode.run(ctx)
	if ctx:inputPort() == "Stop" then
		stop(ctx)

		return
	end

	local startPos = ctx:getInput("startPositionVInput", Vector3.zero)
	local startPosition = DialogueGraphUtils.toVector3(startPos)
	local endPos = ctx:getInput("endPositionVInput", Vector3.zero)
	local endPosition = DialogueGraphUtils.toVector3(endPos)
	local lerpPosition = ctx:getInput("lerpPositionVInput", 0.5)
	local maxIntensity = ctx:getInput("maxIntensityVInput", 2)
	local maxSpeed = ctx:getInput("maxSpeedVInput", 3)

	if not ctx:callCmd(NodeFunc.SCENE_START_LOCAL_WIND, ctx:nodeId(), startPosition, endPosition, maxIntensity, maxSpeed) then
		ctx:triggerFlow("Finish")

		return
	end

	DynamicValueRuntime.bindAll(ctx)

	local effectResId = ctx:getInput("windEffectResIDVInput")

	if not string.isNilOrEmpty(effectResId) then
		local generatorId = tonumber(ctx:callCmd(NodeFunc.EFFECT_GET_GENERATOR_ID, nil)) or 0

		if generatorId ~= 0 then
			local effectPosition = startPosition + (endPosition - startPosition) * lerpPosition
			local direction = endPosition - startPosition
			local effectRotation = Quaternion.LookRotation(direction, Vector3.constUp).eulerAngles
			local effectId = ctx:callCmd(NodeFunc.EFFECT_PLAY, generatorId, effectResId, effectPosition, effectRotation)

			ctx:stateSet("generatorId", generatorId)
			ctx:stateSet("effectId", effectId)
		end
	end

	ctx:triggerFlow("Finish")
end

return DialogueGraphLocalWindNode
