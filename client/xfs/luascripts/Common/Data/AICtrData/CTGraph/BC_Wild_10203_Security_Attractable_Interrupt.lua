-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10203_Security_Attractable_Interrupt.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeContinue(flow, nodeId)
	if nodeId == 79 then
		return _M._to_77_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_77_0(flow)
	flow:setActive()
	_A(flow, "AddAITag", 0, "Finish")

	return true
end

function _M._get_75_2(flow)
	local _0 = _C(74, "GetSelfId", flow)

	return _C(75, "HasAITag", flow, _0, "Behaving")
end

return _M
