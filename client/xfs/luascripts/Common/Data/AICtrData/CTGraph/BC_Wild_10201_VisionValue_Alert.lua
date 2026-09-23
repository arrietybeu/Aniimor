-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10201_VisionValue_Alert.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "VisionValue_Alert" then
		flow:setActive()
		_A(flow, "AddAITag", 0, "TA_VisionAlert")
		flow:setActive()

		local _0 = _C(64, "GetSelfId", flow)

		_A(flow, "HideEmojiOnTarget", _0, "")

		return _M._to_48_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 48 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_48_0(flow)
	if not _B(flow, "PBT_Vision_Alert_Quicker") then
		return
	end

	local _0 = flow:getContextValue("sensorTgtId")

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tSensorTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tRandomWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tRandomWaitTime2", 0)
	flow:setContinue(48)

	return true
end

return _M
