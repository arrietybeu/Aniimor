-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10501_ChangeVisionWhenRage.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeTickLodTrigger(flow)
	return _M._to_25_0(flow)
end

function _M._to_25_0(flow)
	local _0 = _M._get_24_1(flow)

	if _0 then
		flow:setActive()
		_A(flow, "SetVisionAreaOverride", "visionAreaLow")

		return true
	end

	local _2 = _M._get_24_1(flow)
	local _1 = not _2

	if _1 then
		flow:setActive()
		_A(flow, "SetVisionAreaOverride", "visionAreaDefault")

		return true
	end
end

function _M._get_24_1(flow)
	return _C(24, "CheckHasEntityTag", flow, 0, "TE_Wild_10501_Rage")
end

return _M
