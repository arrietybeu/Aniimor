-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Mimicry_EnterPlayer.lua

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

	local _0 = _M._get_16_2(flow)

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

		if _M._get_9_2(flow) then
			return true
		end
	end

	return false
end

function _M._get_6_3(flow)
	local _0 = flow:getCache(5, "__iterItem")

	return _C(6, "GetDistance", flow, _0, 0, false)
end

function _M._get_9_2(flow)
	local _2 = _M._get_6_3(flow)
	local _0 = _2 <= 15

	if not _0 then
		return false
	end

	local _3 = _M._get_6_3(flow)
	local _1 = _3 >= 8

	if not _1 then
		return false
	end

	return true
end

function _M._get_16_2(flow)
	local _0 = _M._get_5_2(flow)

	if not _0 then
		return false
	end

	local _2 = _M._get_23_1(flow)
	local _3 = _C(17, "GetPerceptibilityValue", flow, _2)
	local _1 = _3 >= 1

	if not _1 then
		return false
	end

	return true
end

function _M._get_23_1(flow)
	local _0 = _C(14, "GetPerceptibilityTable", flow)

	if _0 == nil then
		return
	end

	local key = next(_0)
	local value = _0[key]

	for k, v in pairs(_0) do
		if value < v then
			key, value = k, v
		end
	end

	return key
end

return _M
