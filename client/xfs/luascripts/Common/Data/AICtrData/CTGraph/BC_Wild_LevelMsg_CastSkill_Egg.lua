-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_LevelMsg_CastSkill_Egg.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
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
	local _2 = _M._get_139_1(flow)
	local _3 = flow:getContextValue("EmojiBubbleKey")
	local _4 = flow:getContextValue("EmojiBubbleTimeout")
	local _5 = flow:getContextValue("RaycastOpen")

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", _0)
	flow.__agent:addSubTreeLocalParam("tSkillId", _1)
	flow.__agent:addSubTreeLocalParam("tSkillTargetActorId", _2)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", _3)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", _4)
	flow.__agent:addSubTreeLocalParam("tRaycastOpen", _5)
	flow.__agent:addSubTreeLocalParam("tCastAbilitySource", 0)
	flow:setContinue(104)

	return true
end

function _M._get_135_2(flow)
	return flow:getCache(135, "__iterItem")
end

function _M._get_135_3(flow)
	local _0 = _C(134, "GetAoiEntityTableByLevel", flow, 0, 30, 2)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(135, "__iterItem", v)

		if _M._get_138_1(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_138_1(flow)
	local _0 = _M._get_135_2(flow)

	return _C(138, "CheckHasEntityTag", flow, _0, "TE_Wild_Hypnosis")
end

function _M._get_139_1(flow)
	local _0 = _M._get_135_3(flow)

	if _0 == nil then
		return
	end

	local key = 1
	local value = _0[1]

	for k, v in ipairs(_0) do
		if value < v then
			key, value = k, v
		end
	end

	return value
end

return _M
