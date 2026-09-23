-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10201_MiserBro_Security.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_127_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 129 then
		return true
	end

	if nodeId == 180 then
		return _M._to_129_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_127_0(flow)
	local _0 = _M._get_124_2(flow)

	if _0 then
		return _M._to_180_0(flow)
	end
end

function _M._to_129_0(flow)
	if not _B(flow, "PBT_ReadyToFight") then
		return
	end

	local _0 = _M._get_119_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tSensorTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tRandomWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tShowExclamation", false)
	flow:setContinue(129)

	return true
end

function _M._to_180_0(flow)
	if not _B(flow, "PBT_ShowQuestionMark") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tMarkType", "DirectFull")
	flow.__agent:addSubTreeLocalParam("tTimeout", 0.6)
	flow:setContinue(180)

	return true
end

function _M._get_119_1(flow)
	local _0 = _M._get_125_0(flow)

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

function _M._get_124_2(flow)
	local _3 = _M._get_125_0(flow)
	local _4 = not _3 or next(_3) == nil
	local _0 = not _4

	if not _0 then
		return false
	end

	local _5 = _M._get_119_1(flow)
	local _2 = _C(123, "GetPerceptibilityValue", flow, _5)
	local _1 = _2 >= 100

	if not _1 then
		return false
	end

	return true
end

function _M._get_125_0(flow)
	return _C(125, "GetPerceptibilityTable", flow)
end

return _M
