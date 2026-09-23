-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10161_MakeLove_Unlock.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "Msg_MakeLove_Unlock" then
		flow:setActive()

		local _0 = _C(113, "GetSelfId", flow)

		_A(flow, "SendMessageToTrigger", _0, 1016103)

		return true
	end
end

return _M
