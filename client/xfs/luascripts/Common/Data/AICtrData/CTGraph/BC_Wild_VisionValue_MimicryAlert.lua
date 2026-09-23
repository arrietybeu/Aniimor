-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_VisionValue_MimicryAlert.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _A = CTHelper.DoAction

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "VisionValue_Alert" then
		flow:setActive()
		_A(flow, "AddAITag", 0, "TA_VisionAlert")
		flow:setActive()
		_A(flow, "ShowQuestionMark", 0, "")

		return true
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()
	_A(flow, "RemoveAITag", 0, "TA_VisionAlert")

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 68 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

return _M
