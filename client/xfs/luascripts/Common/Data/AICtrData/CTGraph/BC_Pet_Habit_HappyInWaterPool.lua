-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Pet_Habit_HappyInWaterPool.lua

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
	return _M._to_283_0(flow)
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _M._get_153_0(flow)
	local _1 = _M._get_146_1(flow)
	local _2 = _M._get_146_2(flow)

	_A(flow, "ExitResPointPort", _0, _1, _2, 0, 0)

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 142 then
		return _M._to_152_0(flow)
	end

	if nodeId == 151 then
		return _M._to_259_0(flow)
	end

	if nodeId == 259 then
		return _M._to_260_0(flow)
	end

	if nodeId == 260 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_142_0(flow)
	if not _B(flow, "PBT_MoveToResPointPort") then
		return
	end

	local _0 = _M._get_146_1(flow)
	local _1 = _M._get_146_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tPointId", _0)
	flow.__agent:addSubTreeLocalParam("tPortId", _1)
	flow.__agent:addSubTreeLocalParam("tTimeout", 15)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 0)
	flow.__agent:addSubTreeLocalParam("tSpeed", 2.5)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
	flow:setContinue(142)

	return true
end

function _M._to_151_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 151, 0, "Behav_Happy", 0, "Happy", 4, "", false, false, false)
end

function _M._to_152_0(flow)
	flow:setActive()

	local _0 = _M._get_153_0(flow)
	local _1 = _M._get_146_1(flow)
	local _2 = _M._get_146_2(flow)

	_A(flow, "JoinResPointPort", _0, _1, _2)
	flow:setActive()
	_A(flow, "PlayEmojiOnTarget", 0, "Happy", 1)

	return _M._to_151_0(flow)
end

function _M._to_259_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 259, 1, "Env_AcceptLove", 0, "Happy", 4, "", false, false, false)
end

function _M._to_260_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 260, 0, "Behav_Happy", 3, "Happy", 4, "", false, false, false)
end

function _M._to_283_0(flow)
	local _3 = _M._get_234_1(flow)
	local _4 = not _3 or next(_3) == nil
	local _0 = not _4

	if _0 then
		flow:setActive()

		local _1 = _M._get_146_1(flow)
		local _2 = _M._get_146_2(flow)

		_A(flow, "PreJoinResPointPort", 0, _1, _2)

		return _M._to_142_0(flow)
	else
		flow:setActiveFail()
	end
end

function _M._get_144_5(flow)
	local _0 = _C(150, "GetSelfId", flow)

	return _C(144, "GetAoiResPointPortTableByLevel", flow, _0, 30, 0, {
		"TR_PlayInWater"
	}, {
		"TR_PlayInWater",
		"TR_PlayInWater"
	})
end

function _M._get_146_2(flow)
	local _0 = _M._get_235_1(flow)

	return _C(146, "UnpackResPointPort", flow, _0, 2)
end

function _M._get_146_1(flow)
	local _0 = _M._get_235_1(flow)

	return _C(146, "UnpackResPointPort", flow, _0, 1)
end

function _M._get_147_1(flow)
	local _0 = flow:getCache(147, "resPointPortList")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_144_5(flow)

	flow:setCache(147, "resPointPortList", _0)

	return _0
end

function _M._get_148_1(flow)
	local _0 = _M._get_147_1(flow)

	return not _0 or next(_0) == nil
end

function _M._get_153_0(flow)
	return _C(153, "GetSelfId", flow)
end

function _M._get_183_2(flow)
	local _0 = flow:getCache(185, "__iterItem")

	return _C(183, "GetDistanceFromEntityToResPointPort", flow, 0, _0)
end

function _M._get_185_2(flow)
	local _0 = _M._get_147_1(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(185, "__iterItem", v)

		_1 = _M._get_183_2(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_190_1(flow)
	local _0 = _M._get_194_1(flow)

	return _C(190, "SelectOneByRandom", flow, _0)
end

function _M._get_194_1(flow)
	local _0 = flow:getCache(194, "resPointPortList")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_198_4(flow)

	flow:setCache(194, "resPointPortList", _0)

	return _0
end

function _M._get_195_1(flow)
	local _0 = _M._get_194_1(flow)

	return not _0 or next(_0) == nil
end

function _M._get_198_4(flow)
	local _0 = _C(197, "GetSelfId", flow)

	return _C(198, "GetAoiResPointPortTableByLevel", flow, _0, 30, 0, {
		"Water_Point_1"
	}, {
		"Water_Port_1"
	})
end

function _M._get_234_1(flow)
	local _0 = flow:getCache(234, "resPointPortList")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_241_2(flow)

	flow:setCache(234, "resPointPortList", _0)

	return _0
end

function _M._get_235_1(flow)
	local _0 = flow:getCache(235, "resPointPort")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_240_2(flow)

	flow:setCache(235, "resPointPort", _0)

	return _0
end

function _M._get_239_2(flow)
	local _0 = flow:getCache(240, "__iterItem")

	return _C(239, "GetDistanceFromEntityToResPointPort", flow, 0, _0)
end

function _M._get_240_2(flow)
	local _0 = _M._get_234_1(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(240, "__iterItem", v)

		_1 = _M._get_239_2(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_241_2(flow)
	local _2 = _C(238, "GetSelfId", flow)
	local _0 = _C(236, "GetAoiResPointPortTableByLevel", flow, _2, 30, 0, {
		"TR_ShoelWater"
	}, {
		"TR_ShoelWater"
	})

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		flow:setCache(241, "__iterItem", v)

		if _M._get_243_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_243_2(flow)
	local _3 = _C(281, "GetAoiEntityTableByLevel", flow, 0, 30, 2)
	local _1 = _C(282, "SelectOneByRandom", flow, _3)
	local _2 = flow:getCache(241, "__iterItem")
	local _0 = _C(242, "GetDistanceFromEntityToResPointPort", flow, _1, _2)

	return _0 <= 12
end

return _M
