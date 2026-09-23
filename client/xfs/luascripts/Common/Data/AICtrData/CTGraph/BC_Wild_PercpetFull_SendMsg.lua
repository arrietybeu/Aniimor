-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_PercpetFull_SendMsg.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeTickLodTrigger(flow)
	return _M._to_103_0(flow)
end

function _M._to_103_0(flow)
	local _0 = _M._get_105_3(flow)

	if _0 then
		flow:setActive()

		local _1 = _M._get_77_3(flow)

		for _, v in ipairs(_1) do
			local _2 = flow:getMessageContext()

			_2.sourceActorId = flow.__actorId

			flow:sendMessage(v, "Msg_Full_ToBrother", _2)
		end

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_77_2(flow)
	return flow:getCache(77, "__iterItem")
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

function _M._get_83_0(flow)
	return _C(83, "GetSelfId", flow)
end

function _M._get_84_3(flow)
	local _3 = _M._get_77_2(flow)
	local _5 = _M._get_83_0(flow)
	local _4 = _C(82, "GetPuppetData", flow, _5, "ethnicGroup", true, 0)
	local _0 = _C(79, "IsEthnicGroup", flow, _3, _4)

	if not _0 then
		return false
	end

	local _6 = _M._get_77_2(flow)
	local _7 = _M._get_83_0(flow)
	local _8 = _C(85, "GetDistance", flow, _6, _7, false)
	local _10 = _M._get_83_0(flow)
	local _9 = _C(91, "GetPuppetData", flow, _10, "partnerEnterCombatDis", true, 0)
	local _1 = _8 <= _9

	if not _1 then
		return false
	end

	local _11 = _M._get_77_2(flow)
	local _12 = _C(108, "GetPuppetData", flow, _11, "stage", true, 0)
	local _2 = _12 >= 2

	if not _2 then
		return false
	end

	return true
end

function _M._get_100_1(flow)
	local _0 = _C(98, "GetPerceptibilityTable", flow)

	if _0 == nil then
		return
	end

	local key = next(_0)
	local value = _0[key]

	for k, v in pairs(_0) do
		if value < v then
			key, value = k, v
		end
	end

	return key
end

function _M._get_105_3(flow)
	local _5 = _M._get_100_1(flow)
	local _6 = _C(99, "GetPerceptibilityValue", flow, _5)
	local _0 = _6 >= 100

	if not _0 then
		return false
	end

	local _7 = _M._get_77_3(flow)
	local _8 = not _7 or next(_7) == nil
	local _1 = not _8

	if not _1 then
		return false
	end

	local _3 = _M._get_83_0(flow)
	local _4 = _C(92, "GetPuppetData", flow, _3, "stage", true, 0)
	local _2 = _4 == 1

	if not _2 then
		return false
	end

	return true
end

return _M
