-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10031_FlashAttack.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1, value2, value3, value4, value5, value6)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tWaitTime", value0)
	agent:addSubTreeLocalParam("tSkillId", value1)
	agent:addSubTreeLocalParam("tSkillTargetActorId", value2)
	agent:addSubTreeLocalParam("tEmojiBubbleKey", value3)
	agent:addSubTreeLocalParam("tEmojiBubbleTimeout", value4)
	agent:addSubTreeLocalParam("tRaycastOpen", value5)
	agent:addSubTreeLocalParam("tCastAbilitySource", value6)
	flow:setContinue(nodeId)

	return true
end

function _M.executeTickLodTrigger(flow)
	return _M._to_23_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 23 then
		return _M._to_24_0(flow)
	end

	if nodeId == 24 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_23_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_19_2(flow)

	if _0 then
		flow:setActive()
		_C(23, "DoBehaviour", flow, "PBT_CastSkill")

		return _doBehaviourTail_0(flow, 23, 0, 10310900, 0, "", 5, false, 0)
	else
		flow:setActiveFail()
	end
end

function _M._to_24_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	return _doBehaviourTail_0(flow, 24, 0, 10310500, 0, "", 5, false, 0)
end

function _M._get_19_2(flow)
	local _0 = _C(18, "GetAoiEntityTableByLevel", flow, 0, 10, 2)

	if _0 == nil then
		return
	end

	for k, v in ipairs(_0) do
		local _1 = pg.getEntityByActorId(v)

		flow:setCache(19, "__iterItem", _1 and _1.actorId or 0)

		if _M._get_21_2(flow) then
			return true
		end
	end

	return false
end

function _M._get_21_2(flow)
	local _1 = flow:getCache(19, "__iterItem")
	local _0 = _C(20, "GetDistance", flow, _1, 0, false)

	return _0 <= 0
end

return _M
