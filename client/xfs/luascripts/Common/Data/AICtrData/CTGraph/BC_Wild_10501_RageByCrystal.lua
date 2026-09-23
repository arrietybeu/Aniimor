-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10501_RageByCrystal.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _P = CTHelper.DoPatrolBehavior
local _A = CTHelper.DoAction

function _M.executeEventTrigger(flow, eventName)
	if eventName == "IdleMsgTrigger" then
		return _M._to_63_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()
	_A(flow, "SetVisionAreaOverride", "visionAreaDefault")
	flow:setActive()

	local _0 = _C(86, "GetSelfId", flow)

	_A(flow, "HideEmojiOnTarget", _0, "")

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 65 then
		return _M._to_67_0(flow)
	end

	if nodeId == 67 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 65 then
		return _M._get_13_1(flow)
	end

	if nodeId == 67 then
		return _M._get_82_1(flow)
	end
end

function _M._to_63_0(flow)
	local _1 = _M._get_13_1(flow)
	local _0 = not _1

	if _0 then
		flow:setActive()
		_A(flow, "SetVisionAreaOverride", "visionAreaLow")

		return _M._to_65_0(flow)
	else
		flow:setActiveFail()
	end
end

function _M._to_65_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 65)

	if not _1 then
		flow:setActive()
		_C(65, "DoBehaviour", flow, "PBT_AddBuff")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tBuffId", 2150102)
		flow.__agent:addSubTreeLocalParam("duration", -1)
		flow:setContinue(65)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_67_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_79_1(flow)
	local _1 = _M.checkInterrupt(flow, 67)

	if _0 and not _1 then
		flow:setActive()

		local _2 = _M._get_78_1(flow)

		if _P(flow, 1, _2, 1, nil) then
			flow:setContinue(67)

			return true
		end
	else
		flow:setActiveFail()
	end
end

function _M._get_8_2(flow)
	return flow:getCache(8, "__iterItem")
end

function _M._get_8_3(flow)
	local _0 = _C(12, "GetAoiEntityTableByLevel", flow, 0, 50, 8)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(8, "__iterItem", v)

		if _M._get_9_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_9_2(flow)
	local _0 = _M._get_8_2(flow)

	return _C(9, "HasEntityTag", flow, _0, "TE_Wild_Crystal")
end

function _M._get_13_1(flow)
	local _0 = _M._get_8_3(flow)

	return not _0 or next(_0) == nil
end

function _M._get_74_8(flow)
	local _0 = _C(77, "GetSelfId", flow)

	return _C(74, "GetRouteIdFromEntity", flow, _0, -1, 0, 0, "", "RageRoute", "", "")
end

function _M._get_78_1(flow)
	local _0 = flow:getCache(78, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_74_8(flow)

	flow:setCache(78, "1", _0)

	return _0
end

function _M._get_79_1(flow)
	local _1 = _M._get_78_1(flow)
	local _0 = _1 == 0

	return not _0
end

function _M._get_82_1(flow)
	local _1 = _M._get_78_1(flow)
	local _0 = _C(81, "CheckRouteIdIsValid", flow, _1, 0, 0, 0, 0, "", "", "", "")

	return not _0
end

return _M
