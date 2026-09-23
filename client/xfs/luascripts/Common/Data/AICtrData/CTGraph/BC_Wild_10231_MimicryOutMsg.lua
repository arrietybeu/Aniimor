-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10231_MimicryOutMsg.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeEventTrigger(flow, eventName)
	if eventName == "OnCharacterStateChange" then
		return _M._to_52_0(flow)
	end
end

function _M._to_52_0(flow)
	local _0 = _M._get_53_2(flow)

	if _0 then
		flow:setActive()

		local _1 = _C(54, "GetSelfId", flow)

		_A(flow, "SendMessageToTrigger", _1, 1023102)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_53_2(flow)
	local _2 = flow:getContextValue("oldState")
	local _0 = _2 == "MIMICRY"

	if not _0 then
		return false
	end

	local _3 = flow:getContextValue("newState")
	local _1 = _3 == "MIMICRYOUT"

	if not _1 then
		return false
	end

	return true
end

return _M
