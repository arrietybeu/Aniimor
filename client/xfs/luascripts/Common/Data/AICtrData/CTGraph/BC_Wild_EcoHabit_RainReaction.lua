-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_EcoHabit_RainReaction.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

local function _doBehaviourTail_0(flow, nodeId, value0, value1, value2, value3, value4, value5)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tPointId", value0)
	agent:addSubTreeLocalParam("tPortId", value1)
	agent:addSubTreeLocalParam("tTimeout", value2)
	agent:addSubTreeLocalParam("tSpeedRateType", value3)
	agent:addSubTreeLocalParam("tSpeed", value4)
	agent:addSubTreeLocalParam("tUseAccurateArrive", value5)
	flow:setContinue(nodeId)

	return true
end

function _M.executeTickLodTrigger(flow)
	return _M._to_86_0(flow)
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _M._get_66_1(flow)
	local _1 = _M._get_66_2(flow)

	_A(flow, "ExitResPointPort", 0, _0, _1, 0, 1)
	flow:setActive()

	local _2 = _M._get_151_1(flow)
	local _3 = _M._get_151_2(flow)

	_A(flow, "ExitResPointPort", 0, _2, _3, 0, 1)

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 61 then
		return _M._to_136_0(flow)
	end

	if nodeId == 77 then
		return true
	end

	if nodeId == 135 then
		return true
	end

	if nodeId == 153 then
		return _M._to_155_0(flow)
	end

	if nodeId == 154 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 61 then
		return _M._get_130_1(flow)
	end

	if nodeId == 77 then
		return _M._get_130_1(flow)
	end

	if nodeId == 135 then
		return _M._get_130_1(flow)
	end

	if nodeId == 153 then
		return _M._get_130_1(flow)
	end

	if nodeId == 154 then
		return _M._get_130_1(flow)
	end
end

function _M._to_61_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 61)

	if not _1 then
		flow:setActive()
		_C(61, "DoBehaviour", flow, "PBT_MoveToResPointPort")

		local _1 = _M._get_66_1(flow)
		local _2 = _M._get_66_2(flow)

		return _doBehaviourTail_0(flow, 61, _1, _2, 10, 1, 0, false)
	else
		flow:setActiveFail()
	end
end

function _M._to_77_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 77)

	if not _1 then
		flow:setActive()
		_C(77, "DoBehaviour", flow, "PBT_Com_Node_Wait")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tWaitTime", 9999)
		flow:setContinue(77)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_86_0(flow)
	local _0 = _M._get_131_2(flow)

	if _0 then
		return _M._to_132_0(flow)
	end
end

function _M._to_132_0(flow)
	local _3 = _M._get_116_2(flow)
	local _0 = _3 == "Happy"

	if _0 then
		flow:setActive()

		local _4 = _C(138, "GetPuppetData", flow, 0, "ArriveRainShelterDialogId", true, 0)

		_A(flow, "StartNpcDialog", _4, 0)

		return _M._to_135_0(flow)
	end

	local _2 = _M._get_116_2(flow)
	local _1 = _2 == "FindShelter"

	if _1 then
		return _M._to_158_0(flow)
	end
end

function _M._to_135_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 135)

	if not _1 then
		flow:setActive()
		_C(135, "DoBehaviour", flow, "PBT_Com_Happy_New")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 10)
		flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
		flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
		flow.__agent:addSubTreeLocalParam("tPlayOnce", false)
		flow:setContinue(135)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_136_0(flow)
	flow:setActive()

	local _0 = _C(139, "GetPuppetData", flow, 0, "ArriveRainShelterDialogId", true, 0)

	_A(flow, "StartNpcDialog", _0, 0)

	return _M._to_77_0(flow)
end

function _M._to_153_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 153)

	if not _1 then
		flow:setActive()
		_C(153, "DoBehaviour", flow, "PBT_MoveToResPointPort")

		local _1 = _M._get_151_1(flow)
		local _2 = _M._get_151_2(flow)

		return _doBehaviourTail_0(flow, 153, _1, _2, 10, 1, 0, false)
	else
		flow:setActiveFail()
	end
end

function _M._to_154_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 154)

	if not _1 then
		flow:setActive()
		_C(154, "DoBehaviour", flow, "PBT_Com_Node_Wait")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tWaitTime", 9999)
		flow:setContinue(154)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_155_0(flow)
	flow:setActive()

	local _0 = _C(156, "GetPuppetData", flow, 0, "ArriveRainShelterDialogId", true, 0)

	_A(flow, "StartNpcDialog", _0, 0)

	return _M._to_154_0(flow)
end

function _M._to_158_0(flow)
	local _2 = _M._get_97_3(flow)
	local _3 = not _2 or next(_2) == nil
	local _0 = not _3

	if _0 then
		flow:setActive()

		local _6 = _M._get_66_1(flow)
		local _7 = _M._get_66_2(flow)

		_A(flow, "PreJoinResPointPort", 0, _6, _7)
		flow:setActive()

		local _11 = _C(162, "GetPuppetData", flow, 0, "GotoRainShelterDialogId", true, 0)

		_A(flow, "StartNpcDialog", _11, 0)

		return _M._to_61_0(flow)
	end

	local _4 = _M._get_142_3(flow)
	local _5 = not _4 or next(_4) == nil
	local _1 = not _5

	if _1 then
		flow:setActive()

		local _8 = _M._get_151_1(flow)
		local _9 = _M._get_151_2(flow)

		_A(flow, "PreJoinResPointPort", 0, _8, _9)
		flow:setActive()

		local _10 = _C(160, "GetPuppetData", flow, 0, "GotoRainShelterDialogId", true, 0)

		_A(flow, "StartNpcDialog", _10, 0)

		return _M._to_153_0(flow)
	end
end

function _M._get_66_1(flow)
	local _0 = _M._get_103_1(flow)

	return _C(66, "UnpackResPointPort", flow, _0, 1)
end

function _M._get_66_2(flow)
	local _0 = _M._get_103_1(flow)

	return _C(66, "UnpackResPointPort", flow, _0, 2)
end

function _M._get_96_4(flow)
	local _0 = _M._get_134_2(flow)
	local _1 = _M._get_134_2(flow)

	return _C(96, "GetAoiResPointPortTableByLevel", flow, 0, 30, 5, {
		_0
	}, {
		_1
	})
end

function _M._get_97_3(flow)
	local _0 = _M._get_96_4(flow)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(97, "__iterItem", v)

		if _M._get_98_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_97_2(flow)
	return flow:getCache(97, "__iterItem")
end

function _M._get_98_2(flow)
	local _1 = _M._get_97_2(flow)
	local _0 = _C(101, "GetDistanceFromEntityToResPointPort", flow, 0, _1)

	return _0 < 20
end

function _M._get_100_2(flow)
	local _0 = _M._get_97_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(100, "__iterItem", v)

		_1 = _M._get_102_2(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_102_2(flow)
	local _0 = flow:getCache(100, "__iterItem")

	return _C(102, "GetDistanceFromEntityToResPointPort", flow, 0, _0)
end

function _M._get_103_1(flow)
	local _0 = flow:getCache(103, "resPointPort1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_100_2(flow)

	flow:setCache(103, "resPointPort1", _0)

	return _0
end

function _M._get_116_2(flow)
	return _C(116, "GetPuppetData", flow, 0, "reactionRainBehav", true, "")
end

function _M._get_123_1(flow)
	local _0 = _C(113, "GetSelfId", flow)

	return _C(123, "GetCurWeatherId", flow, _0)
end

function _M._get_130_1(flow)
	local _0 = _M._get_131_2(flow)

	return not _0
end

function _M._get_131_2(flow)
	local _2 = _M._get_123_1(flow)
	local _0 = _2 == 2

	if _0 then
		return true
	end

	local _3 = _M._get_123_1(flow)
	local _1 = _3 == 4

	if _1 then
		return true
	end

	return false
end

function _M._get_134_2(flow)
	return _C(134, "GetPuppetData", flow, 0, "reactionRainPRTag", true, "TR_RainShelter")
end

function _M._get_142_3(flow)
	local _0 = _C(141, "GetAoiResPointPortTableByLevel", flow, 0, 30, 5, {
		"TR_RainShelter"
	}, {
		"TR_RainShelter"
	})
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(142, "__iterItem", v)

		if _M._get_143_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_142_2(flow)
	return flow:getCache(142, "__iterItem")
end

function _M._get_143_2(flow)
	local _1 = _M._get_142_2(flow)
	local _0 = _C(146, "GetDistanceFromEntityToResPointPort", flow, 0, _1)

	return _0 < 20
end

function _M._get_145_2(flow)
	local _0 = _M._get_142_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(145, "__iterItem", v)

		_1 = _M._get_147_2(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_147_2(flow)
	local _0 = flow:getCache(145, "__iterItem")

	return _C(147, "GetDistanceFromEntityToResPointPort", flow, 0, _0)
end

function _M._get_148_1(flow)
	local _0 = flow:getCache(148, "resPointPort2")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_145_2(flow)

	flow:setCache(148, "resPointPort2", _0)

	return _0
end

function _M._get_151_2(flow)
	local _0 = _M._get_148_1(flow)

	return _C(151, "UnpackResPointPort", flow, _0, 2)
end

function _M._get_151_1(flow)
	local _0 = _M._get_148_1(flow)

	return _C(151, "UnpackResPointPort", flow, _0, 1)
end

return _M
