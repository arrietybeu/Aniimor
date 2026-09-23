-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_90207_Combat.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "Msg_AudioBar" then
		return _M._to_17_0(flow)
	end

	if eventName == "Msg_AudioBeat" then
		return _M._to_36_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 17 then
		return true
	end

	if nodeId == 36 then
		return _M._to_26_0(flow)
	end

	if nodeId == 41 then
		return _M._to_43_0(flow)
	end

	if nodeId == 43 then
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

	local _0 = _C(25, "HasAITag", flow, 0, "TA_90207_EnterCombat")

	if _0 then
		flow:setActive()
		_C(17, "DoBehaviour", flow, "ST_Monster_AutoCombat_Boss_90207_Music")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("disToTgtForSkillMon", 0)
		flow:setContinue(17)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_26_0(flow)
	flow:setActive()
	_A(flow, "AddAITag", 0, "TA_90207_EnterCombat")

	return _M._to_41_0(flow)
end

function _M._to_36_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_32_1(flow)

	if _0 then
		flow:setActive()
		_C(36, "DoBehaviour", flow, "ST_Monster_AutoCombat_Boss_90207_BornSkill")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tSkillId", 902070900)
		flow:setContinue(36)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_41_0(flow)
	if not _B(flow, "PBT_SetFullbodyIdle") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "Idle")
	flow:setContinue(41)

	return true
end

function _M._to_43_0(flow)
	if not _B(flow, "PBT_SetFullbodyIdle") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "")
	flow:setContinue(43)

	return true
end

function _M._get_32_1(flow)
	local _0 = _C(31, "HasAITag", flow, 0, "TA_90207_EnterCombat")

	return not _0
end

return _M
