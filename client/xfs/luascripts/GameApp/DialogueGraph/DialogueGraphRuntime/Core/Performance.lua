-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Core\\Performance.lua

local Performance = {}
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("DialogueGraphPerformance")
local enabled = false
local SLOW_NODE_THRESHOLD_MS = 20

function Performance.setEnabled(value)
	enabled = value == true
end

function Performance.isEnabled()
	return enabled and LoggerManager.checkLogger(LoggerConst.INFO)
end

function Performance.isRequestedEnabled()
	return enabled
end

function Performance.setSlowNodeThreshold(thresholdMs)
	SLOW_NODE_THRESHOLD_MS = thresholdMs or 20
end

function Performance.nowMs()
	if not Performance.isEnabled() then
		return nil
	end

	return os.clock() * 1000
end

function Performance.elapsedMs(startedAt)
	if startedAt == nil or not Performance.isEnabled() then
		return 0
	end

	return Performance.nowMs() - startedAt
end

function Performance.record(perf, key, milliseconds)
	if not Performance.isEnabled() or perf == nil then
		return
	end

	perf[key] = milliseconds or 0
end

function Performance.add(perf, millisecondsKey, countKey, milliseconds)
	if not Performance.isEnabled() or perf == nil then
		return
	end

	local ms = tonumber(milliseconds) or 0

	perf[millisecondsKey] = (perf[millisecondsKey] or 0) + ms
	perf[countKey] = (perf[countKey] or 0) + 1
end

local framePool = {}
local framePoolSize = 0

function Performance.beginNode(perf)
	if not Performance.isEnabled() or perf == nil then
		return nil
	end

	local frame

	if framePoolSize > 0 then
		frame = framePool[framePoolSize]
		framePoolSize = framePoolSize - 1
	else
		frame = {}
	end

	frame.startedAt = Performance.nowMs()
	frame.childMs = 0
	frame.memoryBefore = collectgarbage("count")
	perf.stack = perf.stack or {}

	table.insert(perf.stack, frame)

	return frame
end

function Performance.endNode(perf, frame, nodeId, nodeKind)
	if frame == nil or perf == nil then
		return
	end

	perf.stack = perf.stack or {}

	table.remove(perf.stack)

	local elapsed = Performance.nowMs() - frame.startedAt
	local selfTime = elapsed - frame.childMs
	local memoryAfter = collectgarbage("count")
	local memoryDelta = memoryAfter - frame.memoryBefore

	if #perf.stack > 0 then
		perf.stack[#perf.stack].childMs = perf.stack[#perf.stack].childMs + elapsed
	end

	if nodeKind then
		Performance.add(perf, nodeKind .. "_ms", nodeKind .. "_count", selfTime)
		Performance.add(perf, nodeKind .. "_memory", nodeKind .. "_memoryCount", memoryDelta)

		local maxKey = nodeKind .. "_maxMs"

		if not perf[maxKey] or selfTime > perf[maxKey] then
			perf[maxKey] = selfTime
			perf[nodeKind .. "_maxNodeId"] = nodeId
		end
	end

	if elapsed >= SLOW_NODE_THRESHOLD_MS then
		perf.slowNodes = perf.slowNodes or {}

		table.insert(perf.slowNodes, {
			nodeId = nodeId,
			nodeKind = nodeKind or "Unknown",
			totalMs = elapsed,
			selfMs = selfTime,
			memoryKB = memoryDelta,
			timestamp = os.date("%H:%M:%S")
		})
	end

	if framePoolSize < 100 then
		framePoolSize = framePoolSize + 1
		framePool[framePoolSize] = frame
	end
end

function Performance.recordCommand(perf, commandName, milliseconds)
	if not Performance.isEnabled() or perf == nil then
		return
	end

	local ms = tonumber(milliseconds) or 0

	Performance.add(perf, "nodeCmdMs", "nodeCmdCount", ms)

	if not perf.slowestCommandMs or ms > perf.slowestCommandMs then
		perf.slowestCommandMs = ms
		perf.slowestCommandName = commandName
	end

	if ms >= SLOW_NODE_THRESHOLD_MS then
		perf.slowCommands = perf.slowCommands or {}

		table.insert(perf.slowCommands, {
			commandName = commandName,
			ms = ms,
			timestamp = os.date("%H:%M:%S")
		})
	end
end

function Performance.recordFinishNodeCleanup(perf, milliseconds, nodeId, nodeKind)
	if not Performance.isEnabled() or perf == nil then
		return
	end

	local ms = tonumber(milliseconds) or 0

	Performance.add(perf, "finishNodeCleanupMs", "finishNodeCleanupCount", ms)

	if perf.maxFinishNodeCleanupMs == nil or ms > perf.maxFinishNodeCleanupMs then
		perf.maxFinishNodeCleanupMs = ms
		perf.maxFinishNodeCleanupNodeId = nodeId
		perf.maxFinishNodeCleanupNodeKind = nodeKind
	end
end

local function getNodeTypeReport(perf, topN)
	topN = topN or 10

	local nodeTypes = {}

	for key, value in pairs(perf) do
		if type(key) == "string" and key:match("_ms$") then
			local nodeKind = key:sub(1, -4)
			local count = perf[nodeKind .. "_count"] or 0
			local memory = perf[nodeKind .. "_memory"] or 0
			local maxMs = perf[nodeKind .. "_maxMs"] or 0
			local maxNodeId = perf[nodeKind .. "_maxNodeId"] or "N/A"

			if count > 0 then
				table.insert(nodeTypes, {
					kind = nodeKind,
					totalMs = value,
					count = count,
					avgMs = value / count,
					maxMs = maxMs,
					maxNodeId = maxNodeId,
					memoryKB = memory,
					avgMemoryKB = memory / count
				})
			end
		end
	end

	table.sort(nodeTypes, function(a, b)
		return a.totalMs > b.totalMs
	end)

	local lines = {}

	for i = 1, math.min(topN, #nodeTypes) do
		local nt = nodeTypes[i]

		table.insert(lines, string.format("  %d. %s: 总计 %.3f ms | 次数 %d | 平均 %.3f ms | 最大 %.3f ms (节点 %s) | 内存 %.2f KB (平均 %.2f KB)", i, nt.kind, nt.totalMs, nt.count, nt.avgMs, nt.maxMs, tostring(nt.maxNodeId), nt.memoryKB, nt.avgMemoryKB))
	end

	return table.concat(lines, "\n")
end

local function getSlowNodesReport(perf, topN)
	topN = topN or 20

	local slowNodes = perf.slowNodes or {}

	if #slowNodes == 0 then
		return "  无慢节点"
	end

	table.sort(slowNodes, function(a, b)
		return a.totalMs > b.totalMs
	end)

	local lines = {}

	table.insert(lines, string.format("  共 %d 个节点超过 %d ms 阈值，Top %d：", #slowNodes, SLOW_NODE_THRESHOLD_MS, math.min(topN, #slowNodes)))

	for i = 1, math.min(topN, #slowNodes) do
		local node = slowNodes[i]

		table.insert(lines, string.format("  %d. [%s] 节点 %s | 类型 %s | 总计 %.3f ms | 自身 %.3f ms | 内存 %.2f KB", i, node.timestamp, tostring(node.nodeId), tostring(node.nodeKind or "Unknown"), node.totalMs, node.selfMs, node.memoryKB))
	end

	return table.concat(lines, "\n")
end

local function getSlowCommandsReport(perf, topN)
	topN = topN or 10

	local slowCommands = perf.slowCommands or {}

	if #slowCommands == 0 then
		return nil
	end

	table.sort(slowCommands, function(a, b)
		return a.ms > b.ms
	end)

	local lines = {}

	table.insert(lines, string.format("\n慢命令日志（超过 %d ms）：", SLOW_NODE_THRESHOLD_MS))

	for i = 1, math.min(topN, #slowCommands) do
		local cmd = slowCommands[i]

		table.insert(lines, string.format("  %d. [%s] %s | %.3f ms", i, cmd.timestamp, cmd.commandName, cmd.ms))
	end

	return table.concat(lines, "\n")
end

function Performance.printSummary(perf, dialogueId, resultCode, resultText)
	if not Performance.isEnabled() or perf == nil then
		return
	end

	local slowestCommand = "N/A"

	if perf.slowestCommandName then
		slowestCommand = string.format("%s (%.3f ms)", perf.slowestCommandName, perf.slowestCommandMs or 0)
	end

	local totalMemory = 0

	for key, value in pairs(perf) do
		if type(key) == "string" and key:match("_memory$") then
			totalMemory = totalMemory + value
		end
	end

	local slowNodesReport = getSlowNodesReport(perf)
	local slowCommandsReport = getSlowCommandsReport(perf)

	logger:info("%s", string.format("====================================\n" .. "对话图性能统计报告\n" .. "对话图 ID：%s\n" .. "执行结果：%s\n" .. "结果码：%s\n" .. "预加载资源耗时：%.3f ms\n" .. "数据加载耗时：%.3f ms\n" .. "Runtime 创建：%.3f ms\n" .. "启动阶段同步执行耗时：%.3f ms\n" .. "节点脚本首次加载：%.3f ms（%d 个）\n" .. "节点业务命令同步耗时：%.3f ms（%d 次）\n" .. "最慢节点业务命令：%s\n" .. "总内存分配：%.2f KB\n" .. "====================================\n" .. "节点类型同步执行耗时 Top 10（包含参数读取，不重复计算同步子流程）：\n%s\n" .. "====================================\n" .. "慢节点（单次总耗时超过 %d ms）：\n%s\n" .. "====================================%s\n", tostring(dialogueId), resultText, tostring(resultCode), perf.preloadMs or 0, perf.dataLoadMs or 0, perf.runtimeCreateMs or 0, perf.luaRuntimePlayMs or 0, perf.logicRequireMs or 0, perf.logicRequireCount or 0, perf.nodeCmdMs or 0, perf.nodeCmdCount or 0, slowestCommand, totalMemory, getNodeTypeReport(perf, 10), SLOW_NODE_THRESHOLD_MS, slowNodesReport, slowCommandsReport or ""))
end

function Performance.hasActiveNodes(perf)
	if not Performance.isEnabled() or perf == nil then
		return false
	end

	return perf.stack ~= nil and #perf.stack > 0
end

function Performance.getReport(dialogueId, resultCode, perf)
	if not Performance.isEnabled() or perf == nil then
		return ""
	end

	local resultText = resultCode == 0 and "成功" or "失败"
	local slowestCommand = "无"

	if perf.slowestCommandName then
		slowestCommand = string.format("%.3f ms，命令：%s", perf.slowestCommandMs or 0, tostring(perf.slowestCommandName))
	end

	local slowestFinishNode = "无"

	if perf.maxFinishNodeCleanupNodeKind ~= nil then
		slowestFinishNode = string.format("%.3f ms，节点：%s，类型：%s", perf.maxFinishNodeCleanupMs or 0, tostring(perf.maxFinishNodeCleanupNodeId), tostring(perf.maxFinishNodeCleanupNodeKind))
	end

	local totalMemory = 0

	for key, value in pairs(perf) do
		if type(key) == "string" and key:match("_memory$") then
			totalMemory = totalMemory + value
		end
	end

	local slowNodesReport = getSlowNodesReport(perf, 5)
	local slowCommandsReport = getSlowCommandsReport(perf, 5)

	return string.format("\n========== 对话图性能报告 ==========\n" .. "对话图 ID：%s\n" .. "运行结果：%s（返回码：%s）\n" .. "预加载总耗时：%.3f ms\n" .. "  ├─ 对话图数据加载：%.3f ms\n" .. "  └─ Runtime 创建：%.3f ms\n" .. "启动阶段同步执行耗时：%.3f ms\n" .. "节点脚本首次加载：%.3f ms（%d 个）\n" .. "节点业务命令同步耗时：%.3f ms（%d 次）\n" .. "最慢节点业务命令：%s\n" .. "结束阶段耗时：\n" .. "  ├─ Scheduler 清理：%.3f ms\n" .. "  ├─ BeginGraphFinish 回调：%.3f ms\n" .. "  ├─ 节点结束清理：%.3f ms（%d 次）\n" .. "  │  └─ 最慢节点清理：%s\n" .. "  ├─ CompleteGraphFinish 回调：%.3f ms\n" .. "  └─ 编辑器调试记录：%.3f ms\n" .. "总内存分配：%.2f KB\n" .. "节点类型同步执行耗时 Top 10：\n%s\n" .. "慢节点（单次总耗时超过 %d ms）：\n%s\n" .. "====================================%s\n", tostring(dialogueId), resultText, tostring(resultCode), perf.preloadMs or 0, perf.dataLoadMs or 0, perf.runtimeCreateMs or 0, perf.luaRuntimePlayMs or 0, perf.logicRequireMs or 0, perf.logicRequireCount or 0, perf.nodeCmdMs or 0, perf.nodeCmdCount or 0, slowestCommand, perf.finishSchedulerCleanupMs or 0, perf.finishBeginCallbackMs or 0, perf.finishNodeCleanupMs or 0, perf.finishNodeCleanupCount or 0, slowestFinishNode, perf.finishCompleteCallbackMs or 0, perf.finishRuntimeDebugMs or 0, totalMemory, getNodeTypeReport(perf, 10), SLOW_NODE_THRESHOLD_MS, slowNodesReport, slowCommandsReport or "")
end

return Performance
