-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Pet_GuideWait.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_5_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 12 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_5_0(flow)
	local _2 = _M._get_0_3(flow)
	local _0 = _2 >= 20

	if _0 then
		flow:setActive()
		_A(flow, "ExitPetGuide", 0)

		return true
	end

	local _1 = _M._get_11_2(flow)

	if _1 then
		return _M._to_12_0(flow)
	end
end

function _M._to_12_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _C(13, "GetPetMaster", flow, 0)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
	flow.__agent:addSubTreeLocalParam("tInstant", false)
	flow:setContinue(12)

	return true
end

function _M._get_0_3(flow)
	local _0 = _C(2, "GetPetMaster", flow, 0)

	return _C(0, "GetDistance", flow, 0, _0, false)
end

function _M._get_11_2(flow)
	local _2 = _M._get_0_3(flow)
	local _0 = _2 >= 10

	if not _0 then
		return false
	end

	local _3 = _C(15, "GetSelfId", flow)
	local _1 = _C(17, "IsInBehavTag", flow, _3, "TB_Pet_Guiding")

	if not _1 then
		return false
	end

	return true
end

return _M
