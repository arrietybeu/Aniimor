-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Pet_Command_MasterMagnesisMode.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "Msg_MasterMagnesisMode" then
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

	local _0 = _M._get_4_2(flow)

	if _0 then
		flow:setActive()
		_C(3, "DoBehaviour", flow, "PBT_Pet_Command_MasterCrouchAndCatchMode")
		flow.__agent:clearSubTreeLocalParams()
		flow:setContinue(3)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_4_2(flow)
	local _2 = _C(1, "GetPetMaster", flow, 0)
	local _0 = _C(2, "IsInMagnesisMode", flow, _2)

	if not _0 then
		return false
	end

	local _3 = _C(6, "GetPetMaster", flow, 0)
	local _1 = _C(5, "GetEntProperty", flow, _3, "canBeFollowed")

	if not _1 then
		return false
	end

	return true
end

return _M
