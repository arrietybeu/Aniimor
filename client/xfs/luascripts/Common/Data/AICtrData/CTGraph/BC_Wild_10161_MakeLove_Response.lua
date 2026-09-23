-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10161_MakeLove_Response.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "Msg_MakeLove_Seek" then
		return _M._to_109_0(flow)
	end
end

function _M._to_54_0(flow)
	local _0 = _M._get_94_1(flow)

	if _0 then
		flow:setActive()

		local _1 = _M._get_101_1(flow)
		local _2 = flow:getMessageContext()
		local _3 = _M._get_103_0(flow)

		_2.TheOtherActorID = _3
		_2.sourceActorId = flow.__actorId

		flow:sendMessage(_1, "Msg_MakeLove_Start", _2)
		flow:setActive()

		local _4 = _M._get_103_0(flow)
		local _5 = flow:getMessageContext()
		local _6 = _M._get_101_1(flow)

		_5.TheOtherActorID = _6
		_5.sourceActorId = flow.__actorId

		flow:sendMessage(_4, "Msg_MakeLove_Start", _5)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_109_0(flow)
	local _0 = _M._get_106_2(flow)

	if _0 then
		return _M._to_54_0(flow)
	end

	local _2 = _M._get_106_2(flow)
	local _1 = not _2

	if _1 then
		return _M._to_116_0(flow)
	end
end

function _M._to_116_0(flow)
	local _0 = _M._get_117_2(flow)

	if _0 then
		flow:setActive()

		local _1 = _M._get_101_1(flow)
		local _2 = flow:getMessageContext()
		local _3 = _M._get_103_0(flow)

		_2.TheOtherActorID = _3
		_2.sourceActorId = flow.__actorId

		flow:sendMessage(_1, "Msg_MakeLove_Start", _2)
		flow:setActive()

		local _4 = _M._get_103_0(flow)
		local _5 = flow:getMessageContext()
		local _6 = _M._get_101_1(flow)

		_5.TheOtherActorID = _6
		_5.sourceActorId = flow.__actorId

		flow:sendMessage(_4, "Msg_MakeLove_Start", _5)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_94_1(flow)
	local _1 = _M._get_101_1(flow)
	local _0 = _C(102, "IsInBehavTag", flow, _1, "TB_SeekLove")

	return not _0
end

function _M._get_101_1(flow)
	return flow:getContextValue("sourceActorId")
end

function _M._get_103_0(flow)
	return _C(103, "GetSelfId", flow)
end

function _M._get_106_2(flow)
	local _0 = _C(112, "GetSelfId", flow)

	return _C(106, "IsInBehavTag", flow, _0, "TB_Recuit")
end

function _M._get_117_2(flow)
	local _0 = _M._get_94_1(flow)

	if not _0 then
		return false
	end

	local _2 = _C(107, "RandomInteger", flow, 0, 10)
	local _1 = _2 <= 3

	if not _1 then
		return false
	end

	return true
end

return _M
