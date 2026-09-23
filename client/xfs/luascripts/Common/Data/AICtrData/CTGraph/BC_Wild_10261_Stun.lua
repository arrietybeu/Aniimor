-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10261_Stun.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeEventTrigger(flow, eventName)
	if eventName == "OnLandStateEnterTrigger" then
		return _M._to_83_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 83 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_83_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_91_2(flow)

	if _0 then
		flow:setActive()
		_C(83, "DoBehaviour", flow, "PBT_CastSkill")

		local _1 = _C(84, "GetSelfId", flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
		flow.__agent:addSubTreeLocalParam("tSkillId", 12610500)
		flow.__agent:addSubTreeLocalParam("tSkillTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 0)
		flow.__agent:addSubTreeLocalParam("tRaycastOpen", false)
		flow.__agent:addSubTreeLocalParam("tCastAbilitySource", 0)
		flow:setContinue(83)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_91_2(flow)
	local _0 = flow:getContextValue("height")

	return _0 >= 5
end

return _M
