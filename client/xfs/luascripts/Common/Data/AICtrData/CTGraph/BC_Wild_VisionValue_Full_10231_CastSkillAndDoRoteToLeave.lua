-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_VisionValue_Full_10231_CastSkillAndDoRoteToLeave.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _P = CTHelper.DoPatrolBehavior
local _A = CTHelper.DoAction

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "VisionValue_Full" then
		flow:setActive()
		_A(flow, "AddAITag", 0, "TA_VisionFull")
		flow:setActive()
		_A(flow, "RemoveAITag", 0, "TA_VisionAlert")
		flow:setActive()

		local _0 = _M._get_5_0(flow)

		_A(flow, "HideEmojiOnTarget", _0, "")

		return _M._to_7_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 3 then
		return true
	end

	if nodeId == 7 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_7_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_8_8(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(7)

		return true
	end
end

function _M._get_0_2(flow)
	return flow:getContextValue("sensorTgtId")
end

function _M._get_5_0(flow)
	return _C(5, "GetSelfId", flow)
end

function _M._get_8_8(flow)
	local _0 = _M._get_5_0(flow)

	return _C(8, "GetRouteIdFromEntity", flow, _0, -1, 0, 0, "", "", "", "")
end

return _M
