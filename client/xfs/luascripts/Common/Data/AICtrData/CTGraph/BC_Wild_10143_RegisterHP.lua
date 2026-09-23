-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10143_RegisterHP.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeTickLodTrigger(flow)
	return _M._to_17_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 17 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_17_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_52_2(flow)

	if _0 then
		flow:setActive()
		_C(17, "DoBehaviour", flow, "ST_Monster_AutoCombat_Boss_10143")

		local _1 = _M._get_43_0(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("disToTgtForSkillMon", 0)
		flow.__agent:addSubTreeLocalParam("goBackDist", 0)
		flow.__agent:addSubTreeLocalParam("tPlayer", _1)
		flow:setContinue(17)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_43_0(flow)
	return _C(43, "GetSelfId", flow)
end

function _M._get_52_2(flow)
	local _2 = _M._get_43_0(flow)
	local _3 = _C(41, "GetHpPercent", flow, _2)
	local _0 = _3 <= 0.5

	if _0 then
		return true
	end

	local _5 = _M._get_43_0(flow)
	local _4 = _C(51, "GetHpPercent", flow, _5)
	local _1 = _4 <= 0.2

	if _1 then
		return true
	end

	return false
end

return _M
