-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_PER_Love_1029100.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeEventTrigger(flow, eventName)
	if eventName == "Event_PER_Love" then
		return _M._to_76_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 76 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 76 then
		return _M._get_57_3(flow)
	end
end

function _M._to_76_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_57_1(flow)
	local _1 = _M.checkInterrupt(flow, 76)

	if _0 and not _1 then
		flow:setActive()
		_C(76, "DoBehaviour", flow, "PBT_Com_Affinity")

		local _2 = _M._get_44_2(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTgtId", _2)
		flow:setContinue(76)

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

function _M._get_57_3(flow)
	local _0 = flow:getSubMacro("BCM_Common_CheckPER")
	local _1 = _M._get_44_2(flow)

	_0:setContextValue("tActorId", _1)

	local _2 = _0:getMacroValue("tIsPlayerInterrupt")

	flow:clearSubMacro(_0)

	return _2
end

return _M
