-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_CE_Burrow_ExitNoPlayer.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeTickLodTrigger(flow)
	return _M._to_101_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 101 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_101_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_115_1(flow)

	if _0 then
		flow:setActive()
		_C(101, "DoBehaviour", flow, "PBT_SneakOut")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tIsHit", false)
		flow:setContinue(101)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_115_1(flow)
	local _0 = _M._get_116_2(flow)

	return not _0
end

function _M._get_116_2(flow)
	local _0 = _C(118, "GetAoiEntityTableByLevel", flow, 0, 50, 256)

	if _0 == nil then
		return
	end

	for k, v in ipairs(_0) do
		local _1 = pg.getEntityByActorId(v)

		flow:setCache(116, "__iterItem", _1 and _1.actorId or 0)

		if _M._get_117_2(flow) then
			return true
		end
	end

	return false
end

function _M._get_117_2(flow)
	local _0 = flow:getCache(116, "__iterItem")

	return _C(117, "HasEntityTag", flow, _0, "TE_Env_StartMark")
end

return _M
