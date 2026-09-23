-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_GrabEggs_LevelMsg_CastSkill_10260400.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTrigger10260400" then
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
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_143_1(flow)

	if _0 then
		flow:setActive()
		_C(104, "DoBehaviour", flow, "PBT_CastSkill")

		local _1 = _M._get_140_2(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
		flow.__agent:addSubTreeLocalParam("tSkillId", 10260400)
		flow.__agent:addSubTreeLocalParam("tSkillTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tRaycastOpen", false)
		flow.__agent:addSubTreeLocalParam("tCastAbilitySource", 0)
		flow:setContinue(104)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_136_3(flow)
	local _0 = _C(135, "GetAoiEntityTableByLevel", flow, 0, 10, 2)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(136, "__iterItem", v)

		_1[#_1 + 1] = v
	end

	return _1
end

function _M._get_140_2(flow)
	local _0 = _M._get_136_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(140, "__iterItem", v)

		_1 = _M._get_141_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_141_3(flow)
	local _0 = flow:getCache(140, "__iterItem")

	return _C(141, "GetDistance", flow, _0, 0, false)
end

function _M._get_143_1(flow)
	local _1 = _M._get_136_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

return _M
