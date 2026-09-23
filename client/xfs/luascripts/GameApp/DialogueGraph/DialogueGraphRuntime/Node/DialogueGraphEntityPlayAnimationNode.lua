-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphEntityPlayAnimationNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphEntityPlayAnimationNode = DialogueGraphFlowNode.extend("DialogueGraphEntityPlayAnimationNode")
local DialogueGraphUtils = require("GameApp.DialogueGraph.DialogueGraphUtils")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE
local PLAYABLE_STATE_TYPE = 1

local function finishOnce(ctx)
	if not ctx:tryConsumeRunToken() then
		return
	end

	ctx:cancelTimeout()
	ctx:triggerFlow("Finish")
end

local function stopPlayAnimation(ctx, stopImmediately)
	local entityId = ctx:stateGet("entityId")

	if entityId ~= nil then
		ctx:callCmd(NodeFunc.ENTITY_STOP_ANIMATION, entityId, stopImmediately)
		ctx:stateSet("entityId", nil)
	end
end

local function toStringArray(value)
	if value == nil then
		return nil
	end

	local result = {}

	for index, item in ipairs(value) do
		result[index] = tostring(item)
	end

	return result
end

local function onFinish(ctx)
	ctx:triggerFlow("Out")
	ctx:triggerFlow("Finish")
end

function DialogueGraphEntityPlayAnimationNode.run(ctx)
	if ctx:inputPort() == "Stop" then
		stopPlayAnimation(ctx, false)

		return
	end

	ctx:cancelTimeout()

	local playAniType = ctx:getField("playAniType", PLAYABLE_STATE_TYPE)

	if playAniType ~= PLAYABLE_STATE_TYPE then
		onFinish(ctx)

		return false, "播放动画Clip片段功能已经废弃"
	end

	local entityId = ctx:getInput("entityIdVInput")
	local staticId = ctx:getInput("staticIdVInput", 0)
	local entity = DialogueGraphUtils.getEntityById(entityId, staticId)

	if entity == nil then
		onFinish(ctx)

		return false, string.format("实体不存在！entityId = %s staticId = %s", tostring(entityId), tostring(staticId)), true
	end

	local entityId = entity.id

	if ctx:callCmd(NodeFunc.ENTITY_SET_ENTITY_TAKE_OVER, entityId) == false then
		onFinish(ctx)

		return false, string.format("EntityPlayAnimation failed to take over entityId=%s", entityId)
	end

	local playStartLoopEnd = ctx:getInput("playStartLoopEndVInput", false)
	local isLooping = ctx:getField("isLooping", false)

	if not playStartLoopEnd and not isLooping then
		local timeoutTime = ctx:getField("processingTime", 0) + 1

		if timeoutTime <= 0 then
			timeoutTime = 10
		end

		ctx:startTimeout(timeoutTime, function()
			finishOnce(ctx)
		end)
	end

	local playableStateName = ctx:getInput("playableStateVInput")

	ctx:stateSet("entityId", entityId)

	local ret = ctx:callCmd(NodeFunc.ENTITY_PLAY_ANIMATION, entityId, playAniType, playableStateName, nil, toStringArray(ctx:getField("aniStateList", nil)), ctx:getInput("animationLayerVInput", 0), ctx:getInput("applyRootMotionVInput", false), playStartLoopEnd, ctx:getInput("loopDurationVInput", 0), ctx:getInput("fadeDurationVInput", 0.25), ctx:getInput("playOnEntityVInput", false), ctx:getInput("speedVInput", 1), isLooping, ctx:getInput("defaultTransStateVInput"), function()
		finishOnce(ctx)
	end)

	if ret == nil or ret <= 0 then
		ctx:stateSet("entityId", nil)

		return false, string.format("播放动画失败！ entityId=%s", entityId)
	end

	ctx:triggerFlow("Out")
end

function DialogueGraphEntityPlayAnimationNode.onGraphFinished(ctx)
	stopPlayAnimation(ctx, true)
end

return DialogueGraphEntityPlayAnimationNode
