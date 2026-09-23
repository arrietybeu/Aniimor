-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10381_shankefish_Response.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "Msg_Shankefish_Fight" then
		return _M._to_29_0(flow)
	end
end

function _M._to_29_0(flow)
	local _0 = _M._get_46_1(flow)

	if _0 then
		flow:setActive()

		local _1 = _M._get_34_1(flow)
		local _2 = flow:getMessageContext()
		local _3 = _M._get_43_0(flow)

		_2.actid = _3
		_2.sourceActorId = flow.__actorId

		flow:sendMessage(_1, "Msg_Shankefish_Fight_OK", _2)

		return _M._to_44_0(flow)
	else
		flow:setActiveFail()
	end
end

function _M._to_44_0(flow)
	local _0 = _M._get_46_1(flow)

	if _0 then
		flow:setActive()

		local _1 = _M._get_43_0(flow)
		local _2 = flow:getMessageContext()
		local _3 = _M._get_34_1(flow)

		_2.actid = _3
		_2.sourceActorId = flow.__actorId

		flow:sendMessage(_1, "Msg_Shankefish_Fight_OK", _2)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_34_1(flow)
	return flow:getContextValue("sourceActorId")
end

function _M._get_43_0(flow)
	return _C(43, "GetSelfId", flow)
end

function _M._get_46_1(flow)
	local _1 = _M._get_34_1(flow)
	local _0 = _C(45, "IsInBehavTag", flow, _1, "TB_shankeyuFight")

	return not _0
end

return _M
