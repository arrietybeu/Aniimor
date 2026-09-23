-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Pet_Afk_Exit.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _A = CTHelper.DoAction

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "Msg_Pet_AfkExit" then
		flow:setActive()
		_A(flow, "StopEffectOnTarget", 0, "Eff_Common_Behav_Love")
		flow:setActive()
		_A(flow, "StopEffectOnTarget", 0, "Eff_Common_Behav_Doubt")
		flow:setActive()
		_A(flow, "CancelFovBlend", 1.5, 3)
		flow:setActive()
		_A(flow, "SetAFKScreen", false)

		return true
	end
end

return _M
