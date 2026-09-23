-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphTimelineNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE
local DialogueGraphTimelineNode = DialogueGraphFlowNode.extend("DialogueGraphTimelineNode")
local DialogueGraphUtils = require("GameApp.DialogueGraph.DialogueGraphUtils")
local Quaternion = Quaternion

local function getActiveContext(ctx)
	local activeContext = ctx:stateGet("activeContext", ctx)

	if activeContext:passToken() ~= ctx:passToken() then
		return ctx
	end

	return activeContext
end

local function preload(ctx)
	if ctx:stateGet("preloaded", false) then
		return true
	end

	local resId = ctx:getInput("timelineResIdVInput")

	if string.isNilOrEmpty(resId) then
		return false
	end

	local eulerAngle = DialogueGraphUtils.toVector3(ctx:getInput("playOnEulerAngleVInput", nil))
	local param = {
		resId = resId,
		pos = DialogueGraphUtils.toVector3(ctx:getInput("playOnPositionVInput", nil)),
		rot = Quaternion.Euler(eulerAngle.x, eulerAngle.y, eulerAngle.z),
		startPlayCallback = function()
			local activeContext = getActiveContext(ctx)

			if activeContext:isValid() then
				activeContext:triggerFlow("StartPlay")
			end
		end,
		preEndCallback = function()
			local activeContext = getActiveContext(ctx)

			if activeContext:isValid() then
				activeContext:triggerFlow("PreFinish")
			end
		end,
		endCallback = function()
			local activeContext = getActiveContext(ctx)

			if activeContext:tryConsumeRunToken() then
				activeContext:stateSet("cutsceneId", -1)
				activeContext:triggerFlow("Finish")
			end
		end
	}

	ctx:stateSet("preloaded", true)
	ctx:stateSet("resId", resId)
	ctx:stateSet("cutsceneId", -1)
	ctx:callCmd(NodeFunc.PRELOAD_CUTSCENE, param)

	return true
end

function DialogueGraphTimelineNode.run(ctx)
	ctx:stateSet("activeContext", ctx)

	if not preload(ctx) then
		ctx:triggerFlow("Finish")
		ctx:triggerFlow("Start")

		return
	end

	local resId = ctx:getInput("timelineResIdVInput")
	local cutsceneId = ctx:callCmd(NodeFunc.PLAY_CUTSCENE, resId)

	ctx:stateSet("cutsceneId", cutsceneId)
	ctx:triggerFlow("Start")
end

function DialogueGraphTimelineNode.onGraphFinished(ctx)
	local resId = ctx:stateGet("resId", nil)

	ctx:stateSet("resId", nil)
	ctx:stateSet("preloaded", nil)
	ctx:stateSet("activeContext", nil)
	ctx:stateSet("cutsceneId", nil)

	if not string.isNilOrEmpty(resId) then
		ctx:callCmd(NodeFunc.UNPRELOAD_CUTSCENE, resId)
	end
end

return DialogueGraphTimelineNode
