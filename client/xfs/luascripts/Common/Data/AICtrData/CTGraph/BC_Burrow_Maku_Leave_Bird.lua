-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Burrow_Maku_Leave_Bird.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_67_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 67 then
		return _M._to_68_0(flow)
	end

	if nodeId == 68 then
		return _M._to_69_0(flow)
	end

	if nodeId == 69 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_67_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_64_2(flow)

	if _0 then
		flow:setActive()
		_C(67, "DoBehaviour", flow, "PBT_SwitchState")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tCharacterState", "FLYING")
		flow.__agent:addSubTreeLocalParam("tAnimationKey", "")
		flow:setContinue(67)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_68_0(flow)
	if not _B(flow, "PBT_LeaveTarget") then
		return
	end

	local _0 = _M._get_60_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tLeaveDistance", 35)
	flow.__agent:addSubTreeLocalParam("tSpeed", 5)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
	flow.__agent:addSubTreeLocalParam("tMaxTime", 10)
	flow:setContinue(68)

	return true
end

function _M._to_69_0(flow)
	if not _B(flow, "PBT_DestroySelf") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow:setContinue(69)

	return true
end

function _M._get_59_2(flow)
	local _0 = _C(65, "GetAoiEntityTableByLevel", flow, 0, 50, 256)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		local _2 = pg.getEntityByActorId(v)

		flow:setCache(59, "__iterItem", _2 and _2.actorId or 0)

		if _M._get_66_2(flow) then
			_1[#_1 + 1] = _2.actorId
		end
	end

	return _1
end

function _M._get_60_1(flow)
	local _0 = _C(62, "GetAoiEntityTableByLevel", flow, 0, 50, 2)

	return _C(60, "SelectOneByRandom", flow, _0)
end

function _M._get_64_2(flow)
	local _1 = _M._get_60_1(flow)
	local _2 = _M._get_59_2(flow)
	local _3 = _C(61, "SelectOneByRandom", flow, _2)
	local _0 = _C(63, "GetDistance", flow, _1, _3, false)

	return _0 <= 15
end

function _M._get_66_2(flow)
	local _0 = flow:getCache(59, "__iterItem")

	return _C(66, "HasEntityTag", flow, _0, "TE_Env_Leave_Maku_Center")
end

return _M
