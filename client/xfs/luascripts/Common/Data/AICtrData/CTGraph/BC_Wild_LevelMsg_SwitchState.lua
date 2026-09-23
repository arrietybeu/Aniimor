-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_LevelMsg_SwitchState.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsg_SwitchState" then
		return _M._to_100_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 100 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_100_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_102_1(flow)

	if _0 then
		flow:setActive()
		_C(100, "DoBehaviour", flow, "PBT_SwitchState")

		local _1 = _M._get_94_1(flow)
		local _2 = flow:getContextValue("replaceAnimationKey")

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tCharacterState", _1)
		flow.__agent:addSubTreeLocalParam("tAnimationKey", _2)
		flow:setContinue(100)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_94_1(flow)
	return flow:getContextValue("targetState")
end

function _M._get_102_1(flow)
	local _1 = _M._get_94_1(flow)
	local _0 = _1 == ""

	return not _0
end

return _M
