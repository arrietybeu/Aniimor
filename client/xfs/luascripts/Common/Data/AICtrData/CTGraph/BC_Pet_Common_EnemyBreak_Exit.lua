-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Pet_Common_EnemyBreak_Exit.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeMessageTrigger(flow, eventName)
	return
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 9 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._get_3_2(flow)
	local _0 = _C(6, "GetSelfId", flow)

	return _C(3, "IsInBehavTag", flow, _0, "TB_Pet_EnemyBreak")
end

return _M
