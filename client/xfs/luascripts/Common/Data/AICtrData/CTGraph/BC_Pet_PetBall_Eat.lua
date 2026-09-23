-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Pet_PetBall_Eat.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeTickLodTrigger(flow)
	return _M._to_21_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 21 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 21 then
		return _M._get_23_1(flow)
	end
end

function _M._to_21_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _C(20, "IsInPetBallExpAction", flow)
	local _1 = _M.checkInterrupt(flow, 21)

	if _0 and not _1 then
		flow:setActive()
		_C(21, "DoBehaviour", flow, "PBT_Eat")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("eatTimeOut", 10)
		flow:setContinue(21)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_23_1(flow)
	local _0 = _C(22, "IsInPetBallExpAction", flow)

	return not _0
end

return _M
