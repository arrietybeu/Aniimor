-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Burrow_EnterNearPlayer.lua

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

	local _0 = _M._get_105_2(flow)

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

function _M._get_105_2(flow)
	local _0 = _C(108, "GetAoiEntityTableByLevel", flow, 0, 50, 2)

	if _0 == nil then
		return
	end

	for k, v in ipairs(_0) do
		local _1 = pg.getEntityByActorId(v)

		flow:setCache(105, "__iterItem", _1 and _1.actorId or 0)

		if _M._get_107_2(flow) then
			return true
		end
	end

	return false
end

function _M._get_107_2(flow)
	local _1 = flow:getCache(105, "__iterItem")
	local _0 = _C(106, "GetDistance", flow, _1, 0, false)

	return _0 <= 50
end

return _M
