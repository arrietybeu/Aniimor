-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphChangeDayNightNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphChangeDayNightNode = DialogueGraphFlowNode.extend("DialogueGraphChangeDayNightNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE

function DialogueGraphChangeDayNightNode.run(ctx)
	local timePeriod = ctx:getField("timePeriod", 0)
	local cloud = ctx:getInput("lightFunCloudShadowContrastVInput", -1)
	local changeType = ctx:getField("changeType", 0)
	local weather = ctx:getField("weather", 0)

	if changeType == nil or changeType < 0 then
		changeType = 0
	end

	ctx:stateSet("needResetTimePeriod", timePeriod > 0)
	ctx:stateSet("needCloudShadowContrast", changeType == 0 and cloud >= 0)
	ctx:stateSet("needResetWeather", changeType == 1)

	local param = {
		type = changeType,
		cloud = cloud,
		weather = weather + 1
	}

	ctx:callCmd(NodeFunc.TOD_CHANGE_WEATHER, timePeriod, param)
	ctx:triggerFlow("Out")
end

function DialogueGraphChangeDayNightNode.onGraphFinished(ctx)
	if ctx:stateGet("needResetTimePeriod", false) or ctx:stateGet("needCloudShadowContrast", false) or ctx:stateGet("needResetWeather", false) then
		ctx:callCmd(NodeFunc.TOD_RESET_WEATHER, ctx:stateGet("needResetTimePeriod", false), ctx:stateGet("needCloudShadowContrast", false), ctx:stateGet("needResetWeather", false))
	end
end

return DialogueGraphChangeDayNightNode
