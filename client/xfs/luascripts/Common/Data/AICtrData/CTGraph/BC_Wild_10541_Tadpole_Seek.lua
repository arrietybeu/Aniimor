-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10541_Tadpole_Seek.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeTickLodTrigger(flow)
	return _M._to_0_0(flow)
end

function _M._to_0_0(flow)
	local _3 = _M._get_7_3(flow)
	local _4 = not _3 or next(_3) == nil
	local _0 = not _4

	if _0 then
		flow:setActive()

		local _1 = _M._get_12_2(flow)
		local _2 = flow:getMessageContext()

		_2.sourceActorId = flow.__actorId

		flow:sendMessage(_1, "Msg_10541_Tadpole_Seek", _2)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_4_3(flow)
	local _6 = _M._get_7_2(flow)
	local _5 = _C(9, "GetPuppetData", flow, _6, "petPrototypeId", true, 0)
	local _0 = _5 == 1054100

	if not _0 then
		return false
	end

	local _4 = _M._get_7_2(flow)
	local _3 = _C(3, "GetDistance", flow, _4, 0, false)
	local _1 = _3 >= 5

	if not _1 then
		return false
	end

	local _7 = _M._get_7_2(flow)
	local _8 = _C(10, "IsInBehavTag", flow, _7, "TB_10541_Hello")
	local _2 = not _8

	if not _2 then
		return false
	end

	return true
end

function _M._get_7_2(flow)
	return flow:getCache(7, "__iterItem")
end

function _M._get_7_3(flow)
	local _0 = _C(6, "GetAoiEntityTableByLevel", flow, 0, 10, 8)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(7, "__iterItem", v)

		if _M._get_4_3(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_11_3(flow)
	local _0 = flow:getCache(12, "__iterItem")

	return _C(11, "GetDistance", flow, _0, 0, false)
end

function _M._get_12_2(flow)
	local _0 = _M._get_7_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(12, "__iterItem", v)

		_1 = _M._get_11_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

return _M
