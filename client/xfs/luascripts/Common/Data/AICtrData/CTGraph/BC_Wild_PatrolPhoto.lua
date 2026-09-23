-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_PatrolPhoto.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _P = CTHelper.DoPatrolBehavior
local _A = CTHelper.DoAction

function _M.executeTickLodTrigger(flow)
	return _M._to_18_0(flow)
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _M._get_14_1(flow)
	local _1 = _M._get_14_2(flow)

	_A(flow, "ExitResPointPort", 0, _0, _1, 0, 0)
	flow:setActive()
	_A(flow, "SetVisionAreaOverride", "visionAreaDefault")
	flow:setActive()

	local _2 = _M._get_14_1(flow)

	_A(flow, "ExitPhotoEcology", _2)

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 8 then
		return _M._to_34_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_8_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_29_8(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(8)

		return true
	end
end

function _M._to_18_0(flow)
	local _4 = _M._get_23_2(flow)
	local _3 = not _4 or next(_4) == nil
	local _0 = not _3

	if _0 then
		flow:setActive()

		local _1 = _M._get_14_1(flow)
		local _2 = _M._get_14_2(flow)

		_A(flow, "PreJoinResPointPort", 0, _1, _2)
		flow:setActive()

		local _5 = _M._get_14_1(flow)

		_A(flow, "EnterPhotoEcology", _5)
		flow:setActive()
		_A(flow, "SetVisionAreaOverride", "visionAreaLow")

		return _M._to_8_0(flow)
	else
		flow:setActiveFail()
	end
end

function _M._to_34_0(flow)
	flow:setActive()
	_A(flow, "SetVisionAreaOverride", "visionAreaDefault")
	flow:setActive()

	local _0 = _M._get_14_1(flow)

	_A(flow, "ExitPhotoEcology", _0)

	return true
end

function _M._get_14_1(flow)
	local _0 = _M._get_22_1(flow)

	return _C(14, "UnpackResPointPort", flow, _0, 1)
end

function _M._get_14_2(flow)
	local _0 = _M._get_22_1(flow)

	return _C(14, "UnpackResPointPort", flow, _0, 2)
end

function _M._get_20_1(flow)
	local _0 = _M._get_23_2(flow)

	return _C(20, "SelectOneByRandom", flow, _0)
end

function _M._get_22_1(flow)
	local _0 = flow:getCache(22, "resPointPort")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_20_1(flow)

	flow:setCache(22, "resPointPort", _0)

	return _0
end

function _M._get_23_2(flow)
	local _0 = _C(19, "GetAoiResPointPortTableByLevel", flow, 0, 30, 4, {
		"TR_PatrolPhoto"
	}, nil)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		flow:setCache(23, "__iterItem", v)

		if _M._get_25_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_25_2(flow)
	local _1 = flow:getCache(23, "__iterItem")
	local _0 = _C(24, "GetDistanceFromEntityToResPointPort", flow, 0, _1)

	return _0 < 25
end

function _M._get_29_8(flow)
	local _0 = _C(32, "GetSelfId", flow)

	return _C(29, "GetRouteIdFromEntity", flow, _0, 0, 0, 0, "", "", "", "")
end

return _M
