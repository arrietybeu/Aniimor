-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_PER_Follow_ToPlayer.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _A = CTHelper.DoAction

function _M.executeEventTrigger(flow, eventName)
	if eventName == "Event_PER_Follow" then
		return _M._to_66_0(flow)
	end
end

function _M._to_66_0(flow)
	local _0 = _M._get_57_1(flow)

	if _0 then
		flow:setActive()

		local _1 = _M._get_44_2(flow)

		_A(flow, "ReqEnterRecruit", _1)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_44_2(flow)
	return flow:getContextValue("interactObjectActorId")
end

function _M._get_57_1(flow)
	local _0 = flow:getSubMacro("BCM_Common_CheckPER")
	local _1 = _M._get_44_2(flow)

	_0:setContextValue("tActorId", _1)

	local _2 = _0:getMacroValue("tIsPlayer")

	flow:clearSubMacro(_0)

	return _2
end

return _M
