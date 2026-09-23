-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Burrow_EnterNearPlayer_Vision.lua

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

	local _0 = _M._get_114_1(flow)

	if _0 then
		flow:setActive()
		_C(0, "DoBehaviour", flow, "PBT_SneakIn")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tWaitTime", 2000)
		flow.__agent:addSubTreeLocalParam("tRandomWaitTime", 0)
		flow:setContinue(0)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_110_3(flow)
	return flow:getCache(110, "__iterItem")
end

function _M._get_110_2(flow)
	local _0 = _C(109, "GetPerceptibilityTable", flow)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(110, "__iterItem", k)

		if _M._get_116_2(flow) then
			_1[#_1 + 1] = k
		end
	end

	return _1
end

function _M._get_114_1(flow)
	local _1 = _M._get_110_2(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_116_2(flow)
	local _2 = _M._get_110_3(flow)
	local _3 = _C(111, "GetPerceptibilityValue", flow, _2)
	local _0 = _3 >= 1

	if not _0 then
		return false
	end

	local _4 = _M._get_110_3(flow)
	local _1 = _C(118, "IsEntityType", flow, _4, "ACTOR_TYPE_PLAYER")

	if not _1 then
		return false
	end

	return true
end

return _M
