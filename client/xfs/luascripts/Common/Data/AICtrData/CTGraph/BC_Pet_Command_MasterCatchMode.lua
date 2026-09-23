-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Pet_Command_MasterCatchMode.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "Msg_MasterCatchMode" then
		return _M._to_8_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _M._get_9_0(flow)

	_A(flow, "HideEmojiOnTarget", _0, "Alert")

	return true
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
	if not _B(flow, "PBT_Pet_Command_MasterCrouchAndCatchMode") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow:setContinue(1)

	return true
end

function _M._to_8_0(flow)
	local _0 = _M._get_11_2(flow)

	if _0 then
		flow:setActive()

		local _1 = _M._get_9_0(flow)

		_A(flow, "PlayEmojiOnTarget", _1, "Alert", 100)

		return _M._to_1_0(flow)
	else
		flow:setActiveFail()
	end
end

function _M._get_9_0(flow)
	return _C(9, "GetSelfId", flow)
end

function _M._get_11_2(flow)
	local _2 = _C(2, "GetPetMaster", flow, 0)
	local _0 = _C(3, "IsInCatchMode", flow, _2)

	if not _0 then
		return false
	end

	local _3 = _C(13, "GetPetMaster", flow, 0)
	local _1 = _C(12, "GetEntProperty", flow, _3, "canBeFollowed")

	if not _1 then
		return false
	end

	return true
end

return _M
