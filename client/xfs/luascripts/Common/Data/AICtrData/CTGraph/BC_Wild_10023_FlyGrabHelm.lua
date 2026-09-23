-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10023_FlyGrabHelm.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_131_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 115 then
		return true
	end

	if nodeId == 122 then
		return _M._to_115_0(flow)
	end

	if nodeId == 131 then
		return _M._to_122_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_115_0(flow)
	if not _B(flow, "PBT_Node_Com_FlyGrabEntity") then
		return
	end

	local _0 = _M._get_84_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow:setContinue(115)

	return true
end

function _M._to_122_0(flow)
	if not _B(flow, "PBT_FlyToTarget") then
		return
	end

	local _0 = _M._get_84_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tActorId", _0)
	flow.__agent:addSubTreeLocalParam("tStopDist", 4)
	flow.__agent:addSubTreeLocalParam("tHeight", 2)
	flow.__agent:addSubTreeLocalParam("tTimeout", 0)
	flow.__agent:addSubTreeLocalParam("tNotFaceToPos", false)
	flow.__agent:addSubTreeLocalParam("tMinHoldTime", 0)
	flow.__agent:addSubTreeLocalParam("tIgnoreVertical", false)
	flow.__agent:addSubTreeLocalParam("tIgnoreHorizontal", false)
	flow.__agent:addSubTreeLocalParam("tSpeed", 0)
	flow:setContinue(122)

	return true
end

function _M._to_131_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_128_2(flow)

	if _0 then
		flow:setActive()
		_C(131, "DoBehaviour", flow, "PBT_TurnToTargetAtYaw")

		local _1 = _M._get_84_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTgtId", _1)
		flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
		flow.__agent:addSubTreeLocalParam("tInstant", false)
		flow:setContinue(131)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_66_3(flow)
	local _0 = _M._get_136_2(flow)

	if not _0 then
		return false
	end

	local _5 = _M._get_76_2(flow)
	local _1 = _C(133, "CheckIsInRangeTgt2D", flow, _5, 0, 8, false, false)

	if not _1 then
		return false
	end

	local _3 = _M._get_76_2(flow)
	local _4 = _C(124, "CheckHasEntityTag", flow, _3, "TE_Wild_IsGrabbed")
	local _2 = not _4

	if not _2 then
		return false
	end

	return true
end

function _M._get_69_2(flow)
	local _0 = _M._get_76_2(flow)

	return _C(69, "GetPuppetData", flow, _0, "baseFormPet", true, 0)
end

function _M._get_76_3(flow)
	local _0 = _C(65, "GetAoiEntityTableByLevel", flow, 0, 30, 8)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(76, "__iterItem", v)

		if _M._get_66_3(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_76_2(flow)
	return flow:getCache(76, "__iterItem")
end

function _M._get_83_1(flow)
	local _0 = _M._get_76_3(flow)

	return _C(83, "SelectOneByRandom", flow, _0)
end

function _M._get_84_1(flow)
	local _0 = flow:getCache(84, "Puppet10021")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_83_1(flow)

	flow:setCache(84, "Puppet10021", _0)

	return _0
end

function _M._get_128_2(flow)
	local _4 = _C(125, "GetSelfId", flow)
	local _5 = _C(127, "CheckHasEntityTag", flow, _4, "TE_Wild_IsGrabbing")
	local _0 = not _5

	if not _0 then
		return false
	end

	local _2 = _M._get_76_3(flow)
	local _3 = not _2 or next(_2) == nil
	local _1 = not _3

	if not _1 then
		return false
	end

	return true
end

function _M._get_136_2(flow)
	local _2 = _M._get_69_2(flow)
	local _0 = _2 == 100210003

	if _0 then
		return true
	end

	local _3 = _M._get_69_2(flow)
	local _1 = _3 == 1002100

	if _1 then
		return true
	end

	return false
end

return _M
