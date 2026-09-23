-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_VisionValue_AlertDoubt.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "VisionValue_AlertDoubt" then
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
	if not _B(flow, "PBT_AlertDoubt") then
		return
	end

	local _0 = _M._get_58_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tSensorTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tRandomWaitTime", 0)
	flow:setContinue(48)

	return true
end

function _M._get_15_0(flow)
	return _C(15, "GetPerceptibilityTable", flow)
end

function _M._get_17_2(flow)
	local _0 = _M._get_52_1(flow)

	return _C(17, "IsEntityType", flow, _0, "ACTOR_TYPE_PLAYER")
end

function _M._get_18_1(flow)
	local _0 = _M._get_52_1(flow)

	return _C(18, "GetPerceptibilityValue", flow, _0)
end

function _M._get_52_1(flow)
	local _0 = _M._get_15_0(flow)

	if _0 == nil then
		return
	end

	local key = next(_0)
	local value = _0[key]

	for k, v in pairs(_0) do
		if value < v then
			key, value = k, v
		end
	end

	return key
end

function _M._get_54_1(flow)
	local _1 = _M._get_15_0(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_55_2(flow)
	local _3 = _M._get_18_1(flow)
	local _0 = _3 > 5

	if not _0 then
		return false
	end

	local _2 = _M._get_18_1(flow)
	local _1 = _2 <= 80

	if not _1 then
		return false
	end

	return true
end

function _M._get_58_1(flow)
	local _0 = _C(59, "GetPerceptibilityTable", flow)

	if _0 == nil then
		return
	end

	local key = next(_0)
	local value = _0[key]

	for k, v in pairs(_0) do
		if value < v then
			key, value = k, v
		end
	end

	return key
end

return _M
