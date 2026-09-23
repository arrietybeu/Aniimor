-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Mimicry_EnterNoPlayer.lua

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

	local _0 = _M._get_8_1(flow)

	if _0 then
		flow:setActive()
		_C(0, "DoBehaviour", flow, "PBT_SwitchState")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tCharacterState", "MIMICRYIDLE")
		flow.__agent:addSubTreeLocalParam("tAnimationKey", "")
		flow:setContinue(0)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_5_2(flow)
	local _0 = _C(4, "GetAoiEntityTableByLevel", flow, 0, 30, 2)

	if _0 == nil then
		return
	end

	for k, v in ipairs(_0) do
		local _1 = pg.getEntityByActorId(v)

		flow:setCache(5, "__iterItem", _1 and _1.actorId or 0)

		if _M._get_7_2(flow) then
			return true
		end
	end

	return false
end

function _M._get_7_2(flow)
	local _1 = flow:getCache(5, "__iterItem")
	local _0 = _C(6, "GetDistance", flow, _1, 0, false)

	return _0 <= 15
end

function _M._get_8_1(flow)
	local _0 = _M._get_5_2(flow)

	return not _0
end

return _M
