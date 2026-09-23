-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Core\\GuardRules\\NodeLoopRule.lua

local Time = require("Core.Common.Time")
local NodeLoopRule = {
	id = "NodeLoop"
}
local MAX_ACTIVE_DEPTH = 512
local BURST_WINDOW_SECONDS = 0.1
local BURST_RUN_LIMIT = 64
local SLOW_WINDOW_SECONDS = 5
local SLOW_RUN_LIMIT = 20
local SLOW_WARNING_COOLDOWN_SECONDS = 30
local EMPTY_CYCLIC_NODE_GROUPS = {}

local function realtimeNow()
	return Time.realtimeSinceStartup
end

local function createIssue(code, action, nodeId, loopGroupId, runTimes, message, extra)
	local issue = {
		rule = NodeLoopRule.id,
		code = code,
		action = action,
		nodeId = nodeId,
		loopGroupId = loopGroupId,
		runTimes = runTimes,
		message = message
	}

	if extra ~= nil then
		for key, value in pairs(extra) do
			issue[key] = value
		end
	end

	return issue
end

local function recordBurst(nodeState, now)
	local nextIndex = nodeState.burstIndex % BURST_RUN_LIMIT + 1

	nodeState.burstIndex = nextIndex
	nodeState.burstTimes[nextIndex] = now
	nodeState.burstCount = math.min(nodeState.burstCount + 1, BURST_RUN_LIMIT)

	if nodeState.burstCount < BURST_RUN_LIMIT then
		return false
	end

	local oldestIndex = nextIndex % BURST_RUN_LIMIT + 1
	local oldestTime = nodeState.burstTimes[oldestIndex]

	return oldestTime ~= nil and now - oldestTime <= BURST_WINDOW_SECONDS
end

function NodeLoopRule.createState(runtime)
	local cyclicNodeGroups = runtime.data and runtime.data.cyclicNodeGroups or EMPTY_CYCLIC_NODE_GROUPS

	return {
		activeDepth = 0,
		cyclicNodeGroups = cyclicNodeGroups,
		nodeStates = {},
		activeActivations = {},
		activeActivationIds = {},
		groupProgressVersions = {},
		timeProvider = runtime.loopTimeProvider or realtimeNow
	}
end

function NodeLoopRule.check(ctx, state, actions)
	local nodeId = ctx:nodeId()
	local activationId = ctx:activationId()
	local isStopPort = ctx:isStopPort()
	local activeActivationId = state.activeActivations[nodeId]

	if not isStopPort and activeActivationId ~= nil then
		return false, createIssue("SynchronousNodeLoop", actions.ABORT_GRAPH, nodeId, state.cyclicNodeGroups[nodeId], 2, "节点在上一次同步执行尚未退出时再次进入，检测到同步死循环", {
			activeActivationId = activeActivationId,
			activationId = activationId
		})
	end

	if state.activeDepth >= MAX_ACTIVE_DEPTH then
		return false, createIssue("ExecutionDepthExceeded", actions.ABORT_GRAPH, nodeId, state.cyclicNodeGroups[nodeId], state.activeDepth + 1, string.format("同步执行深度超过上限%s，终止对话图以避免调用栈溢出", tostring(MAX_ACTIVE_DEPTH)))
	end

	if not isStopPort then
		state.activeActivations[nodeId] = activationId
	end

	state.activeActivationIds[activationId] = true
	state.activeDepth = state.activeDepth + 1

	local loopGroupId = state.cyclicNodeGroups[nodeId]

	if loopGroupId == nil then
		return true
	end

	local now = state.timeProvider()
	local progressVersion = state.groupProgressVersions[loopGroupId] or 0
	local nodeState = state.nodeStates[nodeId]

	if nodeState == nil then
		nodeState = {
			burstCount = 0,
			burstIndex = 0,
			noProgressRuns = 0,
			burstTimes = {},
			progressVersion = progressVersion,
			noProgressStartedAt = now
		}
		state.nodeStates[nodeId] = nodeState
	elseif nodeState.progressVersion ~= progressVersion then
		nodeState.progressVersion = progressVersion
		nodeState.noProgressStartedAt = now
		nodeState.noProgressRuns = 0
	end

	nodeState.noProgressRuns = nodeState.noProgressRuns + 1

	if recordBurst(nodeState, now) then
		return false, createIssue("BurstNodeLoop", actions.ABORT_GRAPH, nodeId, loopGroupId, BURST_RUN_LIMIT, string.format("循环节点在%s秒内进入%s次，检测到快速异步死循环", tostring(BURST_WINDOW_SECONDS), tostring(BURST_RUN_LIMIT)))
	end

	local noProgressDuration = now - nodeState.noProgressStartedAt
	local warningCooldownElapsed = nodeState.lastSlowWarningAt == nil or now - nodeState.lastSlowWarningAt >= SLOW_WARNING_COOLDOWN_SECONDS

	if nodeState.noProgressRuns >= SLOW_RUN_LIMIT and noProgressDuration >= SLOW_WINDOW_SECONDS and warningCooldownElapsed then
		nodeState.lastSlowWarningAt = now

		return true, createIssue("SlowNodeLoop", actions.LOG_ONLY, nodeId, loopGroupId, nodeState.noProgressRuns, string.format("循环节点持续%s秒运行%s次且未检测到有效进展，请检查是否为慢速死循环", tostring(noProgressDuration), tostring(nodeState.noProgressRuns)))
	end

	return true
end

function NodeLoopRule.onNodeFinished(ctx, state)
	local nodeId = ctx:nodeId()
	local activationId = ctx:activationId()

	if not state.activeActivationIds[activationId] then
		return
	end

	state.activeActivationIds[activationId] = nil

	if state.activeActivations[nodeId] == activationId then
		state.activeActivations[nodeId] = nil
	end

	state.activeDepth = math.max(0, state.activeDepth - 1)
end

function NodeLoopRule.markProgress(ctx, state)
	local loopGroupId = state.cyclicNodeGroups[ctx:nodeId()]

	if loopGroupId == nil then
		return
	end

	state.groupProgressVersions[loopGroupId] = (state.groupProgressVersions[loopGroupId] or 0) + 1
end

function NodeLoopRule.reset(state)
	state.nodeStates = {}
	state.activeActivations = {}
	state.activeActivationIds = {}
	state.activeDepth = 0
	state.groupProgressVersions = {}
end

return NodeLoopRule
