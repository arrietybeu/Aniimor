-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10541_Tadpole_Response.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "Msg_10541_Tadpole_Seek" then
		return _M._to_0_0(flow)
	end
end

function _M._to_0_0(flow)
	local _0 = _M._get_4_1(flow)

	if _0 then
		flow:setActive()

		local _1 = _M._get_2_1(flow)
		local _2 = flow:getMessageContext()
		local _3 = _M._get_5_0(flow)

		_2.actid = _3
		_2.sourceActorId = flow.__actorId

		flow:sendMessage(_1, "Msg_10541_Tadpole_Response", _2)

		return _M._to_3_0(flow)
	else
		flow:setActiveFail()
	end
end

function _M._to_3_0(flow)
	local _0 = _M._get_4_1(flow)

	if _0 then
		flow:setActive()

		local _1 = _M._get_5_0(flow)
		local _2 = flow:getMessageContext()
		local _3 = _M._get_2_1(flow)

		_2.actid = _3
		_2.sourceActorId = flow.__actorId

		flow:sendMessage(_1, "Msg_10541_Tadpole_Response", _2)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_2_1(flow)
	return flow:getContextValue("sourceActorId")
end

function _M._get_4_1(flow)
	local _1 = _M._get_2_1(flow)
	local _0 = _C(1, "IsInBehavTag", flow, _1, "TB_10541_Hello")

	return not _0
end

function _M._get_5_0(flow)
	return _C(5, "GetSelfId", flow)
end

return _M
