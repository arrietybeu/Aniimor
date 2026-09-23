-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10201_Jealousy.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7, value8, value9)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tTargetActorId", value0)
	agent:addSubTreeLocalParam("tStopDist", value1)
	agent:addSubTreeLocalParam("tMaxTimeout", value2)
	agent:addSubTreeLocalParam("tFaceTarget", value3)
	agent:addSubTreeLocalParam("tSpeed", value4)
	agent:addSubTreeLocalParam("tMoveUpdateLevel", value5)
	agent:addSubTreeLocalParam("tPathFindType", value6)
	agent:addSubTreeLocalParam("tSpeedRateType", value7)
	agent:addSubTreeLocalParam("tUseAccurateArrive", value8)
	agent:addSubTreeLocalParam("tNoBodySize", value9)
	flow:setContinue(nodeId)

	return true
end

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTriggerRunBarryRun" then
		return _M._to_176_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 155 then
		return _M._to_171_0(flow)
	end

	if nodeId == 171 then
		return true
	end

	if nodeId == 175 then
		return _M._to_155_0(flow)
	end

	if nodeId == 176 then
		return _M._to_175_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_155_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_163_2(flow)

	return _doBehaviourTail_0(flow, 155, _0, 1, 20, true, 7, 2, 0, 1, false, false)
end

function _M._to_171_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_166_2(flow)

	return _doBehaviourTail_0(flow, 171, _0, 1, 20, true, 7, 2, 0, 1, false, false)
end

function _M._to_175_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "Jump")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 2)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 2)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", true)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
	flow:setContinue(175)

	return true
end

function _M._to_176_0(flow)
	if not _B(flow, "PBT_ShowQuestionMark") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tMarkType", "DirectFull")
	flow.__agent:addSubTreeLocalParam("tTimeout", 1)
	flow:setContinue(176)

	return true
end

function _M._get_157_2(flow)
	return flow:getCache(157, "__iterItem")
end

function _M._get_157_3(flow)
	local _0 = _C(172, "GetAoiEntityTableByLevel", flow, 0, 50, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(157, "__iterItem", v)

		if _M._get_159_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_159_2(flow)
	local _0 = _M._get_157_2(flow)

	return _C(159, "HasEntityTag", flow, _0, "TE_Env_WayfindingPoint_D")
end

function _M._get_163_2(flow)
	local _0 = _M._get_157_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(163, "__iterItem", v)

		_1 = _M._get_164_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_164_3(flow)
	local _0 = flow:getCache(163, "__iterItem")

	return _C(164, "GetDistance", flow, _0, 0, false)
end

function _M._get_165_2(flow)
	return flow:getCache(165, "__iterItem")
end

function _M._get_165_3(flow)
	local _0 = _C(173, "GetAoiEntityTableByLevel", flow, 0, 50, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(165, "__iterItem", v)

		if _M._get_169_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_166_2(flow)
	local _0 = _M._get_165_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(166, "__iterItem", v)

		_1 = _M._get_167_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_167_3(flow)
	local _0 = flow:getCache(166, "__iterItem")

	return _C(167, "GetDistance", flow, _0, 0, false)
end

function _M._get_169_2(flow)
	local _0 = _M._get_165_2(flow)

	return _C(169, "HasEntityTag", flow, _0, "TE_Env_WayfindingPoint_C")
end

return _M
