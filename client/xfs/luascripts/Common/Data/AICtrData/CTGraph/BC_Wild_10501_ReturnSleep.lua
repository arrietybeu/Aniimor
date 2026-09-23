-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10501_ReturnSleep.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "IdleMsgTrigger" then
		return _M._to_29_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _C(7, "GetSelfId", flow)

	_A(flow, "RemoveEntityTag", _0, "TE_Wild_10501_ReturnSleep")

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 4 then
		return true
	end

	if nodeId == 30 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_4_0(flow)
	if not _B(flow, "PBT_Sleep") then
		return
	end

	local _0 = _C(22, "RandomInteger", flow, 5, 30)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("sleepTimeOut", _0)
	flow.__agent:addSubTreeLocalParam("tShowEmojiBubble", true)
	flow.__agent:addSubTreeLocalParam("tisLoop", false)
	flow:setContinue(4)

	return true
end

function _M._to_29_0(flow)
	local _0 = _M._get_23_2(flow)

	if _0 then
		flow:setActive()
		_C(12, "RemoveEntityTag", flow, 0, "TE_Wild_10501_ReturnSleep")

		return _M._to_4_0(flow)
	end

	local _1 = _M._get_36_2(flow)

	if _1 then
		return _M._to_30_0(flow)
	end
end

function _M._to_30_0(flow)
	if not _B(flow, "PBT_AddBuff") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tBuffId", 2150102)
	flow.__agent:addSubTreeLocalParam("duration", -1)
	flow:setContinue(30)

	return true
end

function _M._get_23_2(flow)
	local _2 = _C(1, "GetSelfId", flow)
	local _0 = _C(3, "HasEntityTag", flow, _2, "TE_Wild_10501_ReturnSleep")

	if not _0 then
		return false
	end

	local _3 = _C(25, "GetSelfId", flow)
	local _4 = _C(24, "HasEntityTag", flow, _3, "TE_Wild_10501_Rage")
	local _1 = not _4

	if not _1 then
		return false
	end

	return true
end

function _M._get_36_2(flow)
	local _3 = _C(32, "GetSelfId", flow)
	local _4 = _C(33, "HasEntityTag", flow, _3, "TE_Wild_10501_ReturnSleep")
	local _0 = not _4

	if not _0 then
		return false
	end

	local _2 = _C(35, "GetSelfId", flow)
	local _1 = _C(34, "HasEntityTag", flow, _2, "TE_Wild_10501_Rage")

	if not _1 then
		return false
	end

	return true
end

return _M
