-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Burrow_ExitNoPlayer_Vision.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeTickLodTrigger(flow)
	return _M._to_0_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 0 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_0_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_105_1(flow)

	if _0 then
		flow:setActive()
		_C(0, "DoBehaviour", flow, "PBT_SneakOut")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tIsHit", false)
		flow:setContinue(0)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_102_2(flow)
	local _0 = _C(101, "GetPerceptibilityTable", flow)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(102, "__iterItem", k)

		if _M._get_108_2(flow) then
			_1[#_1 + 1] = k
		end
	end

	return _1
end

function _M._get_105_1(flow)
	local _0 = _M._get_102_2(flow)

	return not _0 or next(_0) == nil
end

function _M._get_108_2(flow)
	local _0 = flow:getCache(102, "__iterItem")

	return _C(108, "IsEntityType", flow, _0, "ACTOR_TYPE_PLAYER")
end

return _M
