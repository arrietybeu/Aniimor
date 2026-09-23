-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_GrabEggs_Guard_AlertCheck.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeTickLodTrigger(flow)
	return _M._to_207_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 207 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_207_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_206_2(flow)

	if _0 then
		flow:setActive()
		_C(207, "DoBehaviour", flow, "PBT_Wild_GrabEggs_Guard_AlertCheck")

		local _1 = _M._get_48_1(flow)
		local _2 = _M._get_208_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tSensorTgtId", _1)
		flow.__agent:addSubTreeLocalParam("tSensorTgtPos", _2)
		flow:setContinue(207)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_48_1(flow)
	local _0 = _C(15, "GetPerceptibilityTable", flow)

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

function _M._get_206_2(flow)
	local _1 = _M._get_48_1(flow)
	local _0 = _C(18, "GetPerceptibilityValue", flow, _1)

	return _0 >= 50
end

function _M._get_208_1(flow)
	local _0 = _M._get_48_1(flow)

	return _C(208, "GetEntPosition", flow, _0)
end

return _M
