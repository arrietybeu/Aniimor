-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_Morphling_ListenBuff.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeTickLodTrigger(flow)
	return _M._to_3_0(flow)
end

function _M._to_3_0(flow)
	local _1 = _C(0, "GetSelfId", flow)
	local _2 = _C(1, "GetTargetBuffLayerCount", flow, _1, 920002103)
	local _0 = _2 >= 1

	if _0 then
		flow:setActive()
		_A(flow, "TriggerBluePrint", "YouAreMorphling")

		return true
	else
		flow:setActiveFail()
	end
end

return _M
