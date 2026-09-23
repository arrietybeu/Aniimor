-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Pet_Command_MasterSelfieMode.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "Msg_MasterSelfieMode" then
		return _M._to_3_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 3 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_3_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _C(2, "IsInSelfieMode", flow)

	if _0 then
		flow:setActive()
		_C(3, "DoBehaviour", flow, "PBT_Pet_Command_MasterSelfieMode")
		flow.__agent:clearSubTreeLocalParams()
		flow:setContinue(3)

		return true
	else
		flow:setActiveFail()
	end
end

return _M
