-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_SeekLove_Love_Exit.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeSubFlow(flow)
	return _M._to_8_0(flow)
end

function _M._to_8_0(flow)
	flow:setActive()

	local _0 = flow:getContextValue("targetActorId")
	local _1 = flow:getMessageContext()

	_1.sourceActorId = flow.__actorId

	flow:sendMessage(_0, "Love_Exit", _1)

	return _M._to_11_0(flow)
end

function _M._to_11_0(flow)
	flow:setActive()

	local _0 = _M._get_16_2(flow)

	for _, v in ipairs(_0) do
		local _1 = flow:getMessageContext()

		_1.sourceActorId = flow.__actorId

		flow:sendMessage(v, "Love_StopSing", _1)
	end

	return true
end

function _M._get_15_2(flow)
	local _0 = flow:getCache(16, "__iterItem")

	return _C(15, "IsInBehavTag", flow, _0, "TB_SeekLove_Singing")
end

function _M._get_16_2(flow)
	local _3 = flow:getContextValue("myActorId")
	local _0 = _C(13, "GetAoiEntityTableByLevel", flow, _3, 50, 8)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		local _2 = pg.getEntityByActorId(v)

		flow:setCache(16, "__iterItem", _2 and _2.actorId or 0)

		if _M._get_15_2(flow) then
			_1[#_1 + 1] = _2.actorId
		end
	end

	return _1
end

return _M
