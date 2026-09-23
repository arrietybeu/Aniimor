-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BCM_Common_CheckVisionNormal.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.getMacroValue(flow, valueName)
	if valueName == "result" then
		return _M._get_2_1(flow)
	end
end

function _M._get_2_1(flow)
	local _1 = flow:getContextValue("targetActorId")
	local _0 = _C(3, "HasAITag", flow, _1, "TA_VisionAlert", "TA_VisionFull")

	return not _0
end

return _M
