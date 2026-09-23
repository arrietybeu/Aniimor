-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BCS_Common_VisionFullTag.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _A = CTHelper.DoAction

function _M.executeSubFlow(flow)
	return _M._to_2_0(flow)
end

function _M._to_2_0(flow)
	flow:setActive()
	_A(flow, "AddAITag", 0, "TA_VisionFull")
	flow:setActive()
	_A(flow, "RemoveAITag", 0, "TA_VisionAlert")

	return true
end

return _M
