-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10011_VisionValue_Full_LeaveToClimb.lua

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

		local _0 = _C(5, "GetSelfId", flow)

		_A(flow, "HideEmojiOnTarget", _0, "")

		return _M._to_88_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()
	_A(flow, "RemoveAITag", 0, "TA_VisionFull")
	flow:setActive()
	_A(flow, "ExitResPointPort", 0, 0, 0, 0, 0)

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 87 then
		return _M._to_100_0(flow)
	end

	if nodeId == 100 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_84_0(flow)
	local _0 = _M._get_82_1(flow)

	if _0 then
		flow:setActive()
		_A(flow, "JoinResPointPort", 0, 0, 0)

		return _M._to_87_0(flow)
	else
		flow:setActiveFail()
	end
end

function _M._to_87_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_105_1(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(87)

		return true
	end
end

function _M._to_88_0(flow)
	local _0 = _M._get_82_1(flow)

	if _0 then
		flow:setActive()
		_A(flow, "PreJoinResPointPort", 0, 0, 0)

		return _M._to_84_0(flow)
	else
		flow:setActiveFail()
	end
end

function _M._to_100_0(flow)
	if not _B(flow, "PBT_DestroySelf") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow:setContinue(100)

	return true
end

function _M._get_82_1(flow)
	local _1 = _M._get_92_2(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_89_1(flow)
	local _0 = _M._get_92_2(flow)

	return _C(89, "SelectOneByRandom", flow, _0)
end

function _M._get_91_1(flow)
	local _0 = flow:getCache(91, "resPointPort")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_89_1(flow)

	flow:setCache(91, "resPointPort", _0)

	return _0
end

function _M._get_92_2(flow)
	local _0 = _C(96, "GetAoiResPointPortTableByLevel", flow, 0, 30, 0, {
		"TR_EcoHabit_Climb"
	}, nil)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		flow:setCache(92, "__iterItem", v)

		if _M._get_94_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_94_2(flow)
	local _1 = flow:getCache(92, "__iterItem")
	local _0 = _C(93, "GetDistanceFromEntityToResPointPort", flow, 0, _1)

	return _0 < 15
end

function _M._get_105_1(flow)
	local _1 = _M._get_91_1(flow)
	local _0 = _C(104, "UnpackResPointPort", flow, _1, 1)

	return _C(105, "GetRouteIdFromResPoint", flow, false, _0)
end

return _M
