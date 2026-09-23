-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10011_VisionValue_Full_FollowRouteToLeave.lua

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

		local _0 = _C(5, "GetSelfId", flow)

		_A(flow, "HideEmojiOnTarget", _0, "")

		return _M._to_113_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 113 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_113_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_103_1(flow)

	if _0 then
		flow:setActive()

		local _1 = _M._get_112_1(flow)

		if _P(flow, 1, _1, 1, nil) then
			flow:setContinue(113)

			return true
		end
	else
		flow:setActiveFail()
	end
end

function _M._get_103_1(flow)
	local _1 = _M._get_108_2(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_105_1(flow)
	local _0 = _M._get_108_2(flow)

	return _C(105, "SelectOneByRandom", flow, _0)
end

function _M._get_107_1(flow)
	local _0 = flow:getCache(107, "resPointPort")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_105_1(flow)

	flow:setCache(107, "resPointPort", _0)

	return _0
end

function _M._get_108_2(flow)
	local _0 = _C(111, "GetAoiResPointPortTableByLevel", flow, 0, 10, 0, {
		"TR_NS_GenericTemplate"
	}, nil)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		flow:setCache(108, "__iterItem", v)

		if _M._get_110_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_110_2(flow)
	local _1 = flow:getCache(108, "__iterItem")
	local _0 = _C(109, "GetDistanceFromEntityToResPointPort", flow, 0, _1)

	return _0 < 3
end

function _M._get_112_1(flow)
	local _1 = _M._get_107_1(flow)
	local _0 = _C(104, "UnpackResPointPort", flow, _1, 1)

	return _C(112, "GetRouteIdFromResPoint", flow, false, _0)
end

return _M
