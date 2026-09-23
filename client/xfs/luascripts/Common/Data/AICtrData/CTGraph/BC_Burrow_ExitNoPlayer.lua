-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Burrow_ExitNoPlayer.lua

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

	local _0 = _M._get_4_1(flow)

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

function _M._get_3_2(flow)
	local _0 = _C(100, "GetAoiEntityTableByLevel", flow, 0, 50, 2)

	if _0 == nil then
		return
	end

	for k, v in ipairs(_0) do
		local _1 = pg.getEntityByActorId(v)

		flow:setCache(3, "__iterItem", _1 and _1.actorId or 0)

		if _M._get_8_2(flow) then
			return true
		end
	end

	return false
end

function _M._get_3_3(flow)
	return flow:getCache(3, "__iterItem")
end

function _M._get_4_1(flow)
	local _0 = _M._get_3_2(flow)

	return not _0
end

function _M._get_8_2(flow)
	local _2 = _M._get_3_3(flow)
	local _0 = _C(5, "IsEntityType", flow, _2, "ACTOR_TYPE_PLAYER")

	if not _0 then
		return false
	end

	local _3 = _M._get_3_3(flow)
	local _4 = _C(6, "GetDistance", flow, _3, 0, false)
	local _1 = _4 <= 35

	if not _1 then
		return false
	end

	return true
end

return _M
