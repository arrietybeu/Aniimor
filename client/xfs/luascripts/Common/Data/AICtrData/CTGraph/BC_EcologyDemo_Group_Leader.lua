-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_EcologyDemo_Group_Leader.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeEventTrigger(flow, eventName)
	if eventName == "IdleMsgTrigger" then
		return _M._to_2_0(flow)
	end
end

function _M._to_2_0(flow)
	local _3 = _M._get_1_1(flow)
	local _4 = not _3 or next(_3) == nil
	local _0 = not _4

	if _0 then
		flow:setActive()

		local _1 = _M._get_1_1(flow)

		for _, v in ipairs(_1) do
			local _2 = flow:getMessageContext()

			_2.sourceActorId = flow.__actorId

			flow:sendMessage(v, "Msg_Leader2Partners", _2)
		end

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_1_1(flow)
	return _C(1, "GetPartnerIds", flow, 0)
end

return _M
