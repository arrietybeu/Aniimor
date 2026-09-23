-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_CatchFailure.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "CatchResult_Failure" then
		return _M._to_93_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()
	_A(flow, "RemoveAITag", 0, "TA_VisionFull")

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 93 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_93_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_95_2(flow)

	if _0 then
		flow:setActive()
		_C(93, "DoBehaviour", flow, "PBT_ReadyToFight")

		local _1 = flow:getContextValue("ballMasterActorId")

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tSensorTgtId", _1)
		flow.__agent:addSubTreeLocalParam("tRandomWaitTime", 0)
		flow.__agent:addSubTreeLocalParam("tShowExclamation", false)
		flow:setContinue(93)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_95_2(flow)
	local _0 = _C(94, "GetPuppetData", flow, 0, "catchFailureBehavType", true, "")

	return _0 == "Fight"
end

function _M._get_96_1(flow)
	return _C(96, "GetAoiEntityTableByLevel", flow, 0, 50, 2)
end

return _M
