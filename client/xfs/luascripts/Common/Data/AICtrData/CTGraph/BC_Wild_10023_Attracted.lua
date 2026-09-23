-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10023_Attracted.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_58_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 58 then
		return _M._to_59_0(flow)
	end

	if nodeId == 59 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_58_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_64_1(flow)

	if _0 then
		flow:setActive()
		_C(58, "DoBehaviour", flow, "PBT_Com_Node_OnlyShowBubble")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Shy")
		flow.__agent:addSubTreeLocalParam("tTimeout", 2.5)
		flow:setContinue(58)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_59_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_62_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tStopDist", 2.5)
	flow.__agent:addSubTreeLocalParam("tMaxTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
	flow.__agent:addSubTreeLocalParam("tSpeed", 0)
	flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 2)
	flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 0)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
	flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
	flow:setContinue(59)

	return true
end

function _M._get_46_3(flow)
	local _0 = _C(45, "GetAoiEntityTableByLevel", flow, 0, 30, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(46, "__iterItem", v)

		if _M._get_49_3(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_46_2(flow)
	return flow:getCache(46, "__iterItem")
end

function _M._get_49_3(flow)
	local _3 = _M._get_46_2(flow)
	local _0 = _C(48, "HasEntityTag", flow, _3, "TE_Env_10023_Attraction")

	if not _0 then
		return false
	end

	local _4 = _M._get_46_2(flow)
	local _5 = _M._get_52_0(flow)
	local _6 = _C(50, "GetDistance", flow, _4, _5, false)
	local _1 = _6 <= 8

	if not _1 then
		return false
	end

	local _2 = _M._get_56_2(flow)

	if not _2 then
		return false
	end

	return true
end

function _M._get_52_0(flow)
	return _C(52, "GetSelfId", flow)
end

function _M._get_53_2(flow)
	local _0 = _M._get_46_2(flow)
	local _1 = _M._get_52_0(flow)

	return _C(53, "GetAngleByEntity", flow, _0, _1)
end

function _M._get_56_2(flow)
	local _3 = _M._get_53_2(flow)
	local _0 = _3 < 60

	if _0 then
		return true
	end

	local _2 = _M._get_53_2(flow)
	local _1 = _2 > 300

	if _1 then
		return true
	end

	return false
end

function _M._get_61_1(flow)
	local _0 = _M._get_46_3(flow)

	return _C(61, "SelectOneByRandom", flow, _0)
end

function _M._get_62_1(flow)
	local _0 = flow:getCache(62, "Attractions")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_61_1(flow)

	flow:setCache(62, "Attractions", _0)

	return _0
end

function _M._get_64_1(flow)
	local _1 = _M._get_46_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

return _M
