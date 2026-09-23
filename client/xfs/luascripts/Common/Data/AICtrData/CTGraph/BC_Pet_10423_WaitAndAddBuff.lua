-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Pet_10423_WaitAndAddBuff.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7, value8)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tWaitTime", value0)
	agent:addSubTreeLocalParam("tAnimationKey", value1)
	agent:addSubTreeLocalParam("tAnimationTimeout", value2)
	agent:addSubTreeLocalParam("tEmojiBubbleKey", value3)
	agent:addSubTreeLocalParam("tEmojiBubbleTimeout", value4)
	agent:addSubTreeLocalParam("tTimelineTag", value5)
	agent:addSubTreeLocalParam("tNeedLoop", value6)
	agent:addSubTreeLocalParam("tAnimationPlayOnce", value7)
	agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", value8)
	flow:setContinue(nodeId)

	return true
end

function _M.executeTickLodTrigger(flow)
	return _M._to_17_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 17 then
		return _M._to_18_0(flow)
	end

	if nodeId == 18 then
		return _M._to_25_0(flow)
	end

	if nodeId == 20 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_17_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_16_2(flow)

	if _0 then
		flow:setActive()
		_C(17, "DoBehaviour", flow, "PBT_TurnToTargetAtYaw")

		local _1 = _M._get_14_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTgtId", _1)
		flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
		flow.__agent:addSubTreeLocalParam("tInstant", false)
		flow:setContinue(17)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_18_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 18, 0, "Behav_Angry", 7, "Angry", 5, "", false, true, false)
end

function _M._to_19_0(flow)
	flow:setActive()

	local _0 = _M._get_14_1(flow)

	_A(flow, "AddBuff", _0, 91163012, 3)
	flow:setActive()
	_A(flow, "SendMessageToTrigger", 0, 1042301)

	return true
end

function _M._to_20_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 20, 0, "Skill_Ghost", 3, "", 0, "", false, true, false)
end

function _M._to_24_0(flow)
	flow:setActive()

	local _0 = _C(26, "GetSelfId", flow)

	_A(flow, "PlayEffectOnTarget", _0, "Eff_Parmon_10423_Skill_Ghost01", 0)

	return true
end

function _M._to_25_0(flow)
	flow:addTimer(0.5, _M, "_to_24_0", flow)

	return _M._to_27_0(flow)
end

function _M._to_27_0(flow)
	flow:addTimer(1, _M, "_to_19_0", flow)

	return _M._to_20_0(flow)
end

function _M._get_14_1(flow)
	return _C(14, "GetPetMaster", flow, 0)
end

function _M._get_16_2(flow)
	local _4 = _M._get_14_1(flow)
	local _0 = _C(28, "IsInCharState", flow, _4, 1, 4)

	if not _0 then
		return false
	end

	local _3 = _M._get_14_1(flow)
	local _2 = _C(13, "GetAnimTagDuration", flow, _3)
	local _1 = _2 > 20

	if not _1 then
		return false
	end

	return true
end

return _M
