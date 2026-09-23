-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_NSVisionValueMove.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _P = CTHelper.DoPatrolBehavior
local _A = CTHelper.DoAction

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "VisionValue_Full" then
		flow:setActive()
		_A(flow, "AddAITag", 0, "TA_VisionFull")
		flow:setActive()
		_A(flow, "RemoveAITag", 0, "TA_VisionAlert")
		flow:setActive()

		local _0 = _C(58, "GetSelfId", flow)

		_A(flow, "HideEmojiOnTarget", _0, "")

		return _M._to_40_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 40 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_40_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_49_2(flow)

	if _0 then
		flow:setActive()

		local _1 = _M._get_31_1(flow)

		if _P(flow, 1, _1, 1, nil) then
			flow:setContinue(40)

			return true
		end
	else
		flow:setActiveFail()
	end
end

function _M._get_31_1(flow)
	local _1 = _M._get_62_2(flow)
	local _0 = _C(35, "UnpackResPointPort", flow, _1, 1)

	return _C(31, "GetRouteIdFromResPoint", flow, true, _0, 1)
end

function _M._get_38_2(flow)
	local _1 = _M._get_42_2(flow)
	local _0 = _C(37, "GetDistanceFromEntityToResPointPort", flow, 0, _1)

	return _0 < 5
end

function _M._get_42_3(flow)
	local _0 = _C(41, "GetAoiResPointPortTableByLevel", flow, 0, 30, 0, {
		"TR_NS_GenericTemplate"
	}, nil)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(42, "__iterItem", v)

		if _M._get_38_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_42_2(flow)
	return flow:getCache(42, "__iterItem")
end

function _M._get_49_2(flow)
	if false then
		return false
	end

	local _1 = _M._get_42_3(flow)
	local _2 = not _1 or next(_1) == nil
	local _0 = not _2

	if not _0 then
		return false
	end

	return true
end

function _M._get_62_2(flow)
	local _0 = _M._get_42_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(62, "__iterItem", v)

		_1 = _M._get_63_2(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_63_2(flow)
	local _0 = flow:getCache(62, "__iterItem")

	return _C(63, "GetDistanceFromEntityToResPointPort", flow, 0, _0)
end

return _M
