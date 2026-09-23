-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10201_ExitMimicry_BossFight.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_30_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 30 then
		return _M._to_50_0(flow)
	end

	if nodeId == 50 then
		return _M._to_51_0(flow)
	end

	if nodeId == 51 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_30_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_54_1(flow)

	if _0 then
		flow:setActive()
		_C(30, "DoBehaviour", flow, "PBT_SwitchState")

		local _1 = "MIMICRYOUT"

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tCharacterState", _1)
		flow.__agent:addSubTreeLocalParam("tAnimationKey", "")
		flow:setContinue(30)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_50_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_27_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tSkillId", 12010230)
	flow.__agent:addSubTreeLocalParam("tSkillTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tRaycastOpen", false)
	flow.__agent:addSubTreeLocalParam("tCastAbilitySource", 0)
	flow:setContinue(50)

	return true
end

function _M._to_51_0(flow)
	if not _B(flow, "PBT_DestroySelf") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow:setContinue(51)

	return true
end

function _M._get_6_2(flow)
	return flow:getCache(6, "__iterItem")
end

function _M._get_6_3(flow)
	local _0 = _C(5, "GetAoiEntityTableByLevel", flow, 0, 10, 2)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(6, "__iterItem", v)

		if _M._get_9_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_9_2(flow)
	local _1 = _M._get_6_2(flow)
	local _0 = _C(8, "GetDistance", flow, _1, 0, false)

	return _0 <= 5
end

function _M._get_27_1(flow)
	local _0 = flow:getCache(27, "312")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_28_1(flow)

	flow:setCache(27, "312", _0)

	return _0
end

function _M._get_28_1(flow)
	local _0 = _M._get_6_3(flow)

	return _C(28, "SelectOneByRandom", flow, _0)
end

function _M._get_54_1(flow)
	local _1 = _M._get_6_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

return _M
