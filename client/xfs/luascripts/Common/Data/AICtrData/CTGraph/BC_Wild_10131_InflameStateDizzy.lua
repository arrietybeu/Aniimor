-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10131_InflameStateDizzy.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeEventTrigger(flow, eventName)
	if eventName == "IdleMsgTrigger" then
		return _M._to_7_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 3 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 3 then
		return _M._get_6_1(flow)
	end
end

function _M._to_3_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_1_2(flow)
	local _1 = _M.checkInterrupt(flow, 3)

	if _0 and not _1 then
		flow:setActive()
		_C(3, "DoBehaviour", flow, "PBT_AddBuff")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tBuffId", 10072)
		flow.__agent:addSubTreeLocalParam("duration", 6)
		flow:setContinue(3)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_7_0(flow)
	local _1 = _C(8, "RandomInteger", flow, 0, 1)
	local _0 = _1 > 0.5

	if _0 then
		return _M._to_3_0(flow)
	end
end

function _M._get_1_2(flow)
	local _0 = _C(2, "GetSelfId", flow)

	return _C(1, "HasEntityTag", flow, _0, "TE_Env_InflameState")
end

function _M._get_6_1(flow)
	local _1 = _C(4, "GetSelfId", flow)
	local _0 = _C(5, "HasEntityTag", flow, _1, "TE_Env_InflameState")

	return not _0
end

return _M
