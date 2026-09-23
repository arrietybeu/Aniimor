-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Pet_Habit_DrinkAtWaterPoint.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_262_0(flow)
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

	if nodeId == 216 then
		return true
	end

	if nodeId == 252 then
		return _M._to_216_0(flow)
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

function _M._to_152_0(flow)
	flow:setActive()

	local _0 = _M._get_153_0(flow)
	local _1 = _M._get_146_1(flow)
	local _2 = _M._get_146_2(flow)

	_A(flow, "JoinResPointPort", _0, _1, _2)

	return _M._to_252_0(flow)
end

function _M._to_216_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationStartKey", "Env_Drink_Start")
	flow.__agent:addSubTreeLocalParam("tAnimationLoopKey", "Env_Drink_Loop")
	flow.__agent:addSubTreeLocalParam("tAnimationEndKey", "Env_Drink_End")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 8)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow:setContinue(216)

	return true
end

function _M._to_252_0(flow)
	if not _B(flow, "PBT_TurnToTargetPos") then
		return
	end

	local _0 = _M._get_251_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
	flow.__agent:addSubTreeLocalParam("tTargetPos", _0)
	flow:setContinue(252)

	return true
end

function _M._to_262_0(flow)
	local _4 = _M._get_241_1(flow)
	local _3 = not _4 or next(_4) == nil
	local _0 = not _3

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

function _M._get_144_4(flow)
	local _0 = _C(150, "GetSelfId", flow)

	return _C(144, "GetAoiResPointPortTableByLevel", flow, _0, 30, 0, {
		"TR_DrinkBesideWater"
	}, {
		"TR_DrinkBesideWater"
	})
end

function _M._get_146_2(flow)
	local _0 = _M._get_240_1(flow)

	return _C(146, "UnpackResPointPort", flow, _0, 2)
end

function _M._get_146_1(flow)
	local _0 = _M._get_240_1(flow)

	return _C(146, "UnpackResPointPort", flow, _0, 1)
end

function _M._get_147_1(flow)
	local _0 = flow:getCache(147, "resPointPortList")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_144_4(flow)

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

function _M._get_217_1(flow)
	local _0 = _M._get_219_1(flow)

	return _C(217, "SelectOneByRandom", flow, _0)
end

function _M._get_219_1(flow)
	local _0 = flow:getCache(219, "resPointPortList")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_224_4(flow)

	flow:setCache(219, "resPointPortList", _0)

	return _0
end

function _M._get_220_1(flow)
	local _0 = _M._get_219_1(flow)

	return not _0 or next(_0) == nil
end

function _M._get_224_4(flow)
	local _0 = _C(222, "GetSelfId", flow)

	return _C(224, "GetAoiResPointPortTableByLevel", flow, _0, 30, 0, {
		"TR_DrinkBesideWater"
	}, {
		"TR_DrinkBesideWater"
	})
end

function _M._get_235_2(flow)
	local _0 = _M._get_241_1(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(235, "__iterItem", v)

		_1 = _M._get_236_2(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_236_2(flow)
	local _0 = flow:getCache(235, "__iterItem")

	return _C(236, "GetDistanceFromEntityToResPointPort", flow, 0, _0)
end

function _M._get_240_1(flow)
	local _0 = flow:getCache(240, "resPointPort")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_235_2(flow)

	flow:setCache(240, "resPointPort", _0)

	return _0
end

function _M._get_241_1(flow)
	local _0 = flow:getCache(241, "resPointPortList")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_243_2(flow)

	flow:setCache(241, "resPointPortList", _0)

	return _0
end

function _M._get_243_2(flow)
	local _2 = _C(237, "GetSelfId", flow)
	local _0 = _C(246, "GetAoiResPointPortTableByLevel", flow, _2, 30, 0, {
		"TR_DrinkPoint"
	}, {
		"TR_DrinkPoint"
	})

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		flow:setCache(243, "__iterItem", v)

		if _M._get_245_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_245_2(flow)
	local _3 = _C(258, "GetAoiEntityTableByLevel", flow, 0, 30, 2)
	local _1 = _C(259, "SelectOneByRandom", flow, _3)
	local _2 = flow:getCache(243, "__iterItem")
	local _0 = _C(244, "GetDistanceFromEntityToResPointPort", flow, _1, _2)

	return _0 <= 12
end

function _M._get_251_2(flow)
	local _0 = _M._get_146_1(flow)
	local _1 = _M._get_146_2(flow)

	return _C(251, "GetResPointPortPosition", flow, _0, _1)
end

return _M
