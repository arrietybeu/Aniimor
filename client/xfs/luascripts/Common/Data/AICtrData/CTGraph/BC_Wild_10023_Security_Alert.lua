-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10023_Security_Alert.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _B = CTHelper.BeginBehaviourV2

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "VisionValue_Alert" then
		return _M._to_1_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 1 then
		return _M._to_2_0(flow)
	end

	if nodeId == 2 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_1_0(flow)
	flow:setActive()

	local _0 = flow:getSubFlow("BCS_Common_VisionAlertTag")

	if _0:executeSubFlow() then
		flow:setContinue(1)

		if _0:isFinish() then
			return flow:executeContinue()
		end

		return true
	end
end

function _M._to_2_0(flow)
	if not _B(flow, "PBT_ShowQuestionMark") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tMarkType", "Normal")
	flow.__agent:addSubTreeLocalParam("tTimeout", 0)
	flow:setContinue(2)

	return true
end

return _M
