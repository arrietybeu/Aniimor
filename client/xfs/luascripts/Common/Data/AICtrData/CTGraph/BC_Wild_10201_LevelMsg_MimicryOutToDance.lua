-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10201_LevelMsg_MimicryOutToDance.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTriggerStartShow" then
		return _M._to_105_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 103 then
		return _M._to_104_0(flow)
	end

	if nodeId == 104 then
		return true
	end

	if nodeId == 105 then
		return _M._to_103_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_103_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "IdleSpecial")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Happy")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", true)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", true)
	flow:setContinue(103)

	return true
end

function _M._to_104_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_114_1(flow)

	if _0 then
		flow:setActive()
		_C(104, "DoBehaviour", flow, "PBT_LeaveTarget")

		local _1 = _M._get_108_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("tLeaveDistance", 5)
		flow.__agent:addSubTreeLocalParam("tSpeed", 4)
		flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
		flow.__agent:addSubTreeLocalParam("tMaxTime", 3)
		flow:setContinue(104)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_105_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tCharacterState", "LOCOMOTION")
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "")
	flow:setContinue(105)

	return true
end

function _M._get_107_1(flow)
	local _0 = _M._get_111_3(flow)

	return _C(107, "SelectOneByRandom", flow, _0)
end

function _M._get_108_1(flow)
	local _0 = flow:getCache(108, "312")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_107_1(flow)

	flow:setCache(108, "312", _0)

	return _0
end

function _M._get_111_3(flow)
	local _0 = _C(112, "GetAoiEntityTableByLevel", flow, 0, 50, 2)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(111, "__iterItem", v)

		_1[#_1 + 1] = v
	end

	return _1
end

function _M._get_114_1(flow)
	local _1 = _M._get_111_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

return _M
