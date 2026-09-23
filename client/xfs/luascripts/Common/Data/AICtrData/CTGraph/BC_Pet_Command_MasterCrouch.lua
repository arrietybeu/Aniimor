-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Pet_Command_MasterCrouch.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "Msg_MasterCrouch" then
		return _M._to_1_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 1 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_1_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_3_1(flow)

	if _0 then
		flow:setActive()
		_C(1, "DoBehaviour", flow, "PBT_Pet_Command_MasterCrouchAndCatchMode")
		flow.__agent:clearSubTreeLocalParams()
		flow:setContinue(1)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_3_1(flow)
	local _0 = _C(2, "GetPetMaster", flow, 0)

	return _C(3, "IsInCrouch", flow, _0)
end

return _M
