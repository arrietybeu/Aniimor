-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10381_shankefish_Eat_Run.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_14_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 58 then
		return _M._to_115_0(flow)
	end

	if nodeId == 107 then
		return _M._to_114_0(flow)
	end

	if nodeId == 114 then
		return true
	end

	if nodeId == 115 then
		return _M._to_107_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_14_0(flow)
	local _1 = _M._get_24_3(flow)
	local _2 = not _1 or next(_1) == nil
	local _0 = not _2

	if _0 then
		return _M._to_58_0(flow)
	end
end

function _M._to_58_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Surprise")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 1)
	flow:setContinue(58)

	return true
end

function _M._to_107_0(flow)
	if not _B(flow, "PBT_LeaveTarget") then
		return
	end

	local _0 = _M._get_109_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tLeaveDistance", 30)
	flow.__agent:addSubTreeLocalParam("tSpeed", 5)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
	flow.__agent:addSubTreeLocalParam("tMaxTime", 5)
	flow:setContinue(107)

	return true
end

function _M._to_114_0(flow)
	if not _B(flow, "PBT_Behav_Com_MimicryIn") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow:setContinue(114)

	return true
end

function _M._to_115_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_109_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
	flow.__agent:addSubTreeLocalParam("tInstant", false)
	flow:setContinue(115)

	return true
end

function _M._get_24_3(flow)
	local _0 = _C(32, "GetAoiEntityTableByLevel", flow, 0, 30, 8)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(24, "__iterItem", v)

		if _M._get_113_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_24_2(flow)
	return flow:getCache(24, "__iterItem")
end

function _M._get_108_1(flow)
	local _0 = _M._get_24_3(flow)

	return _C(108, "SelectOneByRandom", flow, _0)
end

function _M._get_109_1(flow)
	local _0 = flow:getCache(109, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_108_1(flow)

	flow:setCache(109, "1", _0)

	return _0
end

function _M._get_113_2(flow)
	local _2 = _M._get_24_2(flow)
	local _3 = _C(66, "GetPuppetData", flow, _2, "petPrototypeId", true, 0)
	local _0 = _3 == 1042100

	if not _0 then
		return false
	end

	local _4 = _M._get_24_2(flow)
	local _5 = _C(110, "GetDistance", flow, _4, 0, false)
	local _1 = _5 < 2

	if not _1 then
		return false
	end

	return true
end

return _M
