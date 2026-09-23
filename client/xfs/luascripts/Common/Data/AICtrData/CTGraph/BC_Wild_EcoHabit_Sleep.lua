-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_EcoHabit_Sleep.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

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

local function _doBehaviourTail_1(flow, nodeId, value0, value1, value2)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("sleepTimeOut", value0)
	agent:addSubTreeLocalParam("tShowEmojiBubble", value1)
	agent:addSubTreeLocalParam("tisLoop", value2)
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

	local _2 = _M._get_107_1(flow)
	local _3 = _M._get_107_2(flow)

	_A(flow, "ExitResPointPort", 0, _2, _3, 0, 1)

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 61 then
		return _M._to_119_0(flow)
	end

	if nodeId == 77 then
		return true
	end

	if nodeId == 81 then
		return true
	end

	if nodeId == 109 then
		return _M._to_120_0(flow)
	end

	if nodeId == 110 then
		return true
	end

	if nodeId == 119 then
		return true
	end

	if nodeId == 120 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 81 then
		return _M._get_91_1(flow)
	end

	if nodeId == 119 then
		return _M._get_91_1(flow)
	end

	if nodeId == 120 then
		return _M._get_91_1(flow)
	end
end

function _M._to_61_0(flow)
	if not _B(flow, "PBT_MoveToResPointPort") then
		return
	end

	local _0 = _M._get_66_1(flow)
	local _1 = _M._get_66_2(flow)

	return _doBehaviourTail_0(flow, 61, _0, _1, 10, 1, 0, false)
end

function _M._to_79_0(flow)
	local _0 = _M._get_117_2(flow)

	if _0 then
		flow:setActive()

		local _4 = _M._get_66_1(flow)
		local _5 = _M._get_66_2(flow)

		_A(flow, "PreJoinResPointPort", 0, _4, _5)

		return _M._to_61_0(flow)
	end

	local _2 = _M._get_92_3(flow)
	local _3 = not _2 or next(_2) == nil
	local _1 = not _3

	if _1 then
		flow:setActive()

		local _6 = _M._get_107_1(flow)
		local _7 = _M._get_107_2(flow)

		_A(flow, "PreJoinResPointPort", 0, _6, _7)

		return _M._to_109_0(flow)
	end

	return _M._to_81_0(flow)
end

function _M._to_81_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 81)

	if not _1 then
		flow:setActive()
		_C(81, "DoBehaviour", flow, "PBT_Sleep")

		return _doBehaviourTail_1(flow, 81, 30, false, false)
	else
		flow:setActiveFail()
	end
end

function _M._to_86_0(flow)
	local _1 = _C(83, "GetDayTime", flow)
	local _2 = _C(113, "GetSelfId", flow)
	local _3 = _C(85, "GetPuppetData", flow, _2, "sleepDayTime", true, 0)
	local _0 = _1 == _3

	if _0 then
		return _M._to_79_0(flow)
	end
end

function _M._to_109_0(flow)
	if not _B(flow, "PBT_MoveToResPointPort") then
		return
	end

	local _0 = _M._get_107_1(flow)
	local _1 = _M._get_107_2(flow)

	return _doBehaviourTail_0(flow, 109, _0, _1, 10, 1, 0, false)
end

function _M._to_119_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 119)

	if not _1 then
		flow:setActive()
		_C(119, "DoBehaviour", flow, "PBT_Sleep")

		return _doBehaviourTail_1(flow, 119, 30, false, false)
	else
		flow:setActiveFail()
	end
end

function _M._to_120_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 120)

	if not _1 then
		flow:setActive()
		_C(120, "DoBehaviour", flow, "PBT_Sleep")

		return _doBehaviourTail_1(flow, 120, 30, false, false)
	else
		flow:setActiveFail()
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

function _M._get_70_1(flow)
	local _0 = flow:getCache(70, "resPointPort2")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_94_2(flow)

	flow:setCache(70, "resPointPort2", _0)

	return _0
end

function _M._get_74_2(flow)
	local _1 = _M._get_92_2(flow)
	local _0 = _C(73, "GetDistanceFromEntityToResPointPort", flow, 0, _1)

	return _0 < 20
end

function _M._get_91_1(flow)
	local _1 = _C(89, "GetDayTime", flow)
	local _2 = _C(114, "GetSelfId", flow)
	local _3 = _C(88, "GetPuppetData", flow, _2, "sleepDayTime", true, 0)
	local _0 = _1 == _3

	return not _0
end

function _M._get_92_2(flow)
	return flow:getCache(92, "__iterItem")
end

function _M._get_92_3(flow)
	local _0 = _C(62, "GetAoiResPointPortTableByLevel", flow, 0, 30, 5, {
		"TR_Sleep"
	}, {
		"TR_Sleep"
	})
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(92, "__iterItem", v)

		if _M._get_74_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_94_2(flow)
	local _0 = _M._get_92_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(94, "__iterItem", v)

		_1 = _M._get_95_2(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_95_2(flow)
	local _0 = flow:getCache(94, "__iterItem")

	return _C(95, "GetDistanceFromEntityToResPointPort", flow, 0, _0)
end

function _M._get_96_4(flow)
	local _0 = _M._get_106_2(flow)
	local _1 = _M._get_106_2(flow)

	return _C(96, "GetAoiResPointPortTableByLevel", flow, 0, 30, 5, {
		_0
	}, {
		_1
	})
end

function _M._get_97_2(flow)
	return flow:getCache(97, "__iterItem")
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

function _M._get_106_2(flow)
	return _C(106, "GetPuppetData", flow, 0, "sleepRPTag", true, "")
end

function _M._get_107_2(flow)
	local _0 = _M._get_70_1(flow)

	return _C(107, "UnpackResPointPort", flow, _0, 2)
end

function _M._get_107_1(flow)
	local _0 = _M._get_70_1(flow)

	return _C(107, "UnpackResPointPort", flow, _0, 1)
end

function _M._get_117_2(flow)
	local _4 = _C(116, "GetPuppetData", flow, 0, "sleepRPTag", true, "")
	local _5 = _4 == ""
	local _0 = not _5

	if not _0 then
		return false
	end

	local _2 = _M._get_97_3(flow)
	local _3 = not _2 or next(_2) == nil
	local _1 = not _3

	if not _1 then
		return false
	end

	return true
end

return _M
