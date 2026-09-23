-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_LevelMsg_CastSkill.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsg_CastSkill" then
		return _M._to_104_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 104 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_104_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = flow:getContextValue("WaitTime")
	local _1 = flow:getContextValue("SkillId")
	local _2 = flow:getContextValue("EmojiBubbleKey")
	local _3 = flow:getContextValue("EmojiBubbleTimeout")
	local _4 = flow:getContextValue("RaycastOpen")

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", _0)
	flow.__agent:addSubTreeLocalParam("tSkillId", _1)
	flow.__agent:addSubTreeLocalParam("tSkillTargetActorId", 0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", _2)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", _3)
	flow.__agent:addSubTreeLocalParam("tRaycastOpen", _4)
	flow.__agent:addSubTreeLocalParam("tCastAbilitySource", 0)
	flow:setContinue(104)

	return true
end

return _M
