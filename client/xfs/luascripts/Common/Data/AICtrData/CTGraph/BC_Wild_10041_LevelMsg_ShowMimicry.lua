-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10041_LevelMsg_ShowMimicry.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _P = CTHelper.DoPatrolBehavior
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTriggerStartShow" then
		return _M._to_109_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 84 then
		return true
	end

	if nodeId == 85 then
		return _M._to_111_0(flow)
	end

	if nodeId == 96 then
		return _M._to_85_0(flow)
	end

	if nodeId == 109 then
		return _M._to_96_0(flow)
	end

	if nodeId == 110 then
		return _M._to_114_0(flow)
	end

	if nodeId == 111 then
		return true
	end

	if nodeId == 113 then
		return _M._to_110_0(flow)
	end

	if nodeId == 114 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_85_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_108_1(flow)

	if _0 then
		flow:setActive()
		_C(85, "DoBehaviour", flow, "PBT_Node_Com_LookAtEntity")

		local _1 = _M._get_106_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetStaticId", _1)
		flow.__agent:addSubTreeLocalParam("tForce", false)
		flow:setContinue(85)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_96_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_87_1(flow)

	if _0 then
		flow:setActive()

		local _1 = _M._get_95_1(flow)

		if _P(flow, 1, _1, 1, nil) then
			flow:setContinue(96)

			return true
		end
	else
		flow:setActiveFail()
	end
end

function _M._to_109_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Surprise")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow:setContinue(109)

	return true
end

function _M._to_110_0(flow)
	if not _B(flow, "PBT_Node_Com_CancelLookAtEntity") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow:setContinue(110)

	return true
end

function _M._to_111_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Happy")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tAnimationStartKey", "EnvBehav_ScreenShowStart")
	flow.__agent:addSubTreeLocalParam("tAnimationLoopKey", "EnvBehav_ScreenShowLoop")
	flow.__agent:addSubTreeLocalParam("tAnimationEndKey", "EnvBehav_ScreenShowEnd")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", true)
	flow:setContinue(111)

	return true
end

function _M._to_114_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_106_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
	flow.__agent:addSubTreeLocalParam("tInstant", false)
	flow:setContinue(114)

	return true
end

function _M._get_87_1(flow)
	local _1 = _M._get_89_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_89_3(flow)
	local _0 = _C(88, "GetAoiResPointPortTableByLevel", flow, 0, 10, 0, {
		"TR_NS_GenericTemplate"
	}, nil)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(89, "__iterItem", v)

		_1[#_1 + 1] = v
	end

	return _1
end

function _M._get_91_2(flow)
	local _0 = _M._get_89_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(91, "__iterItem", v)

		_1 = _M._get_92_2(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_92_2(flow)
	local _0 = flow:getCache(91, "__iterItem")

	return _C(92, "GetDistanceFromEntityToResPointPort", flow, 0, _0)
end

function _M._get_93_1(flow)
	local _0 = flow:getCache(93, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_91_2(flow)

	flow:setCache(93, "1", _0)

	return _0
end

function _M._get_95_1(flow)
	local _1 = _M._get_93_1(flow)
	local _0 = _C(94, "UnpackResPointPort", flow, _1, 1)

	return _C(95, "GetRouteIdFromResPoint", flow, false, _0)
end

function _M._get_97_3(flow)
	local _0 = flow:getCache(98, "__iterItem")

	return _C(97, "GetDistance", flow, _0, 0, false)
end

function _M._get_98_2(flow)
	local _0 = _M._get_103_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(98, "__iterItem", v)

		_1 = _M._get_97_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_103_2(flow)
	return flow:getCache(103, "__iterItem")
end

function _M._get_103_3(flow)
	local _0 = _C(105, "GetAoiEntityTableByLevel", flow, 0, 10, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(103, "__iterItem", v)

		if _M._get_119_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_106_1(flow)
	local _0 = flow:getCache(106, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_98_2(flow)

	flow:setCache(106, "1", _0)

	return _0
end

function _M._get_108_1(flow)
	local _1 = _M._get_103_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_119_2(flow)
	local _0 = _M._get_103_2(flow)

	return _C(119, "HasEntityTag", flow, _0, "TE_Env_UniversalMark_A")
end

return _M
