-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10261_LeaveToCloud.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "VisionValue_Full" then
		return _M._to_82_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _M._get_68_1(flow)
	local _1 = _M._get_68_2(flow)

	_A(flow, "ExitResPointPort", 0, _0, _1, 0, 0)

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 63 then
		return _M._to_87_0(flow)
	end

	if nodeId == 85 then
		return true
	end

	if nodeId == 87 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_63_0(flow)
	if not _B(flow, "PBT_MoveToResPointPort") then
		return
	end

	local _0 = _M._get_68_1(flow)
	local _1 = _M._get_68_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tPointId", _0)
	flow.__agent:addSubTreeLocalParam("tPortId", _1)
	flow.__agent:addSubTreeLocalParam("tTimeout", 1000)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
	flow.__agent:addSubTreeLocalParam("tSpeed", 0)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
	flow:setContinue(63)

	return true
end

function _M._to_82_0(flow)
	local _1 = _M._get_73_2(flow)
	local _2 = not _1 or next(_1) == nil
	local _0 = not _2

	if _0 then
		flow:setActive()
		_A(flow, "AddAITag", 0, "TA_VisionFull")
		flow:setActive()
		_A(flow, "RemoveAITag", 0, "TA_VisionAlert")
		flow:setActive()

		local _3 = _M._get_68_1(flow)
		local _4 = _M._get_68_2(flow)

		_A(flow, "PreJoinResPointPort", 0, _3, _4)

		return _M._to_63_0(flow)
	end

	flow:setActive()
	_A(flow, "AddAITag", 0, "TA_VisionFull")
	flow:setActive()
	_A(flow, "RemoveAITag", 0, "TA_VisionAlert")

	return _M._to_85_0(flow)
end

function _M._to_85_0(flow)
	if not _B(flow, "PBT_Leave") then
		return
	end

	local _0 = flow:getContextValue("sensorTgtId")

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tSensorTgtId", _0)
	flow:setContinue(85)

	return true
end

function _M._to_87_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	local _0 = "FLYING"

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tCharacterState", _0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "")
	flow:setContinue(87)

	return true
end

function _M._get_65_1(flow)
	local _0 = _M._get_73_2(flow)

	return _C(65, "SelectOneByRandom", flow, _0)
end

function _M._get_68_2(flow)
	local _0 = _M._get_72_1(flow)

	return _C(68, "UnpackResPointPort", flow, _0, 2)
end

function _M._get_68_1(flow)
	local _0 = _M._get_72_1(flow)

	return _C(68, "UnpackResPointPort", flow, _0, 1)
end

function _M._get_72_1(flow)
	local _0 = flow:getCache(72, "resPointPort")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_65_1(flow)

	flow:setCache(72, "resPointPort", _0)

	return _0
end

function _M._get_73_2(flow)
	local _0 = _C(64, "GetAoiResPointPortTableByLevel", flow, 0, 30, 0, {
		"TR_10261_LeaveToCloud"
	}, nil)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		flow:setCache(73, "__iterItem", v)

		if _M._get_75_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_75_2(flow)
	local _1 = flow:getCache(73, "__iterItem")
	local _0 = _C(74, "GetDistanceFromEntityToResPointPort", flow, 0, _1)

	return _0 < 30
end

return _M
