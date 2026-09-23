-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Pet_DefenceFollow.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeTickLodTrigger(flow)
	return _M._to_1_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 1 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_1_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_8_2(flow)

	if _0 then
		flow:setActive()
		_C(1, "DoBehaviour", flow, "PBT_Pet_DefenseFollow")
		flow.__agent:clearSubTreeLocalParams()
		flow:setContinue(1)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_8_2(flow)
	local _2 = _M._get_20_0(flow)
	local _0 = _C(19, "IsInBehavTag", flow, _2, "TB_RookGuard_DefenceMode")

	if not _0 then
		return false
	end

	local _3 = _M._get_20_0(flow)
	local _4 = _C(23, "GetPetMaster", flow, 0)
	local _5 = _C(21, "GetDistance", flow, _3, _4, false)
	local _1 = _5 > 5

	if not _1 then
		return false
	end

	return true
end

function _M._get_20_0(flow)
	return _C(20, "GetSelfId", flow)
end

return _M
