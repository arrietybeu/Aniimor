-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10261_DropWithOutCloud.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeTickLodTrigger(flow)
	return _M._to_6_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 6 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_6_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_4_1(flow)

	if _0 then
		flow:setActive()
		_C(6, "DoBehaviour", flow, "PBT_SwitchState")

		local _1 = "LOCOMOTION"

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tCharacterState", _1)
		flow.__agent:addSubTreeLocalParam("tAnimationKey", "")
		flow:setContinue(6)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_4_1(flow)
	local _1 = _C(2, "GetSelfId", flow)
	local _0 = _C(10, "HasAITag", flow, _1, "TA_InLowGravity")

	return not _0
end

return _M
