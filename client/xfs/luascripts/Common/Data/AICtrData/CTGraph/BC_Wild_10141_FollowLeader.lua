-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10141_FollowLeader.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeEventTrigger(flow, eventName)
	if eventName == "IdleMsgTrigger" then
		return _M._to_0_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 0 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_0_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_11_1(flow)

	if _0 then
		flow:setActive()
		_C(0, "DoBehaviour", flow, "PBT_FollowOneByOne")

		local _1 = _M._get_16_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tFollowEntActorID", _1)
		flow.__agent:addSubTreeLocalParam("tFollowStopDist", 2)
		flow.__agent:addSubTreeLocalParam("tStartFollowDist", 0)
		flow:setContinue(0)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_2_2(flow)
	return flow:getCache(2, "__iterItem")
end

function _M._get_2_3(flow)
	local _0 = _C(8, "GetAoiEntityTableByLevel", flow, 0, 50, 8)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(2, "__iterItem", v)

		if _M._get_9_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_7_3(flow)
	local _0 = flow:getCache(12, "__iterItem")

	return _C(7, "GetDistance", flow, _0, 0, false)
end

function _M._get_9_2(flow)
	local _0 = _M._get_2_2(flow)

	return _C(9, "HasEntityTag", flow, _0, "TE_Wild_Leader")
end

function _M._get_11_1(flow)
	local _1 = _M._get_2_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_12_2(flow)
	local _0 = _M._get_2_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(12, "__iterItem", v)

		_1 = _M._get_7_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_16_1(flow)
	local _0 = flow:getCache(16, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_12_2(flow)

	flow:setCache(16, "1", _0)

	return _0
end

return _M
