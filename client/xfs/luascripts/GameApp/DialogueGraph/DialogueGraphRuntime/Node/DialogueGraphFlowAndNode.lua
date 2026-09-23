-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphFlowAndNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphFlowAndNode = DialogueGraphFlowNode.extend("DialogueGraphFlowAndNode")
local Time = require("Core.Common.Time")

local function reset(ctx)
	ctx:stateSet("inCalls", {})
end

function DialogueGraphFlowAndNode.run(ctx)
	if ctx:inputPort() == "Reset" then
		reset(ctx)

		return
	end

	local portCount = ctx:getField("portCount", 2)
	local inputIndex = tonumber(ctx:inputPort())

	if inputIndex == nil or inputIndex < 0 or portCount <= inputIndex then
		return
	end

	local inCalls = ctx:stateGet("inCalls", {})
	local currentTime = Time.realtimeSinceStartup

	inCalls[inputIndex] = currentTime

	ctx:stateSet("inCalls", inCalls)

	local maxAwaitTime = tonumber(ctx:getField("maxAwaitTime", -1)) or -1

	for index = 0, portCount - 1 do
		local portId = tostring(index)

		if ctx:isFlowInputConnected(portId) then
			local callTime = inCalls[index]

			if callTime == nil then
				return
			end

			if maxAwaitTime > 0 and currentTime - callTime > math.abs(maxAwaitTime) then
				break
			end
		end
	end

	ctx:triggerFlow("Out")
end

return DialogueGraphFlowAndNode
