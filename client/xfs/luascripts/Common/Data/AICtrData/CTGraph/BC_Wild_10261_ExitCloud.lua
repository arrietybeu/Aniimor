-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10261_ExitCloud.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeEventTrigger(flow, eventName)
	if eventName == "OnAITagRemoveMsgTrigger" then
		return _M._to_80_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 80 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_80_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_79_2(flow)

	if _0 then
		flow:setActive()
		_C(80, "DoBehaviour", flow, "PBT_SwitchState")

		local _1 = "LOCOMOTION"

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tCharacterState", _1)
		flow.__agent:addSubTreeLocalParam("tAnimationKey", "")
		flow:setContinue(80)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_79_2(flow)
	local _0 = flow:getContextValue("tag")

	return _0 == "TA_InLowGravity"
end

return _M
