-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_ParEnterCombat_SendMsg.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeEventTrigger(flow, eventName)
	if eventName == "EnterCombatTrigger" then
		return _M._to_74_0(flow)
	end
end

function _M._to_74_0(flow)
	flow:setActive()

	local _0 = _M._get_77_3(flow)

	for _, v in ipairs(_0) do
		local _1 = flow:getMessageContext()
		local _2 = flow:getContextValue("tTargetActorId")

		_1.tTargetActorId = _2
		_1.sourceActorId = flow.__actorId

		flow:sendMessage(v, "Msg_AddSelfHate", _1)
	end

	return true
end

function _M._get_77_3(flow)
	local _0 = _C(76, "GetAoiEntityTableByLevel", flow, 0, 30, 8)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(77, "__iterItem", v)

		if _M._get_84_3(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_77_2(flow)
	return flow:getCache(77, "__iterItem")
end

function _M._get_83_0(flow)
	return _C(83, "GetSelfId", flow)
end

function _M._get_84_3(flow)
	local _2 = _M._get_77_2(flow)
	local _4 = _M._get_83_0(flow)
	local _3 = _C(82, "GetPuppetData", flow, _4, "ethnicGroup", true, 0)
	local _0 = _C(79, "IsEthnicGroup", flow, _2, _3)

	if not _0 then
		return false
	end

	local _5 = _M._get_77_2(flow)
	local _6 = _M._get_83_0(flow)
	local _7 = _C(85, "GetDistance", flow, _5, _6, false)
	local _9 = _M._get_83_0(flow)
	local _8 = _C(91, "GetPuppetData", flow, _9, "partnerEnterCombatDis", true, 0)
	local _1 = _7 <= _8

	if not _1 then
		return false
	end

	if false then
		return false
	end

	return true
end

return _M
