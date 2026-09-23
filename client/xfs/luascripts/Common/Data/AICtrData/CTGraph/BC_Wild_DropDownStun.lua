-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_DropDownStun.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeEventTrigger(flow, eventName)
	if eventName == "OnLandStateEnterTrigger" then
		return _M._to_5_0(flow)
	end
end

function _M._to_5_0(flow)
	local _0 = _M._get_8_2(flow)

	if _0 then
		flow:setActive()
		_A(flow, "AddBuff", 0, 10072, 0)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_8_2(flow)
	local _2 = flow:getContextValue("height")
	local _0 = _2 >= 5

	if not _0 then
		return false
	end

	local _3 = _C(7, "GetSelfId", flow)
	local _4 = _C(6, "CheckHasAbility", flow, _3, "Fly")
	local _1 = not _4

	if not _1 then
		return false
	end

	return true
end

return _M
