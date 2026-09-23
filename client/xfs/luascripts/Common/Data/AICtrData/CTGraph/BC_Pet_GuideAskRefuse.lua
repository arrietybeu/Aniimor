-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Pet_GuideAskRefuse.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeTickLodTrigger(flow)
	return _M._to_2_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 2 then
		return _M._to_1_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_1_0(flow)
	flow:setActive()
	_A(flow, "ExitPetGuide", 0)

	return true
end

function _M._to_2_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _C(3, "CheckInDialog", flow, 70002000)

	if _0 then
		flow:setActive()
		_C(2, "DoBehaviour", flow, "PBT_Pet_GuideAsk")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tSensorTgtId", 0)
		flow.__agent:addSubTreeLocalParam("tRandomWaitTime", 0)
		flow:setContinue(2)

		return true
	else
		flow:setActiveFail()
	end
end

return _M
