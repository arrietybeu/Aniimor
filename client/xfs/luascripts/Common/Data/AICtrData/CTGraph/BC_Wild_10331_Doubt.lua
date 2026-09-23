-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10331_Doubt.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeTickLodTrigger(flow)
	return _M._to_32_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 43 then
		return _M._to_44_0(flow)
	end

	if nodeId == 44 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 43 then
		return _M._get_14_1(flow)
	end

	if nodeId == 44 then
		return _M._get_14_1(flow)
	end
end

function _M._to_32_0(flow)
	local _1 = _M._get_3_3(flow)
	local _2 = not _1 or next(_1) == nil
	local _0 = not _2

	if _0 then
		return _M._to_43_0(flow)
	end
end

function _M._to_43_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 43)

	if not _1 then
		flow:setActive()
		_C(43, "DoBehaviour", flow, "PBT_ShowEmojiBubble")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Think")
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 10)
		flow:setContinue(43)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_44_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 44)

	if not _1 then
		flow:setActive()
		_C(44, "DoBehaviour", flow, "PBT_TurnToTargetAtYaw")

		local _1 = _M._get_10_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTgtId", _1)
		flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
		flow.__agent:addSubTreeLocalParam("tInstant", false)
		flow:setContinue(44)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_3_2(flow)
	return flow:getCache(3, "__iterItem")
end

function _M._get_3_3(flow)
	local _0 = _C(11, "GetAoiEntityTableByLevel", flow, 0, 10, 8)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(3, "__iterItem", v)

		if _M._get_4_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_4_2(flow)
	local _0 = _M._get_3_2(flow)

	return _C(4, "HasEntityTag", flow, _0, "TE_Wild_10231_GetClose")
end

function _M._get_6_3(flow)
	local _0 = flow:getCache(9, "__iterItem")

	return _C(6, "GetDistance", flow, _0, 0, false)
end

function _M._get_9_2(flow)
	local _0 = _M._get_3_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(9, "__iterItem", v)

		_1 = _M._get_6_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_10_1(flow)
	local _0 = flow:getCache(10, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_9_2(flow)

	flow:setCache(10, "1", _0)

	return _0
end

function _M._get_14_1(flow)
	local _0 = _M._get_18_2(flow)

	return not _0
end

function _M._get_18_2(flow)
	local _3 = _M._get_10_1(flow)
	local _0 = _C(16, "CheckEntityExist", flow, _3)

	if not _0 then
		return false
	end

	local _2 = _M._get_10_1(flow)
	local _1 = _C(15, "HasEntityTag", flow, _2, "TE_Wild_10231_GetClose")

	if not _1 then
		return false
	end

	return true
end

return _M
