-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_GrabEggs_11035100051_LootCombat.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeEventTrigger(flow, eventName)
	if eventName == "SensedMsgTrigger" then
		return _M._to_211_0(flow)
	end
end

function _M._to_211_0(flow)
	local _0 = _C(212, "CheckHasEntityTag", flow, 0, "TE_Par_Bellicose")

	if _0 then
		flow:setActive()

		local _1 = _M._get_217_1(flow)

		_A(flow, "EnterCombat", 0, _1)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_217_1(flow)
	local _0 = _C(213, "GetPerceptibilityTable", flow)

	if _0 == nil then
		return
	end

	local key = next(_0)
	local value = _0[key]

	for k, v in pairs(_0) do
		if value < v then
			key, value = k, v
		end
	end

	return key
end

return _M
