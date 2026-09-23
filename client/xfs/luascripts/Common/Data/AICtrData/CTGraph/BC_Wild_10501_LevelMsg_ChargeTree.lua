-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10501_LevelMsg_ChargeTree.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTriggerChargeTree" then
		return _M._to_64_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 64 then
		return _M._to_65_0(flow)
	end

	if nodeId == 65 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_64_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_68_2(flow)

	if _0 then
		flow:setActive()
		_C(64, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_69_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("tStopDist", 4)
		flow.__agent:addSubTreeLocalParam("tMaxTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
		flow.__agent:addSubTreeLocalParam("tSpeed", 1)
		flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 99999)
		flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
		flow.__agent:addSubTreeLocalParam("tSpeedRateType", 0)
		flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
		flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
		flow:setContinue(64)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_65_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_69_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tSkillId", 10800351)
	flow.__agent:addSubTreeLocalParam("tSkillTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tRaycastOpen", false)
	flow.__agent:addSubTreeLocalParam("tCastAbilitySource", 0)
	flow:setContinue(65)

	return true
end

function _M._get_62_3(flow)
	local _0 = flow:getCache(67, "__iterItem")

	return _C(62, "GetDistance", flow, _0, 0, false)
end

function _M._get_66_2(flow)
	return flow:getCache(66, "__iterItem")
end

function _M._get_66_3(flow)
	local _0 = _C(61, "GetAoiEntityTableByLevel", flow, 0, 10, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(66, "__iterItem", v)

		if _M._get_73_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_67_2(flow)
	local _0 = _M._get_66_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(67, "__iterItem", v)

		_1 = _M._get_62_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_68_2(flow)
	local _3 = _M._get_66_3(flow)
	local _2 = not _3 or next(_3) == nil
	local _0 = not _2

	if not _0 then
		return false
	end

	local _4 = _M._get_69_1(flow)
	local _1 = _C(70, "CheckEntityExist", flow, _4)

	if not _1 then
		return false
	end

	return true
end

function _M._get_69_1(flow)
	local _0 = flow:getCache(69, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_67_2(flow)

	flow:setCache(69, "1", _0)

	return _0
end

function _M._get_73_2(flow)
	local _0 = _M._get_66_2(flow)

	return _C(73, "HasEntityTag", flow, _0, "TE_Env_BlastTree")
end

return _M
