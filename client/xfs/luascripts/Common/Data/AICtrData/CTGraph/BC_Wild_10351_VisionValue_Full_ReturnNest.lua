-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10351_VisionValue_Full_ReturnNest.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _P = CTHelper.DoPatrolBehavior
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "VisionValue_Full" then
		flow:setActive()
		_A(flow, "AddAITag", 0, "TA_VisionFull")
		flow:setActive()
		_A(flow, "RemoveAITag", 0, "TA_VisionAlert")
		flow:setActive()

		local _0 = _C(72, "GetSelfId", flow)

		_A(flow, "HideEmojiOnTarget", _0, "")

		return _M._to_63_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _M._get_111_1(flow)

	_A(flow, "RemoveAITag", _0, "TE_Env_BeUsed")

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 63 then
		return _M._to_135_0(flow)
	end

	if nodeId == 139 then
		return true
	end

	if nodeId == 142 then
		return _M._to_141_0(flow)
	end

	if nodeId == 199 then
		return _M._to_203_0(flow)
	end

	if nodeId == 203 then
		return _M._to_142_0(flow)
	end

	if nodeId == 208 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_63_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tCharacterState", "FLYING")
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "")
	flow:setContinue(63)

	return true
end

function _M._to_135_0(flow)
	local _2 = _M._get_100_3(flow)
	local _3 = not _2 or next(_2) == nil
	local _0 = not _3

	if _0 then
		flow:setActive()

		local _1 = _M._get_111_1(flow)

		_A(flow, "AddEntityTag", _1, "TE_Env_BeUsed")

		return _M._to_199_0(flow)
	else
		flow:setActiveFail()
	end
end

function _M._to_141_0(flow)
	flow:setActive()
	_A(flow, "AddEntityTag", 0, "TE_Wild_DewyInNest")

	return _M._to_208_0(flow)
end

function _M._to_142_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = flow:getContextValue("sensorTgtId")

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
	flow.__agent:addSubTreeLocalParam("tInstant", false)
	flow:setContinue(142)

	return true
end

function _M._to_199_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_78_1(flow)

	if _0 then
		flow:setActive()
		_C(199, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_114_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("tStopDist", 1)
		flow.__agent:addSubTreeLocalParam("tMaxTimeout", -1)
		flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
		flow.__agent:addSubTreeLocalParam("tSpeed", 4)
		flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 99999)
		flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
		flow.__agent:addSubTreeLocalParam("tSpeedRateType", 2)
		flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
		flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
		flow:setContinue(199)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_203_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_186_1(flow)

	if _0 then
		flow:setActive()

		local _1 = _M._get_191_1(flow)

		if _P(flow, 1, _1, 1, nil) then
			flow:setContinue(203)

			return true
		end
	else
		flow:setActiveFail()
	end
end

function _M._to_208_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 60)
	flow:setContinue(208)

	return true
end

function _M._get_76_3(flow)
	local _0 = _C(82, "GetAoiEntityTableByLevel", flow, 0, 50, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(76, "__iterItem", v)

		if _M._get_81_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_76_2(flow)
	return flow:getCache(76, "__iterItem")
end

function _M._get_78_1(flow)
	local _1 = _M._get_76_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_79_2(flow)
	local _0 = _M._get_76_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(79, "__iterItem", v)

		_1 = _M._get_80_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_80_3(flow)
	local _0 = flow:getCache(79, "__iterItem")

	return _C(80, "GetDistance", flow, _0, 0, false)
end

function _M._get_81_2(flow)
	local _0 = _M._get_76_2(flow)

	return _C(81, "HasEntityTag", flow, _0, "TE_Env_DewyNestPlatform")
end

function _M._get_100_3(flow)
	local _0 = _C(106, "GetAoiEntityTableByLevel", flow, 0, 100, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(100, "__iterItem", v)

		if _M._get_131_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_100_2(flow)
	return flow:getCache(100, "__iterItem")
end

function _M._get_105_3(flow)
	local _0 = flow:getCache(110, "__iterItem")

	return _C(105, "GetDistance", flow, _0, 0, false)
end

function _M._get_110_2(flow)
	local _0 = _M._get_100_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(110, "__iterItem", v)

		_1 = _M._get_105_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_111_1(flow)
	local _0 = flow:getCache(111, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_110_2(flow)

	flow:setCache(111, "1", _0)

	return _0
end

function _M._get_114_1(flow)
	local _0 = flow:getCache(114, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_79_2(flow)

	flow:setCache(114, "1", _0)

	return _0
end

function _M._get_131_2(flow)
	local _4 = _M._get_100_2(flow)
	local _0 = _C(107, "HasEntityTag", flow, _4, "TE_Env_DewyNest")

	if not _0 then
		return false
	end

	local _2 = _M._get_100_2(flow)
	local _3 = _C(101, "HasEntityTag", flow, _2, "TE_Env_BeUsed")
	local _1 = not _3

	if not _1 then
		return false
	end

	return true
end

function _M._get_151_1(flow)
	local _0 = _C(149, "GetPerceptibilityTable", flow)

	if _0 == nil then
		return
	end

	local key = next(_0)
	local value = _0[key]

	for k, v in pairs(_0) do
		if value < v then
			key, value = k, v
		end
	end

	return key
end

function _M._get_152_2(flow)
	local _1 = _M._get_151_1(flow)
	local _0 = _C(150, "GetPerceptibilityValue", flow, _1)

	return _0 <= 1
end

function _M._get_186_1(flow)
	local _1 = _M._get_190_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_188_1(flow)
	local _0 = flow:getCache(188, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_192_2(flow)

	flow:setCache(188, "1", _0)

	return _0
end

function _M._get_190_3(flow)
	local _0 = _C(189, "GetAoiResPointPortTableByLevel", flow, 0, 30, 0, {
		"TR_NS_GenericTemplate"
	}, nil)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(190, "__iterItem", v)

		_1[#_1 + 1] = v
	end

	return _1
end

function _M._get_191_1(flow)
	local _1 = _M._get_188_1(flow)
	local _0 = _C(187, "UnpackResPointPort", flow, _1, 1)

	return _C(191, "GetRouteIdFromResPoint", flow, false, _0)
end

function _M._get_192_2(flow)
	local _0 = _M._get_190_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(192, "__iterItem", v)

		_1 = _M._get_193_2(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_193_2(flow)
	local _0 = flow:getCache(192, "__iterItem")

	return _C(193, "GetDistanceFromEntityToResPointPort", flow, 0, _0)
end

return _M
