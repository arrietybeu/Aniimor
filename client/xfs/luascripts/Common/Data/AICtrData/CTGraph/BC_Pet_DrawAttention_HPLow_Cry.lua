-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Pet_DrawAttention_HPLow_Cry.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeTickLodTrigger(flow)
	return _M._to_139_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 139 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_139_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_145_4(flow)

	if _0 then
		flow:setActive()
		_C(139, "DoBehaviour", flow, "PBT_Com_Cry")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
		flow:setContinue(139)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_145_4(flow)
	local _7 = _M._get_147_0(flow)
	local _0 = _C(167, "IsInCharState", flow, _7, 1, 4)

	if not _0 then
		return false
	end

	local _5 = _M._get_147_0(flow)
	local _6 = _C(146, "GetAnimTagDuration", flow, _5)
	local _1 = _6 > 5

	if not _1 then
		return false
	end

	local _3 = _M._get_147_0(flow)
	local _4 = _C(141, "GetHpPercent", flow, _3)
	local _2 = _4 < 0.5

	if not _2 then
		return false
	end

	if false then
		return false
	end

	return true
end

function _M._get_147_0(flow)
	return _C(147, "GetSelfId", flow)
end

function _M._get_150_2(flow)
	return _C(150, "RandomInteger", flow, 1, 10)
end

return _M
