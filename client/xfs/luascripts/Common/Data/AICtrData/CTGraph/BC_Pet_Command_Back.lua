-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Pet_Command_Back.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "Event_PetEnterBack" then
		return _M._to_34_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()
	_A(flow, "RemoveAITag", 0, "TA_PetEnterBack")

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 34 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_34_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _C(36, "HasAITag", flow, 0, "TA_PetEnterBack")

	if _0 then
		flow:setActive()
		_C(34, "DoBehaviour", flow, "PBT_Pet_Back")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tInWaterDepth", 0)
		flow.__agent:addSubTreeLocalParam("tCurrentDistToMaster", 0)
		flow:setContinue(34)

		return true
	else
		flow:setActiveFail()
	end
end

return _M
