-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Npc_Assist_Reaction.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeTickLodTrigger(flow)
	return _M._to_33_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 28 then
		return true
	end

	if nodeId == 44 then
		return true
	end

	if nodeId == 60 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 28 then
		return _M._get_32_2(flow)
	end

	if nodeId == 44 then
		return _M._get_47_1(flow)
	end

	if nodeId == 60 then
		return _M._get_59_2(flow)
	end
end

function _M._to_28_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 28)

	if not _1 then
		flow:setActive()
		_C(28, "DoBehaviour", flow, "PBT_RunAway")
		flow.__agent:clearSubTreeLocalParams()
		flow:setContinue(28)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_33_0(flow)
	local _3 = _M._get_29_2(flow)
	local _0 = _3 > 0

	if _0 then
		return _M._to_28_0(flow)
	end

	local _1 = _M._get_34_1(flow)

	if _1 then
		return _M._to_44_0(flow)
	end

	local _4 = _M._get_56_2(flow)
	local _2 = _4 > 0

	if _2 then
		return _M._to_60_0(flow)
	end
end

function _M._to_44_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 44)

	if not _1 then
		flow:setActive()
		_C(44, "DoBehaviour", flow, "PBT_TransferTarget")

		local _1 = _M._get_46_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("CurrentDistToTarget", 0)
		flow.__agent:addSubTreeLocalParam("tActorId", _1)
		flow.__agent:addSubTreeLocalParam("tSkillID", 0)
		flow.__agent:addSubTreeLocalParam("maxSkillDist", 0)
		flow.__agent:addSubTreeLocalParam("skillStopDist", 0)
		flow.__agent:addSubTreeLocalParam("CurrentBoxDistToTarget", 0)
		flow.__agent:addSubTreeLocalParam("tMaxAttackDist", 0)
		flow:setContinue(44)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_60_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 60)

	if not _1 then
		flow:setActive()
		_C(60, "DoBehaviour", flow, "PBT_Assist_MoveAround")
		flow.__agent:clearSubTreeLocalParams()
		flow:setContinue(60)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_29_2(flow)
	local _0 = _C(30, "GetSelfId", flow)

	return _C(29, "GetTargetBuffLayerCount", flow, _0, 4003032)
end

function _M._get_32_2(flow)
	local _0 = _M._get_29_2(flow)

	return _0 == 0
end

function _M._get_34_1(flow)
	local _0 = _M._get_46_1(flow)

	return _C(34, "CheckEntityExist", flow, _0)
end

function _M._get_38_3(flow)
	local _0 = _C(36, "GetAoiEntityTableByLevel", flow, 0, 50, 12)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(38, "__iterItem", v)

		if _M._get_40_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_38_2(flow)
	return flow:getCache(38, "__iterItem")
end

function _M._get_40_2(flow)
	local _0 = _M._get_38_2(flow)

	return _C(40, "HasEntityTag", flow, _0, "TE_Wild_Assist_Robot")
end

function _M._get_43_1(flow)
	local _0 = _M._get_38_3(flow)

	return _C(43, "SelectOneByRandom", flow, _0)
end

function _M._get_46_1(flow)
	local _0 = flow:getCache(46, "target")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_43_1(flow)

	flow:setCache(46, "target", _0)

	return _0
end

function _M._get_47_1(flow)
	local _0 = _M._get_34_1(flow)

	return not _0
end

function _M._get_56_2(flow)
	local _0 = _C(57, "GetSelfId", flow)

	return _C(56, "GetTargetBuffLayerCount", flow, _0, 4003022)
end

function _M._get_59_2(flow)
	local _0 = _M._get_56_2(flow)

	return _0 == 0
end

return _M
