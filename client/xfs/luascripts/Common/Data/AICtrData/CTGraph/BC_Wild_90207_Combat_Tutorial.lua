-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_90207_Combat_Tutorial.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "Msg_AudioBar" then
		return _M._to_40_0(flow)
	end

	if eventName == "Msg_AudioBeat" then
		return _M._to_47_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 40 then
		return true
	end

	if nodeId == 47 then
		return _M._to_43_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_40_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _C(42, "HasAITag", flow, 0, "TA_90207_EnterCombat")

	if _0 then
		flow:setActive()
		_C(40, "DoBehaviour", flow, "ST_Monster_AutoCombat_Boss_90207_Tutorial")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("disToTgtForSkillMon", 0)
		flow:setContinue(40)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_43_0(flow)
	flow:setActive()
	_A(flow, "AddAITag", 0, "TA_90207_EnterCombat")

	return true
end

function _M._to_47_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_45_1(flow)

	if _0 then
		flow:setActive()
		_C(47, "DoBehaviour", flow, "ST_Monster_AutoCombat_Boss_90207_BornSkill")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tSkillId", 902070901)
		flow:setContinue(47)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_45_1(flow)
	local _0 = _C(46, "HasAITag", flow, 0, "TA_90207_EnterCombat")

	return not _0
end

return _M
