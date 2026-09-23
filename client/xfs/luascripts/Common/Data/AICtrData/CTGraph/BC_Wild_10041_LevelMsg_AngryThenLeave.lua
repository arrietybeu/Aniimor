-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10041_LevelMsg_AngryThenLeave.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTriggerAngryThenLeave" then
		return _M._to_17_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 17 then
		return _M._to_31_0(flow)
	end

	if nodeId == 31 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_17_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "Behav_Angry")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Angry")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", true)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", true)
	flow:setContinue(17)

	return true
end

function _M._to_31_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_72_1(flow)

	if _0 then
		flow:setActive()
		_C(31, "DoBehaviour", flow, "PBT_LeaveTargetAndDestroy")

		local _1 = _M._get_73_2(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("tLeaveDistance", 50)
		flow.__agent:addSubTreeLocalParam("tSpeed", 4)
		flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
		flow.__agent:addSubTreeLocalParam("tMaxTime", 50)
		flow.__agent:addSubTreeLocalParam("tDestroyOnFail", false)
		flow:setContinue(31)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_69_3(flow)
	local _0 = _C(68, "GetAoiEntityTableByLevel", flow, 0, 30, 8)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(69, "__iterItem", v)

		if _M._get_71_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_69_2(flow)
	return flow:getCache(69, "__iterItem")
end

function _M._get_71_2(flow)
	local _0 = _M._get_69_2(flow)

	return _C(71, "HasEntityTag", flow, _0, "TE_Wild_PetMark")
end

function _M._get_72_1(flow)
	local _1 = _M._get_69_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_73_2(flow)
	local _0 = _M._get_69_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(73, "__iterItem", v)

		_1 = _M._get_74_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_74_3(flow)
	local _0 = flow:getCache(73, "__iterItem")

	return _C(74, "GetDistance", flow, _0, 0, false)
end

return _M
