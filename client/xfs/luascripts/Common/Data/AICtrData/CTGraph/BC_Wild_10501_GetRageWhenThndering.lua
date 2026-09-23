-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10501_GetRageWhenThndering.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

local function _doBehaviourTail_0(flow, nodeId, value0, value1)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tBuffId", value0)
	agent:addSubTreeLocalParam("duration", value1)
	flow:setContinue(nodeId)

	return true
end

function _M.executeEventTrigger(flow, eventName)
	if eventName == "IdleMsgTrigger" then
		return _M._to_86_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 84 then
		return true
	end

	if nodeId == 88 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 84 then
		return _M._get_87_2(flow)
	end

	if nodeId == 88 then
		return _M._get_85_2(flow)
	end
end

function _M._to_84_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 84)

	if not _1 then
		flow:setActive()
		_C(84, "DoBehaviour", flow, "PBT_AddBuff")

		return _doBehaviourTail_0(flow, 84, 2150102, -1)
	else
		flow:setActiveFail()
	end
end

function _M._to_86_0(flow)
	local _0 = _M._get_85_2(flow)

	if _0 then
		return _M._to_84_0(flow)
	end

	local _1 = _M._get_87_2(flow)

	if _1 then
		return _M._to_88_0(flow)
	end
end

function _M._to_88_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 88)

	if not _1 then
		flow:setActive()
		_C(88, "DoBehaviour", flow, "PBT_AddBuff")

		return _doBehaviourTail_0(flow, 88, 215010101, -1)
	else
		flow:setActiveFail()
	end
end

function _M._get_82_1(flow)
	local _0 = _C(83, "GetSelfId", flow)

	return _C(82, "GetCurWeatherId", flow, _0)
end

function _M._get_85_2(flow)
	local _0 = _M._get_82_1(flow)

	return _0 == 4
end

function _M._get_87_2(flow)
	local _0 = _M._get_82_1(flow)

	return _0 == 1
end

return _M
