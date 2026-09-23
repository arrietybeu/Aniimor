-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10501_RageChasePuppet.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "IdleMsgTrigger" then
		return _M._to_86_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 86 then
		return _M._to_88_0(flow)
	end

	if nodeId == 88 then
		return _M._to_89_0(flow)
	end

	if nodeId == 89 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_86_0(flow)
	if not _B(flow, "PBT_AddBuff") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tBuffId", 2150102)
	flow.__agent:addSubTreeLocalParam("duration", -1)
	flow:setContinue(86)

	return true
end

function _M._to_88_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_90_1(flow)

	if _0 then
		flow:setActive()
		_C(88, "DoBehaviour", flow, "PBT_Node_Com_SensedAlert")

		local _1 = _M._get_87_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow:setContinue(88)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_89_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_90_1(flow)

	if _0 then
		flow:setActive()
		_C(89, "DoBehaviour", flow, "PBT_Behav_Com_Chase")

		local _1 = _M._get_87_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("", 2)
		flow.__agent:addSubTreeLocalParam("Speed", 4)
		flow:setContinue(89)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_87_1(flow)
	return _C(87, "GetLeaderId", flow, 0)
end

function _M._get_90_1(flow)
	local _0 = _M._get_87_1(flow)

	return _C(90, "CheckEntityExist", flow, _0)
end

return _M
