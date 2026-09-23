-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Pet_10291_RemoveSorrowOfSelf.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_10_0(flow)
end

function _M.executeEndTrigger(flow)
	flow:setActive()
	_A(flow, "HideQuestionMark", 0)
	flow:setActive()

	local _0 = _C(15, "GetSelfId", flow)

	_A(flow, "HideEmojiOnTarget", _0, "")

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 1 then
		return _M._to_8_0(flow)
	end

	if nodeId == 8 then
		return true
	end

	if nodeId == 10 then
		return _M._to_11_0(flow)
	end

	if nodeId == 11 then
		return _M._to_1_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_1_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_4_0(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tSkillId", 12930900)
	flow.__agent:addSubTreeLocalParam("tSkillTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 0)
	flow.__agent:addSubTreeLocalParam("tRaycastOpen", false)
	flow.__agent:addSubTreeLocalParam("tCastAbilitySource", 0)
	flow:setContinue(1)

	return true
end

function _M._to_8_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Happy")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow:setContinue(8)

	return true
end

function _M._to_10_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_3_2(flow)

	if _0 then
		flow:setActive()
		_C(10, "DoBehaviour", flow, "PBT_ShowQuestionMark")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tMarkType", "DirectFull")
		flow.__agent:addSubTreeLocalParam("tTimeout", 0.5)
		flow:setContinue(10)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_11_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 1)
	flow:setContinue(11)

	return true
end

function _M._get_3_2(flow)
	local _1 = _M._get_4_0(flow)
	local _0 = _C(2, "GetTargetBuffLayerCount", flow, _1, 2129304)

	return _0 > 6
end

function _M._get_4_0(flow)
	return _C(4, "GetSelfId", flow)
end

return _M
