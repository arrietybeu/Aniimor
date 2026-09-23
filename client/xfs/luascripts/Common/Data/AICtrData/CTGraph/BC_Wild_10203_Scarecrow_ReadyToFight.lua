-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10203_Scarecrow_ReadyToFight.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_58_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 57 then
		return true
	end

	if nodeId == 58 then
		return _M._to_57_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_57_0(flow)
	if not _B(flow, "PBT_ReadyToFight") then
		return
	end

	local _0 = _M._get_52_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tSensorTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tRandomWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tShowExclamation", false)
	flow:setContinue(57)

	return true
end

function _M._to_58_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_47_2(flow)

	if _0 then
		flow:setActive()
		_C(58, "DoBehaviour", flow, "PBT_ShowQuestionMark")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tMarkType", "DirectFull")
		flow.__agent:addSubTreeLocalParam("tTimeout", 1)
		flow:setContinue(58)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_47_2(flow)
	local _2 = _M._get_50_0(flow)
	local _3 = not _2 or next(_2) == nil
	local _0 = not _3

	if not _0 then
		return false
	end

	local _4 = _M._get_52_1(flow)
	local _5 = _C(51, "GetPerceptibilityValue", flow, _4)
	local _1 = _5 >= 100

	if not _1 then
		return false
	end

	return true
end

function _M._get_50_0(flow)
	return _C(50, "GetPerceptibilityTable", flow)
end

function _M._get_52_1(flow)
	local _0 = _M._get_50_0(flow)

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
