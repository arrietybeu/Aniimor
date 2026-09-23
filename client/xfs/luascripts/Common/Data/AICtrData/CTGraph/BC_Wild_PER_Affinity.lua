-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_PER_Affinity.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeEventTrigger(flow, eventName)
	if eventName == "Event_PER_Affinity" then
		return _M._to_92_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 92 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 92 then
		return _M._get_80_1(flow)
	end
end

function _M._to_92_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_83_2(flow)
	local _1 = _M.checkInterrupt(flow, 92)

	if _0 and not _1 then
		flow:setActive()
		_C(92, "DoBehaviour", flow, "PBT_Com_Affinity")

		local _2 = _M._get_44_2(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTgtId", _2)
		flow:setContinue(92)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_44_2(flow)
	return flow:getContextValue("interactObjectActorId")
end

function _M._get_80_1(flow)
	local _0 = _M._get_44_2(flow)

	return _C(80, "IsControllingPet", flow, _0)
end

function _M._get_83_2(flow)
	local _2 = _M._get_44_2(flow)
	local _0 = _C(71, "IsEntityType", flow, _2, "ACTOR_TYPE_PLAYER")

	if not _0 then
		return false
	end

	local _3 = _C(82, "RandomInteger", flow, 1, 10)
	local _1 = _3 < 2

	if not _1 then
		return false
	end

	return true
end

return _M
