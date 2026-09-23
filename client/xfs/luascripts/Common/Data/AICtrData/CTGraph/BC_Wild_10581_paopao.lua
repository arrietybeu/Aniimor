-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10581_paopao.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeTickLodTrigger(flow)
	return _M._to_11_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 11 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_11_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_6_1(flow)

	if _0 then
		flow:setActive()
		_C(11, "DoBehaviour", flow, "PBT_CastSkill")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
		flow.__agent:addSubTreeLocalParam("tSkillId", 15810910)
		flow.__agent:addSubTreeLocalParam("tSkillTargetActorId", 0)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tRaycastOpen", false)
		flow.__agent:addSubTreeLocalParam("tCastAbilitySource", 0)
		flow:setContinue(11)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_0_2(flow)
	return flow:getCache(0, "__iterItem")
end

function _M._get_0_3(flow)
	local _0 = _C(1, "GetAoiEntityTableByLevel", flow, 0, 10, 2)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(0, "__iterItem", v)

		if _M._get_13_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_6_1(flow)
	local _1 = _M._get_0_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_13_2(flow)
	local _3 = _M._get_0_2(flow)
	local _2 = _C(3, "GetDistance", flow, _3, 0, false)
	local _0 = _2 <= 5

	if not _0 then
		return false
	end

	local _1 = _C(12, "IsChildOfCharState", flow, 0, "LOCOMOTION")

	if not _1 then
		return false
	end

	return true
end

return _M
